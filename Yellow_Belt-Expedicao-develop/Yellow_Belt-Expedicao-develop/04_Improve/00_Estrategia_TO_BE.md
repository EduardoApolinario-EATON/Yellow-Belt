# 📋 Estratégia TO-BE — Visão Geral

> **Revisão: 2026-10-14.** A estratégia abaixo é planejamento histórico. Estado atual: Power BI e botões de atualizar modelo, paga guias e processar PDFs em SharePoint funcionais conforme responsável; produção, homologação e ganho medido não confirmados.

Arquitetura observada: múltiplos Bronze -> modelo Import/M/DAX -> relatório -> fluxos externos -> conferência/impressão humana. Não presumir dataflow dedicado, licença Free suficiente ou ausência de controles manuais. Ver [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md) e [pendências](../03_Analyze/07_Open_Questions.md).

> Solução integrada: Power BI + Power Automate + SharePoint.  
> **Objetivo:** Reduzir ciclo de 4h para ~30 min via automação de roteamento de NFs.  
> **Último update:** 2026-06-22

---

## 1. Stack Tecnológico

| Componente | Escolha | Razão |
|---|---|---|
| **Data warehouse** | Power BI Pro — **dataflow de ingestão → dataset** | Oracle/gateway encapsulados no dataflow; modo Import, sem Premium |
| **Orquestração** | Power Automate Cloud Free | 6.000 actions/dia (atende ~350 NFs) |
| **Armazenamento PDFs** | SharePoint/OneDrive | Integração nativa com Power Automate |
| **Ingesta PDFs** | Manual (Opção A) → RPA (Opção B futuro) | Start simples, evolui para automação |
| **OCR/Matching** | Azure Document Intelligence | Extrai CHAVE_ACESSO (44 dígitos) |

---

## 2. Fluxo End-to-End (30 min)

```
1. DATAFLOW (Ingestão)
   └─ DF_Expedicao_Base ingere as 11 tabelas-base do Oracle (Power Query/M, filtros org_id)
      ↓
2. POWER BI (Semantic Model)
   └─ Dataset construído a partir do dataflow + relacionamentos + M/DAX (PAGA_GUIA, NOTA_MAE, ORDEM_CLASSIFICACAO)
      ↓
3. OPERADOR (OneDrive)
   └─ Faz download manual de PDFs (SYNCHRO → OneDrive/SharePoint)
      ↓
4. POWER AUTOMATE (Flow #1 - Sync)
   └─ Diariamente 8h: Power BI → Lista SharePoint (dataset sincronizado)
      ↓
5. POWER AUTOMATE (Flow #2 - Classificador)
   └─ Monitora pasta de entrada (OneDrive)
      ├─ Step 1: PDF chega → dispara flow
      ├─ Step 2: Extrai CHAVE_ACESSO (OCR)
      ├─ Step 3: Busca NF no dataset (Power BI)
      ├─ Step 4: Calcula prefixo (001_, 002_, etc.) via ORDEM_CLASSIFICACAO
      ├─ Step 5: Cria pasta destino (SUB_LOC + roteamento)
      └─ Step 6: Move + renomeia PDF
      ↓
6. SAÍDA (SharePoint/Drives)
   └─ PDFs organizados por prisma (OLEO, MONITOR, etc.)
      com subpastas por PAGA_GUIA, DELIVERY_STATUS, CASO_BLOQUEIO
```

---

## 3. Responsabilidades por Peça

| Peça | Responsável | Entrega |
|---|---|---|
| **Dataflow de ingestão (tabelas-base)** | Analista BI | 11 tabelas-base, filtros org_id/STATUS em M |
| **Power BI (tabelas + relacionamentos)** | Analista BI | Semantic model testado vs. queries |
| **Power BI (DAX)** | Analista BI | Colunas calc. PAGA_GUIA, NOTA_MAE, ORDEM_CLASSIFICACAO |
| **Power Automate (Sync)** | Desenvolvedor PA | Flow #1 executa diariamente 8h |
| **Power Automate (Classificador)** | Desenvolvedor PA | Flow #2 processa PDFs em lote |
| **SharePoint (Listas + schema)** | Admin SharePoint | 3 listas criadas (dataset, ciclos_log, falhas_log) |
| **Testes** | QA / Operador | 5 PDFs end-to-end |
| **Go-live** | Project Manager | Comunicação + suporte primeiras 48h |

---

## 4. Timeline (4 semanas)

| Sem. | Foco | Owner | Entrega |
|---|---|---|---|
| **1** | Dataflow de ingestão + tabelas-base | BI | Dataflow publicado + dataset base |
| **2** | Relacionamentos PBI + DAX | BI | Modelo semântico completo |
| **3** | Power Automate flows | PA | Fluxo de classificação testado |
| **4** | Testes integ. + Go-live | QA + PM | Produção |

---

## 5. Decisões-chave

### Opção D (Tabelas Base vs. Views)
- ✅ **Decisão:** Ingerir as tabelas-base Oracle (não views) via **dataflow dedicado**
- **Motivo:** Views requerem policy context (não disponível em Free/Pro); tabelas-base garantem controle total
- **Implementação:** dataflow `DF_Expedicao_Base` com 11 tabelas-base (RA_CUSTOMER_TRX_ALL, CLL_F031..., HZ_CUST_ACCOUNTS, etc.); dataset construído a partir dele

### PAGA_GUIA Routing
- ✅ **Decisão:** Calculado em DAX, não em query
- **Lógica:** IF(STATE IN (AC,AL,...,TO) AND EXTENDED_AMOUNT <> 0, "SIM", "NÃO")
- **Destino:** /AGUARDANDO_GUIA/ para SIM

### Ingesta PDFs (Dual Path)
- ✅ **Opção A (imediato):** Operador faz download manual SYNCHRO → OneDrive
- ⏳ **Opção B (futuro):** RPA/Power Automate Desktop + Synchro API (pendente estudo)

---

## 🔗 Referência

- [`03_Integracao/01_Fluxo_Operador.md`](03_Integracao/01_Fluxo_Operador.md) — passo-a-passo operacional
- [`01_PowerBI/04_Fluxo_Classificacao_Analise.md`](01_PowerBI/04_Fluxo_Classificacao_Analise.md) — análise do fluxo de classificação
- [`04_Arquitetura/01_Opcao_D_Refatoracao.md`](04_Arquitetura/01_Opcao_D_Refatoracao.md) — decisão técnica
- [`06_RPA_Synchro/README.md`](06_RPA_Synchro/README.md) — os 2 caminhos lado a lado
