# 🔧 Opção D: Refatoração com Tabelas Base

> **Revisão: 2026-10-14.** Proposta histórica de arquitetura. O modelo atual usa tabelas-base Bronze; não é necessário refazê-lo a partir dos exemplos abaixo.

Diferenças: múltiplos dataflows existentes, joins de negócio M, 39 colunas e relacionamentos automáticos de data. Janelas, gateway, licenças e contexto EBS upstream precisam de verificação com o orquestrador. Não alterar produção nem entidades compartilhadas sem dono. Referência atual: [Manual Técnico](../../docs_ferramenta/01_Documentacao_Tecnica.md).

> Decisão arquitetural: Por que tabelas base Oracle (não views).  
> **Último update:** 2026-06-22

---

## 📌 A Decisão

```
AS-IS (Queries):
  └─ 3 queries SQL diretamente em Oracle
     ├─ View tables (13 views XV XXETN_*, XXCLL_*, etc.)
     └─ Retorna 23 colunas consolidadas

TO-BE (Opção D):
  └─ Dataflow dedicado ingere 11 tabelas BASE (RA_*, HZ_*, CLL_*, WSH_*, MTL_*)
     ├─ Conexão Oracle/gateway encapsulada na ingestão (Power Query/M)
     ├─ Dataset construído A PARTIR do dataflow
     ├─ Views resolvidas em suas tabelas base reais
     ├─ Relacionamentos no modelo PBI (não na query)
     └─ Cálculos em M/DAX (não em SQL monolítico)

DIFERENÇA CHAVE: Views → Base Tables
  └─ Por quê? Policy Context
```

---

## ❌ Por Que NÃO Views (Opções A, B, C)

### **Opção A: Views em Power Query (Descartada)**

```sql
SELECT * FROM XXCLL_F031_ELECTRONIC_TRX_ALL_BR_V
```

**Bloqueador:** Policy Context  
Views em Oracle EBS frequentemente dependem de policy context (ex: `mo_global.set_policy_context(...)`). Quando a ingestão (Power Query) tenta importar a view:

```
Error: ORA-20001: Application code error
ERROR: Policy context not set (Set_Policy_Context required)
```

**Resultado:** ❌ Query falha. Power BI não consegue importar.

---

### **Opção B: Views + Force Context (Hacky)**

```sql
BEGIN
  mo_global.set_policy_context('GLOBAL', 1344, 101);
END;

SELECT * FROM XXCLL_F031_ELECTRONIC_TRX_ALL_BR_V;
```

**Problema:** Power Query (ingestão) **não executa PL/SQL** (apenas SELECT).  
Tentativa usar EXECUTE IMMEDIATE falha em query estática.

**Resultado:** ❌ Não funciona em Power BI.

---

### **Opção C: Criar Nova View (Sem Policy Context)**

```sql
CREATE VIEW XXCLL_F031_ELECTRONIC_TRX_ALL_BR_V_NO_POLICY AS
SELECT * FROM CLL_F031_ELECTRONIC_TRX_ALL
WHERE org_id = 1344;
```

**Problema:** DBA pode recusar criar views genéricas (fora do padrão XXETN_*).  
Além disso, a nova view ainda depende de views internas que usam policy context.

**Resultado:** ❌ Slow adoption, vendor lock-in (depends on DBA).

---

## ✅ Opção D: Tabelas Base Diretas (RECOMENDADO)

```sql
SELECT 
  RCT.TRX_NUMBER AS NF,
  RCT.TRX_DATE,
  ELT.ATTRIBUTE2 AS CHAVE_ACESSO,
  HZ.STATE,
  ...
FROM RA_CUSTOMER_TRX_ALL RCT
  LEFT JOIN CLL_F031_ELECTRONIC_TRX_ALL ELT 
    ON RCT.CUSTOMER_TRX_ID = ELT.CUSTOMER_TRX_ID
  LEFT JOIN HZ_CUST_ACCOUNTS CA 
    ON RCT.SOLD_TO_CUSTOMER_ID = CA.CUST_ACCOUNT_ID
  LEFT JOIN HZ_LOCATIONS LOC 
    ON CA.LOCATION_ID = LOC.LOCATION_ID
WHERE RCT.ORG_ID = 1344
  AND RCT.STATUS NOT IN ('4', '6')
```

