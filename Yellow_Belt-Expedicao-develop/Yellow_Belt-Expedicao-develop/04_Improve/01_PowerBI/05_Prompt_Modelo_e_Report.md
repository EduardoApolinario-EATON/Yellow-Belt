# PROMPT — Construção do Modelo Semântico e Report (Power BI) — Projeto Expedição AFT

> Prompt autocontido para colar em um agente de IA (Power BI Copilot, ChatGPT, Claude etc.)
> encarregado de construir o modelo semântico e o report. Regras extraídas e validadas a partir
> das queries Oracle EBS R12 e da macro VBA legada (ver [07_Mapa_de_Regras.md](../07_Mapa_de_Regras.md)).
> **Última atualização:** 2026-07-16

---

## Papel
Você é um especialista em Power BI (Power Query/M, DAX, modelagem em estrela e Power BI Report).
Sua tarefa é construir um **modelo semântico** e um **report** para automatizar a classificação e a ordem de impressão de Notas Fiscais (NF) da Expedição da Eaton Valinhos (Aftermarket / AFT). Siga as regras abaixo à risca — elas foram extraídas e validadas a partir de queries Oracle EBS R12 e de uma macro VBA legada.

## Contexto de negócio
A expedição fatura de 4 a 6 ciclos por dia (~350 NFs/dia). Hoje um operador organiza manualmente os PDFs das NFs por "prisma" (localização física / SUB_LOC) e define a ordem de impressão — o que consome ~2h12 por ciclo. O objetivo é gerar um dataset onde **cada linha permita 3 decisões sem consulta adicional**:
1. Encontrar o PDF pela CHAVE_ACESSO (44 dígitos).
2. Definir o destino pelo SUB_LOC, PAGA_GUIA, STATUS_FISCAL e CASE_RILA.
3. Definir a ordem de impressão pela ORDEM_CLASSIFICACAO.

## Arquitetura obrigatória (restrições)
- Fonte do dataset = **dataflows** do Power BI Service (encapsulam gateway + credencial Oracle). NÃO conectar o dataset direto no Oracle.
- Modo **Import** (NÃO DirectQuery). Refresh encadeado: dataflow → dataset.
- **NÃO** usar query nativa Oracle consolidada nem UNION ALL de views. Ingerir **tabelas base** e empurrar a lógica para **Power Query (M)** e **DAX**.
- As 13 views `_BR_V` falham no Power BI por contexto de política (mo_global.set_policy_context); usar as **tabelas base** com `ORG_ID = 1344` como filtro normal.
- ORDEM_CLASSIFICACAO: NÃO usar ROW() em DAX; criar índice após ordenação no Power Query.

## Fonte de dados — 11 tabelas base (schema APPS, exceto onde indicado)
Aplicar `ORG_ID = 1344` onde a coluna existir.

| # | Tabela | Colunas a manter | Filtro |
|---|--------|------------------|--------|
| 1 | RA_CUSTOMER_TRX_ALL | CUSTOMER_TRX_ID, TRX_NUMBER, TRX_DATE, CT_REFERENCE, CUST_TRX_TYPE_ID, BATCH_SOURCE_ID, SOLD_TO_CUSTOMER_ID, SHIP_TO_SITE_USE_ID, ORG_ID | ORG_ID=1344; TRX_DATE = hoje |
| 2 | CLL_F031_ELECTRONIC_TRX_ALL | CUSTOMER_TRX_ID, ATTRIBUTE2 (chave 44 díg.), STATUS | ORG_ID=1344 |
| 3 | RA_CUSTOMER_TRX_LINES_ALL | CUSTOMER_TRX_ID, LINE_TYPE, QUANTITY_INVOICED, EXTENDED_AMOUNT, VAT_TAX_ID, GLOBAL_ATTRIBUTE19 | ORG_ID=1344 |
| 4 | RA_CUST_TRX_TYPES_ALL | CUST_TRX_TYPE_ID, NAME, GLOBAL_ATTRIBUTE3 (CFOP) | ORG_ID=1344 |
| 5 | RA_INTERFACE_LINES_ALL | CUSTOMER_TRX_ID, QUANTITY_ORDERED, BATCH_SOURCE_NAME | — |
| 6 | HZ_PARTIES | PARTY_ID, PARTY_NAME | — |
| 7 | HZ_CUST_ACCOUNTS | CUST_ACCOUNT_ID, PARTY_ID | — |
| 8 | HZ_CUST_ACCT_SITES | CUST_ACCT_SITE_ID, CUST_ACCOUNT_ID, LOCATION_ID, ORG_ID | ORG_ID=1344 |
| 9 | HZ_LOCATIONS | LOCATION_ID, STATE, GLOBAL_ATTRIBUTE3/4/5 (CNPJ) | — |
| 10 | WSH_DELIVERY_DETAILS | DELIVERY_DETAIL_ID, SUBINVENTORY, SHIPPED_QUANTITY, SHIPMENT_PRIORITY_CODE, SOURCE_CODE | SOURCE_CODE='OE' |
| 11 | WSH_DELIVERY_ASSIGNMENTS (schema WSH) | DELIVERY_DETAIL_ID, DELIVERY_ID | — |

