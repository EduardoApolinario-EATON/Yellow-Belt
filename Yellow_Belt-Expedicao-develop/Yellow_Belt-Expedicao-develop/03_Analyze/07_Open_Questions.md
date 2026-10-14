# Open Questions — Pendências para Resolver

> **Registro vigente: 2026-10-14.** Substitui a priorização de junho no anexo. Não considerar funcionalidades já confirmadas como bloqueios de viabilidade; o foco atual é homologação, continuidade e entrega operacional.

## Confirmado nesta revisão

- Dataset é cópia atual; fonte oficial permanece no orquestrador `mobility-powerbi-architecture`.
- Power BI e os botões de atualização do modelo, paga guias e processamento de PDFs funcionam, conforme responsável.
- O processamento classifica PDFs em pastas SharePoint conforme a ordem da Lista de Impressão.
- Entrega documental solicitada apenas em Markdown; informações operacionais ausentes devem ficar a confirmar.

## Pendências de entrega e transferência

Todas as linhas abaixo estão **a confirmar**. O papel indicado é sugestão de responsabilidade, não nomeação de pessoa. Prazo e aprovador devem ser preenchidos na homologação.

| ID | Prioridade | Informação / evidência necessária | Papel | Critério de fechamento |
|---|---|---|---|---|
| P01 | Antes da rotina liberada | Ambiente autorizado, link do relatório e status produção/piloto | BI + supervisor | Acesso validado e ambiente registrado |
| P02 | Antes da rotina liberada | Caminhos de PDFs, biblioteca, entrada, destinos e identificação de rodada | Automação + Expedição | Um ciclo acompanhado com origem/destino por chave |
| P03 | Antes da rotina liberada | Export dos fluxos e mapeamento dos quatro visuais | Automação | Três fluxos funcionais identificados; teste segregado |
| P04 | Antes da rotina liberada | Universo consultado pelo fluxo e efeito dos filtros do relatório | Automação + BI | Teste demonstra exatamente quais chaves são processadas |
| P05 | Antes da rotina liberada | Procedimento do botão Paga Guia: entrada, saída, destinatários, retorno e liberação | Fiscal + Automação | Runbook aprovado sem pressupor pagamento automático |
| P06 | Antes da rotina liberada | Bloqueio de duplicação, chave única, concorrência e falha parcial | Automação + TI | Duplo clique/retry não gera duplicação não autorizada |
| P07 | Antes da rotina liberada | Momento da gravação em NFS_IMPRESSAS e evidência de impressão física | Automação + Expedição | Processado e impresso distinguíveis e reconciliáveis |
| P08 | Antes da rotina liberada | Método e ordem de impressão; reimpressão autorizada | Expedição + TI | Lote de teste e recuperação de interrupção aprovados |
| P09 | Antes da rotina liberada | Aptidão, guia com nota não apta, mãe/filha, prisma ausente e múltiplos locators | Fiscal + Armazém | Casos de aceite documentados e aprovados |
| P10 | Antes da rotina liberada | Contatos titulares/substitutos e canal de incidente | TI + supervisor | Escalonamento testado e contatos preenchidos |
| P11 | Continuidade técnica | Refresh real de cada origem, encadeamento, janelas e DaysText upstream | Dados/orquestrador | Horários e dependências registrados; origem antes do modelo |
| P12 | Continuidade técnica | Permissões, contas de conexão, licenças, limites API/refresh e DLP | TI/plataforma | Validação no tenant e substituto de proprietário |
| P13 | Continuidade técnica | CNPJ de filial, validação fiscal de chave e vigência de impostos | Fiscal + Dados | Regras aceitas ou lacunas com tratamento aprovado |
| P14 | Continuidade técnica | Fuso CREATION_DATE, filtros de faturamento e recorte 45 dias WSH | Dados | Amostra por horário/data e cobertura comprovadas |
| P15 | Continuidade técnica | Backup, restauração, publicação e rollback no oficial | TI/BI | Recuperação testada incluindo efeitos externos |
| P16 | Continuidade técnica | Guarda/limpeza de PDFs, logs e histórico; acesso a dados fiscais | TI + Compliance | Política aprovada sem destruir memória de processamento |
| P17 | Medição | Baseline aprovado, volume/cadência e ganhos observados | Yellow Belt + supervisor | Amostra, período, fonte, método e aprovação registrados |
| P18 | Rotinas adicionais | Download SYNCHRO, comando *DN e etiquetas | Expedição + TI | Procedimentos acompanhados; não inferidos do nome da página |
| P19 | SLA | Tempos esperados e limiares de suporte/refresh/fiscal | Gestores de cada serviço | Valores aprovados e medição disponível |

