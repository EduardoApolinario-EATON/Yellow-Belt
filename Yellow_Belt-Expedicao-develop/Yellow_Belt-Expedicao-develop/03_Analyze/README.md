# Fase 03 — Analyze

> **Índice revisado: 2026-10-14.** Análises 01-06 são estudos do legado/arquitetura inicial. O estado atual é o da cópia TMDL/JSON, sem garantia de paridade integral.

Prioridade para entrega: [Pendências P01-P19](07_Open_Questions.md), [Mapa de Regras](../04_Improve/07_Mapa_de_Regras.md) e [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md).

Esta fase disseca tecnicamente o processo atual: análise das 3 queries Oracle, restrições arquiteturais (Power BI × views EBS), causa-raiz do gargalo e perguntas pendentes para outras áreas.

## Documentos desta fase

| Documento | Conteúdo |
|---|---|
| [03_Analise_Query_Pt1_Monitor.md](03_Analise_Query_Pt1_Monitor.md) | Query 1 (IMPRESSÃO PART 1) — 4 blocos UNION ALL como dashboard SQL |
| [04_Analise_Query_Pt2_Oleo.md](04_Analise_Query_Pt2_Oleo.md) | Query 2 (PART 2 ÓLEO) — fluxo de itens de óleo |
| [05_Analise_Query_Revisada.md](05_Analise_Query_Revisada.md) | Query 3 (EXPEDICAO REVISADA) — pacote principal de impressão |
| [02_Diagnostico_Transversal.md](02_Diagnostico_Transversal.md) | Problemas que se repetem nas 3 queries |
| [06_Restricao_PowerBI_Views.md](06_Restricao_PowerBI_Views.md) | Por que Power BI não acessa as views `_BR_V` e como resolver |
| [01_Causa_Raiz.md](01_Causa_Raiz.md) | Ishikawa + 5 Porquês |
| [07_Open_Questions.md](07_Open_Questions.md) | Perguntas pendentes para Fiscal, TI, Operação, SYNCHRO etc. |

## O que esta fase responde

- O que cada query faz, como está construída e quais problemas técnicos tem?
- Por que o Power BI não consome as views Oracle diretamente?
- Quais opções arquiteturais existem e por que a Opção D foi escolhida?
- Qual é a causa-raiz do gargalo de 2h12 de separação manual?
- O que ainda precisamos perguntar para destravar a Fase Improve?

## Status

✅ Concluída (estrutural). Pendências viraram itens de `07_Open_Questions.md` e bloqueiam o início da Fase Improve.
