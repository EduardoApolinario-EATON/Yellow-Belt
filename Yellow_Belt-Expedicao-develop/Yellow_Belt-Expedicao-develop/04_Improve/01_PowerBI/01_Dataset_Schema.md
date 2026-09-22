# 🎯 Power BI - Dataset Schema

> As **23 colunas** que seu dataset Power BI deve ter.  
> **Última atualização:** 2026-06-22

---

## 📊 Objetivo

Consolidar as **3 queries Oracle originais** em 1 dataset Power BI com 23 colunas, removendo redundâncias.

Este dataset é a fonte de verdade do Power Automate. Portanto, cada linha precisa permitir três decisões sem consulta adicional:

1. **Encontrar o PDF** pelo `CHAVE_ACESSO`.
2. **Definir o destino** pelo `SUB_LOC`, `PAGA_GUIA`, `STATUS_FISCAL` e `CASE_RILA`.
3. **Definir a ordem de impressão** pelo `ORDEM_CLASSIFICACAO`.

---

## 📋 As 23 Colunas Finais

> A coluna **Origem Oracle** abaixo é um resumo de alto nível. As **derivações exatas e fiéis às fontes** (CASE/DECODE/SUBSTR, listas de imposto, lookups) estão catalogadas em [07_Mapa_de_Regras.md](../07_Mapa_de_Regras.md) §2, baseado em [QUERY_EXPEDICAO_REVISADA.sql](../../queries/QUERY_EXPEDICAO_REVISADA.sql) e na macro. Em caso de divergência, **vale o 07_Mapa_de_Regras / as queries**.

| # | Coluna | Tipo | Origem Oracle | Uso |
|---|---|---|---|---|
| 1 | **NF** | Text | RA_CUSTOMER_TRX_ALL.TRX_NUMBER | PK, identificação |
| 2 | **TRX_DATE** | Date | RA_CUSTOMER_TRX_ALL.TRX_DATE | Filtro, data faturamento |
| 3 | **CNPJ** | Text | HZ_PARTIES.REGISTRATION_NUM | Validação cliente |
| 4 | **PARTY_NAME** | Text | HZ_PARTIES.PARTY_NAME | Nome cliente |
| 5 | **INVOICE_TYPE** | Text | RA_CUSTOMER_TRX_ALL.TRX_TYPE | Tipo documento (NF, remessa, etc) |
| 6 | **FISCAL_CLASS_CODE** | Text | JL_BR_AR_INVOICE_HEADERS.FISCAL_CLASS_CODE | Filtro exportação (EX*) |
| 7 | **OPERATION_FISCAL_DESC** | Text | JL_BR_AR_* | Descrição operação fiscal |
| 8 | **BATCH_SOURCE_NAME** | Text | RA_BATCH_SOURCES.BATCH_SOURCE_NAME | Origem entrada |
| 9 | **QUANTITY** | Number | RA_CUSTOMER_TRX_LINES_ALL.QUANTITY_INVOICED | Volume |
| 10 | **EXTENDED_AMOUNT** | Number | RA_CUSTOMER_TRX_LINES_ALL.EXTENDED_AMOUNT | Valor total |
| 11 | **SUB_LOC** | Text | WSH_DELIVERY_ASSIGNMENTS.SUBINVENTORY | ⭐ **PRISMA** (agrupamento) |
| 12 | **DELIVERY** | Number | WSH_DELIVERY_DETAILS.DELIVERY_ID | Entrega/delivery |
| 13 | **NOTA_MAE** | Text | (calculado) | Identifica nota mãe (null = mãe) |
| 14 | **CHAVE_ACESSO** | Text | CLL_F031_ELECTRONIC_TRX_ALL.ATTRIBUTE2 | ⭐ **Matching PDF** (44 dígitos, sem prefixo `DFE`) |
| 15 | **STATUS_FISCAL** | Text | `DECODE` de STATUS (query) | Valores reais: `FINALIZADO` / `ERRO` / `CANCELADO` (2→FINALIZADO; 4/6→CANCELADO; 1/3/5/7/8→ERRO) |
| 16 | **CASE_RILA** | Text | compara QTY pedida vs embarcada (query) | `OK` / `VERF_RILA` |
| 17 | **MOTIVO_BLOQUEIO** | Text | derivado da Pt.1 (monitor) | Se bloqueado, o motivo (⚠️ confirmar origem na Pt.1) |
| 18 | **DI_NUMERO** | Text | ⚠️ **não consta nas queries/macro** | Candidata a sair do MVP (sem origem confirmada) |
| 19 | **STATE** | Text | HZ_LOCATIONS.STATE | UF cliente |
| 20 | **ICMS_RATE** | Number | ⚠️ **não consta nas queries/macro** | A query calcula `ICMS_ST`/`FCP_ST` em **valor**, não alíquota %; candidata a sair do MVP |
| 21 | **IPI_VALUE** | Number | RA_CUSTOMER_TRX_LINES_ALL.IPI_AMOUNT | Valor IPI |
| 22 | **PAGA_GUIA** | Text | (calculado) | `AC,AM,AP,RO,RR` sempre; `AL,DF,GO,MS,TO` só se `EXTENDED_AMOUNT<>0` |
| 23 | **ORDEM_CLASSIFICACAO** | Text | (calculado após sort) | Prefixo A/B/C/D para impressão |

---

## ✅ Decisões de Implementação