> ℹ️ O SQL acima ilustra a **lógica de junção**. Na implementação, cada tabela-base é uma **entidade do dataflow** (ingestão em Power Query/M) e os JOINs viram **relacionamentos do modelo** — não uma query monolítica.

**Vantagens:**
- ✅ **Sem policy context:** Tabelas base (RA_*, HZ_*, CLL_*) aceitam org_id como parâmetro normal
- ✅ **Ingestão via dataflow (Power Query/M):** funciona sem PL/SQL nem policy context
- ✅ **Controle total:** Você especifica os filtros e relacionamentos no modelo (não depende de view definition)
- ✅ **Transparência:** Fácil debugar qual tabela, qual coluna
- ✅ **Flexibilidade:** Futuros ajustes sem esperar DBA

**Desvantagens:**
- ❌ Mais colunas para importar (mas Power BI filtra no Power Query)
- ❌ Query um pouco mais longa (mas legível)

---

## 🗂️ Mapeamento: Views → Tabelas Base

| View Original | Tabela Base | Por quê |
|---|---|---|
| XXRA_CUSTOMER_TRX_BR_V | RA_CUSTOMER_TRX_ALL | Transações de cliente (notas fiscais) |
| XXCLL_F031_ELECTRONIC_TRX_ALL_BR_V | CLL_F031_ELECTRONIC_TRX_ALL | Dados eletrônicos (CHAVE_ACESSO, STATUS_FISCAL) |
| XXRA_CUST_TRX_TYPES_BR_V | RA_CUST_TRX_TYPES_ALL | Tipos de transação (invoice type, fiscal class) |
| XXRA_BATCH_SOURCES_BR_V | RA_BATCH_SOURCES_ALL | Fontes de lote (origin, workflow) |
| XXETN_RA_CUSTOMERS | HZ_CUST_ACCOUNTS + HZ_PARTIES | Cliente (nome, registro) |
| XXETN_RA_ADDRESSES_ALL_BR_V | HZ_CUST_ACCT_SITES + HZ_LOCATIONS | Endereço de cliente (estado, CNPJ) |
| XXRA_CUSTOMER_TRX_LINES_BR_V | RA_CUSTOMER_TRX_LINES_ALL | Linhas da transação (quantidade, valor, impostos) |
| XXWSH_DELIVERY_DETAILS_BR_V | WSH_DELIVERY_DETAILS | Detalhes de entrega (localização subinventory) |
| XXMTL_SYSTEM_ITEMS_BR_V | MTL_SYSTEM_ITEMS_B | Itens de estoque (descrição, categoria) |
| XXOE_ORDER_HEADERS_BR_V | OE_ORDER_HEADERS_ALL | Cabeçalho de pedido |
| XXOE_ORDER_LINES_BR_V | OE_ORDER_LINES_ALL | Linhas de pedido |
| XXRA_INTERFACE_LINES_BR_V | RA_INTERFACE_LINES_ALL | Interface com origem (BATCH_SOURCE_NAME, CASE_RILA) |
| XXMTL_ITEM_CATEGORIES_BR_V | MTL_ITEM_CATEGORIES | Categorias de item |

---

## 🔗 Relacionamentos (Power BI Model)

```
RA_CUSTOMER_TRX_ALL (TRANSAÇÕES)
  [CUSTOMER_TRX_ID] → CLL_F031_ELECTRONIC_TRX_ALL [CUSTOMER_TRX_ID]
  [CUSTOMER_TRX_ID] → RA_CUSTOMER_TRX_LINES_ALL [CUSTOMER_TRX_ID]
  [CUSTOMER_TRX_ID] → RA_INTERFACE_LINES_ALL [CUSTOMER_TRX_ID]
  [CUST_TRX_TYPE_ID] → RA_CUST_TRX_TYPES_ALL [CUST_TRX_TYPE_ID]
  [CT_REFERENCE] → WSH_DELIVERY_ASSIGNMENTS [DELIVERY_ID]
  [SOLD_TO_CUSTOMER_ID] → HZ_CUST_ACCOUNTS [CUST_ACCOUNT_ID]
  [SHIP_TO_SITE_USE_ID] → HZ_CUST_ACCT_SITES [CUST_ACCT_SITE_ID]

HZ_CUST_ACCOUNTS
  [PARTY_ID] → HZ_PARTIES [PARTY_ID]
  [CUST_ACCT_SITE_ID] → HZ_CUST_ACCT_SITES [CUST_ACCT_SITE_ID]

HZ_CUST_ACCT_SITES
  [LOCATION_ID] → HZ_LOCATIONS [LOCATION_ID]

WSH_DELIVERY_ASSIGNMENTS
  [DELIVERY_DETAIL_ID] → WSH_DELIVERY_DETAILS [DELIVERY_DETAIL_ID]
```