## Lacunas técnicas observadas

O modelo não valida DV/dígitos da chave; CNPJ não garante filial/14 dígitos; não implementa categoria EMBREAGEM_DSH; Qtd Excecoes sobrepõe guia; NFS_IMPRESSAS é Import; auxiliar MesmaNF_OutroLocator é vazia. São fatos do código, não decisões automáticas de correção. Aceitar ou corrigir cada lacuna no artefato oficial com negócio e TI.

Não modificar fluxos ou regras fiscais nesta revisão documental. Materiais binários antigos, exemplos e testes offline não comprovam a versão operacional atual. PDFs de manuais não foram regenerados.

## Protocolo de aprovação

Para cada Pxx registrar resposta, evidência restrita, ambiente/versão, aprovador, data e tratamento de risco. Encerrar treinamento e transferência apenas após os itens de rotina liberada; pendências restantes precisam de responsável e prazo aceitos.

Referências: [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md), [Manual do Operador](../05_Control/05_Manual_Operador.md), [Checklist](../04_Improve/05_Implementacao/02_Checklist.md).

<details>
<summary>Perguntas e decisões históricas de junho/2026: não representam o estado atual</summary>

> Perguntas críticas para a implementação Opção D: Power BI Pro (dataflow de ingestão → dataset) + Power Automate Free + OneDrive/SharePoint.
> Última atualização: 2026-06-23

---

## Ordem de abordagem

As perguntas estão organizadas por **bloqueante → necessário → nice-to-have**.
Marque ✅ quando responder.

---

## 🔴 BLOQUEANTES — Sem resposta, projeto não sai do papel

### 1. Sistema de Bips / WMS (Operação + TI)

> **Resposta parcial (2026-06-23):** a operação roda em **Oracle EBS R12** e os bips são feitos por **coletores RF (handhelds)** escaneando as etiquetas dos LPNs — ou seja, via **Oracle MSCA (Mobile Supply Chain Applications)**, a interface mobile do EBS. Logo, os bips caem no **mesmo banco Oracle** de onde sai o dataset (módulos WMS/Inventory + Shipping/`WSH.*`), e não em sistema externo. Isso simplifica o trigger: pode ser **Oracle-based** (consulta à mesma base), sem depender de API/conector Premium.

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **9.4** | **Como o sistema sabe quando "todos os bips foram feitos"?** Opções: (a) operador clica botão "Ciclo pronto", (b) horário fixo (ex: sempre 14h), (c) automático após silêncio de X min. | Define o gatilho para Power Automate disparar as queries e classificador. Crítico para saber se operador tem ação a mais ou se é automático. | ⬜ | |
| 9.1 | Qual é o nome/sistema que registra os bips? | Define como Power Automate vai obter trigger/dados. | ✅ | **Oracle EBS R12 via coletores RF (MSCA)** — mesma base do dataset. |
| 9.2 | Onde os dados de bips são armazenados? (Oracle? API? Arquivo?) | Pré-requisito para integração. | 🟡 | **Oracle EBS R12.** Falta confirmar a **tabela/coluna exata** do evento de bip (candidatas: `WSH_DELIVERY_DETAILS.RELEASED_STATUS`, `MTL_MATERIAL_TRANSACTIONS`, tabelas `WMS_*`/LPN). |
| 9.5 | Qual transação MSCA o coletor executa no bip — **Pick Confirm / LPN Pack / Staging Move** — e qual **timestamp** marca o bip de cada LPN? | Define a coluna usada para detectar "ciclo pronto" (opção 9.4c) e ligar o bip ao `SUB_LOC`. | ⬜ | |