## Relacionamentos (estrela em torno de RA_CUSTOMER_TRX_ALL = RCT)
- RCT[CUSTOMER_TRX_ID] → CLL_F031_ELECTRONIC_TRX_ALL[CUSTOMER_TRX_ID] (1:1)
- RCT[CUSTOMER_TRX_ID] → RA_CUSTOMER_TRX_LINES_ALL[CUSTOMER_TRX_ID] (1:N)
- RCT[CUSTOMER_TRX_ID] → RA_INTERFACE_LINES_ALL[CUSTOMER_TRX_ID] (1:N)
- RCT[CUST_TRX_TYPE_ID] → RA_CUST_TRX_TYPES_ALL[CUST_TRX_TYPE_ID] (N:1)
- RCT[CT_REFERENCE] → WSH_DELIVERY_ASSIGNMENTS[DELIVERY_ID] (1:N) → WSH_DELIVERY_DETAILS[DELIVERY_DETAIL_ID] (N:1)
- RCT[SOLD_TO_CUSTOMER_ID] → HZ_CUST_ACCOUNTS[CUST_ACCOUNT_ID] (N:1) → HZ_PARTIES[PARTY_ID] (N:1)
- RCT[SHIP_TO_SITE_USE_ID] → HZ_CUST_ACCT_SITES[CUST_ACCT_SITE_ID] (N:1) → HZ_LOCATIONS[LOCATION_ID] (N:1)

Observação: como há linhas (N) por transação, faça as agregações (soma de quantidade, soma de imposto) no Power Query antes de montar a tabela final de 1 linha por NF.

## Colunas do dataset final (1 linha por NF)
NF, TRX_DATE, CNPJ, PARTY_NAME, INVOICE_TYPE, BATCH_SOURCE_NAME, QUANTITY, EXTENDED_AMOUNT, SUB_LOC, DELIVERY, NOTA_MAE, CHAVE_ACESSO, STATUS_FISCAL, CASE_RILA, CFOP_ST, STATE, PAGA_GUIA, ORDEM_CLASSIFICACAO.

## Regras derivadas (implementar fielmente)

### CNPJ
`Text.Middle(Text.Combine({GA3,GA4,GA5}), 1, 14)` (equivale a SUBSTR(...,2,14) do SQL, do endereço BILL_TO).

### CHAVE_ACESSO
Apenas os 44 dígitos de CLL_F031.ATTRIBUTE2 (sem prefixo 'DFE'). Validar LEN = 44.

### CFOP_ST
`CFOP (RA_CUST_TRX_TYPES_ALL.GLOBAL_ATTRIBUTE3)` concatenado com:
- ` S_ST` se a soma de EXTENDED_AMOUNT das linhas de imposto ICMS-ST (LINE_TYPE='TAX' e VAT_TAX_ID na lista de códigos ICMS-ST) for 0/nulo;
- ` C_ST` caso contrário.
> A lista real tem ~46 VAT_TAX_ID de ICMS-ST (parametrizar).

### CASE_RILA
`"OK"` se SUM(QUANTITY_ORDERED) = SUM(SHIPPED_QUANTITY); senão `"VERF_RILA"`.

### STATUS_FISCAL (DECODE do CLL_F031.STATUS)
- `2` → FINALIZADO
- `4` ou `6` → CANCELADO
- `1,3,5,7,8` → ERRO

### SUB_LOC (campo mais crítico — agrupa por prisma)
- Se CFOP ∈ {6.655, 5.655} (óleo) → `OLEO_<GLOBAL_ATTRIBUTE19>`;
- senão se GLOBAL_ATTRIBUTE19 preenchido → usar GLOBAL_ATTRIBUTE19;
- senão → usar SUBINVENTORY (locator físico, formato SEG1.SEG2.SEG3).
- Sufixo `_EMBREAGEM_DSH` quando SHIPMENT_PRIORITY_CODE = 'DIRECT SHIPMENT'.
> Regra completa D.2 também checa categoria BRA MFG='A' (MTL_ITEM_CATEGORIES) — opcional no MVP.

