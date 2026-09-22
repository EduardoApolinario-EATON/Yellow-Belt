# 01 — Documentação Técnica

> Referência para quem **mantém** a ferramenta (você / TI). Cobre o fluxo de dados, os dataflows, a lógica do dataset `NotasFiscais` e o fluxo Power Automate.
> **Última atualização:** 2026-08-31

---

## 1. Fluxo de dados (ponta a ponta)

```
Oracle EBS (P188)
   └─ Dataflows Bronze (BRZ_ORACLE_*) — ingestão por tabela
        └─ Dataset NotasFiscais (Power BI) — 1 linha por NF (CUSTOMER_TRX_ID)
             ├─ Report (Visão Geral, Lista de Impressão, Óleo, Chaves)
             └─ Power Automate "Processar Ciclo" — lê o dataset + PDFs da ENTRADA
                  └─ SAIDA/<Ciclo>/<destino> (PRONTO / AGUARDANDO GUIA / OLEO / EXCECAO)
```

**Fonte da verdade:** o dataset replica a query PL/SQL original da expedição (`QUERY_AFTK`). A macro antiga não calculava nada — consumia essa query. Toda a lógica de classificação está no dataset.

## 2. Dataflows que alimentam o modelo

| Tabela | Dataflow | Muda por ciclo? |
|---|---|---|
| `RA_CUSTOMER_TRX_ALL` / `RA_CUSTOMER_TRX_LINES_ALL` | `BRZ_ORACLE_AR_DOC_CUR` | 🔴 Sim (as NFs) |
| `CLL_F031_ELECTRONIC_TRX_ALL` | `BRZ_ORACLE_CLL_TXN` | 🔴 Sim (chave + status SEFAZ) |
| `WSH_DELIVERY_DETAILS` / `WSH_DELIVERY_ASSIGNMENTS` / `WSH_NEW_DELIVERIES` | `BRZ_ORACLE_WSH_DOC_CUR` | 🔴 Sim (entregas / locator) |
| `OE_ORDER_LINES_ALL` | `BRZ_ORACLE_ONT_DOC_CUR` | 🔴 Sim (qtd embarcada, prioridade) |
| `RA_INTERFACE_LINES_ALL` | `BRZ_ORACLE_AR_TXN` | 🔴 Sim |
| `MTL_ITEM_LOCATIONS` / `MTL_SYSTEM_ITEMS_B` | `BRZ_ORACLE_INV_MST` | 🟡 Cadastro (diário) |
| `HZ_*` / `RA_ADDRESSES_ALL` / `RA_CUST_TRX_TYPES_ALL` / `AR_VAT_TAX_ALL_B` | `BRZ_ORACLE_AR_MST` | 🟡 Cadastro (diário) |
| `FND_LOOKUP_VALUES` (lista ICMS-ST) | `BRZ_ORACLE_APPLSYS_MST` | 🟡 Cadastro (diário) |

**Ordem de refresh:** dataflows **primeiro**, dataset **depois** (o dataset só relê o que os dataflows materializaram). Os 🔴 mudam a cada ciclo; os 🟡 (MST) atualizam 1×/dia.

## 3. Categorias de dataflow e a regra DOC_CUR

Cada tabela Oracle é classificada numa categoria que define o refresh: **MST** (cadastro, full), **BAL** (snapshot), **DOC** (documento com status), **TXN** (evento imutável), **REG** (referência mutável grande). Ver o guia de categorias em `CONTEXTOS/EXPEDICAO_AFT/guia_categorias_dataflow.html`.

**Regra canônica DOC_CUR** (a família WSH/AR/ONT que usamos) = **status + janela de recência**:
```sql
WHERE 1 = 1
    AND ( STATUS aberto OR (STATUS fechado AND fechado hoje) )
    AND LAST_UPDATE_DATE >= TRUNC(SYSDATE) - DaysText
    AND LAST_UPDATE_DATE <  TRUNC(SYSDATE) + 1
```
- A **janela `DaysText` é obrigatória** em DOC_CUR (não é desvio).
- Nos **filhos** (sem status próprio), a regra espelha o status do **pai** via `EXISTS`/`NOT EXISTS`, mais a janela.
- **Sargabilidade:** nunca `TRUNC(coluna)` no filtro — usar a coluna crua para o índice ser usado.

> ⚠️ **Performance WSH_DOC_CUR:** as entidades atualizam em paralelo; o tempo total = a mais lenta. `WSH_DELIVERY_DETAILS` e `ASSIGNMENTS` já têm janela; **falta janelar `WSH_NEW_DELIVERIES` e `WSH_DOCUMENT_INSTANCES`**. O valor do `DaysText` e alterar entidades compartilhadas é decisão do **dono do dataflow**.

## 4. O dataset `NotasFiscais` — colunas derivadas

