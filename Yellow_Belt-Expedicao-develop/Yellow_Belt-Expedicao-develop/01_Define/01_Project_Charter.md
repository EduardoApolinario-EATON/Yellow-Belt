# Project Charter — Redução de retrabalho na expedição

> Carta do projeto Yellow Belt. Consolida problema, objetivos, escopo, time, cronograma e premissas.
> Última atualização: 2026-05-28

## 1. Título

Redução de retrabalho no processo de expedição por meio da melhoria na geração e organização de documentos fiscais.

## 2. Contexto

No processo de expedição da Eaton Valinhos, após o faturamento dos pedidos, são executadas queries no Oracle EBS que geram um arquivo Excel com as informações das Notas Fiscais (NFs). Esse arquivo deveria alimentar uma macro VBA que gerava os arquivos PDF organizados por prisma, permitindo a impressão na sequência correta de separação física.

Após uma atualização do SYNCHRO, a macro parou de gerar os PDFs (a pasta ZIP de saída fica vazia). O Excel continua sendo gerado normalmente. Como consequência, o time da expedição imprime as notas fora de ordem e realiza a separação manual por prisma — gerando ~2h12min de retrabalho por ciclo de faturamento, sobre um volume médio de 350 NFs.

## 3. Declaração do problema

O processo de expedição apresenta falha na geração automática de PDFs classificados das Notas Fiscais. A equipe imprime as notas sem ordenação e separa manualmente por prisma, consumindo ~2h12min por ciclo, com risco de erro humano e atraso no embarque.

## 4. Impacto

| Dimensão | Valor atual |
|---|---|
| Tempo total do ciclo de expedição | ~4h |
| Tempo de separação manual por prisma | ~2h12min (~55% do ciclo) |
| Volume médio | 350 NFs/ciclo |
| Risco operacional | Erro de separação física, atraso de embarque |
| Risco de compliance | Uso de serviço externo (`api.pdfconverted.com`) para merge de PDFs reais (ver `01_Define/02_Justificativa.md`) |

## 5. Objetivos SMART

| # | Objetivo | Métrica | Meta | Prazo |
|---|---|---|---|---|
| O1 | Eliminar a separação manual por prisma | Tempo de separação física | de ~2h12 → 0 | Encerramento do projeto |
| O2 | Garantir 100% das NFs disponíveis em PDF organizado por prisma | % NFs classificadas automaticamente | ≥ 99% | Encerramento do projeto |
| O3 | Substituir a Query Pt.1 manual por dashboard de monitoramento | Tempo de validação fiscal | ≤ 5 min | Fim da Fase Improve |
| O4 | Reduzir o ciclo total da expedição | Tempo total por ciclo | de ~4h → ~1h15 (-70%) | Encerramento do projeto |

## 6. Indicadores

- **Lead Time do ciclo de expedição** (min/ciclo)
- **Tempo de separação por prisma** (min/ciclo)
- **% NFs classificadas automaticamente** (cobertura)
- **Taxa de falha de classificação** (PDFs não pareados / total)
- **Volume diário de NFs** (controle de variabilidade)

Os valores AS-IS detalhados estão em `02_Measure/01_Baseline_AS_IS.md`. O plano de medição contínua está em `05_Control/01_Plano_de_Controle.md`.

## 7. Escopo

**Dentro do escopo (Fase 1):**
- Reescrita da lógica das 3 queries Oracle contra tabelas-base (Opção D), ingeridas via dataflow e consolidadas no dataset (M/DAX)
- Modelo semântico no Power BI Pro (Import) consolidando elegibilidade fiscal, classificação e dados de impressão
- Dashboard operacional Power BI para monitoramento (substitui a Pt.1 manual)
- Fluxo Power Automate Cloud (Free) para classificar PDFs em pastas por prisma
- Estratégia para obtenção dos PDFs do SYNCHRO em dois caminhos paralelos (manual + RPA Power Automate Desktop)
- Estrutura de auditoria mínima (SharePoint Lists de ciclos e falhas)

