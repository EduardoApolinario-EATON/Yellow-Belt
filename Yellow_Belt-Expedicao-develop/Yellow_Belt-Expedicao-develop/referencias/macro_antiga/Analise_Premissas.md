# Análise do Arquivo Premissas.xlsx (Macro Antiga)

> **Revisão documental: 2026-10-14.** Estudo histórico da planilha, não schema obrigatório nem plano de teste homologado da ferramenta atual. As sugestões de importar todas as 51 colunas ou usar dados reais devem ser reavaliadas.

NotasFiscais possui 39 colunas conforme [Dicionário atual](../../04_Improve/01_PowerBI/01_Dataset_Schema.md). Dados de cliente/NF não devem ser usados em testes ou publicados sem autorização/anonimização. O estudo não comprova código VBA, regras de fluxo nem equivalência de dados; validar paridade com negócio e TI.

> O que foi recebido, o que contém e como pode ajudar no TO-BE.
> Última atualização: 2026-06-09

---

## 🔍 O que é este arquivo?

**NÃO é o código da macro VBA**, mas sim um **arquivo de dados + fórmulas de consolidação** que a macro antiga provavelmente **consumia e alimentava**.

---

## 📋 Estrutura

### Aba 1: **venda** (46.748 linhas)

Dados de **Notas Fiscais** do Oracle EBS.

| Campo | Exemplo | Propósito |
|---|---|---|
| `TRX_NUMBER` | 389144 | ID da NF |
| `TRX_DATE` | 2024-01-27 | Data de faturamento |
| `CNPJ` | 00.000.000/0000-00 | Cliente (anonimizado) |
| `PARTY_NAME` | CLIENTE EXEMPLO LTDA | Nome do cliente (anonimizado) |
| `INVOICE_TYPE` | Venda | Tipo de documento |
| `FISCAL_CLAS_CODE` | 5.915 | Código fiscal (CFOP) |
| `OPERATION_FISCAL_DESCRIPTION` | REMESSA DE MERCADORIA... | Descrição fiscal |
| `BATCH_SOURCE_NAME` | VALI REMESSA MANUAL | Origem do lançamento |
| `QUANTITY_INVOICED` | 1 | Quantidade |
| `EXTENDED_AMOUNT` | 15000 | Valor total |
| `SHIPMENT_NUMBER` | — | NF de remessa |
| `SALES_ORDER` | — | Pedido de venda |

**Total: 51 colunas**

---

### Aba 2: **reserva** (11.009 linhas)

Dados de **Reservas / Inventário / Picking**.

| Campo | Exemplo |
|---|---|
| `ORG` | VWH |
| `ITEM` | 022526 |
| `ORDER_NUMBER` | 4947714 |
| `LOCATION` | 00.000.000/0000-00 |
| `CUSTOMER` | CLIENTE EXEMPLO... |
| `RESERVATION` | 20 |
| `TOTAL_RESERVATION` | 6,2 |
| `PENDING` | 0 |
| `SHIP_READY_FLAG` | 2 |
| `DATA_RESERVA` | 10/01/2024 22:00:28 |

**Total: 24 colunas**

Parece ser o **lado da warehouse/inventory** — o que está reservado, aguardando, pendente.

---

### Aba 3: **premissas** (51 linhas)

Tabela de **consolidação/resumo** com **fórmulas SUMIF**.

| Tipo de Ordem | Fórmula |
|---|---|
| BRA REMAN 1 | `=SUMIF(venda!$AY:$AY,premissas...` |
| BRA REMAN 2 | (fórmula similar) |
| BRA REMAN A | (agrupa dados por tipo) |

**Parece ser:** Consolidação de volume por tipo de ordem (quantos itens faturados, embalando, reservados).

---

## 🤔 Isso é a macro?

**NÃO.** O arquivo é:

❌ **NÃO contém código VBA** (nenhuma lógica programada visível)
✅ **Contém dados de teste/premissas** que a macro processava
✅ **Contém fórmulas de consolidação** (SUMIF, referências entre abas)
✅ **Parece ser um "staging area"** onde dados de venda + reserva se encontravam

---

## ✅ Como pode ajudar no TO-BE?

### 1. **Validar estrutura de dados**
- As 51 colunas de `venda` = campos que **Power BI precisa consumir do Oracle**
- Compare com schema atual (dataset refatorado Opção D)

### 2. **Testar o Power Automate**
- Use esses ~47K dados como **dados de teste** para validar classificador
- Simulte o fluxo: venda + reserva → prisma + impressão

### 3. **Validar regras de negócio**
- Campos como `BATCH_SOURCE_NAME`, `FISCAL_CLAS_CODE`, `SHIPMENT_NUMBER` confirmam as regras que Power Automate precisa implementar
- As fórmulas SUMIF mostram como dados foram consolidados antes

### 4. **Entender o processo anterior**
- `venda` + `reserva` → consolidado em `premissas` = **exatamente o que o TO-BE fará** (dataset Power BI + SharePoint List)

---

## 🎯 Próximas ações

1. **Conferir se as 51 colunas de `venda`** estão todas no dataset refatorado (Opção D)
2. **Usar dados de `venda`** como dataset de teste para Power Automate Classificador
3. **Validar regras** das fórmulas em `premissas` — a lógica de consolidação precisa estar no Power Automate também

---

## ⚠️ O que ESTÁ FALTANDO

- ❌ **Código VBA da macro** — nenhuma lógica programada visível aqui
- ❌ **Estrutura de pastas/PDFs** — como a macro organizava os PDFs por prisma
- ✅ **Dados** — temos bons dados de teste

**Conclusão:** Este arquivo é **útil para testes e validação**, mas **não é o código original** da macro. Se precisar do código, peça o arquivo `.vba` ou a macro extraída do Excel.

---