### 2. Acesso Power BI às tabelas-base Oracle (TI + Suporte EBS)

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **7.10** | **O usuário de banco usado pelo Power BI tem permissão SELECT nas tabelas-base** (`RA_CUSTOMER_TRX_ALL`, `JL_BR_AR_*`, `HZ_PARTIES`, `WSH.*`, etc.)? | Sem acesso, a Opção D não funciona — o dataflow não consegue ingerir as tabelas-base. | ⬜ | |
| **7.9** | **Por que Power BI não consegue executar as views `_BR_V`?** Opções: (a) policy context/RLS exigido pela view, (b) Power BI não consegue acessar a lógica interna/JOINs da view, (c) sintaxe Oracle-specific não suportada, (d) combinação dos acima? | Valida se reescrever contra tabelas-base (Opção D) realmente resolve. Critério de sucesso: poder ingerir as tabelas-base (sem views) no dataflow com sucesso. | ⬜ | |
| 7.11 | Existe documentação interna do mapeamento view EBS → tabelas-base? | Reduz tempo de refatoração da query. | ⬜ | |

### 3. Obtenção de PDFs do SYNCHRO — piloto manual (Operação + SYNCHRO)

> **Decisão atual:** o piloto começa com **Opção A — download manual** (operador baixa do SYNCHRO → OneDrive/SharePoint, vide [`../04_Improve/06_RPA_Synchro/03_Decisao_e_Trigger.md`](../04_Improve/06_RPA_Synchro/03_Decisao_e_Trigger.md)). Só estas perguntas bloqueiam o piloto:

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **8.6** | **Como o operador baixa/exporta os DANFEs do SYNCHRO hoje?** É possível exportar em lote (ZIP)? E como o sistema antigo obtinha os PDFs — o que exatamente quebrou? | Confirma se a Opção A (download manual) é viável no dia a dia. | ⬜ | |
| **8.3** | **Identificador estável do PDF** (nome do arquivo, ID SYNCHRO, ou chave de acesso de 44 dígitos legível no conteúdo) para o Power Automate casar PDF ↔ NF? | Sem isso, o classificador não associa PDF à NF. | ⬜ | |

---

## 🟡 NECESSÁRIOS — Bloqueiam operação piloto, mas menos urgentes

### 4. Regras operacionais (Supervisor Expedição + Fiscal)

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **3.1** | **Frequência de ciclos por dia?** Tem horário fixo ou demand-driven? | Define cadência e agendamento do Power Automate. | ⬜ | |
| **3.6** | **A separação por prisma é a única forma** de agrupar fisicamente? Ou casos por LPN puro / delivery? | Define estrutura de pastas no TO-BE (`/prisma/...` vs outro). | ⬜ | |
| **3.7** | **Ordem dentro do prisma** (nota mãe acima, delivery menor→maior) tem exceções? | Confirma regras de ordenação para Power Automate. | ✅ | **Macro (sort final de impressão, ~linha 1183):** `GUIA` DESC → `SUB_LOC`/locator ASC → `DELIVERY` ASC → linha ASC. Sem exceções no código; a nota mãe fica acima por ser a 1ª ocorrência do par `NF+DELIVERY` (vides logo abaixo). |
| **8.1** | **Como distinguir nota mãe de vide nota?** Por `CT_REFERENCE` ou outro atributo? | Power Automate precisa replicar para ordenar PDFs corretamente. | ✅ | **Macro (M.1, ~linhas 745-752):** se o par `NF+DELIVERY` repete a linha anterior → é **VIDE** (filha, volume = 0); a 1ª ocorrência é a **nota mãe**. Dedup por `NF+DELIVERY+LOCATOR`. |
| 8.4 | **SUB_LOC está populado ≥99%?** Quando nulo, `GLOBAL_ATTRIBUTE19` cobre? | Validação obrigatória — é a chave de pasta. | ⬜ | |

### 5. Regras fiscais (Time Fiscal)

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **1.1** | **Regra Bloco 3** (cliente VESPOR + múltiplos pedidos = cancelar) ainda válida? | Se não, removemos. Se sim, fica regra no TO-BE. | ⬜ | |
| **1.6** | **SLA esperado para "delivery com erro"** que vai para fiscal? (5 dias? Teto ou média?) | Impacta tratamento de exceção. | ⬜ | |
| 1.4 | **Lista de 45 VAT_TAX_IDs** para ICMS_ST — está atualizada? | Hoje hardcoded; proposta = tabela de config. | 🟡 | **A lista (~46 IDs) está na query `QUERY_EXPEDICAO_REVISADA.sql`** (e os 10 IDs de FCP); o **valor** do ICMS_ST usa lookup dinâmico `XXBR8282_GFSS_TAX_ICMS_ST`. Falta só o Fiscal confirmar se os IDs hardcoded estão vigentes. |

