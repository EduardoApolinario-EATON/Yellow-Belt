# 🗂️ Modelo Semântico — Tabelas Base Oracle

> **Atualização: 2026-10-14.** A arquitetura vigente usa múltiplos dataflows Bronze, modelo Import e joins de negócio em M; não um dataflow dedicado nem os relacionamentos de negócio propostos abaixo. O restante deste documento é estudo de junho/2026, não configuração vigente.

## Modelo atual

São 33 tabelas no projeto, incluindo automáticas de data. NotasFiscais tem 39 colunas e 12 medidas; o relatório tem sete páginas. As fontes e os oito relacionamentos automáticos de data estão documentados no [Manual Técnico](../../docs_ferramenta/01_Documentacao_Tecnica.md); o contrato completo está no [Dicionário](01_Dataset_Schema.md).

Não há RA_INTERFACE_LINES_ALL nem OE_ORDER_HEADERS_ALL na cópia atual. UF usa a cadeia ship-to site use -> account site -> party site -> location. CNPJ usa JGZZ_FISCAL_CODE. Quantidade enviada vem de OE_ORDER_LINES_ALL. Mãe/filha é calculada em M pela menor NF numérica da delivery, não por ISBLANK em DAX.

WSH usa WSH_DOC com corte local de 45 dias e deduplicação. A atualização do modelo não comprova atualização das origens nem snapshot transacional simultâneo. Licenças, capacidade, limites e cadência são a confirmar no tenant, não garantias de Pro/Free. O funcionamento dos três botões foi confirmado; consultas/filtros dos fluxos externos requerem export.

## Estudo histórico - não executar como especificação atual

> Mapeamento das 13 views para tabelas base reais + modelo semântico Power BI.  
> **Abordagem confirmada:** Ingestão das tabelas base via **dataflows** → modelo semântico (dataset) com relacionamentos e **lógica das queries empurrada para Power Query (M) e DAX** → Power Automate consome o dataset publicado via ação **"Run a query against a dataset"** (DAX `EVALUATE`).  
> **Último update:** 2026-06-23

---

## 0. Camada de Ingestão — Dataflows

A origem do dado **não** é o Oracle direto no dataset, e sim **dataflows** no workspace do Power BI Service. Isso encapsula a conexão Oracle (gateway + credenciais) na camada de ingestão.

```
Oracle (tabelas base)
   │  (gateway + credencial ficam AQUI)
   ▼
Dataflow(s) no workspace  ──►  Dataset/modelo semântico  ──►  "Run a query against a dataset"  ──►  Power Automate
```

**Checklist de origem das tabelas-base (§4):**

| Cenário | Situação | Ação | Gateway/Oracle |
|---|---|---|---|
| **A** | Tabela já existe num dataflow do workspace | Conectar o dataset ao dataflow | ❌ encapsulado |
| **B** | Falta tabela → adicionar entidade a dataflow existente | Reusa a conexão Oracle do dataflow | ⚠️ depende do dataflow |
| **C** | Criar dataflow novo apontando p/ Oracle | Ingestão própria (confirmada viável) | ✅ feita na ingestão |

> ✅ **Decisão:** a ingestão das tabelas que faltarem será feita por nós (cenário B/C) — sem bloqueio de infraestrutura.

**Notas de licença/refresh:**
- Dataflows de ingestão (Gen1) funcionam com **Pro**. Entidades **computadas/vinculadas** e compute aprimorado exigem **Premium/PPU** — evitar no MVP.
- Refresh é **encadeado e separado**: agendar dataflow **antes** do dataset. Teto de **8 refreshes/dia** em cada um no Pro.

### 0.1 Decisão: dataflow **dedicado** ao projeto

> ✅ **Decisão de arquitetura:** usar **um dataflow dedicado** (ex.: `DF_Expedicao_Base`) com **todas as tabelas-base** do §4 — e **não** reaproveitar tabelas espalhadas em dataflows de cadências diferentes.

**Motivo — coerência temporal:** tabelas que serão **relacionadas** precisam representar o **mesmo instante**. Se a tabela de embarques viesse de um dataflow que atualiza de 4 em 4h e a de notas de um que atualiza de 12 em 12h, o `JOIN` casaria estados de momentos diferentes → linhas órfãs, NF sem chave, `CASE_RILA` falso. Um único dataflow garante que **todas as entidades atualizam no mesmo ciclo**.

