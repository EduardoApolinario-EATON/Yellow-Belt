# Power BI - Dicionário do Modelo Atual

> **Referência vigente: 2026-10-14.** Conferida contra [NotasFiscais.tmdl](../../../../Dataset/Modelo_Expedicao_ATUAL.SemanticModel/definition/tables/NotasFiscais.tmdl). O esquema proposto de 23 colunas, preservado no anexo, foi substituído. Fonte oficial do PBIP: orquestrador; Dataset é uma cópia.

## Contrato de NotasFiscais

São **39 colunas: 36 importadas de Power Query e três calculadas em DAX**. Tipos são os declarados no TMDL. Não converter NF, delivery ou chave em número. A granularidade pretendida é por CUSTOMER_TRX_ID, mas esse ID não é exposto; NF não é PK garantida. Validação de unicidade/cardinalidade depende de dados homologados.

| Campo | Tipo TMDL | Origem/regra e uso |
|---|---|---|
| ORDEM_CLASSIFICACAO | int64 | Índice M após sort, iniciado em 1; não é prefixo textual nem ID persistente |
| NF | string | AR TRX_NUMBER; identificação da nota |
| TRX_DATE | dateTime | Data da transação AR |
| PARTY_NAME | string | HZ_PARTIES.PARTY_NAME, sem corte para 20 caracteres |
| TRANSP | string | Cabeçalho AR SHIP_VIA |
| UF | string | HZ_LOCATIONS.STATE via endereço ship-to |
| DELIVERY | string | AR CT_REFERENCE |
| VOL | string | WSH GLOBAL_ATTRIBUTE3; filha recebe 0 |
| SUB_LOC | string | Óleo/item, GA19 ou locator, mais prioridade |
| LOC_ALL | string | Locators distintos concatenados com ` \| `; diagnóstico |
| SUBINV_ALL | string | Subinventários distintos; diagnóstico |
| REL_ALL | string | Status WSH distintos; diagnóstico |
| QTD_PEDIDA | double | Soma QUANTITY_ORDERED das linhas AR LINE |
| QTD_ENVIADA | double | Soma SHIPPED_QUANTITY das linhas OE relacionadas |
| QUANTITY | double | Soma QUANTITY_INVOICED de LINE; não confundir com volume |
| EXTENDED_AMOUNT | double | Soma EXTENDED_AMOUNT de LINE; não é o imposto usado em PAGA_GUIA |
| CHAVE_ACESSO | string | CLL ATTRIBUTE2, valor bruto |
| CHAVE_LEN | int64 | Comprimento bruto da chave, nulo tratado como vazio |
| STATUS_FISCAL | string | FINALIZADO, CANCELADO, SEM_STATUS ou ERRO |
| APTA | string | Sim/Nao: FINALIZADO + RILA OK + CHAVE_LEN 44 |
| CASE_RILA | string | OK/VERF_RILA: igualdade exata de pedido e embarcado, ambos não nulos |
| PAGA_GUIA | string | SIM/NAO por UF e ICMS-ST |
| GUIA | string | PAGA GUIA/NÃO PAGA, rótulo de apresentação |
| MOTIVO | string | OK, CHAVE INVALIDA, ERRO NF, VERIFICAR DELIVERY, ERRO DELIVERY + ERRO NF |
| PASTA_DESTINO | string | AGUARDANDO GUIA, OLEO, PRONTO ou EXCECAO/*; guia tem precedência |
| NOME_ARQUIVO | string | Nome sugerido do PDF com letra/posição ou DFE/chave |
| MULTI_LOCATOR | string | Sim/Nao por quantidade de locators distintos |
| LOCATOR_PRINCIPAL | string | Locator selecionado pela agregação WSH |
| CFOP | string | RA_CUST_TRX_TYPES_ALL.GLOBAL_ATTRIBUTE3 |
| CFOP_ST | string | S_ST/C_ST por ICMS-ST zero/não zero |
| CFOP_COMPLETO | string | CFOP + espaço + CFOP_ST |
| ICMS_ST | double | Soma TAX por lookup; ausência convertida em zero |
| FCP_ST | double | Soma TAX por dez IDs fixos; pode permanecer nulo |
| CNPJ | string | Dígitos de HZ_PARTIES.JGZZ_FISCAL_CODE; não garante CNPJ de 14 dígitos |
| NOTA_MAE | string | Referência à menor NF numérica da delivery para filhas; mãe/isolada recebe nulo |
| DATA_HORA_FAT | dateTime | CREATION_DATE interpretada em UTC-5 e convertida a UTC-3; validar premissa |
| DL_CMD | Calculada DAX | Texto constante *DN |
| CHAVE_44 | Calculada DAX | Trim e remoção de DFE inicial; não valida dígitos/DV |
| STATUS_CICLO | Calculada DAX | SEM CHAVE / JA PROCESSADA / PENDENTE; histórico importado |

O código não garante que 44 caracteres sejam 44 dígitos fiscais válidos. CHAVE_44 e CHAVE_LEN usam bases diferentes. Chaves devem ser conciliadas com documentos e origem autorizada.

## Tabelas auxiliares e medidas

`NFS_IMPRESSAS`: histórico SharePoint, 42 colunas incluindo metadados. `Atualizacao`: texto de refresh UTC-3. `MesmaNF_OutroLocator`: nove colunas e partição vazia; a página de múltiplos locators usa NotasFiscais. São 24 tabelas não automáticas, oito tabelas locais de data e um template.

As 12 medidas e a linhagem completa estão no [Manual Técnico](../../docs_ferramenta/01_Documentacao_Tecnica.md). Qtd Excecoes conta APTA Nao, podendo sobrepor o cartão de guia. ChavesParaCopiar não exclui histórico nem deduplica por si só.

## Contrato com automações

O modelo calcula NOME_ARQUIVO e PASTA_DESTINO; não movimenta arquivos. Confirmar no export de cada fluxo campos consultados, filtros, normalização, biblioteca, subpastas, histórico, concorrência e limites. O JSON dos botões não comprova que o filtro da tela restrinja a execução.

Campos antigos como INVOICE_TYPE, STATE, MOTIVO_BLOQUEIO, DI_NUMERO, ICMS_RATE e IPI_VALUE não são colunas finais deste modelo. Consumidores devem usar os nomes reais e testar qualquer mudança de contrato.

<details>
<summary>Esquema proposto em junho/2026: histórico, não implementar como contrato atual</summary>

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

- Dados de exemplo históricos: Exemplo_Notas_Fiscais.xlsb não está disponível nesta cópia. Não usar notas reais sem autorização/anonimização.
- Regras de negócio: [`01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md)

</details>
