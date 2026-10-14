# Dashboard de Gestão

> **Referência atual: 2026-10-14.** Esta seção descreve as medidas existentes; o desenho antigo abaixo é proposta, não dashboard adicional implantado.

## Leitura da Visão Geral

Total do Ciclo conta linhas no contexto de filtro. Prontos/Oleo/Paga Guia usam PASTA_DESTINO. Exceções conta APTA Nao, podendo incluir notas com guia. Os quatro cartões não são grupos disjuntos; a soma pode ultrapassar o total. Conferir período de DATA_HORA_FAT e filtros antes de interpretar.

MOTIVO/Monitor orientam investigação. Indicadores de prisma são heurísticos e não validam localização física. Histórico é importado; JA PROCESSADA não prova impressão física. Chaves para Download não exclui histórico por si só.

Tempos, backlog por idade, alertas e redução de retrabalho não são métricas implementadas comprovadas pela cópia. Medir conforme [Coleta](../02_Measure/03_Coleta_de_Dados.md). Ações por destino estão no [Manual do Operador](05_Manual_Operador.md); definições DAX no [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md).

## Desenho histórico de indicadores futuros

> Cards e visões da aba "Gestão" no Power BI, consumindo os Lists de auditoria.
> Última atualização: 2026-05-28

## 1. Fonte de dados

| Fonte | Tabela / List |
|---|---|
| Operacional | Dataset Power BI Pro (modelo unificado) |
| Auditoria | SharePoint Lists `EXP_CICLOS_LOG` e `EXP_FALHAS_LOG` |

## 2. Aba "Operacional" (tempo real)

Aba alimentada pelo dataset Power BI unificado (ver [`../04_Improve/01_PowerBI/03_Modelo_Semantico.md`](../04_Improve/01_PowerBI/03_Modelo_Semantico.md)).

| Visão | Mostra |
|---|---|
| Funil de status | Qtd NFs por `STATUS_FISCAL` (hoje) |
| Pendências por motivo | NFs `≠ FINALIZADO` por `MOTIVO_BLOQUEIO` |
| Tempo aguardando | NFs com `MINUTOS_AGUARDANDO > 30` |
| NFs aptas | Quantas `FINALIZADO` (+ `CASE_RILA = OK`) aguardam o próximo ciclo |
| Distribuição por prisma | NFs `FINALIZADO` por `SUB_LOC` (preview do ciclo) |

## 3. Aba "Gestão" (acompanhamento pós-implantação)

### Cards de topo (KPIs do plano de controle)

| Card | Cálculo | Cor |
|---|---|---|
| Lead Time médio (semana) | AVG(`Fim` - `Inicio`) por ciclo | Verde ≤75; Vermelho >75 |
| % Classificação automática | (`Total_Classificadas` / `Total_NFs`) × 100 | Verde ≥99; Vermelho <99 |
| Taxa de falha | (`Total_Falhas` / `Total_NFs`) × 100 | Verde <1; Vermelho ≥1 |
| Ciclos do mês | COUNT(`Ciclo_ID`) | — |
| NFs do mês | SUM(`Total_NFs`) | — |

### Visuais

| Visual | Eixos | Filtros |
|---|---|---|
| Tendência semanal Lead Time | x: semana, y: avg lead time | últimos 12 meses |
| Tendência semanal % classificação | x: semana, y: % | últimos 12 meses |
| Top 10 motivos de falha | Bar chart de `EXP_FALHAS_LOG.Motivo` (count) | últimos 30 dias |
| Distribuição de volume por dia | Line chart `Data` × `Total_NFs` | últimos 30 dias |
| Mapa por prisma | Heatmap de `SUB_LOC` × frequência | últimos 30 dias |

### Filtros globais
- Período (últimos 7 / 30 / 90 dias)
- Operador (`EXP_CICLOS_LOG.Operador`)
- Status do ciclo (`OK / OK_COM_FALHAS / ERRO`)

## 4. Aba "Compliance"

Card único:

| Card | Cálculo | Meta |
|---|---|---|
| NFs enviadas para serviço externo | Sempre 0 no TO-BE (atestado manual) | 0 |

Espaço para anotação livre se algum incidente ocorrer.

## 5. Refresh

| Aba | Refresh |
|---|---|
| Operacional | Junto com o dataset (1–2x/dia) |
| Gestão | A cada hora (Lists do SharePoint mudam por ciclo) |
| Compliance | Manual / mensal |