- ⚠️ **"Linked entities" não resolvem** o problema de cadência (herdam o refresh da origem + exigem Premium/PPU). A coerência exige **ingestão própria**.
- ⚠️ Refresque com o ciclo de faturamento **fechado/quieto** para evitar ler durante alta movimentação.

### 0.2 Estratégia de refresh — **sob demanda**, sem tempo real

O negócio roda **4 a 6 ciclos de faturamento/dia** — cabe com folga nos **8 refreshes/dia** do Pro. **Não** é necessário tempo real / DirectQuery (o PDF já é baixado manualmente do Synchro, então há latência humana natural).

Sequência ideal, disparada pelo **Power Automate** ao fim de cada ciclo:

```
Ciclo de faturamento fecha
   → 1. Refresh do DATAFLOW dedicado  (espera concluir)
   → 2. Refresh do DATASET           (espera concluir)
   → 3. Run a query against a dataset (lista NFs)
   → 4. Casa com PDF, renomeia, move
```

- ⚠️ O passo 2 **não** pode começar antes do passo 1 terminar (senão o dataset lê dado velho) → usar a opção de **aguardar conclusão** de cada refresh.
- ⚠️ Os 8 refreshes/dia valem para **agendado + API/Power Automate combinados** — com 4-6 ciclos sobra pouco para *retries*.
- ⚠️ Garanta que o espaçamento entre ciclos seja **maior que a duração** do refresh (dataflow + dataset), para não empilhar.

---

## 1. Views → Tabelas Base

| View | Tabela Base Real | Filtro |
|---|---|---|
| XXRA_CUSTOMER_TRX_BR_V | **RA_CUSTOMER_TRX_ALL** | nenhum |
| XXCLL_F031_ELECTRONIC_TRX_ALL_BR_V | **CLL_F031_ELECTRONIC_TRX_ALL** | org_id = 1344 |
| XXRA_CUST_TRX_TYPES_BR_V | **RA_CUST_TRX_TYPES_ALL** | org_id = 1344 |
| XXRA_BATCH_SOURCES_BR_V | **RA_BATCH_SOURCES_ALL** | org_id = 1344 |
| XXETN_RA_CUSTOMERS | **HZ_CUST_ACCOUNTS + HZ_PARTIES** | nenhum |
| XXETN_RA_ADDRESSES_ALL_BR_V | **HZ_CUST_ACCT_SITES + HZ_LOCATIONS + HZ_PARTY_SITES** | org_id = 1344 |
| XXRA_CUSTOMER_TRX_LINES_BR_V | **RA_CUSTOMER_TRX_LINES_ALL** | org_id = 1344 |
| XXWSH_DELIVERY_DETAILS_BR_V | **WSH_DELIVERY_DETAILS** | nenhum |
| XXMTL_SYSTEM_ITEMS_BR_V | **MTL_SYSTEM_ITEMS_B** | nenhum |
| XXOE_ORDER_HEADERS_BR_V | **OE_ORDER_HEADERS_ALL** | org_id = 1344 |
| XXOE_ORDER_LINES_BR_V | **OE_ORDER_LINES_ALL** | org_id = 1344 |
| XXRA_INTERFACE_LINES_BR_V | **RA_INTERFACE_LINES_ALL** | nenhum |
| XXMTL_ITEM_CATEGORIES_BR_V | **MTL_ITEM_CATEGORIES** + ⚠️ XXORG_ORGANIZATION_DEFS_V | — |

**WSH_DELIVERY_ASSIGNMENTS** — tabela base direta (não é view), usada nas queries.

---

## 2. Tabelas Base (Resolvidas)

Nenhum pendente! Todas as 13 views resolvem para tabelas base.

| View | Tabela Base | Tabela Base |
|---|---|---|
| XXETN_RA_ADDRESSES_ALL_BR_V | **HZ_CUST_ACCT_SITES** (acct_site) | **HZ_LOCATIONS** (loc) |
| | **HZ_PARTY_SITES** (party_site) | — |

---

## 3. Views Pendentes

✅ **RESOLVIDO!** Não há mais views pendentes.

---

## 4. Tabelas Base Mínimas para o Modelo

Apenas as tabelas necessárias para as 23 colunas do dataset:

