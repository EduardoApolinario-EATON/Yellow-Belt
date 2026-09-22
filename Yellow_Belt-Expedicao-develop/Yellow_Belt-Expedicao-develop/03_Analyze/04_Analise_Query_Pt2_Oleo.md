# Análise — Query 2 (IMPRESSÃO PART 2 / Óleo)

> Fluxo específico de NFs de itens de óleo.
> Fonte: `queries/IMPRESSAO_PART_2_OLEO.sql`.

## 1. O que ela é

Trata o **fluxo específico de itens de óleo**, identificados por CFOP `'6.655'` ou `'5.655'`.

## 2. Estrutura

- SELECT principal: NFs de óleo com classificação `OLEO_<ITEM>` no SUB_LOC.
- `UNION ALL` com bloco RILA (NFs ainda em interface).

## 3. Pontos relevantes

### 3.1. CFOP determina o fluxo
Item de óleo segue uma regra de `SUB_LOC` diferente das demais NFs: o SUB_LOC vira `OLEO_<segment1 do item>`, agrupando fisicamente por tipo de item.

### 3.2. Lógica complexa de `EMBREAGEM_DSH`
Subquery aninhada com 6 tabelas para identificar a combinação de categoria 'A' + shipment priority `DIRECT SHIPMENT`. Resultado vira um fluxo paralelo separado.

### 3.3. Inscrição estadual hardcoded por UF
Lista `DECODE` com 18 UFs e suas inscrições estaduais. Risco: qualquer mudança de IE estadual exige alteração no SQL.

### 3.4. Tabela de impostos com 45 VAT_TAX_IDs hardcoded
Mesma lista de 45 IDs aparece **duplicada** em duas seções da query — para identificar `ICMS_ST` e `FCP_ST`. Manutenção em dois lugares.

### 3.5. Mistura de responsabilidades
A query faz simultaneamente:
- identificação fiscal (CFOP, ICMS_ST),
- classificação logística (SUB_LOC, EMBREAGEM_DSH),
- cálculo de impostos,
- enriquecimento (inscrições UF, cliente, transportadora).

Difícil isolar uma camada para refatorar.

## 4. Relação com a Query 3 (Revisada)

A Pt.2 Óleo e a Query Revisada são **~80% idênticas**. A diferença prática parece ser apenas o filtro de CFOP (Pt.2 filtra `IN ('6.655','5.655')`; revisada inclui mais ou não filtra). No TO-BE serão unificadas com a coluna `FLUXO ∈ {PADRAO, OLEO, EMBREAGEM_DSH}` distinguindo o caminho.

## 5. Papel no TO-BE

- Lógica de óleo absorvida pelo dataset unificado como coluna `FLUXO = 'OLEO'`.
- VAT_TAX_IDs migram para SharePoint List como tabela de configuração.
- Inscrições UF idem.

Detalhamento em `04_Improve/04_Arquitetura/01_Opcao_D_Refatoracao.md` e `04_Improve/01_PowerBI/01_Dataset_Schema.md`.
