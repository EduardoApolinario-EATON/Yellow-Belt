# 🗄️ Lógica das Queries → Dataflow + Dataset

> Como a lógica das 3 queries Oracle é replicada no **dataflow de ingestão** (tabelas-base) e no **dataset** (M/DAX). As queries servem de **especificação versionada** — não são executadas como query monolítica/native query.  
> **Último update:** 2026-06-23

---

## 🎯 Objetivo

Mapear a lógica das 3 queries AS-IS:
```
QUERY 1: Monitor (4 blocos UNION ALL)
QUERY 2: Óleo
QUERY 3: Revisada
```

Para a arquitetura TO-BE (dataflow → dataset):
```
Dataflow dedicado (DF_Expedicao_Base) ingere as tabelas-base
        ↓
Dataset/modelo semântico (relacionamentos + M/DAX)
        ↓
23 colunas consolidadas
```

---

## 📋 Abordagem

## 🔎 Diagnóstico da Query 2 Atual

Arquivo analisado: `queries/IMPRESSAO_PART_2_OLEO.sql`.

A Query 2 já entrega campos importantes para o piloto, mas sua saída não é igual ao schema final de 23 colunas. Ela retorna aproximadamente estes campos operacionais:

| Campo Query 2 | Uso no dataset final | Observação |
|---|---|---|
| `NF` | `NF` | Direto |
| `DELIVERY` | `DELIVERY` | Direto |
| `SUB_LOC` | `SUB_LOC` | Direto, já contém lógica de óleo/subinventário/prioridade |
| `VOL` | `QUANTITY` ou campo auxiliar | Precisa validar significado operacional |
| `CNPJ` | `CNPJ` | Direto |
| `CLIENTE` | `PARTY_NAME` | Nome truncado em 20 caracteres; avaliar se basta |
| `UF` | `STATE` | Direto |
| `CHAVE_DE_ACESSO` | `CHAVE_ACESSO` | Remover prefixo `DFE` para matching por 44 dígitos |
| `TRANSP` | Campo auxiliar | Não está nas 23 colunas finais |
| `CFOP` | `FISCAL_CLASS_CODE` / operação fiscal | Hoje vem concatenado com indicador `S_ST`/`C_ST` |
| `CASE_RILA` | `CASE_RILA` | Direto |
| `STATUS` | `STATUS_FISCAL` | Hoje é texto via `DECODE(B.STATUS, ...)` |
| `DATA_HORA` | Campo auxiliar | Pode ajudar auditoria, mas não está nas 23 finais |
| `DATA_GL` | `TRX_DATE` | Direto |
| `ICMS_ST` | Campo fiscal auxiliar | Não é o mesmo que `ICMS_RATE` |
| `FCP_ST` | Campo fiscal auxiliar | Não está nas 23 finais |
| `INSCRICAO_UF` | Campo fiscal auxiliar | Não está nas 23 finais |
| `INSCRICAO_CLIENTE` | Campo fiscal auxiliar | Não está nas 23 finais |

### Gaps para fechar as 23 colunas

Antes de publicar o dataset, confirmar origem destes campos:

| Coluna final | Status |
|---|---|
| `INVOICE_TYPE` | Não aparece explicitamente na saída da Query 2 |
| `BATCH_SOURCE_NAME` | Usado em filtro (`D.NAME`), mas não sai no SELECT |
| `QUANTITY` | Query traz `VOL`; validar se é volume ou quantidade faturada |
| `EXTENDED_AMOUNT` | Usado em cálculos fiscais, mas não sai como coluna final |
| `MOTIVO_BLOQUEIO` | Não aparece na Query 2 |
| `DI_NUMERO` | Não aparece na Query 2 |
| `ICMS_RATE` | Query traz valores `ICMS_ST`/`FCP_ST`, não alíquota |
| `IPI_VALUE` | Não aparece na Query 2 |

### Decisão técnica recomendada

Para o piloto, não tentar transformar a Query 2 inteira em uma query monolítica imediatamente. Melhor caminho:

1. Usar a Query 2 como referência de lógica confirmada para `SUB_LOC`, `CASE_RILA`, `STATUS`, `UF` e `CHAVE_ACESSO`.
2. Ingerir as tabelas-base no **dataflow dedicado** e montar o dataset **a partir dele**, conforme [`03_Modelo_Semantico.md`](03_Modelo_Semantico.md).
3. Normalizar as 23 colunas em Power Query (M) e DAX no dataset.
4. Validar paridade com uma amostra da Query 2 antes do piloto.

### Como a consolidação acontece (dataflow → dataset)

A consolidação **não** é um `UNION ALL` em SQL executado contra o Oracle. Ela acontece em duas camadas:

1. **Dataflow de ingestão (`DF_Expedicao_Base`)** — uma entidade por **tabela-base** (`RA_CUSTOMER_TRX_ALL`, `WSH_DELIVERY_DETAILS`, `OE_ORDER_*`, `CLL_F031...`, etc.), com os filtros do policy context (`org_id = 1344`, `STATUS`) aplicados em **Power Query (M)**. A conexão Oracle e o gateway ficam encapsulados aqui.
2. **Dataset/modelo semântico** — construído **a partir do dataflow**: relacionamentos entre as entidades + a lógica das 3 queries (joins, `CASE`/`DECODE`, blocos RILA) traduzida para **M e DAX** (`SUB_LOC`, `CFOP`, `CASE_RILA`, `STATUS`, `PAGA_GUIA`, `NOTA_MAE`, `ORDEM_CLASSIFICACAO`).

> ⚠️ **Não** usar DirectQuery nem native query consolidada no dataset. A coerência temporal e a cadência são resolvidas pelo refresh encadeado **dataflow → dataset** (ver [`03_Modelo_Semantico.md`](03_Modelo_Semantico.md) §0.1 e §0.2).

As 3 queries em [`../../queries/`](../../queries/README.md) permanecem como **especificação versionada** da lógica a replicar e base para o teste de paridade.

---

## 🔗 Referência

- [`01_Dataset_Schema.md`](01_Dataset_Schema.md) — 23 colunas esperadas
- Contato Oracle: [DBA contact info quando disponível]
