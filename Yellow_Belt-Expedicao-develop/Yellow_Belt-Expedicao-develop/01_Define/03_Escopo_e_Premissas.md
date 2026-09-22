# Escopo e Premissas

> Detalha o que está dentro e fora do escopo da Fase 1, restrições firmes e premissas técnicas/operacionais.
> Última atualização: 2026-05-28

## 1. Escopo da Fase 1

### 1.1 Dentro do escopo

| Item | Detalhe |
|---|---|
| Replicação da lógica | Replicar a lógica das 3 queries (Pt.1, Pt.2 Óleo, Revisada) contra as **tabelas-base** do Oracle (Opção D), substituindo as views `_BR_V`, em Power Query (M) e DAX |
| Modelo Power BI | Dataflow de ingestão das tabelas-base → dataset no Power BI Pro (modo Import); lógica em M/DAX |
| Dashboard operacional | Substitui a Pt.1 manual: funil de status fiscal, NFs aptas, tempo aguardando, distribuição por prisma |
| Carregamento SharePoint | Power Automate Cloud lê o dataset via "Run a query against a dataset" (DAX) e popula uma SharePoint List |
| Classificação dos PDFs | Power Automate Cloud cruza PDF (nome com chave de acesso) × Lista (NF → SUB_LOC) e move cada PDF para `/ciclos/<id>/prisma_<SUB_LOC>/` |
| Download dos PDFs do SYNCHRO | Dois caminhos paralelos: (A) Power Automate Desktop substituindo a macro antiga, (B) download manual pelo time de faturamento como fallback |
| Auditoria lite | SharePoint Lists `EXP_CICLOS_LOG` e `EXP_FALHAS_LOG` |
| Manual do operador | 1 página com os passos no TO-BE |

### 1.2 Fora do escopo (Fase 2 / futuro)

- Materialização no Oracle (tabela física, jobs Oracle, procedures) — exige DBA.
- Power Automate Premium / conector Oracle nativo.
- **Qualquer integração via API REST / HTTP institucional** (SYNCHRO, serviços externos) — o YB não tem acesso a APIs.
- Universal Print / impressão totalmente automática (sem clique do operador).
- Mudanças no processo de faturamento ou na operação fiscal upstream.
- Substituição do SYNCHRO ou alteração de sua configuração.

## 2. Restrições firmes (não negociáveis na Fase 1)

| # | Restrição | Razão |
|---|---|---|
| R1 | Sem DBA / sem objetos novos no Oracle | Não há acesso DBA para o YB |
| R2 | Sem Power Automate Premium | Sem licença disponível para o projeto |
| R3 | Sem API REST/HTTP institucional | YB não tem credenciais nem acesso a APIs corporativas (SYNCHRO inclusive) |
| R4 | Sem interrupção da expedição em testes | Operação 24/7 não pode parar |
| R5 | Soluções devem priorizar baixo risco operacional | Falha do projeto não pode parar embarques |
| R6 | Automações fora do Power Automate não são aceitas como entrega oficial | Padrão corporativo |

## 3. Recursos disponíveis

| Recurso | Status |
|---|---|
| Acesso de leitura ao Oracle para rodar queries | ✅ |
| Power BI Pro (licença Eduardo) | ✅ |
| Power Automate Cloud Free (conectores Standard) | ✅ |
| Conector Power BI no Power Automate (ações "Run a query against a dataset" e "Refresh a dataset") | ✅ (gated pelo Power BI Pro, não pelo Power Automate Premium) |
| Power Automate Desktop (Windows 10/11) — ação "Invoke web service" inclusa | ✅ (gratuito, instalado por TI) |
| SharePoint Online / OneDrive corporativo | ✅ |
| Outlook + Teams | ✅ |
| Excel Online | ✅ |
| DBA / criação de tabelas e jobs no Oracle | ❌ |
| Power Automate Premium | ❌ |
| Acesso direto ao SYNCHRO via API | ❌ |

## 4. Premissas técnicas

| # | Premissa | Risco se falhar | Como validar |
|---|---|---|---|
| PT1 | A ingestão das tabelas-base (Opção D) roda no dataflow sem depender de policy context | Alto — Fase Improve não inicia | Teste de paridade row-by-row vs views (ver `03_Analyze/06_Restricao_PowerBI_Views.md` §5) |
| PT2 | O usuário de banco usado pelo Power BI tem `SELECT` direto nas tabelas-base | Alto | Confirmar com TI/EBS (pergunta 7.10) |
| PT3 | O nome do PDF baixado do SYNCHRO contém a chave de acesso de 44 dígitos | Médio | Inspecionar amostra de PDFs do ciclo atual (pergunta 8.3) |
| PT4 | `SUB_LOC` está populado em ≥ 99% das NFs do ciclo | Médio | Auditoria de 5 dias na Coleta de Dados (pergunta 8.4) |
| PT5 | A diferença entre nota mãe e vide nota é derivável dos campos Oracle | Médio | Conferir com Fiscal (pergunta 8.1) |
| PT6 | Volume de PDFs por ciclo (≤ 500) cabe no limite de 6000 actions/dia do Power Automate Free | Baixo | Cálculo: 350 NFs × 10 actions = 3.500/dia |

## 5. Premissas operacionais

| # | Premissa | Validação |
|---|---|---|
| PO1 | A operação aceita testar o fluxo em paralelo ao atual antes de cortar a macro definitivamente | Acordo com supervisão |
| PO2 | Operadores têm acesso ao SharePoint a partir da estação de trabalho de expedição | Pergunta 5 do Fluxo_TO_BE — a confirmar |
| PO3 | Os ciclos de faturamento têm um padrão razoavelmente previsível (1–4/dia) | Coleta de Dados (5 dias) |
| PO4 | A organização física por prisma é a chave de agrupamento real (não LPN puro nem delivery) | Pergunta 3.6 — a confirmar |

## 6. Dependências externas

| De quem | O que | Quando precisa |
|---|---|---|
| TI / EBS | Confirmar acesso direto às tabelas-base + lista de views vs tabelas | Antes de Improve |
| Time Fiscal | Validar regras de classificação (paga guia, prisma, nota mãe) | Antes de Improve |
| Suporte SYNCHRO | Padrão de nome dos PDFs e mecanismo atual de download | Antes do desenho de RPA |
| Andre Apparecido | Política corporativa para Power Automate Desktop / RPA | Antes de Caminho A |
| Patrocinador | Aprovação do charter e dos limites de escopo | Antes de Measure final |

## 7. O que muda em relação ao processo atual

| Bloco | AS-IS | TO-BE Fase 1 |
|---|---|---|
| Validação fiscal | Roda Pt.1 manual em Oracle, lê resultado | Dashboard Power BI consumido visualmente |
| Geração do pacote | Macro VBA → falha → merge via serviço externo | Power Automate classifica PDFs por prisma em pastas SharePoint |
| Separação física por prisma | Manual (~2h12) | Eliminada — operador abre a pasta pronta |
| Auditoria | Inexistente (sem trilha) | SharePoint Lists com ciclo e falhas |