**Fora do escopo (Fase 2 / futuro):**
- Materialização no Oracle / criação de tabelas / jobs / acesso DBA
- Power Automate Premium / conector Oracle nativo
- Qualquer integração via API REST / HTTP institucional
- Universal Print / impressão totalmente automática
- Mudança no processo de faturamento

Detalhamento completo em `03_Escopo_e_Premissas.md`.

## 8. Time e papéis

| Papel | Pessoa |
|---|---|
| Yellow Belt (líder) | Eduardo Apolinario |
| Patrocinador / chefe direto | (a confirmar — dono do orquestrador Power BI) |
| Mentor YB | (a confirmar) |
| Apoio técnico (sugestão de RPA) | Andre Apparecido |
| Operação expedição | Everton Muralhes, Leandro M Silva, Leandro H Silva, Irisnaldo Oliveira |
| Interlocutores externos | Time Fiscal, TI/EBS, Suporte SYNCHRO, Billing, PCP/Logística |

Detalhamento em `05_Time_e_Stakeholders.md`.

## 9. Cronograma DMAIC

| Fase | Status | Saída esperada |
|---|---|---|
| Define | ✅ Concluída | Charter + escopo + time |
| Measure | 🟡 Em andamento | Baseline AS-IS quantificado, 5 dias de coleta |
| Analyze | ✅ Concluída (estrutural) | Análise das 3 queries + restrição Power BI + opções A/B/C/D |
| Improve | ⬜ Próxima | Dataflow + dataset (lógica refatorada) + dashboard + fluxo Power Automate + classificação por prisma |
| Control | ⬜ Pendente | Plano de controle + manual do operador + auditoria lite |

## 10. Premissas

- O Power BI Pro está disponível para o YB e suporta dataflows de ingestão + dataset em modo Import.
- O Power Automate Cloud Free possui as ações "Run a query against a dataset" e "Refresh a dataset" do conector Power BI (já confirmado pelo YB).
- O conector Power BI no Power Automate é gated pela licença Power BI Pro, não por Power Automate Premium.
- SharePoint Online está disponível como destino dos PDFs e das Lists de auditoria.
- A operação aceita testar fora do horário crítico (sem interromper expedição).

## 11. Restrições firmes (não negociáveis na Fase 1)

- Sem DBA / sem criação de objetos no Oracle (tabela materializada, jobs, procedures).
- Sem Power Automate Premium / sem conector Oracle nativo.
- **Sem qualquer integração via API REST / HTTP institucional** — o YB não tem acesso a APIs (SYNCHRO ou externas).
- Stack permitido: Power BI Pro + Power Automate Cloud Free + Power Automate Desktop (para SYNCHRO) + M365 (SharePoint, Excel Online, Outlook, Teams).

## 12. Riscos macro

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Reescrita contra tabelas-base não passar nos testes de paridade (Opção D inviável) | Média | Alto | Plano B: pedir TI um view "achatado" sem policy context |
| PDFs do SYNCHRO não terem identificador estável (chave de acesso no nome) | Média | Alto | OCR via Power Automate Desktop ou padronizar nome na origem |
| Operador sem acesso ao SharePoint na máquina | Baixa | Médio | OneDrive Sync ou pasta de rede como alternativa |
| Macro antiga não disponível para engenharia reversa | Baixa | Médio | Recorrer ao time Fiscal para regras críticas |

## 13. Justificativa

Resumo curto em `02_Justificativa.md`. Razão central: o retrabalho de separação manual consome >50% do ciclo de expedição, gera risco de erro físico e expõe a empresa a um risco de compliance hoje invisível (uso de serviço externo gratuito para merge de PDFs fiscais).

## 14. Aprovação

| Papel | Nome | Data | Assinatura |
|---|---|---|---|
| Yellow Belt | Eduardo Apolinario | 2026-05-28 | — |
| Patrocinador | (a confirmar) | | |
| Mentor YB | (a confirmar) | | |