### PAGA_GUIA (varia por UF — NÃO aplicar <>0 a todos)
- UF ∈ {AC, AM, AP, RO, RR} → "SIM" (incondicional);
- UF ∈ {AL, DF, GO, MS, TO} → "SIM" só se EXTENDED_AMOUNT <> 0;
- senão "NAO".

### NOTA_MAE
"SIM" se DELIVERY (CT_REFERENCE) vazio; senão "NAO".

### ORDEM_CLASSIFICACAO (ordem de impressão)
1. Ordenar por: PAGA_GUIA (desc) → SUB_LOC (asc) → DELIVERY (asc) → NF (asc).
2. Criar índice sequencial (1,2,3…) após o sort.
3. Prefixo por nº de dígitos do índice: <10 → "A", <100 → "B", <1000 → "C", senão "D". Ex.: A1, A2… A9, B10…
> Motivo do prefixo: garantir ordem alfabética correta na impressão do Windows.

## Filtros de entrada (WHERE)
- ORG_ID = 1344 (Valinhos AFT).
- Batch source AFT automática (BATCH_SOURCE_NAME começa com 'VALI AFT VENDA AUTOMATICA').
- Excluir canceladas/inutilizadas (STATUS NOT IN ('4','6')) — manter no dataset apenas se for rotear exceção.
- Excluir exportação (STATE <> 'EX' e FISCAL_CLASS_CODE não começa com 'EX').
- LINE_TYPE = 'LINE' para volumes; WDD.SOURCE_CODE = 'OE'.

## Consulta DAX para consumo externo (Power Automate — "Run a query against a dataset")
```dax
EVALUATE
FILTER(
    Modelo_Expedicao,
    Modelo_Expedicao[STATUS_FISCAL] = "FINALIZADO"
        && Modelo_Expedicao[CASE_RILA] = "OK"
        && Modelo_Expedicao[PAGA_GUIA] = "NAO"
)
```

## Report (Power BI) — requisitos
Criar um relatório com 3 páginas:

1. **Fila de Impressão** (operacional)
   - Tabela ordenada por ORDEM_CLASSIFICACAO com: ORDEM_CLASSIFICACAO, NF, SUB_LOC, DELIVERY, PARTY_NAME, QUANTITY, CHAVE_ACESSO.
   - Segmentações: TRX_DATE (hoje), STATUS_FISCAL, PAGA_GUIA.
   - Realce condicional: STATUS_FISCAL ≠ FINALIZADO em vermelho; CASE_RILA = VERF_RILA em laranja.

2. **Exceções** (fiscal/qualidade)
   - Filtrar linhas com STATUS_FISCAL ∈ {ERRO, CANCELADO} ou CASE_RILA = VERF_RILA.
   - Colunas: NF, STATUS_FISCAL, CASE_RILA, MOTIVO, PARTY_NAME, CHAVE_ACESSO.

3. **Paga-Guia** (aguardando guia)
   - Filtrar PAGA_GUIA = "SIM".
   - Agrupar por STATE; medir contagem de NF e SUM(EXTENDED_AMOUNT).

### Medidas DAX sugeridas
```dax
Total NFs = DISTINCTCOUNT(Modelo_Expedicao[NF])
NFs Prontas = CALCULATE([Total NFs], Modelo_Expedicao[STATUS_FISCAL]="FINALIZADO", Modelo_Expedicao[CASE_RILA]="OK", Modelo_Expedicao[PAGA_GUIA]="NAO")
NFs Exceção = CALCULATE([Total NFs], OR(Modelo_Expedicao[STATUS_FISCAL]<>"FINALIZADO", Modelo_Expedicao[CASE_RILA]="VERF_RILA"))
NFs Paga Guia = CALCULATE([Total NFs], Modelo_Expedicao[PAGA_GUIA]="SIM")
% Prontas = DIVIDE([NFs Prontas], [Total NFs])
```

## Critérios de aceite
- Uma linha por NF, sem duplicidade por NF+DELIVERY+LOCATOR.
- SUB_LOC resolve corretamente óleo, embreagem DSH e locator normal.
- CFOP_ST marca C_ST quando há ICMS-ST; S_ST quando não há.
- PAGA_GUIA respeita a distinção por UF (incondicional vs. condicional a EXTENDED_AMOUNT).
- ORDEM_CLASSIFICACAO gera fila estável na ordem PAGA_GUIA→SUB_LOC→DELIVERY→NF com prefixo A/B/C/D.
- CHAVE_ACESSO com 44 dígitos.
