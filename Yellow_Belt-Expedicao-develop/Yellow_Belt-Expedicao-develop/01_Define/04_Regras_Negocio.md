# Regras de Negócio - Classificação de NFs

> **Referência vigente: 2026-10-14.** O resumo a seguir descreve o modelo atual. As regras extraídas da macro permanecem no anexo histórico e não comprovam paridade ou aprovação fiscal.

## Regras atuais para Expedição e Fiscal

| Tema | Regra | Cuidado operacional |
|---|---|---|
| Aptidão | Fiscal FINALIZADO, quantidades iguais/não nulas e chave com comprimento 44 | Não comprova guia paga, PDF disponível ou prisma válido |
| Guia | AC/AM/AP/RO/RR; AL/DF/GO/MS/TO quando ICMS-ST não zero | Não usar valor de produtos EXTENDED_AMOUNT como imposto |
| Prisma | Óleo/item, GA19 ou locator, mais prioridade | Conferir localização com Armazém; formatos variam |
| Mãe/filha | Menor NF numérica da delivery é mãe; filhas referenciam essa NF | Campo vazio também pode ser nota isolada; volume filha 0 |
| Ordem | Guia, prisma de ordenação da mãe, delivery, NF; índice em M | Pode mudar no refresh; não renumera com filtro |
| Destino | Guia precede aptidão; depois óleo apto, pronto apto e exceções | AGUARDANDO GUIA pode conter nota não apta |
| Histórico | SEM CHAVE, JA PROCESSADA ou PENDENTE por lista importada | Não confundir processamento com impressão ou liberação |

O responsável confirmou Power BI, atualização do modelo, processamento de PDFs em SharePoint e paga guias. Fluxos detalhados, retorno da guia, contatos e homologação: a confirmar. Nenhuma nota deve ser liberada apenas pelo nome de uma pasta ou botão.

As regras completas, divergências do legado e limites estão no [Mapa de Regras](../04_Improve/07_Mapa_de_Regras.md) e no [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md). Mudanças de regra fiscal exigem aprovação do Fiscal; mudanças de separação/ordem exigem Expedição; TI valida implementação e controles.

<details>
<summary>Regras extraídas da macro em junho/2026: histórico, não procedimento vigente</summary>

> Lógica extraída da macro VBA legada (7 módulos).  
> **Última atualização:** 2026-06-22

---

## 🎯 Objetivo

Entender as **regras de classificação** que a macro usa hoje, para replicar no Power BI + Power Automate.

---

## 🔑 Conceitos Principais

### 1️⃣ NOTA_MAE (Nota Mãe vs Nota Filha)

**Definição:** Uma nota mãe pode ter **1 ou mais notas filhas** relacionadas.

**Identificação (macro, `Modulos_Macro.txt` ~linhas 745-752 / 951-970):**
```
IF (NF + DELIVERY) = linha anterior
  THEN é VIDE NOTA (filha) — célula de DELIVERY fica vazia, volume = 0
  ELSE é NOTA_MAE (1ª ocorrência do par NF+DELIVERY)
```

**Exemplo:**
- NF 565271 (1ª ocorrência do par NF+DELIVERY) → **NOTA_MAE**
- NF 565271 repetida (mesmo NF+DELIVERY) → **VIDE NOTA** (filha), volume = 0

**Observação:** Notas filhas ficam agrupadas com a mãe na mesma pasta (prisma/SUB_LOC). A macro **não** usa prefixo `001_/002_`; a ordem de impressão é dada pelo prefixo `A/B/C/D` (ver §4) e o nome do arquivo é `EXPEDICAO <X><n> - NF <nf> - <data>.pdf`.

---

### 2️⃣ PAGA_GUIA (Estados Incentivados)

**Definição:** NFs de estados que pagam ICMS dispensado (incentivos fiscais).

**Estados que PAGAM GUIA (a condição varia por UF):**

| UF | Condição |
|---|---|
| AC, AM, AP, RO, RR | **Incondicional** (sempre paga guia) |
| AL, DF, GO, MS, TO | Só se **`EXTENDED_AMOUNT <> 0`** (há imposto) |

> `MA` foi **removida** da macro (estava condicional, hoje comentada).

**Lógica (fiel à macro, `Modulos_Macro.txt` ~linha 1240):**
```
IF STATE IN (AC, AM, AP, RO, RR)
   OR (STATE IN (AL, DF, GO, MS, TO) AND EXTENDED_AMOUNT <> 0)
  THEN PAGA_GUIA = TRUE
  ELSE PAGA_GUIA = FALSE
```