---

## 📊 Comparação AS-IS vs. TO-BE

| Aspecto | AS-IS (3 Queries) | TO-BE (Opção D) | Ganho |
|---|---|---|---|
| **Dependência Policy Context** | ❌ Problema | ✅ Resolvido | Sem bloqueio |
| **Manutenibilidade** | Média (SQL na pasta) | ✅ Alta (modelo centralizado) | Documentado |
| **Performance** | Boa (query otimizada) | ✅ Boa (PBI cache) | Equivalent |
| **Flexibilidade** | Baixa (precisa SQL dev) | ✅ Alta (DAX self-service) | DAX > SQL for biz logic |
| **Rastreabilidade** | Débil (logs em arquivo) | ✅ Forte (Power Automate logs) | Audit trail completo |
| **Integração BI** | Nenhuma (standalone) | ✅ Total (nativa) | Extensível |

---

## 🚀 Plano de Implementação Opção D

### **Fase 1: Validação (Semana 1)**

```
1. Configurar a ingestão de cada tabela-base no dataflow (11 tabelas)
2. Aplicar os filtros padrão em Power Query (M):
   - ORG_ID = 1344 (ou listar orgs aplicáveis)
   - Filtros de data (ex: TRX_DATE >= TRUNC(SYSDATE) - 30)
3. Teste no dataflow: cada entidade ingere OK?
4. Contar registros vs. query original (paridade?)
```

### **Fase 2: Integration (Semana 2)**

```
1. Dataflow: ingerir 11 tabelas-base (Power Query/M)
2. Dataset a partir do dataflow: criar relacionamentos conforme mapeamento
3. M/DAX: Colunas calculadas (PAGA_GUIA, NOTA_MAE, ORDEM_CLASSIFICACAO)
4. Validar totalizações vs. queries originais (paridade)
```

### **Fase 3: Teste Paridade (Semana 2-3)**

```
1. Query original (SQL em Oracle) → Dataset A
2. Power BI (tabelas base + DAX) → Dataset B
3. Comparar:
   - Total de NFs (A == B?)
   - Total de valor (A == B?)
   - Status distribution (A == B?)
   - Sample de 50 NFs: campos iguais?
4. Se diferenças: debugar (onde diverge?)
```

### **Fase 4: Deploy (Semana 4)**

```
1. Publicar Power BI workspace
2. Refresh schedule: Daily 7 AM
3. Monitor primeira semana para anomalias
```

---

## 📋 Checklist Opção D

- [ ] DBA fornece 11 queries tabelas base
- [ ] Cada query testada isoladamente (row counts OK)
- [ ] Power BI importa todas as 11 tabelas
- [ ] Relacionamentos criados (all 10+ relationship keys)
- [ ] DAX colunas calculadas testadas
- [ ] Paridade dataset vs. query original (> 99% rows match)
- [ ] Performance aceitável (refresh < 10 min)
- [ ] Documentação atualizada
- [ ] Stakeholders aprovam antes do deploy

---

## ⚠️ Riscos + Mitigação

| Risco | Mitigation |
|---|---|
| Policy context ainda requerido em subtabelas | Solicitar DBA garantia ou criar view simples sem policy |
| Query mais lenta (joins complexos) | Índices em FK; PBI cache compensa |
| Dificuldade encontrar colunas corretas | Usar data dictionary Oracle; documentar mapeamento |

---

## 🔗 Referência

- [`../01_PowerBI/03_Modelo_Semantico.md`](../01_PowerBI/03_Modelo_Semantico.md) — Modelo semântico com 11 tabelas
- [`../01_PowerBI/04_Fluxo_Classificacao_Analise.md`](../01_PowerBI/04_Fluxo_Classificacao_Analise.md) — Análise de classificação e validação
- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md) — Lógica de negócio (DAX)