### 1. `CHAVE_ACESSO` deve ficar normalizada

A Query 2 atual monta `CHAVE_DE_ACESSO` como:

```sql
'DFE' || B.ATTRIBUTE2 CHAVE_DE_ACESSO
```

Para matching com PDF, o Power Automate procura a chave fiscal de **44 dígitos**. Portanto, no dataset final:

- `CHAVE_ACESSO` deve armazenar apenas os 44 dígitos de `ATTRIBUTE2`.
- O prefixo `DFE` pode existir em coluna auxiliar ou visual, mas não deve entrar no campo usado para matching.
- Antes de publicar, validar que `LEN(CHAVE_ACESSO) = 44` para todas as linhas elegíveis.

### 2. `ORDEM_CLASSIFICACAO` não deve usar `ROW()` em DAX

O prefixo depende da posição da linha **após a ordenação final**. Em DAX, `ROW()` não representa o número sequencial da linha no dataset.

Abordagem recomendada:

1. Ordenar o dataset por:
   - `PAGA_GUIA` DESC
   - `SUB_LOC` ASC
   - `DELIVERY` ASC
   - `NF` ASC
2. Criar um índice sequencial após esse sort, via Power Query ou SQL `ROW_NUMBER()`.
3. Calcular `ORDEM_CLASSIFICACAO` a partir desse índice.

Exemplo em Power Query:

```powerquery
TabelaOrdenada = Table.Sort(Fonte, {
  {"PAGA_GUIA", Order.Descending},
  {"SUB_LOC", Order.Ascending},
  {"DELIVERY", Order.Ascending},
  {"NF", Order.Ascending}
}),
ComIndice = Table.AddIndexColumn(TabelaOrdenada, "INDICE_CLASSIFICACAO", 1, 1, Int64.Type),
ComOrdem = Table.AddColumn(ComIndice, "ORDEM_CLASSIFICACAO", each
  if [INDICE_CLASSIFICACAO] < 10 then "A" & Text.From([INDICE_CLASSIFICACAO])
  else if [INDICE_CLASSIFICACAO] < 100 then "B" & Text.From([INDICE_CLASSIFICACAO])
  else if [INDICE_CLASSIFICACAO] < 1000 then "C" & Text.From([INDICE_CLASSIFICACAO])
  else "D" & Text.From([INDICE_CLASSIFICACAO])
)
```

### 3. `STATUS_FISCAL` e `CASE_RILA` ainda orientam exceções

A Query 2 atual usa `B.STATUS NOT IN ('4', '6')`, ou seja, remove cancelados, mas mantém status de erro/contingência. Antes do piloto, confirmar se o fluxo deve:

- processar apenas `STATUS = FINALIZADO`; ou
- receber também `ERRO`/`CONTINGENCIA` e rotear para pasta de exceção.

Até essa decisão, não remover `STATUS_FISCAL`, `CASE_RILA` e `MOTIVO_BLOQUEIO` do dataset.

---

## 🔧 Colunas Calculadas (DAX)

Estas **não vêm de Oracle**, são calculadas no Power BI:

### **NOTA_MAE**
```dax
NOTA_MAE = IF(ISBLANK([DELIVERY]), "SIM", "NÃO")
```

### **PAGA_GUIA**

A condição **varia por UF** (fiel à macro `Modulos_Macro.txt` ~linha 1240): 5 estados pagam sempre; 5 só quando há imposto (`EXTENDED_AMOUNT <> 0`). Não aplicar `<> 0` aos 10 estados.

```dax
PAGA_GUIA =
VAR Incondicional = [STATE] IN { "AC", "AM", "AP", "RO", "RR" }
VAR Condicional   = [STATE] IN { "AL", "DF", "GO", "MS", "TO" } && [EXTENDED_AMOUNT] <> 0
RETURN IF ( Incondicional || Condicional, "SIM", "NÃO" )
```

### **ORDEM_CLASSIFICACAO**

Calcular no Power Query ou no SQL, após sort final. Não usar `ROW()` em DAX.

---

## 📝 Filtros Críticos

### Filtro mínimo para montar o dataset operacional

Manter canceladas/devoluções fora do fluxo, mas preservar campos de exceção para análise:

```sql
WHERE
  ORG_ID = [seu_org]
  AND TRUNC(TRX_DATE) = TRUNC(SYSDATE)
  AND FISCAL_CLASS_CODE NOT LIKE 'EX%'
  AND TRX_TYPE NOT IN ('CANCELAÇÃO', 'DEVOLUÇÃO')
  AND DELETED_FLAG IS NULL
```

### Filtro para piloto restrito, se validado pelo time

Usar somente se a operação confirmar que o piloto deve imprimir apenas NFs sem exceção:

```sql
AND STATUS_FISCAL = 'FINALIZADO'
AND CASE_RILA = 'OK'
AND PAGA_GUIA = 'NÃO'
```

---

## 🎯 Próximos Passos

1. Consolidar as 3 queries originais neste schema
2. Testar paridade com dados originais
3. Publicar no Power BI Service
4. Power Automate lerá via "Run a query against a dataset"

---

## 🔗 Referência

- Dados de exemplo: [`referencias/exemplos/Exemplo_Notas_Fiscais.xlsb`](../../referencias/exemplos/Exemplo_Notas_Fiscais.xlsb)
- Regras de negócio: [`01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md)