**Ação:** NFs PAGA_GUIA separam para folder `AGUARDANDO GUIA/` (não imprimem imediatamente).

---

### 3️⃣ SUB_LOC (LOCATOR / PRISMA)

**Definição:** Grupo/local físico de armazenamento no galpão.

**Formato:** `STG.XXXX.NNN` (ex: STG.A12.001, STG.A12.002, STG.B07.013)

**Função:** Agrupa notas para impressão no mesmo prisma.

**Exemplo:**
```
Folder: /ciclos/2026-06-18_1400/prisma_STG.A12.001/
  001_565271.pdf (nota mãe)
  002_565272.pdf (entrega 2)
  003_565273.pdf (entrega 3)

Folder: /ciclos/2026-06-18_1400/prisma_STG.A12.002/
  001_565274.pdf (nota mãe)
  002_565275.pdf (entrega 2)
```

---

### 4️⃣ ORDEM_CLASSIFICACAO (Prefixos para Impressão)

**Objetivo:** Garantir que PDFs sejam impressos na ordem alfabética correta.

**Fórmula:**
```
IF LEN(ROW()) = 1 THEN "A" & ROW()    (linhas 1-9)
IF LEN(ROW()) = 2 THEN "B" & ROW()    (linhas 10-99)
IF LEN(ROW()) = 3 THEN "C" & ROW()    (linhas 100-999)
IF LEN(ROW()) = 4 THEN "D" & ROW()    (linhas 1000+)
```

**Resultado:**
```
EXPEDICAO_A1_NF_565271.pdf (linha 1-9)
EXPEDICAO_B10_NF_565272.pdf (linha 10-99)
EXPEDICAO_C100_NF_565273.pdf (linha 100-999)
EXPEDICAO_D1000_NF_565274.pdf (linha 1000+)
```

**Por quê:** Windows imprime em **ordem alfabética** → A < B < C < D.

---

### 5️⃣ STATUS_FISCAL e CASE_RILA

**Portão de impressão (macro — matriz `CASE_RILA` × `STATUS`):**
```
imprime SOMENTE se  STATUS   = 'FINALIZADO'   (NF-e autorizada pela SEFAZ)
                AND CASE_RILA = 'OK'           (embarcado = pedido)
exclui exportação:  STATE NOT IN ('EX')        (filtro da query)
```

> O valor canônico do status apto é **`FINALIZADO`** (query `DECODE` STATUS `2` → `FINALIZADO`; a macro testa `="FINALIZADO"`). O rótulo `"APTA"` **não** aparece nas queries nem na macro.

**Resultado:** Apenas NFs prontas para impressão entram no fluxo.

---

## 📊 Ordenação Final

**Ordem de Sort no dataset:**

1. **GUIA** (DESC) — PAGA GUIA vem primeiro
2. **SUB_LOC** (ASC) — alfabético por prisma
3. **DELIVERY** (ASC) — dentro do prisma, por entrega
4. **NF** (ASC) — dentro da entrega, por NF

**Resultado:** Todas as notas agrupadas por prisma, depois por delivery, prontas para impressão.

---

## 🔄 Fluxo Completo (Macro Legada)

```
1. Download 3 queries Oracle
2. Consolidação em Excel
3. Filtro: FINALIZADO + OK + não EX + não CANCELADA
4. Transformação: extrai CHAVE_ACESSO, calcula PAGA_GUIA
5. Sort: GUIA DESC, SUB_LOC ASC, DELIVERY ASC, NF ASC
6. Busca PDFs em 3 pastas (local, SYNCHRO, delivery_parada)
7. Renomeia com prefixo (A/B/C/D + linha)
8. Move para 3 categorias:
   - PRONTO (imprime imediatamente)
   - PAGA_GUIA (aguarda guia)
   - DELIVERY_NAO_FINALIZADA (aguarda conclusão)
9. Gera relatório Excel (5 abas) + ZIP
10. Envia email com anexos
```

**TO-BE:** Replicar passos 1-8 em Power BI + Power Automate, eliminar email/ZIP.

---

## 📝 Implementação

Esses conceitos devem ser refletidos em:
- **Power BI:** Colunas do dataset (NOTA_MAE, PAGA_GUIA, SUB_LOC, ORDEM_CLASSIFICACAO)
- **Power Automate:** Lógica de matching, renaming, e organização em pastas

---

## 🔗 Referência

Análise completa em [`referencias/macro_antiga/README.md`](../referencias/macro_antiga/README.md)

</details>