| # | Tabela Base | Colunas Necessárias | Para |
|---|---|---|---|
| 1 | **RA_CUSTOMER_TRX_ALL** | TRX_NUMBER, TRX_DATE, CUSTOMER_TRX_ID, CT_REFERENCE, CUST_TRX_TYPE_ID, BATCH_SOURCE_ID, ORG_ID, GLOBAL_ATTRIBUTE19, SOLD_TO_CUSTOMER_ID, SHIP_TO_SITE_USE_ID | NF, TRX_DATE, DELIVERY |
| 2 | **CLL_F031_ELECTRONIC_TRX_ALL** | CUSTOMER_TRX_ID, ATTRIBUTE2, STATUS | CHAVE_ACESSO, STATUS_FISCAL |
| 3 | **RA_CUSTOMER_TRX_LINES_ALL** | CUSTOMER_TRX_ID, QUANTITY_INVOICED, EXTENDED_AMOUNT, VAT_TAX_ID, LINE_TYPE, GLOBAL_ATTRIBUTE19 | QUANTITY, EXTENDED_AMOUNT, ICMS_RATE, IPI_VALUE |
| 4 | **RA_CUST_TRX_TYPES_ALL** | CUST_TRX_TYPE_ID, NAME, GLOBAL_ATTRIBUTE3 | INVOICE_TYPE, FISCAL_CLASS_CODE |
| 5 | **RA_INTERFACE_LINES_ALL** | INTERFACE_LINE_ATTRIBUTE3, BATCH_SOURCE_NAME, ORG_ID | BATCH_SOURCE_NAME, CASE_RILA |
| 6 | **HZ_PARTIES** | PARTY_ID, PARTY_NAME | PARTY_NAME |
| 7 | **HZ_CUST_ACCOUNTS** | CUST_ACCOUNT_ID, PARTY_ID | Ligação cliente ↔ NF |
| 8 | **HZ_CUST_ACCT_SITES** | CUST_ACCT_SITE_ID, CUST_ACCOUNT_ID, ORG_ID | Ligação conta de cliente ↔ Local |
| 9 | **HZ_LOCATIONS** | LOCATION_ID, STATE, GLOBAL_ATTRIBUTE3/4/5 (CNPJ) | STATE, CNPJ |
| 10 | **WSH_DELIVERY_DETAILS** | DELIVERY_DETAIL_ID, SUBINVENTORY, SHIPPED_QUANTITY | SUB_LOC |
| 11 | **WSH_DELIVERY_ASSIGNMENTS** | DELIVERY_DETAIL_ID, DELIVERY_ID | Ligação NF ↔ Delivery |

---

## 4. Joins Entre Tabelas Base

```
RA_CUSTOMER_TRX_ALL (RCT)
  ├─ RCT.CUST_TRX_TYPE_ID = RCTTA.CUST_TRX_TYPE_ID
  │   RA_CUST_TRX_TYPES_ALL                    → INVOICE_TYPE, FISCAL_CLASS_CODE
  │
  ├─ RCT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
  │   RA_CUSTOMER_TRX_LINES_ALL (CTL)          → QUANTITY, EXTENDED_AMOUNT, ICMS_RATE
  │
  ├─ RCT.CUSTOMER_TRX_ID = ELT.CUSTOMER_TRX_ID (+)
  │   CLL_F031_ELECTRONIC_TRX_ALL (ELT)        → CHAVE_ACESSO, STATUS_FISCAL
  │
  ├─ RCT.TRX_NUMBER = RILA.TRX_NUMBER (ou ATTRIBUTE1)
  │   RA_INTERFACE_LINES_ALL (RILA)             → BATCH_SOURCE_NAME, CASE_RILA
  │
  ├─ RCT.CT_REFERENCE = WDA.DELIVERY_ID
  │   WSH_DELIVERY_ASSIGNMENTS (WDA)
  │     └─ WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
  │         WSH_DELIVERY_DETAILS (WDD)          → SUB_LOC
  │
  └─ RCT.SOLD_TO_CUSTOMER_ID = CA.CUST_ACCOUNT_ID
      HZ_CUST_ACCOUNTS (CA)
        ├─ CA.PARTY_ID = P.PARTY_ID
        │   HZ_PARTIES (P)                      → PARTY_NAME
        │
        └─ via SHIP_TO_SITE_USE_ID = CUST_ACCT_SITE_ID
            HZ_CUST_ACCT_SITES (ACCT)          → Ligação ao local
              └─ ACCT.LOCATION_ID = LOC.LOCATION_ID
                  HZ_LOCATIONS (LOC)            → STATE, CNPJ
```

---

## 5. ✅ Abordagem: Modelo Semântico Power BI com Tabelas Base