### 5b. Lógica de Roteamento / Classificação (Supervisor Expedição + Fiscal)

> Define em qual pasta cada NF cai no Power Automate. Sem isso, o classificador não sabe separar `/PRONTO/`, `/AGUARDANDO_GUIA/`, exceções, etc.
> Cada NF precisa cair em **exatamente uma** pasta — por isso também precisamos da **ordem de precedência** entre as regras.

> **✅ Boa parte foi recuperada da macro legada** (linha 701 de `referencias/macro_antiga/Modulos_Macro.txt`). A macro roteia por uma matriz 2×2 de `CASE_RILA` (= `OK` ou não) × `STATUS` (= `FINALIZADO` ou não):
>
> | `CASE_RILA` | `STATUS` | Resultado |
> |---|---|---|
> | OK | FINALIZADO | **IMPRIME** (PRONTO) |
> | OK | ≠ FINALIZADO | ERRO NF → exceção |
> | ≠ OK | FINALIZADO | VERIFICAR DELIVERY → exceção |
> | ≠ OK | ≠ FINALIZADO | ERRO DELIVERY + ERRO NF → exceção |
>
> Pré-filtros da macro: `CANCELADO` → descartado; chave vazia/`VE_DE_ACESSO` → descartado; `NF+DELIVERY` repetido → agrupado (nota mãe). Detalhe em [`../04_Improve/01_PowerBI/04_Fluxo_Classificacao_Analise.md`](../04_Improve/01_PowerBI/04_Fluxo_Classificacao_Analise.md) §2.2.

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **R.1** | NFs com erro entram no piloto ou viram exceção? | Define se filtra ou cria pasta de exceção. | ✅ | **Macro:** só imprime `CASE_RILA=OK` **e** `STATUS=FINALIZADO`; o resto vira exceção (não imprime). |
| **R.3** | `DELIVERY_NAO_FINALIZADA` — qual lógica identifica? | Sem isso a pasta não funciona. | ✅ | **Macro:** é o caso `STATUS ≠ FINALIZADO` (com `CASE_RILA=OK` = "ERRO NF"). |
| **R.6** | Precedência das regras (NF cai em mais de uma)? | Garante 1 pasta por NF. | ✅ | **Macro:** descarta CANCELADO/chave inválida → depois PAGA_GUIA → depois matriz RILA×STATUS. |
| **R.7** | Lista de pastas/destinos do piloto? | Define estrutura de pastas. | 🟡 | **Macro:** PRONTO (imprime), PAGA_GUIA (branch próprio), Exceção (e-mail). Falta decidir se exceção vira **pasta** no TO-BE (vide R.9). |
| **R.4** | `CASE_RILA = 'VERF_RILA'` — ação? | Trata como exceção ou diferente? | 🟡 | **Macro** só testa `="OK"`; qualquer outro valor é "≠ OK" (exceção). Confirmar se `VERF_RILA` precisa tratamento próprio. |
| **R.2** | Status CONTINGÊNCIA (5) — imprime, segura ou roteia? | Granularidade de status. | ⬜ | (Para a macro é só "≠ FINALIZADO". Confirmar se basta o binário.) |
| **R.5** | `MOTIVO_BLOQUEIO` roteia ou é informativo? | Define se vira regra de pasta. | ⬜ | (Não aparece na matriz da macro.) |
| **R.8** | Há critério de roteamento fora da macro/queries? | Evita regra escondida. | ⬜ | |
| **R.9** | **No TO-BE, exceção vai para PASTA `/EXCECAO/...` ou mantém E-MAIL** (como a macro)? | Decisão de desenho nova — produto agora são PDFs, não e-mail. | ⬜ | |
| **R.10** | **Fluxo PAGA_GUIA — retorno ao fiscal:** (a) a NF paga-guia retorna ao **time fiscal** para emitir/pagar a GNRE antes de imprimir? (b) **quem/como sinaliza que a guia foi paga** (manual, status no Oracle, planilha)? (c) enquanto aguarda, ela **bloqueia o embarque do prisma inteiro** ou só dela? | A macro tira a paga-guia da fila e parqueia em `/AGUARDANDO GUIA/` até a guia voltar paga (controle hoje em `BANCO DE DADOS - PAGA GUIA.xlsb`). O **sinal de "guia paga"** é o gatilho que o Power Automate precisa para imprimir essas notas. | 🟡 | **Hipótese a validar:** estados da regra PAGA_GUIA exigem ICMS-ST por GNRE; a NF retorna ao fiscal, é paga, e só então é impressa em lote separado. |

