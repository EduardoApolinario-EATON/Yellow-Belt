# 📌 Plano de Ação — 5W2H

> Ações concretas para levar a solução à produção.  
> **Última atualização:** 2026-06-22

---

## Ações por Fase

### **Semana 1: Setup Dataflow + Power BI Base**

| # | O quê | Quem | Quando | Onde | Por quê | Como | Quanto |
|---|---|---|---|---|---|---|---|
| 1.1 | Configurar dataflow de ingestão das tabelas-base | BI | Seg-Ter | Power BI Service | Dataflow único (coerência temporal) | Entidades + filtros org_id em M | ~8h |
| 1.2 | Testar paridade (queries vs. dataset) | QA | Qua | Power BI | Garantir mesmos dados | Volume/somatórios/amostras | ~4h |
| 1.3 | Construir dataset a partir do dataflow | BI | Qui-Sex | Power BI Desktop | Modelo semântico | Conectar ao dataflow + M/DAX | ~12h |
| 1.4 | Criar relacionamentos (RA_CUSTOMER_TRX_ALL hub) | BI | Sex | Power BI Desktop | Integridade referencial | 1:N e N:1 conforme spec | ~8h |

---

### **Semana 2: DAX + Power Automate Skeleton**

| # | O quê | Quem | Quando | Onde | Por quê | Como | Quanto |
|---|---|---|---|---|---|---|---|
| 2.1 | Calcular colunas DAX (PAGA_GUIA, NOTA_MAE, ORDEM_CLASSIFICACAO) | BI | Seg-Ter | Power BI Desktop | Roteamento baseado em regras | IF/CASE + lógica de negócio | ~12h |
| 2.2 | Testar paridade PBI vs. macro (PAGA_GUIA, SUB_LOC) | QA | Qua | Power BI / Excel | Validar regras | Amostras 50-100 NFs | ~8h |
| 2.3 | Criar 3 Listas no SharePoint | Admin SP | Qui | SharePoint | Hub de dados para PA | EXP_NF_DATASET, EXP_CICLOS_LOG, EXP_FALHAS_LOG | ~4h |
| 2.4 | Skeleton Flow #1 (Power BI → SharePoint) | PA | Qui-Sex | Power Automate Cloud | Teste de integração básica | Trigger manual + simples | ~8h |
| 2.5 | Skeleton Flow #2 (Monitor pasta + placeholder) | PA | Sex | Power Automate Cloud | Teste de automação de pastas | File trigger + passos vazios | ~4h |

---

### **Semana 3: Power Automate Completo + Testes**

| # | O quê | Quem | Quando | Onde | Por quê | Como | Quanto |
|---|---|---|---|---|---|---|---|
| 3.1 | Implementar Flow #1 completo (Sync PBI → SP daily) | PA | Seg-Ter | Power Automate Cloud | Atualizações automáticas | Schedule 8h AM + Get data from PBI | ~12h |
| 3.2 | Implementar extração OCR (Azure Doc Intelligence) | PA | Qua | Power Automate Cloud | Ler CHAVE_ACESSO de PDF | Cognitive Services connector + regex | ~8h |
| 3.3 | Implementar matching (CHAVE vs. dataset) | PA | Qui | Power Automate Cloud | Localizar NF na lista | Lookup/Filter + fallback /FAILED/ | ~8h |
| 3.4 | Implementar prefixação (001_, 002_, etc.) | PA | Fri | Power Automate Cloud | Garantir ordem de impressão | Cálculo ORDEM_CLASSIFICACAO via SharePoint | ~6h |
| 3.5 | Testar 5 PDFs end-to-end | QA + Op | Sex | Test folder | Validação integral | 5 NFs reais, 5 casos de erro | ~6h |
| 3.6 | Corrigir gaps identificados nos testes | PA + BI | Seg (S4) | Power Automate / PBI | Robustez | Falhas, refis, edge cases | ~8h |

---

### **Semana 4: Go-live**

| # | O quê | Quem | Quando | Onde | Por quê | Como | Quanto |
|---|---|---|---|---|---|---|---|
| 4.1 | Comunicação ao operador (1-pager + vídeo demo) | PM + Op | Seg | Email + Teams | Alinhamento | 05_Manual_Operador.md + screencast | ~2h |
| 4.2 | Deploy em produção (PBI + flows) | DevOps | Seg-Ter | Production | Ativar solução | Publish PBI workspace + Enable flows | ~4h |
| 4.3 | Suporte primeiras 48h (helpdesk) | PA + BI | Ter-Qua | Slack/Email | Problemas iniciais | Sombra em ciclos, debug rápido | ~16h |
| 4.4 | Retrospectiva + lições aprendidas | PM | Qui | Meeting | Fechamento e feedback | 1h meeting + doc | ~2h |

---

## Gráfico Gantt (resumido)

```
Sem 1  ██████████ Query + PBI Base
Sem 2        ██████████ DAX + Flows skeleton
Sem 3               ██████████ PA completo + Testes
Sem 4                      ██████ Go-live + Suporte
```

---

## KPIs de Sucesso

| KPI | Baseline AS-IS | Target TO-BE | Método |
|---|---|---|---|
| **Tempo ciclo NF** | 4h | 30 min | Cronômetro operador |
| **Bloqueios manuais** | 2h/dia | 15 min/dia | Logs Power Automate |
| **Precisão roteamento** | 85% | >99% | Auditoria semanal (50 NFs) |
| **Disponibilidade** | 95% | >99% | Uptime SharePoint/PA |

---

## Riscos + Mitigação

| Risco | Impacto | Prob. | Mitigação |
|---|---|---|---|
| Query consolidada mais lenta | Alt | Med | Teste vol em Dev; índices Oracle |
| Falha OCR (PDF baixa qualidade) | Alt | Med | Fallback manual (/FAILED/) + retry |
| Limite 6k actions/dia Power Automate | Med | Baixa | Monitorar diariamente; batch se necessário |
| Policy context bloqueia views | Alt | Baixa | Opção D garante tabelas base |

---

## 🔗 Referência

- [`00_Estrategia_TO_BE.md`](00_Estrategia_TO_BE.md) — Visão geral
- [`04_Improve/04_Arquitetura/`](04_Arquitetura/) — Decisões técnicas
- [`05_Control/01_Plano_de_Controle.md`](../05_Control/01_Plano_de_Controle.md) — KPIs pós-implantação