O dataset conecta-se às entidades dos **dataflows** (§0) — que carregam as tabelas base do Oracle — e cria os relacionamentos no modelo.

### Tabelas a importar (origem: dataflow; filtros aplicados na ingestão ou no Power Query):

| Tabela | Filtro Power Query | Colunas a manter |
|---|---|---|
| **RA_CUSTOMER_TRX_ALL** | ORG_ID = 1344, TRX_DATE = hoje | CUSTOMER_TRX_ID, TRX_NUMBER, TRX_DATE, CT_REFERENCE, CUST_TRX_TYPE_ID, BATCH_SOURCE_ID, SOLD_TO_CUSTOMER_ID, SHIP_TO_SITE_USE_ID |
| **CLL_F031_ELECTRONIC_TRX_ALL** | ORG_ID = 1344 | CUSTOMER_TRX_ID, ATTRIBUTE2 (CHAVE_ACESSO), STATUS |
| **RA_CUSTOMER_TRX_LINES_ALL** | ORG_ID = 1344 | CUSTOMER_TRX_ID, QUANTITY_INVOICED, EXTENDED_AMOUNT, VAT_TAX_ID, LINE_TYPE, GLOBAL_ATTRIBUTE19 |
| **RA_CUST_TRX_TYPES_ALL** | ORG_ID = 1344 | CUST_TRX_TYPE_ID, NAME, GLOBAL_ATTRIBUTE3 |
| **RA_INTERFACE_LINES_ALL** | ORG_ID = 1344 | CUSTOMER_TRX_ID, INTERFACE_LINE_ATTRIBUTE3, BATCH_SOURCE_NAME |
| **HZ_CUST_ACCOUNTS** | sem filtro | CUST_ACCOUNT_ID, PARTY_ID |
| **HZ_PARTIES** | sem filtro | PARTY_ID, PARTY_NAME |
| **WSH_DELIVERY_DETAILS** | sem filtro | DELIVERY_DETAIL_ID, SUBINVENTORY, SHIPPED_QUANTITY |
| **HZ_CUST_ACCT_SITES** | ORG_ID = 1344 | CUST_ACCT_SITE_ID, CUST_ACCOUNT_ID, ORG_ID, STATUS |
| **HZ_LOCATIONS** | sem filtro | LOCATION_ID, STATE, COUNTRY, CITY, ADDRESS1, GLOBAL_ATTRIBUTE3/4/5 (CNPJ) |

### Relacionamentos no modelo:

```
RA_CUSTOMER_TRX_ALL [CUSTOMER_TRX_ID]
  → CLL_F031_ELECTRONIC_TRX_ALL [CUSTOMER_TRX_ID]     (1:1)
  → RA_CUSTOMER_TRX_LINES_ALL [CUSTOMER_TRX_ID]        (1:N)
  → RA_INTERFACE_LINES_ALL [CUSTOMER_TRX_ID]           (1:N)

RA_CUSTOMER_TRX_ALL [CUST_TRX_TYPE_ID]
  → RA_CUST_TRX_TYPES_ALL [CUST_TRX_TYPE_ID]          (N:1)

RA_CUSTOMER_TRX_ALL [CT_REFERENCE = DELIVERY_ID]
  → WSH_DELIVERY_ASSIGNMENTS [DELIVERY_ID]             (1:N)
  → WSH_DELIVERY_DETAILS [DELIVERY_DETAIL_ID]          (N:1)

RA_CUSTOMER_TRX_ALL [SOLD_TO_CUSTOMER_ID]
  → HZ_CUST_ACCOUNTS [CUST_ACCOUNT_ID]                (N:1)
  → HZ_PARTIES [PARTY_ID]                             (N:1)

RA_CUSTOMER_TRX_ALL [SHIP_TO_SITE_USE_ID = CUST_ACCT_SITE_ID]
  → HZ_CUST_ACCT_SITES [CUST_ACCT_SITE_ID]             (N:1)
  → HZ_LOCATIONS [LOCATION_ID]                        (N:1)
```

### Colunas calculadas em DAX:

```dax
CHAVE_ACESSO = CLL_F031_ELECTRONIC_TRX_ALL[ATTRIBUTE2]

NOTA_MAE = IF(ISBLANK(RA_CUSTOMER_TRX_ALL[CT_REFERENCE]), TRUE, FALSE)

-- PAGA_GUIA: a condição varia por UF (ver 07_Mapa_de_Regras §4)
-- AC, AM, AP, RO, RR = incondicional
-- AL, DF, GO, MS, TO = só se houver imposto (EXTENDED_AMOUNT <> 0)
PAGA_GUIA = IF(
    HZ_LOCATIONS[STATE] IN {"AC","AM","AP","RO","RR"}
    || (
        HZ_LOCATIONS[STATE] IN {"AL","DF","GO","MS","TO"}
        && RA_CUSTOMER_TRX_LINES_ALL[EXTENDED_AMOUNT] <> 0
    ),
    "PAGA GUIA", "NÃO PAGA"
)

-- CASE_RILA: integridade da entrega (qtd pedida vs. embarcada)
CASE_RILA = IF(
    [Soma_Qtd_Pedida] = [Soma_Qtd_Embarcada],
    "OK", "VERF_RILA"
)

-- STATUS: decode do status fiscal (CLL_F031 ... STATUS)
STATUS = SWITCH(
    CLL_F031_ELECTRONIC_TRX_ALL[STATUS],
    "2", "FINALIZADO",
    "4", "CANCELADO", "6", "CANCELADO",
    "ERRO"  -- 1,3,5,7,8
)
```

> ⚠️ A maior parte da lógica fiscal (CFOP `S_ST/C_ST`, somas de imposto por lista de `VAT_TAX_ID`, SUB_LOC óleo/embreagem) é mais simples de fazer no **Power Query (M)** na carga do que em DAX. Relacionamentos sozinhos **não** replicam as subqueries escalares do SQL.

---

## 6. Integração com o Power Automate — "Run a query against a dataset"

O fluxo consome o dataset publicado no **Power BI Service** executando uma consulta **DAX**:

```dax
EVALUATE
FILTER(
    Dataset,
    Dataset[STATUS] = "FINALIZADO"
        && Dataset[CASE_RILA] = "OK"
        && Dataset[JA_IMPRESSA] = FALSE   -- registro anti-reimpressão
)
```

A tabela retornada (NF, CHAVE_DE_ACESSO, SUB_LOC, GUIA, prefixo A/B/C/D…) é o que o Power Automate usa para **casar com o PDF** e **mover/renomear**.

### Pré-requisitos e pontos de atenção

| Item | Detalhe | Obrigatório |
|---|---|---|
| **Dataset publicado no Service** | A ação só enxerga datasets no workspace do Power BI Service (não no Desktop) | ✅ |
| **Conexão Oracle (gateway + credencial)** | Encapsulada no **dataflow** (§0), não no dataset — ingestão feita por nós | ✅ resolvido na ingestão |
| **Power BI Pro** | A ação "Run a query against a dataset" exige Pro | ✅ (você tem) |
| **Frescor (Import)** | Pro permite até **8 refreshes/dia**; nota nova só aparece no próximo refresh | ⚠️ definir cadência |
| **Limite de linhas da ação** | A ação trunca o resultado (~100k linhas / tamanho fixo) → **filtre no DAX** | ⚠️ |
| **Match por chave** | O PDF do Synchro vem como `DFE<chave>.pdf`; casar com `CHAVE_DE_ACESSO` | ✅ confirmar export |

---

## 7. ✅ Viabilidade com as ferramentas atuais

| Necessidade | Ferramenta que você tem | Cobre? |
|---|---|---|
| Ingestão das tabelas base | Dataflows no workspace (ingestão própria) | ✅ |
| Modelar e replicar lógica das queries | Power BI Pro + Power Query (M) + DAX | ✅ |
| Expor a lista classificada | "Run a query against a dataset" | ✅ |
| Receber PDFs | SharePoint / OneDrive (download manual Synchro) | ✅ |
| Classificar/renomear/mover PDFs | Power Automate Cloud Free | ✅ |
| Anti-reimpressão | Lista SharePoint / coluna de controle | ✅ |

**Conclusão:** o projeto é **viável** com Power BI Pro + Power Automate Free + SharePoint/OneDrive. Com a ingestão via dataflows feita por nós, **não há bloqueio de infraestrutura**; resta apenas confirmar o **export do Synchro com a chave de acesso no nome do PDF**.

---

## 🔗 Referência

- [`01_Dataset_Schema.md`](01_Dataset_Schema.md) — 23 colunas finais
- Queries originais: `git show bd14596:"queries/IMPRESSÃO PART 2_SOMENTE_OLEO.~sql"`
