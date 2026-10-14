# Auditoria Lite

> **Revisão: 2026-10-14.** Critérios atuais de trilha e reconciliação; implementação dos logs/controles propostos e retenção precisam de confirmação. O roteiro antigo não comprova auditoria implantada.

## Trilha mínima de uma rodada

Registrar operador, ambiente/versão, rodada, filtros, horário/ID de execução, chaves esperadas e arquivos presentes. Reconciliar cada chave com decisão do modelo, nome/destino efetivo, registro em NFS_IMPRESSAS e conferência de impressão física. Separar rejeitado, sem PDF, processado, impresso e pendente; esses estados não são todos colunas já implementadas.

Notas de reimpressão: autorização, motivo e lote afetado; não apagar chave do histórico como substituto de trilha. Registrar falhas parciais e retries. DataImpressao é nome de campo, não comprovação automática de spooler. Definir unicidade, retenção, acesso e restauração com TI/Compliance.

Guardar documentos fiscais em canal restrito. Nenhuma nota real é necessária em issue pública. Ver [P06/P07/P15/P16](../03_Analyze/07_Open_Questions.md), [Checklist](../04_Improve/05_Implementacao/02_Checklist.md) e [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md).

## Roteiro histórico

> Como as SharePoint Lists `EXP_CICLOS_LOG` e `EXP_FALHAS_LOG` registram o que aconteceu.
> Última atualização: 2026-05-28

## 1. Escopo

"Lite" significa: trilha mínima para responder "o que rodou, quando, com que sucesso, e o que falhou". Não substitui auditoria fiscal — substitui a **ausência total** de trilha que existe no AS-IS.

## 2. EXP_CICLOS_LOG

Uma linha por ciclo do classificador.

| Campo | Quando preenchido | Por quem |
|---|---|---|
| `Ciclo_ID` | Início do fluxo | Power Automate (variável inicial) |
| `Inicio` | Início do fluxo | Power Automate |
| `Fim` | Fim do fluxo | Power Automate |
| `Total_NFs` | Após filtro | Power Automate |
| `Total_Classificadas` | No fim do loop | Power Automate (contador) |
| `Total_Falhas` | No fim do loop | Power Automate (contador) |
| `Status` | No fim | OK se Falhas = 0; OK_COM_FALHAS se 0 < Falhas < Total; ERRO se Falhas = Total ou exceção |
| `Link_Pasta` | Após criar pasta do ciclo | Power Automate |
| `Operador` | No trigger manual | Power Automate (`triggerOutputs()?['headers']?['x-ms-user-name']`) |
| `Origem_PDFs` | Manual ou config | Caminho_A / Caminho_B |

## 3. EXP_FALHAS_LOG

Uma linha por PDF que falhou na classificação.

| Campo | Função |
|---|---|
| `Ciclo_ID` | FK para o ciclo |
| `Arquivo_PDF` | Nome original |
| `Motivo` | NF_NAO_ENCONTRADA / ERRO_MOVER / SUB_LOC_NULO / OUTRO |
| `Data` | Timestamp |
| `Detalhe` | Mensagem do erro (capturada do `Apply to each` via `Run after = has failed`) |

## 4. Como o operador usa

| Situação | Onde olhar | Ação |
|---|---|---|
| Notificação Teams diz "X falhas" | Abrir `/_falhas/` da pasta do ciclo | Investigar PDFs listados |
| Quer histórico do dia | Power BI aba Gestão | Filtrar por hoje |
| Quer reprocessar um ciclo | Apagar pasta do ciclo + redepositar PDFs em `/INPUT/PDFs/` + acionar trigger | Manual |

## 5. Como o supervisor / Eduardo usam

| Situação | Onde olhar |
|---|---|
| Tendência semanal | Power BI aba Gestão |
| Auditoria de um ciclo específico | EXP_CICLOS_LOG com filtro Ciclo_ID |
| Padrão de falha recorrente | Top motivos em EXP_FALHAS_LOG |
| Performance do fluxo | Power Automate Analytics (separado das Lists) |

## 6. Retenção

| List | Retenção sugerida |
|---|---|
| `EXP_NF_DATASET` | 7 dias (rolling) — é snapshot operacional |
| `EXP_CICLOS_LOG` | 1 ano (auditoria) |
| `EXP_FALHAS_LOG` | 1 ano (auditoria) |

Limpeza pode ser feita por um fluxo Power Automate agendado semanal (delete onde `Inicio < addDays(utcNow(),-365)`).

## 7. O que esta auditoria não cobre

- Mudanças no schema do dataset.
- Quem alterou regras de classificação (fica no histórico do repo Git).
- Atos de impressão física (depende do Windows / impressora).
- Auditoria fiscal completa (continua no SYNCHRO/Oracle).
