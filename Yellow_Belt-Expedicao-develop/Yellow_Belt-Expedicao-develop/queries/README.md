# queries/ — Queries originais (AS-IS)

> Cópias das queries SQL originais usadas no fluxo AS-IS, antes da refatoração Opção D.
> Última atualização: 2026-05-28

## Arquivos

| Arquivo | Descrição | Análise |
|---|---|---|
| `IMPRESSAO_PART_1.sql` | Query 1 — Monitor de NFs (4 blocos UNION ALL) | [`03_Analyze/03_Analise_Query_Pt1_Monitor.md`](../03_Analyze/03_Analise_Query_Pt1_Monitor.md) |
| `IMPRESSAO_PART_2_OLEO.sql` | Query 2 — Notas de óleo (CFOP 6.655/5.655) | [`03_Analyze/04_Analise_Query_Pt2_Oleo.md`](../03_Analyze/04_Analise_Query_Pt2_Oleo.md) |
| `QUERY_EXPEDICAO_REVISADA.sql` | Query 3 — Versão revisada (80% sobreposição com Pt.2) | [`03_Analyze/05_Analise_Query_Revisada.md`](../03_Analyze/05_Analise_Query_Revisada.md) |

## Por que mantidas aqui

- **Referência histórica**: registro do estado anterior à refatoração.
- **Comparação de paridade**: serão usadas nos testes documentados em [`04_Improve/01_PowerBI/04_Fluxo_Classificacao_Analise.md`](../04_Improve/01_PowerBI/04_Fluxo_Classificacao_Analise.md).
- **Auditoria YB**: evidência do AS-IS.

## Não editar

Estes arquivos são read-only. O schema consolidado está documentado em [`04_Improve/01_PowerBI/01_Dataset_Schema.md`](../04_Improve/01_PowerBI/01_Dataset_Schema.md).
