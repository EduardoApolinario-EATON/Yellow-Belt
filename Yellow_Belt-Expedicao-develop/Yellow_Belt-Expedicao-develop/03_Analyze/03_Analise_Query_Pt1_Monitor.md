# Análise — Query 1 (IMPRESSÃO PART 1)

> **Revisão documental: 2026-10-14.** Análise histórica da query, não especificação da página Monitor atual. No modelo atual MOTIVO é derivado em M e prioriza comprimento inválido antes dos erros fiscal/delivery.

Fonte atual e tratamentos: [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md) e [Manual do Operador](../05_Control/05_Manual_Operador.md). Não atribuir CHAVE INVALIDA automaticamente a PDF ilegível.

> Monitor de elegibilidade fiscal das NFs, formatado como dashboard SQL.
> Fonte: `queries/IMPRESSAO_PART_1.sql`.

## 1. O que ela é

Não é uma query de extração de dados — é um **dashboard de monitoramento em formato de SQL**. Junta 4 blocos via `UNION ALL`, cada um respondendo "quantas NFs estão presas em cada gate?".

A coluna `OBS` funciona como **instrução literal** para o operador esperar ou escalar.

## 2. Estrutura

| Bloco | Local | Pergunta que responde | Condição-chave |
|---|---|---|---|
| 1 | `1.SYNCHRO` | Quantas NFs aguardam autorização SEFAZ? | `B.STATUS IS NULL` |
| 2 | `2.RILA` | Quantas estão presas na interface (não viraram NF)? | `XXRA_INTERFACE_LINES_BR_V` populada |
| 3 | `3.CANCELAR_NF` | Quantas NFs do cliente VESPOR têm múltiplos pedidos (regra de cancelamento)? | `COUNT(DISTINCT INTERFACE_LINE_ATTRIBUTE13) > 1` |
| 4 | `4.RETORNO_SYNCHRO` | Quais NFs específicas estão sem retorno do SYNCHRO + há quanto tempo? | `B.STATUS IS NULL` (mesma do bloco 1) |

Saída agregada com colunas `LOCAL | SOURCE | NF_DELIVERY | ORDEM | OBS`.

Exemplo de saída do Bloco 2 (RILA com SHIPMENT INVOICES):
```
2.RILA | SHIPMENT INVOICES |  11 | BRA P-DOMESTIC      | Aguardar tempo de processamento RILA X SYNCHRO
2.RILA | SHIPMENT INVOICES |   1 | BRA RMA-CUST-RETURN | Aguardar tempo de processamento RILA X SYNCHRO
2.RILA | SHIPMENT INVOICES | 125 | BRA S-DOMESTIC      | Aguardar tempo de processamento RILA X SYNCHRO
2.RILA | SHIPMENT INVOICES |   5 | BRA S-RLM DOMESTIC  | Aguardar tempo de processamento RILA X SYNCHRO
```

## 3. Problemas identificados

### 3.1. Duplicação massiva entre Blocos 1 e 4
Mesmos JOINs, mesma condição (`B.STATUS IS NULL`).
- Bloco 1 → conta total agrupado por `D.NAME`
- Bloco 4 → lista cada NF com horário de criação

São **a mesma pergunta com granularidades diferentes**. No TO-BE: uma única tabela linha-a-linha; agregação fica no Power BI.

### 3.2. Tabelas joinadas e nunca usadas
Blocos 1 e 4 fazem JOIN com `XXETN_RA_CUSTOMERS E`, `FND_USER_VIEW F`, `XXETN_RA_CUSTOMERS RA` — nenhuma coluna delas aparece no SELECT. **JOIN morto** (custo de I/O sem retorno).

### 3.3. Sintaxe Oracle antiga
```sql
FROM TabelaA A, TabelaB B, TabelaC C
WHERE A.X = B.X(+) AND ...
```
Estilo pré-ANSI. Difícil de ler, propenso a erro de cardinalidade. Padrão moderno: `LEFT JOIN ... ON ...`.

### 3.4. `TRUNC(TRX_DATE)` mata índice
```sql
TRUNC(TRX_DATE) >= TO_DATE('&DATA_INIC', 'DD/MM/RRRR')
```
Aplicar `TRUNC` numa coluna indexada faz o Oracle ignorar o índice. Substituição:
```sql
TRX_DATE >= TO_DATE('&DATA_INIC', 'DD/MM/RRRR')
  AND TRX_DATE <  TO_DATE('&DATA_INIC', 'DD/MM/RRRR') + 1
```

### 3.5. Formatos de data inconsistentes
- Blocos 1, 3, 4: `DD/MM/RRRR`
- Bloco 2: `DD/MM/YY`

Mesmo parâmetro `&DATA_INIC`, dois formatos. Risco de bug silencioso (interpretação ambígua de ano de 2 dígitos).

### 3.6. Magic numbers e valores hardcoded
- `ORG_ID = 1344`
- `WAREHOUSE_ID = 1627`
- `'VALI AFT VENDA AUTOMATICA'`
- `'VESPOR AUTOMOTIVE DISTR DE AUTO PECAS LTDA'`
- `creation_DATE + .08333` (= 2 horas em fração de dia, ajuste de timezone)

Tudo embutido. No TO-BE → parâmetros do Power BI ou tabela de configuração.

### 3.7. Bloco 3 (VESPOR) — regra fiscal específica enterrada
NFs com mais de um pedido para o cliente VESPOR devem ser canceladas. Está hardcoded. Validade e abrangência da regra precisam ser confirmadas com o Time Fiscal (perguntas 1.1 e 1.2 do `07_Open_Questions.md`).

### 3.8. Coluna `ORDEM` polissêmica
A mesma coluna assume 4 significados diferentes:

| Bloco | Conteúdo de `ORDEM` |
|---|---|
| 1 | Literal `'AFT'` |
| 2 | `INTERFACE_LINE_ATTRIBUTE2` (tipo de pedido) |
| 3 | `TRX_NUMBER \|\| '_' \|\| CUSTOMER_NAME` |
| 4 | `TRX_NUMBER \|\| '_HORARIO_' \|\| hora` |

Inviável consumir programaticamente (Power BI/Power Automate). Refatorar em **colunas separadas e tipadas**.

## 4. Papel da Pt.1 no TO-BE

Hoje, o operador roda a Pt.1 manualmente, espera os contadores zerarem e só então roda a Pt.2. No TO-BE:

- A lógica dos 4 blocos vira **colunas de status** (`STATUS_FISCAL`, `MOTIVO_BLOQUEIO`, `MINUTOS_AGUARDANDO`) no dataset unificado.
- O dashboard Power BI substitui a execução manual.
- Diagnóstico transversal e proposta detalhada em `04_Improve/01_PowerBI/01_Dataset_Schema.md`.