### 6. Performance e infraestrutura (TI + Suporte EBS)

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| **2.8** | **Existe restrição de horário/janela** para rodar queries? (impacto em produção?) | Define agendamento do Power Automate. | ⬜ | |
| **2.9** | **Há índices em `TRX_DATE`** e nas chaves dos JOINs? | Valida performance da ingestão do dataflow e dos relacionamentos. | ⬜ | |
| 2.1 | `ORG_ID = 1344` é única ou há outras organizações? | Define se vira parâmetro ou valor fixo. | ⬜ | |

---

## 🟢 NICE-TO-HAVE — Bom ter, mas não bloqueiam início

### 6b. Investigação Opção B (RPA/API SYNCHRO) — futuro, não bloqueia piloto

> Estas perguntas só importam quando/se a operação migrar de Opção A (manual) para Opção B (automação). Critério de migração em [`../04_Improve/06_RPA_Synchro/03_Decisao_e_Trigger.md`](../04_Improve/06_RPA_Synchro/03_Decisao_e_Trigger.md).

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| 8.7 | **SYNCHRO expõe API REST** para obter DANFE a partir da chave de acesso? Se sim, qual endpoint? | Necessário para automação (Opção B). | ⬜ | |
| 8.8 | **SYNCHRO grava PDFs em pasta de rede** acessível por outros sistemas? Qual o padrão? (ex: `\\server\danfes\<ano>\<mes>\<chave>.pdf`) | Alternativa de automação (Opção B), se não houver API. | ⬜ | |

### 7. Detalhes adicionais

| # | Pergunta | Por que importa | Status | Resposta |
|---|---|---|---|---|
| 8.5 | **Timestamp autorização SEFAZ** tem coluna oficial ou é derivado? | Necessário para `MINUTOS_AGUARDANDO` no dashboard. | ⬜ | |
| 8.10 | **Risco compliance:** PDFs enviados para `api.pdfconverted.com`? Já foi avaliado por Compliance? | Argumento adicional para priorizar TO-BE. | ⬜ | |
| 3.2 | **Volume 350 NFs é estável?** Min/máx histórico? | Para fase Measure (variabilidade). | ⬜ | |
| 4.1 | **Excel de impressão ainda é necessário?** Ou dashboard substitui? | Define se continua sendo entrega obrigatória. | ⬜ | |

---

## Observações

- ~~Opções A, B, C~~ — descartadas (vide seção 7 antigo)
- ~~Perguntas sobre Premium/Gateway~~ — não se aplicam à Opção D
- **Foco:** Opção D (tabelas-base) + Power Automate Free + OneDrive/SharePoint

> ⚠️ **Cuidado com a nomenclatura (dois eixos diferentes):**
> - **Opção A/B/C/D** = forma de o **Power BI acessar o Oracle**. Escolhida: **Opção D** (tabelas-base).
> - **Opção A/B** = forma de **obter os PDFs do SYNCHRO**. Escolhida para o piloto: **Opção A** (download manual); **Opção B** (RPA/API) é futuro.

---

## Priorização de reuniões sugerida

1. **9.4 + 9.1 + 9.2** → Supervisor/Operação (sistema de bips)
2. **7.10 + 7.9** → TI/Suporte EBS (acesso tabelas-base)
3. **8.6 + 8.3** → Operação/SYNCHRO (download manual de PDFs — Opção A)
4. **3.1 + 3.6 + 3.7 + 8.1** → Supervisor Expedição (operacional)
5. **R.1 a R.8** → Supervisor Expedição + Fiscal (lógica de roteamento/classificação)
6. **1.1 + 1.6** → Time Fiscal (regras)
7. **2.8 + 2.9** → TI/Suporte EBS (performance)

</details>
