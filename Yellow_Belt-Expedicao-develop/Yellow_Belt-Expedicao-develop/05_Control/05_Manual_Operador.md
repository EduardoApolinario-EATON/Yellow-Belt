# Manual de Operação — Expedição AFT (Eaton Valinhos)

> Documentação de uso e funcionamento para **operadores e equipe da expedição**.
> Descreve o fluxo real: baixar NFs → colocar na pasta do ciclo → clicar **Processar Ciclo** no Power BI → imprimir na ordem certa.
> **Última atualização:** 2026-08-18

> ⚙️ **Antes de publicar, confirme os itens marcados com ⚙️** (caminho do SharePoint, rótulo exato do botão, contatos).

---

## Como funciona (visão geral)

O sistema substitui a macro manual. Você baixa os PDFs das notas, coloca na pasta do ciclo, e o **Power BI + Power Automate** classificam cada NF automaticamente: renomeiam na ordem de impressão e movem para a pasta do destino físico (prisma). Você só confere e imprime.

```
SYNCHRO (baixa PDFs)  →  Pasta ENTRADA do ciclo (você coloca)
        →  Botão "Processar Ciclo" no Power BI (você clica)
        →  Power Automate classifica, renomeia e organiza em SAIDA/<Ciclo>/
        →  Você abre as pastas de destino e imprime na ordem já correta
```

---

# PARTE 1 — Guia Rápido do Operador (imprima e cole na bancada)

| # | O que fazer | Onde |
|---|---|---|
| 1 | Baixar do SYNCHRO os PDFs das NFs autorizadas do ciclo | SYNCHRO |
| 2 | Copiar os PDFs para a pasta **ENTRADA** do ciclo | File Explorer (atalho OneDrive) |
| 3 | **Esperar todos os PDFs ficarem com ✅ verde** (sincronizados na nuvem) | File Explorer |
| 4 | Abrir o relatório no **Power BI** e conferir a **Visão Geral** (totais do ciclo) | Power BI |
| 5 | Clicar no botão **"Processar Ciclo"** ⚙️ | Power BI (relatório) |
| 6 | Aguardar o fluxo terminar (~poucos minutos) | — |
| 7 | Abrir a pasta **SAIDA/\<Ciclo\>** e imprimir cada destino na ordem (ver Parte 2) | File Explorer |
| 8 | Conferir a pasta **EXCECAO** (se houver) e tratar manualmente | File Explorer |

> ⚠️ **Regra de ouro nº 1:** só clique **Processar Ciclo** depois que **todos** os PDFs estiverem com **✅ verde** no Explorer. Ícone de nuvem azul/setas = ainda subindo → o fluxo não acha o arquivo.

> ⚠️ **Regra de ouro nº 2:** **não reimprima** um ciclo já processado. O sistema tem memória anti-reimpressão — NFs já impressas voltam como **JA_IMPRESSO** e não são reprocessadas.

---

# PARTE 2 — Manual Completo de Operação

## 2.1 As pastas

⚙️ Local: SharePoint **"Expedição - Valinhos"** → biblioteca **Documents** (acessível pelo **File Explorer** via atalho do OneDrive).

| Pasta | Para que serve |
|---|---|
| **ENTRADA** | Onde **você** coloca os PDFs baixados do SYNCHRO, antes de processar |
| **SAIDA/\<Ciclo\>** | Onde o sistema **entrega** os PDFs já classificados e renomeados |

> Cada disparo é um **ciclo novo**: os PDFs de um ciclo **não** podem ser misturados com os do ciclo anterior. A pasta **SAIDA/\<Ciclo\>** separa cada rodada.

## 2.2 As 4 classificações (pastas de destino)

Dentro de **SAIDA/\<Ciclo\>**, cada NF cai em uma destas pastas:

| Pasta | Significa | O que o operador faz |
|---|---|---|
| **PRONTO** | NF apta, sem pendência — pode imprimir e expedir | Imprimir na ordem dos nomes |
| **AGUARDANDO GUIA** | NF com ICMS-ST / paga guia — depende da guia antes de expedir | Imprimir e encaminhar conforme regra fiscal |
| **OLEO** | NF de óleo (CFOP 6.655 / 5.655) — separação específica | Imprimir e separar no fluxo do óleo |
| **EXCECAO/** | NF que **não** pôde ser classificada (erro/pendência) | **Tratar manualmente** (ver Parte 3) |

## 2.3 Nomes de arquivo e ordem de impressão

O sistema renomeia cada PDF para garantir a ordem certa na impressão do Windows:

| Tipo | Padrão do nome |
|---|---|
| NF apta | `EXPEDICAO <L><pos> - NF <nf>.pdf` |
| Paga guia | `PAGA GUIA <L><pos> - NF <nf>.pdf` |
| Sem classificação | `DFE<chave>.pdf` |

- **`<L>` é a letra da ordem** (A, B, C, D) conforme o número de dígitos da posição — garante que o Windows ordene A→B→C→D corretamente.
- **Imprima assim:** abra a pasta do destino, ordene por **Nome**, selecione tudo (Ctrl+A) e imprima. A ordem alfabética já é a ordem física de separação (nota mãe antes das filhas, no mesmo prisma).

## 2.4 Ordem recomendada de impressão dos destinos
1. **PRONTO** (o grosso do ciclo)
2. **AGUARDANDO GUIA** (encaminhar conforme fiscal)
3. **OLEO** (fluxo específico)
4. **EXCECAO** (tratar antes de imprimir — ver Parte 3)

---

# PARTE 3 — Exceções (pasta EXCECAO)

Quando uma NF não pode ser classificada, ela vai para uma subpasta de **EXCECAO** indicando o motivo:

| Subpasta | O que aconteceu | Ação sugerida |
|---|---|---|
| **ERRO_NF** | Problema nos dados da NF | Conferir a NF no sistema / avisar Fiscal |
| **VERIFICAR_DELIVERY** | Delivery inconsistente | Conferir a delivery no Oracle/WMS |
| **ERRO_DELIVERY_NF** | Divergência NF × delivery | Conferir vínculo NF/delivery |
| **CHAVE_INVALIDA** | Chave de acesso do PDF não tem 44 dígitos / ilegível | Rebaixar o PDF do SYNCHRO novamente |
| **OUTROS** | Caso não previsto | Escalar ao responsável |

> Uma NF em EXCECAO **não** foi impressa nem marcada como concluída. Depois de resolver, ela entra no próximo ciclo normalmente.

---

# PARTE 4 — Solução de Problemas

| Sintoma | O que fazer |
|---|---|
| Cliquei **Processar Ciclo** e nada moveu | Confirme que os PDFs estavam com **✅ verde** na ENTRADA antes de clicar. Se estavam subindo (nuvem azul), aguarde e clique de novo. |
| Um PDF ficou em **CHAVE_INVALIDA** | O PDF veio ilegível/incompleto. Baixe de novo do SYNCHRO e reprocesse (só ele, no próximo ciclo). |
| NF que eu esperava **não apareceu** em nenhuma pasta | Pode já ter sido impressa antes (**JA_IMPRESSO** — memória anti-reimpressão). Confira com o supervisor antes de forçar. |
| O Power BI mostra números **desatualizados** | O dado vem do refresh dos dataflows (pode levar até ~30 min). Avise ⚙️ [responsável] se persistir. |
| O botão **Processar Ciclo** dá erro | Não reprocesse repetidamente. Anote o horário e avise ⚙️ [responsável]. |
| Impressora travou / sem papel | Resolver no prédio. Reimprimir **só** o lote afetado (a ordem dos nomes garante a sequência). |
| SYNCHRO fora do ar | Acionar TI. |

---

# PARTE 5 — Papéis e contatos

| Assunto | Quem |
|---|---|
| Fluxo Power Automate / Power BI | ⚙️ Eduardo Apolinario |
| NF bloqueada / dúvida fiscal | Time Fiscal |
| Acesso SharePoint / Power BI / OneDrive | TI |
| Impressora | TI / Prédio |
| Política de processo | Supervisor da Expedição |

---

# PARTE 6 — Glossário

| Termo | Significado |
|---|---|
| **Ciclo** | Uma rodada de faturamento/expedição (~350 NFs). 4–6 por dia. |
| **Prisma / SUB_LOC** | Localização física de separação para onde a NF vai. |
| **Chave de acesso** | Código de 44 dígitos que identifica a NF-e; usado para casar o PDF com o dado. |
| **NOTA MÃE / filha** | Notas agrupadas no mesmo prisma; a mãe imprime antes das filhas. |
| **PAGA GUIA** | NF com ICMS-ST que exige guia antes da expedição. |
| **PRONTO / OLEO / AGUARDANDO GUIA / EXCECAO** | As 4 classificações de destino do PDF. |
| **JA_IMPRESSO** | NF que já foi processada/impressa antes — bloqueada para não reimprimir. |
| **✅ verde (OneDrive)** | Arquivo já sincronizado na nuvem; pronto para o fluxo ler. |

---

## ⚙️ Itens a confirmar antes de publicar
- Caminho exato do SharePoint / atalho OneDrive das pastas **ENTRADA** e **SAIDA**.
- Rótulo exato do botão no relatório (ex.: "Processar Ciclo").
- Nome/contato do responsável técnico para escalonamento.
- Decisão pendente do `DaysText` (janela de refresh) — não afeta o operador, mas afeta a atualização dos dados.

---

*Versão imprimível: a **Parte 1** cabe em 1 página — imprima e cole na bancada.*
