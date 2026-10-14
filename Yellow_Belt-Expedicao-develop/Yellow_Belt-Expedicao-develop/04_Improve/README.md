# Fase 04 — Improve

> **Índice revisado: 2026-10-14.** Esta fase contém contratos atuais e propostas históricas. Presença de roteiro, exemplo ou script não comprova implantação.

Contratos vigentes: [Dicionário](01_PowerBI/01_Dataset_Schema.md), [Mapa de Regras](07_Mapa_de_Regras.md), [Handoff](05_Implementacao/HANDOFF.md). Operação: [Manual do Operador](../05_Control/05_Manual_Operador.md). Fonte oficial do PBIP: orquestrador; Dataset é cópia atual. Export dos fluxos e homologação: [a confirmar](../03_Analyze/07_Open_Questions.md).

Esta fase consolida a estratégia TO-BE: arquitetura, queries refatoradas, fluxos Power Automate, organização dos PDFs, compliance.

## Documentos desta fase

| Documento | Conteúdo |
|---|---|
| [00_Estrategia_TO_BE.md](00_Estrategia_TO_BE.md) | Visão alto-nível em 1 página (stack, peças, diagrama) |
| [08_Plano_de_Acao.md](08_Plano_de_Acao.md) | Ações 5W2H + responsáveis + prazos |
| [09_Ganho_Esperado.md](09_Ganho_Esperado.md) | Antes/depois numérico |
| [11_Relatorio_Estagios.md](11_Relatorio_Estagios.md) | Relatório da solução em 3 estágios (BI / Synchro / Power Automate) + status |

## Subpastas técnicas

| Pasta | Conteúdo |
|---|---|
| [01_PowerBI/](01_PowerBI/) | Dataset, dataflow de ingestão, modelo semântico e análise de classificação |
| [02_PowerAutomate/](02_PowerAutomate/) | Fluxo classificador, matching, renaming, erros e consumo de ações |
| [03_Integracao/](03_Integracao/) | Fluxo do operador e armazenamento dos PDFs |
| [05_Implementacao/](05_Implementacao/) | Fases e checklist de go-live |
| [04_Arquitetura/](04_Arquitetura/) | Decisões arquiteturais complementares |
| [06_RPA_Synchro/](06_RPA_Synchro/) | Caminho A manual e investigação de automação via Synchro API |

## O que esta fase entrega

- Tabelas-base ingeridas via dataflow dedicado (Opção D); lógica consolidada no dataset (M/DAX).
- Dataset Power BI Pro em modo Import.
- Dashboard operacional substituindo a Pt.1 manual.
- Fluxo Power Automate Cloud que popula SharePoint List e classifica PDFs em pastas por prisma.
- Estratégia dual de obtenção dos PDFs do SYNCHRO.
- Estrutura mínima de auditoria.

## Status

⬜ Próxima fase. Bloqueada por: respostas das perguntas 7.9/7.10/7.11 (Open_Questions) + premissas sobre PDF/SUB_LOC/nota mãe.
