# Mapa de Processo AS-IS

> Mapa BPI do processo atual de expedição (impressão e organização de NFs).
> Última atualização: 2026-05-28

## Convenções BPI

- 🟢 **Agrega valor** — atividade pela qual o cliente pagaria
- 🔵 **Não agrega valor, mas necessária** — exigência legal/sistêmica
- 🔴 **Não agrega valor** — desperdício / retrabalho

Volume de referência: **~350 NFs por ciclo**. Tempo total: **~4 horas**.

---

## Bloco 1 — Faturamento e Bipagem 🟢🔵

| | |
|---|---|
| **Responsável** | Operação (Expedição) |
| **Entradas** | Pedidos liberados, palets físicos, etiquetas LPN |
| **Atividades** | 1.1 Bipar LPN's por prisma 🟢 <br> 1.2 Anotar nº do prisma no papel 🔵 |
| **Saídas** | NFs faturadas no Oracle, registro físico do prisma |
| **Tempo** | 6 min |
| **Frequência** | Por ciclo de faturamento |

## Bloco 2 — Validação fiscal (Query Pt.1) 🔵

| | |
|---|---|
| **Responsável** | Billing / Expedição |
| **Entradas** | NFs faturadas no Oracle |
| **Atividades** | 2.1 Executar Query Impressão Pt.1 <br> 2.2 Aguardar zeragem (SEFAZ + RILA) <br> 2.3 Tratar exceções (CANCELAR_NF, RETORNO_SYNCHRO) |
| **Saídas** | NFs aptas à impressão, lista de pendências fiscais |
| **Tempo** | 30 min (caminho normal) <br> ⚠️ **Até 5 dias** se houver delivery com erro fiscal |
| **Indicadores** | % de NFs com erro fiscal por ciclo |

## Bloco 3 — Geração do pacote de impressão (Query Pt.2 + Macro) 🔵🔴

| | |
|---|---|
| **Responsável** | Billing / Sistema (Macro) |
| **Entradas** | NFs aptas |
| **Atividades** | 3.1 Executar Query Pt.2 <br> 3.2 Exportar Excel <br> 3.3 Compartilhar com Billing por e-mail <br> 3.4 Macro processa Excel <br> 3.5 Merge PDFs via serviço externo (`api.pdfconverted.com`) ⚠️ risco compliance |
| **Saídas esperadas** | Excel ordenado + ZIP de PDFs classificados por prisma |
| **Saídas reais** | Excel ordenado ✅ + **ZIP vazio ❌ (FALHA SISTÊMICA — macro quebrada)** |
| **Tempo** | 6 min |
| **Causa raiz da falha** | Atualização do SYNCHRO incompatibilizou a macro |

## Bloco 4 — Impressão física 🟢🔴

| | |
|---|---|
| **Responsável** | Operação (Expedição) |
| **Entradas** | Excel ordenado (PDFs ausentes) |
| **Atividades** | 4.1 Imprimir NFs **fora de ordem** 🟢 <br> 4.2 Imprimir etiquetas 🟢 |
| **Saídas** | Pilha de NFs físicas desordenadas + etiquetas |
| **Tempo** | 5 min NFs + **1h etiquetas** = ~1h05 |

## Bloco 5 — Organização manual (RETRABALHO) 🔴

| | |
|---|---|
| **Responsável** | Operação (Expedição) |
| **Entradas** | NFs impressas desordenadas, Excel ordenado (consultado como referência) |
| **Atividades** | 5.1 Separar vide nota / grampear (2 min) <br> 5.2 Separar notas de guia (10 min) <br> 5.3 **Separar notas por prisma manualmente (~2h)** ← gargalo <br> 5.4 Reordenar / ajustar sequência |
| **Saídas** | NFs físicas organizadas por prisma, prontas para expedição |
| **Tempo** | ~2h12 |
| **Indicadores** | Retrabalho 100%, risco de erro humano alto |
| **Origem do desperdício** | Falha do Bloco 3 (macro) |

---

## Fluxo AS-IS (visão geral)

```
[1. Faturamento/Bipagem] 6 min 🟢🔵
        ↓
[2. Query Pt.1 — validação] 30 min 🔵 ─── (erro fiscal: até 5 dias)
        ↓
[3. Query Pt.2 + Macro] 6 min 🔵 ─── ❌ FALHA: PDFs não gerados
        ↓
[4. Impressão fora de ordem] ~1h05 🟢🔴
        ↓
[5. ORGANIZAÇÃO MANUAL] ~2h12 🔴 ← RETRABALHO causado pelo Bloco 3
        ↓
[NFs prontas para expedição]
```

**Total: ~4 horas. Tempo "vermelho" (retrabalho puro): 2h12 (~55% do total).**

---

## Pontos a confirmar com a operação

1. Os tempos do Excel do BPI valem para todos os ciclos ou variam por volume?
2. A frequência "5 dias" no Bloco 2 é exceção rara ou recorrente?
3. O retrabalho do Bloco 5 já tem variação medida (mín/máx/médio entre dias)?
4. "Imprimir etiquetas" (1h) entra neste BPI ou em outro fluxo?
5. Confirmar terminologia: **prisma** (não LPN) como unidade de agrupamento.
6. O Bloco 3 hoje gera ZIP vazio ou simplesmente não gera o ZIP?

Estas perguntas estão duplicadas em `03_Analyze/07_Open_Questions.md` (blocos 3 e 5).
