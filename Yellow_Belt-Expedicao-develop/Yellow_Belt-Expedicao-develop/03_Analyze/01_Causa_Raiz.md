# Causa Raiz — Ishikawa + 5 Porquês

> **Revisão documental: 2026-10-14.** Diagnóstico do processo legado, não causa automática de incidente atual. A revisão estática não validou todas as hipóteses com operação ou dados reais.

Para falhas atuais, seguir o [runbook técnico](../docs_ferramenta/01_Documentacao_Tecnica.md): validar fontes, joins, filtros, refresh e execução. Locator ausente não tem causa única comprovada; classificação funcional não demonstra que todo retrabalho foi eliminado.

> Análise de causa-raiz do gargalo de 2h12 de separação manual por prisma (Bloco 5 do AS-IS).
> Última atualização: 2026-05-28

## 1. Problema-foco

> **Os operadores da expedição gastam ~2h12 por ciclo separando manualmente as NFs por prisma, sobre um volume de 350 NFs.**

Este bloco representa 55% do tempo total do ciclo e é 100% retrabalho (não agrega valor ao cliente).

## 2. Ishikawa (6M)

```
          MÉTODO                        MÁQUINA                       MEDIÇÃO
   ┌─────────────────┐          ┌──────────────────────┐    ┌────────────────────┐
   │ Macro VBA é     │          │ Macro VBA quebrada   │    │ Sem trilha de      │
   │ ponto único de  │          │ após update SYNCHRO  │    │ auditoria do ciclo │
   │ falha           │          │ ────────────────────│    │ ────────────────── │
   │ Merge externo   │          │ Sem fallback        │    │ Sem KPI de tempo   │
   │ (api.pdfconv.)  │          │ Sem versão alterna  │    │ por prisma         │
   └─────────────────┘          └──────────────────────┘    └────────────────────┘
                          ╲              │               ╱
                           ╲             │              ╱
                            ╲            ▼             ╱
                             ╲                        ╱
                              ─────────[PROBLEMA]──────
                                      2h12 de
                                separação manual
                              ─────────────────────────
                             ╱                        ╲
                            ╱            ▲             ╲
                           ╱             │              ╲
                          ╱              │               ╲
   ┌─────────────────┐          ┌──────────────────────┐    ┌────────────────────┐
   │ Operador sem    │          │ Excel não tem        │    │ Ambiente não       │
   │ visibilidade do │          │ ponteiro útil para   │    │ permite RPA atual  │
   │ status fiscal   │          │ o PDF físico         │    │ (sem Premium, sem  │
   │ ────────────────│          │ ────────────────────│    │  DBA, sem API)     │
   │ Treinamento     │          │ PDFs vêm do SYNCHRO │    └────────────────────┘
   │ centrado na     │          │ sem nome estável    │
   │ separação       │          │                      │
   │ manual          │          │                      │
   └─────────────────┘          └──────────────────────┘
       MÃO DE OBRA                   MATERIAL                MEIO AMBIENTE
```

## 3. Causas mapeadas por categoria

| Categoria (6M) | Causas |
|---|---|
| **Método** | Macro VBA como ponto único de falha; merge via serviço externo (`api.pdfconverted.com`); processo dependente de Excel + e-mail |
| **Máquina** | Macro quebrada após atualização do SYNCHRO; sem fallback; sem versionamento |
| **Medição** | Sem trilha de auditoria; sem KPI de tempo por prisma; sem rastreio de falhas |
| **Mão de obra** | Operador sem visibilidade do status fiscal em tempo real; treinamento centrado no manual; sem alerta upstream |
| **Material** | PDFs do SYNCHRO sem identificador estável no nome; Excel sem ponteiro para o PDF; SUB_LOC potencialmente nulo |
| **Meio ambiente** | Restrições corporativas (sem Premium, sem DBA, sem API REST); ambiente Oracle EBS com policy context invisível ao Power BI |

## 4. 5 Porquês para o problema-foco

| # | Pergunta | Resposta |
|---|---|---|
| 1 | Por que os operadores gastam 2h12 separando manualmente? | Porque imprimem as NFs **fora de ordem** e precisam reorganizar fisicamente por prisma. |
| 2 | Por que imprimem fora de ordem? | Porque a saída do Bloco 3 (PDFs classificados) **não existe** — o ZIP gerado pela macro está vazio. |
| 3 | Por que o ZIP está vazio? | Porque a macro VBA que gerava os PDFs **quebrou após uma atualização do SYNCHRO** e ninguém conseguiu corrigi-la. |
| 4 | Por que não conseguiram corrigir? | Porque a macro depende da integração com o SYNCHRO antigo (anterior ao update) e dependia de um merge externo (`api.pdfconverted.com`); a parte que falhou está acoplada ao layout antigo do SYNCHRO. |
| 5 | Por que a expedição depende de uma macro frágil? | Porque o processo nunca foi desenhado com tolerância a falha: 1 ponto único (macro), sem dashboard de monitoramento, sem alternativa de classificação automática, sem trilha de auditoria. |

## 5. Causa-raiz priorizada

**Causa-raiz #1:** O processo de classificação dos PDFs está acoplado a um ponto único de falha (macro VBA + merge externo) sem alternativa nem monitoramento.

**Causa-raiz #2 (associada):** A camada de dados (queries Oracle) não foi desenhada para ser consumida programaticamente por ferramentas modernas (Power BI / Power Automate) — depende de contexto de sessão EBS, tem campos polissêmicos, listas hardcoded e ausência de tipagem estável.

## 6. Como o TO-BE ataca cada causa-raiz

| Causa-raiz | Como o TO-BE Fase 1 ataca |
|---|---|
| Ponto único de falha (macro) | Power Automate Cloud classifica os PDFs de forma idempotente; ciclos são auditados via SharePoint List |
| Merge externo (compliance) | Eliminado — pasta por prisma + "imprimir tudo da pasta" dispensa arquivo único merged |
| Sem dashboard | Power BI Pro com aba operacional substitui a Pt.1 manual |
| Query acoplada a contexto EBS | Opção D — ingere as tabelas-base via dataflow; lógica replicada no dataset (M/DAX) |
| Sem identificador estável do PDF | Premissa de validação: chave de acesso no nome (confirmação na Coleta de Dados) |
| Sem trilha de auditoria | SharePoint Lists `EXP_CICLOS_LOG` e `EXP_FALHAS_LOG` |

Detalhe do plano em `04_Improve/08_Plano_de_Acao.md`.