### 4.1 SUB_LOC (destino físico / prisma)
```
SUB_LOC = base + " " + PRIORIDADE
  base: óleo (CFOP 6.655/5.655) → "OLEO_" + item
        GLOBAL_ATTRIBUTE19 preenchido → GA19 (prisma digitado)
        senão → LOCATOR = SEG1.SEG2.SEG3 (via WSH_DELIVERY_DETAILS.LOCATOR_ID → MTL_ITEM_LOCATIONS)
  PRIORIDADE: DIRECT SHIPMENT / EMBREAGENS / UNIDADE PARADA DSH (do pedido)
```
> **Bug conhecido:** se o dataflow WSH filtrar fora o detalhe da entrega, o `LOCATOR` vem nulo e o `SUB_LOC` mostra só a prioridade (ex.: "DIRECT SHIPMENT" sem `STG.XXX.###`). Causa raiz e correção: ver `CONTEXTOS/EXPEDICAO_AFT/analise_wsh_doc_cur_performance.html`.

### 4.2 PASTA_DESTINO (classificação)
| Valor | Regra |
|---|---|
| `AGUARDANDO GUIA` | `PAGA_GUIA = SIM` (ICMS-ST) |
| `OLEO` | apta e CFOP 6.655/5.655 |
| `PRONTO` | apta e não-óleo |
| `EXCECAO/*` | não apta (ERRO_NF / VERIFICAR_DELIVERY / ERRO_DELIVERY_NF / CHAVE_INVALIDA / OUTROS) |

### 4.3 ORDEM_CLASSIFICACAO + mãe/filha
- Ordena por `PAGA_GUIA` desc, `SORT_SUBLOC` asc, `DELIVERY`, `NF`; depois numera (índice).
- **Mãe/filha:** a filha herda o `SUB_LOC` da mãe (`SORT_SUBLOC`) só para ordenar → agrupa no mesmo prisma.

### 4.4 NOME_ARQUIVO (ordem de impressão do Windows)
- Apta: `EXPEDICAO <L><pos> - NF <nf>.pdf`
- Paga guia: `PAGA GUIA <L><pos> - NF <nf>.pdf`
- Sem classificação: `DFE<chave>.pdf`
- `<L>` = A/B/C/D pelo nº de dígitos da posição (garante ordem alfabética correta).

### 4.5 APTA / MOTIVO / PAGA_GUIA
- **APTA = Sim** se `STATUS_FISCAL = FINALIZADO` **e** `CASE_RILA = OK` **e** `CHAVE_LEN = 44`.
- **PAGA_GUIA:** por UF (AC/AM/AP/RO/RR sempre; AL/DF/GO/MS/TO se ICMS-ST ≠ 0).
- **CASE_RILA = OK** se `QTD_PEDIDA = QTD_ENVIADA`.

## 5. Fluxo Power Automate — "Processar Ciclo"

Disparado por um **botão dentro do report**. Passos-chave:
1. Lê os PDFs da pasta **ENTRADA**.
2. Extrai a **chave (44 dígitos)** de cada PDF.
3. **Casa a chave com o dataset** (o que o report mostra) → obtém `NOME_ARQUIVO` e `PASTA_DESTINO`.
4. Confere a lista **anti-reimpressão `NFS_IMPRESSAS`**.
5. Renomeia e **move** para `SAIDA/<Ciclo>/<destino>`.

**Comportamentos importantes:**
- **Anti-reimpressão:** NF já processada → volta como `JA_IMPRESSO`, não reprocessa.
- **Mismatch de ciclo:** PDF cuja chave não está no dataset atual **não casa → vai pra EXCECAO**. Exceção em massa = sinal de que os PDFs não correspondem ao ciclo que o report mostra.
- **Retenção de pastas:** não há expiração automática. **ENTRADA** é limpa a cada rodada; **SAIDA/\<Ciclo\>** e **EXCECAO** acumulam até limpeza manual. A lista `NFS_IMPRESSAS` é memória separada (apagar pastas não a apaga).

## 6. Pontos de atenção para manutenção
- **Refresh:** dataflows antes do dataset; MST 1×/dia; os de ciclo a cada ciclo.
- **`DaysText`/janela:** define quanto histórico entra no CUR — decisão de retenção do dono do dataflow.
- **Locator nulo → SUB_LOC errado:** sempre efeito do filtro do WSH (não da lógica do modelo).
- **Governança:** DEV para trabalho; PROD nunca sem backup; dataflows são compartilhados.

## 7. Referências
- `CONTEXTOS/EXPEDICAO_AFT/guia_categorias_dataflow.html` — categorias de dataflow.
- `CONTEXTOS/EXPEDICAO_AFT/analise_wsh_doc_cur_performance.html` — bug do SUB_LOC + performance.
- `reports/EXPEDICAO_AFT/HANDOFF.md` (repo do orquestrador) — contexto técnico do modelo.
- `docs/architecture/REFRESH_TIERS_AND_GUARDRAILS.md` (orquestrador) — regras de refresh.
