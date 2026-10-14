# Time e Stakeholders

> **Revisão documental: 2026-10-14.** A lista original é histórica; nomes, disponibilidade e atribuições individuais precisam de reconfirmação. Não presumir que o autor continuará como único suporte.

## Responsabilidade operacional por papel

Expedição: rodada, conferência e impressão. Supervisor: autorização de rotina/reimpressão e escalonamento. Fiscal: regras, guia e liberação. Armazém: delivery e localização. BI/Dados: modelo, origens e refresh. Automação/TI: fluxos, conexões, acesso, incidentes e recuperação. Plataforma/Compliance: licenças, DLP e retenção.

Titular, substituto e canal de contato de cada papel: **a confirmar**. Formalizar aceite e transferência no [Handoff](../04_Improve/05_Implementacao/HANDOFF.md) e no [Manual do Operador](../05_Control/05_Manual_Operador.md).

## Time registrado originalmente

> Mapeia papéis no projeto e interlocutores por área para resolver pendências.
> Última atualização: 2026-05-28

## 1. Time do projeto (núcleo)

| Papel | Pessoa | Responsabilidade no projeto |
|---|---|---|
| Yellow Belt (líder) | Eduardo Apolinario | Conduz DMAIC, refatora queries, constrói dataset Power BI, fluxos Power Automate, documenta |
| Sponsor / Gerente direto | Andre Apparecido | Aprova escopo, libera tempo, valida alinhamento estratégico |
| Mentor | Everton Muralhes | Revisa entregáveis DMAIC, garante rigor metodológico |
| Apoio técnico | Andre Apparecido | Orienta escolha de ferramentas, valida arquitetura |

## 2. Time da operação (expedição)

| Pessoa | Função | Como contribui |
|---|---|---|
| Lenadro M Silva | Expedição | Supervisor, valida fluxo TO-BE |
| Erica Oliveira | Expedição | Operação atual, valida fluxo TO-BE |
| Irisnaldo Oliveira | Expedição | Operação atual, valida fluxo TO-BE |

## 3. Interlocutores externos (por área)

Cada área tem perguntas pendentes mapeadas em `03_Analyze/07_Open_Questions.md`. Use esta tabela para identificar com quem falar antes de avançar na Fase Improve.

| Área | Função no projeto | Perguntas que respondem | Quando acionar |
|---|---|---|---|
| **Time Fiscal** | Confirma regras hardcoded nas queries (VESPOR, ICMS_ST, inscrições UF, SLAs) | Bloco 1 (1.1–1.7) | Antes de refatorar queries |
| **TI / Suporte Oracle EBS** | Parâmetros técnicos da integração (ORG_ID, WAREHOUSE_ID, batch sources, gateway, índices) | Bloco 2 (2.1–2.9) + Bloco 7 (7.9–7.11 prioritários) | Bloqueante para Opção D |
| **Supervisor / Coordenador Expedição** | Valida o lado operacional (frequência de ciclos, regras de prisma, exceções) | Bloco 3 (3.1–3.8) | Antes de validar fluxo TO-BE |
| **Billing** | Hoje recebe Excel da query — define se continua precisando | Bloco 4 (4.1–4.3) | Durante desenho do TO-BE |
| **PCP / Logística** | Estrutura física (prismas ativos, óleo, embreagem DSH, aéreo/rodoviário) | Bloco 5 (5.1–5.4) | Antes da classificação automática |
| **Andre Apparecido** | Stack técnico, licenças, gateway, política RPA | Bloco 6 (6.1–6.5) | Bloqueante para Caminho A do SYNCHRO |
| **Suporte SYNCHRO** | Como obter PDFs (API, pasta de rede, BLOB), padrão de nome, integração antiga | Bloco 8 (8.2, 8.3, 8.6–8.9) | Bloqueante para download dos PDFs |
| **Compliance / Legal / Segurança** | Avaliar uso atual de `api.pdfconverted.com` | Bloco 8 (8.10) | Antes de migrar (ou para parar imediatamente) |

## 4. Matriz RACI resumida

| Atividade | YB | Patrocinador | Mentor | TI | Fiscal | Operação |
|---|---|---|---|---|---|---|
| Refatorar queries | **R/A** | I | C | C | C | — |
| Construir dataset Power BI | **R/A** | I | C | C | — | — |
| Construir fluxos Power Automate | **R/A** | I | C | C | — | — |
| Validar regras fiscais | C | I | I | — | **R/A** | — |
| Validar fluxo operacional | C | I | I | — | — | **R/A** |
| Aprovar charter / escopo | C | **R/A** | C | — | — | — |
| Aprovar entregas DMAIC | C | C | **R/A** | — | — | — |
| Liberar acesso técnico (banco, gateway, RPA) | C | I | — | **R/A** | — | — |

R = Responsible, A = Accountable, C = Consulted, I = Informed.

## 5. Cadência de alinhamentos sugerida

| Reunião | Frequência | Participantes |
|---|---|---|
| Status YB com mentor | Semanal | Eduardo + Mentor |
| Revisão com patrocinador | Quinzenal | Eduardo + Chefe |
| Alinhamento operacional | Sob demanda | Eduardo + Supervisor + 1 operador |
| Bloqueios técnicos | Sob demanda | Eduardo + Andre / TI |

## 6. Como esta lista evolui

Conforme nomes forem confirmados (patrocinador, mentor, interlocutores nominais por área), atualizar aqui. A lista atual reflete o estado em 2026-05-28; campos com "a confirmar" são pendências reais do projeto.
