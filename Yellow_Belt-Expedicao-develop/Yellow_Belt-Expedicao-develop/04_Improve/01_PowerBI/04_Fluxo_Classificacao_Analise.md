# 📋 Fluxo de Classificação — Análise das Queries + Macro

> O que as queries e macro realmente fazem (sem suposições).  
> **Baseado em:** Query 2 (AFT) + Macro VBA (7 módulos)  
> **Último update:** 2026-06-22

---

## 1. Filtro de Entrada (Query)

### O que ENTRA no dataset:

```sql
WHERE B.STATUS NOT IN ('4', '6')  -- Exclui CANCELADO
```

**Status que passam:**
- 1 = ERRO
- 2 = FINALIZADO (Autorizado)
- 3 = ERRO
- 5 = CONTIGENCIA / ENVIADO
- 7 = ERRO
- 8 = ERRO

**Conclusão:** Query deixa passar **tudo que não é CANCELADO**, incluindo status de erro.

---

## 2. Roteamento (Macro Legada)

Conforme documentado na macro, NFs são separadas em **3 categorias:**

```
1. PRONTO              → Imprime imediatamente
2. PAGA_GUIA           → Aguarda guia, depois imprime
3. DELIVERY_NAO_FINALIZADA → Aguarda conclusão delivery
```

### 2.1 PAGA_GUIA (Confirmado nas Regras de Negócio)

```
Estados: AC, AL, AM, AP, DF, GO, MS, RO, RR, TO

Lógica:
IF STATE IN (AC, AL, AM, AP, DF, GO, MS, RO, RR, TO) 
   AND EXTENDED_AMOUNT <> 0
THEN PAGA_GUIA = "SIM"
```

**Destino:** Folder `/AGUARDANDO_GUIA/` (não imprime imediatamente)

### 2.2 Matriz de Exceção — EXTRAÍDA DA MACRO (linha 701 de `Modulos_Macro.txt`)

> A macro **não** usa os 8 códigos numéricos de status para rotear. Ela decide com base em **2 campos textuais**: `CASE_RILA` (= `"OK"` ou não) e `STATUS` (= `"FINALIZADO"` ou não). Fórmula real decodificada:

| `CASE_RILA` | `STATUS` | Rótulo gerado | Destino na macro | Destino TO-BE (proposto) |
|---|---|---|---|---|
| OK | FINALIZADO | *(vazio — sem erro)* | ✅ **IMPRIME** | `/PRONTO/` |
| OK | ≠ FINALIZADO | `ERRO NF` | ❌ E-mail fiscal (não imprime) | `/EXCECAO/ERRO_NF/` |
| ≠ OK | FINALIZADO | `VERIFICAR DELIVERY` | ❌ E-mail fiscal (não imprime) | `/EXCECAO/VERIFICAR_DELIVERY/` |
| ≠ OK | ≠ FINALIZADO | `ERRO DELIVERY + ERRO NF` | ❌ E-mail fiscal (não imprime) | `/EXCECAO/ERRO_DELIVERY_NF/` |

**Filtros aplicados ANTES da matriz (também na macro):**

1. `STATUS = "CANCELADO"` → linha **deletada** (excluída do fluxo) — linha 640.
2. Chave de acesso vazia ou `"VE_DE_ACESSO"` → linha **deletada** — linha 623.
3. `NF + DELIVERY` iguais à linha anterior → tratado como **duplicado/agrupado** (nota mãe), não vira erro.

**Comportamento da exceção na macro:** as linhas com erro são destacadas, ordenadas e **enviadas por e-mail** ao time de billing (GFSS Brazil) — linhas 780-800. No TO-BE, a proposta é roteá-las para uma **pasta de exceção** (e opcionalmente notificar), já que o produto final agora são PDFs.

---

## 3. Gaps Pendentes (Tirar dúvida com time)

> A maior parte do roteamento foi **recuperada da macro** (ver §2.2). Restam apenas 3 nuances de validação:

| Pergunta | Impacto | Status |
|---|---|---|
| ~~O que fazer com NFs status ERRO?~~ | — | ✅ **Resolvido pela macro**: vira exceção (não imprime) |
| ~~Como identificar DELIVERY_NAO_FINALIZADA?~~ | — | ✅ **Resolvido**: `STATUS ≠ FINALIZADO` |
| **No TO-BE, exceção vai para PASTA ou e-mail?** (macro usava e-mail) | Alto | ❌ Decisão de desenho novo |
| **Basta o binário `STATUS = FINALIZADO`** ou precisamos da granularidade dos 8 códigos? | Médio | ❌ Pendente |
| **`CASE_RILA = 'VERF_RILA'`** deve ter tratamento diferente de "≠ OK"? (macro só testa `="OK"`) | Médio | ❌ Pendente |
| **`MOTIVO_BLOQUEIO`** determina roteamento ou é só informativo? | Baixo | ❌ Pendente |

---

## 4. Mapeamento para Power BI

### Colunas que determinam roteamento:

| Coluna | Valores | Determina |
|---|---|---|
| **PAGA_GUIA** | SIM / NÃO | Vai para `/AGUARDANDO_GUIA/` |
| **STATUS** | FINALIZADO / ≠ FINALIZADO | Eixo 1 da matriz de exceção (§2.2) |
| **CASE_RILA** | OK / ≠ OK | Eixo 2 da matriz de exceção (§2.2) |
| **MOTIVO_BLOQUEIO** | vários | ❓ Pendente (só informativo?) |

### Implementação em Power Automate (alinhada à macro):

```text
-- Pré-filtros (excluir do fluxo):
IF STATUS = "CANCELADO" THEN descartar
IF CHAVE_ACESSO vazia OU = "VE_DE_ACESSO" THEN descartar

-- Roteamento (precedência):
IF PAGA_GUIA = "SIM" THEN
  Pasta: /AGUARDANDO_GUIA/
ELSE IF CASE_RILA = "OK" AND STATUS = "FINALIZADO" THEN
  Pasta: /PRONTO/                         -- imprime
ELSE IF CASE_RILA = "OK" AND STATUS <> "FINALIZADO" THEN
  Pasta: /EXCECAO/ERRO_NF/
ELSE IF CASE_RILA <> "OK" AND STATUS = "FINALIZADO" THEN
  Pasta: /EXCECAO/VERIFICAR_DELIVERY/
ELSE  -- CASE_RILA <> OK AND STATUS <> FINALIZADO
  Pasta: /EXCECAO/ERRO_DELIVERY_NF/
```

> Decisão de desenho pendente: confirmar se exceção vira **pasta** (acima) ou mantém **e-mail** como a macro. Ver §3.

---

## 5. Checklist — Dúvidas com Time

> Núcleo do roteamento já recuperado da macro (§2.2). Só estas nuances precisam de validação:

- [ ] **Exceção no TO-BE:** vai para **pasta** `/EXCECAO/...` ou mantém **e-mail** (como a macro)?
- [ ] **Granularidade de status:** basta o binário `FINALIZADO` / `≠ FINALIZADO`, ou precisamos separar os 8 códigos?
- [ ] **`CASE_RILA = 'VERF_RILA'`** merece tratamento próprio, ou entra em "≠ OK" como na macro?
- [ ] **`MOTIVO_BLOQUEIO`** — afeta roteamento ou é só informativo?
- [ ] Há algum critério de roteamento adicional **fora** da macro/queries?

> **Estas perguntas estão consolidadas e priorizadas em** [`../../03_Analyze/07_Open_Questions.md`](../../03_Analyze/07_Open_Questions.md) **(seção 5b — Lógica de Roteamento).** A matriz de §2.2 já cobre a maior parte; só as nuances acima ficam pendentes.

---

## 🔗 Referência

- [`01_Dataset_Schema.md`](01_Dataset_Schema.md) — 23 colunas
- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md) — PAGA_GUIA
- Queries: `git show bd14596:"queries/IMPRESSÃO PART 2_SOMENTE_OLEO.~sql"`
- Macro: `referencias/macro_antiga/`
