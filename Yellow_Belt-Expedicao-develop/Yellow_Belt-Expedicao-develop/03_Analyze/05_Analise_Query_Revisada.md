# Análise — Query 3 (EXPEDIÇÃO REVISADA)

> **Revisão documental: 2026-10-14.** Referência de paridade do legado, não prova de equivalência integral ao PBIP atual.

Diferenças observadas: canceladas podem permanecer no modelo; CNPJ usa JGZZ_FISCAL_CODE; não há categoria EMBREAGEM_DSH; mãe/filha usa menor NF da delivery. Ver [Mapa de Regras](../04_Improve/07_Mapa_de_Regras.md) e validar amostra autorizada antes de aceitar diferenças.

> Query principal do processo. Gera o pacote lógico de impressão das NFs.
> Fonte: `queries/QUERY_EXPEDICAO_REVISADA.sql`.

## 1. O que ela é

**A query principal do processo** — gera o pacote lógico de impressão com todas as NFs já classificadas. É o que vira o Excel enviado para a macro hoje.

## 2. Estrutura

Praticamente idêntica à Pt.2 Óleo na maior parte. A diferença prática parece ser apenas o filtro de CFOP (Pt.2 filtra `IN ('6.655','5.655')`; revisada não filtra ou inclui ambos).

Composição: SELECT principal + `UNION ALL` com bloco RILA.

## 3. Colunas-chave de saída

| Coluna | Função |
|---|---|
| `NF` | Identificação |
| `DELIVERY` | Chave logística |
| `SUB_LOC` | **Agrupamento físico** — define em qual prisma/grupo a NF entra |
| `VOL` | Volume |
| `CNPJ`, `CLIENTE`, `UF` | Cliente |
| `CHAVE_DE_ACESSO` | Identificador SEFAZ (44 dígitos) |
| `TRANSP` | Transportadora |
| `CFOP` | Classificação fiscal (S_ST / C_ST) |
| `CASE_RILA` | OK / VERF_RILA (validação qty faturada vs expedida) |
| `STATUS` | Estado fiscal decodificado (FINALIZADO / ERRO / CANCELADO) |
| `ICMS_ST`, `FCP_ST` | Impostos |
| `INSCRICAO_UF`, `INSCRICAO_CLIENTE` | Inscrições estaduais |

`SUB_LOC` é construído por concatenação:
```sql
MIL.SEGMENT1 || '.' || MIL.SEGMENT2 || '.' || MIL.SEGMENT3
```
com fallback para `GLOBAL_ATTRIBUTE19` quando vazio.

## 4. Problemas adicionais

### 4.1. Duplicação com Query 2 Óleo
~80% do código é idêntico. Manutenção em dois lugares.

### 4.2. Subqueries correlacionadas no SELECT
Várias colunas do SELECT são subqueries correlacionadas (`SHIPMENT_PRIORITY_CODE`, `EMBREAGEM_DSH`, `INSCRICAO_CLIENTE`, etc.). Cada linha do resultado dispara N subqueries → **não escala bem** e dificulta Direct Query no Power BI.

### 4.3. `SUB_LOC` construído por concatenação encadeada
Regra fiscal + regra logística + regra de embreagem misturadas no mesmo CASE. Difícil de auditar e manter.

### 4.4. Lista de 45 VAT_TAX_IDs hardcoded (dobrada)
Mesmo problema da Pt.2: lista repetida em duas seções da query.

### 4.5. Inscrições estaduais hardcoded (18 UFs)
Mesma lógica DECODE da Pt.2.

## 5. Papel no TO-BE

A Query Revisada é a **espinha dorsal** da refatoração unificada. Ela contém os campos físicos da impressão (SUB_LOC, DELIVERY, CHAVE_DE_ACESSO) e a maior parte do esquema final.

A unificação consiste em:
1. Manter a estrutura desta query como base.
2. Absorver Pt.2 Óleo via coluna `FLUXO`.
3. Absorver Pt.1 via colunas `STATUS_FISCAL` e `MOTIVO_BLOQUEIO`.
4. Substituir subqueries correlacionadas por JOINs explícitos.
5. Migrar listas hardcoded para SharePoint Lists de configuração.
6. Replicar a lógica contra tabelas-base (Opção D), ingeridas via dataflow e consolidadas no dataset (M/DAX).

Detalhamento em `04_Improve/04_Arquitetura/01_Opcao_D_Refatoracao.md`.
