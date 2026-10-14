# Relatório da Solução — Entrega em 3 Estágios (Expedição AFT)

> **Status vigente: 2026-10-14.** O relatório de agosto abaixo é histórico. Percentuais de paridade, lote de 224 e validação DEV são relatos anteriores, não reproduzidos nem reconfirmados nesta revisão.

| Estágio | Evidência atual | Pendência |
|---|---|---|
| BI | PBIP/TMDL/JSON atuais; funcionamento confirmado | Ambiente, paridade com dados e aceite |
| Obtenção de PDFs | Não comprovada por esta cópia | Procedimento SYNCHRO; API/RPA não confirmados |
| Automação | Atualizar modelo, Paga Guia e PROCESSAR PDFs funcionais conforme responsável | Exports, filtros, caminhos, histórico, concorrência e suporte |

O relatório tem sete páginas, incluindo DL Etiquetas e Mesma NF em Outro Locator. STATUS_CICLO usa JA PROCESSADA, não JA_IMPRESSO; WSH usa WSH_DOC e janela local 45 dias. Não garantir ordem física ou ganho realizado apenas pelo nome de arquivo. Fonte oficial continua no orquestrador.

Ver [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md), [Mapa atual](07_Mapa_de_Regras.md) e [P01-P19](../03_Analyze/07_Open_Questions.md).

## Relatório histórico de agosto/2026

> Relatório de arquitetura e status da automação da Expedição AFT (Eaton Valinhos),
> organizado em **3 estágios de entrega**.
> **Última atualização:** 2026-08-18

---

## Resumo executivo

O projeto substitui a macro VBA manual (~2h12/ciclo) por uma solução Power BI + Power Automate
que **classifica as NFs**, define o **destino físico (prisma)** e garante a **ordem de impressão**.
A entrega foi dividida em 3 estágios, dos quais **o 1 e o 3 estão construídos e validados** e o **2
fica para uma fase futura**.

| Estágio | Escopo | Status |
|---|---|---|
| **1 — BI** | Dataflows, dataset, modelo semântico e relatórios | ✅ Construído e validado (em DEV) |
| **2 — Obtenção dos PDFs (Synchro)** | Automatizar o download dos PDFs do SYNCHRO (API/RPA) | ⏸️ **Não implementado agora** (fase futura) |
| **3 — Automação Power Automate** | Fluxo que classifica, renomeia e organiza os PDFs por ciclo | ✅ Construído e validado funcionalmente (em DEV) |

> **Fluxo hoje (com os estágios 1 e 3):** o operador **baixa manualmente** os PDFs do SYNCHRO
> (o Estágio 2 automatizaria esse passo), coloca na pasta **ENTRADA** do ciclo, clica **Processar
> Ciclo** no Power BI (Estágio 3), e imprime a partir das pastas de destino.

---

## Contexto (problema e meta)

- **AS-IS:** após uma atualização do SYNCHRO, a macro parou de gerar os PDFs classificados. O time
  imprime fora de ordem e separa manualmente por prisma → ~2h12 de retrabalho por ciclo, sobre ~350 NFs.
- **Meta:** reduzir o ciclo com classificação automática, mantendo o operador apenas na conferência e impressão.
- Referências: [`../01_Define/01_Project_Charter.md`](../01_Define/01_Project_Charter.md),
  [`00_Estrategia_TO_BE.md`](00_Estrategia_TO_BE.md).

---

# Estágio 1 — BI (Dataflows, Dataset, Modelo e Relatórios) ✅

**Objetivo:** transformar as tabelas-base do Oracle em um dataset onde **cada linha (1 por NF)** já
carrega as 3 decisões: classificação fiscal, destino físico e ordem de impressão.

### O que foi construído
- **Ingestão:** dataflows Bronze do orquestrador (Oracle EBS → `BRZ_ORACLE_*`), sem usar views `_BR_V`
  (o Power BI reconstrói a lógica a partir das tabelas base).
- **Dataset `NotasFiscais`:** modelo denormalizado, 1 linha por `CUSTOMER_TRX_ID`, replicando a
  [`../queries/QUERY_AFTK_ORIGINAL.sql`](../queries/QUERY_AFTK_ORIGINAL.sql) (fonte de verdade da macro).
- **Colunas derivadas** (M/DAX): `PASTA_DESTINO`, `NOME_ARQUIVO`, `ORDEM_CLASSIFICACAO`, `PAGA_GUIA`,
  `APTA`, `MOTIVO`, `CFOP`, `STATUS_FISCAL`, agrupamento **mãe/filha**.
- **Relatório:** página **Visão Geral** (KPIs do ciclo), **Lista de Impressão**, **Monitor**, **Óleo**,
  **Chaves para Download**; tema visual Eaton aplicado.

### Regras-chave implementadas
- **ICMS-ST dinâmico:** lista de impostos deixou de ser fixa/desatualizada e passou a ser lida
  dinamicamente do dataflow de lookups (corrigiu divergências de PAGA_GUIA).
- **Ordenação mãe/filha:** a filha herda o `SUB_LOC` da mãe apenas para ordenar (agrupa no mesmo prisma).

### Validação
- **Classificação: 100%** vs. o Excel de produção; **ordem: 99,6%** (as poucas quebras restantes são
  multi-locator, sem impacto no destino).
- Detalhes: [`07_Mapa_de_Regras.md`](07_Mapa_de_Regras.md),
  [`01_PowerBI/03_Modelo_Semantico.md`](01_PowerBI/03_Modelo_Semantico.md),
  [`../referencias/validacao/`](../referencias/validacao/).

### Pendências ⚙️
- **Promoção DEV → PROD** (governança; nunca mexer no workspace de produção sem backup).
- **Performance de refresh** (ver [`../04_Improve/04_Arquitetura/README.md`](04_Arquitetura/README.md)):
  avaliar a janela `DaysText` no dataflow WSH_DOC_CUR (decisão com o dono do dataflow).

---

# Estágio 2 — Automação da obtenção dos PDFs do SYNCHRO ⏸️ (fase futura)

> **Não será implementado neste momento.** Documentado aqui para registrar o escopo e a decisão.

**Objetivo (futuro):** eliminar o download manual dos PDFs do SYNCHRO, obtendo-os automaticamente.

### Caminhos avaliados
- **Caminho A (atual, manual):** operador baixa os PDFs do SYNCHRO e coloca na pasta ENTRADA.
  Ver [`06_RPA_Synchro/01_Caminho_A_Download_Manual.md`](06_RPA_Synchro/01_Caminho_A_Download_Manual.md).
- **Caminho B (futuro, automático):** RPA ou **API do SYNCHRO** para buscar os PDFs sem intervenção.
  Ver [`06_RPA_Synchro/02_Caminho_B_RPA_SYNCHRO_API.md`](06_RPA_Synchro/02_Caminho_B_RPA_SYNCHRO_API.md)
  e [`06_RPA_Synchro/03_Decisao_e_Trigger.md`](06_RPA_Synchro/03_Decisao_e_Trigger.md).

### Por que ficou para depois
- O download manual é rápido e **não é o gargalo** do processo; a maior dor (classificação/ordem) já é
  resolvida pelos Estágios 1 e 3.
- A automação via API/RPA depende de acesso/integração com o SYNCHRO (escopo e viabilidade a definir com TI).

### Pré-requisitos para retomar (futuro)
- Definição de acesso à API do SYNCHRO **ou** ferramenta de RPA homologada.
- Ponto de entrega dos PDFs = a mesma pasta **ENTRADA** por ciclo (o Estágio 3 não muda).

---

# Estágio 3 — Automação Power Automate (fluxos) ✅

**Objetivo:** a partir dos PDFs na pasta ENTRADA e do dataset classificado, **renomear e organizar**
cada NF na pasta de destino correta, na ordem de impressão.

### O que foi construído
- **Fluxo "Processar Ciclo"** disparado por um **botão dentro do relatório Power BI** (o operador clica).
- **Arquitetura de pastas por ciclo:** cada rodada usa **ENTRADA** (entrada) e **SAIDA/\<Ciclo\>** (saída),
  garantindo que os PDFs de um ciclo não se misturem com os do anterior.
- **Matching por chave de acesso (44 dígitos):** casa cada PDF com a linha do dataset.
- **Renomeação + destino:** aplica `NOME_ARQUIVO` e move para `PRONTO`, `AGUARDANDO GUIA`, `OLEO` ou
  `EXCECAO/*`, conforme `PASTA_DESTINO`.
- **Memória anti-reimpressão (`NFS_IMPRESSAS`):** NFs já processadas retornam como **JA_IMPRESSO** e não
  são reprocessadas (fonte de verdade contra reimpressão).
- **Fluxo de refresh do dataset** disparável para atualizar os dados antes de processar.

### Validação funcional
- Rodada com **224 NFs novas → todas PRONTO** (0 JA_IMPRESSO); reprocesso das mesmas 224 → **todas JA_IMPRESSO**.
- Referências: [`02_PowerAutomate/01_Fluxo_Classificador.md`](02_PowerAutomate/01_Fluxo_Classificador.md),
  [`02_PowerAutomate/02_Algoritmo_Matching.md`](02_PowerAutomate/02_Algoritmo_Matching.md),
  [`02_PowerAutomate/03_Estrategia_Renaming.md`](02_PowerAutomate/03_Estrategia_Renaming.md),
  [`02_PowerAutomate/04_Tratamento_Erros.md`](02_PowerAutomate/04_Tratamento_Erros.md).

### Pendências ⚙️
- **Governança:** mover os fluxos do ambiente pessoal/DEV para o **ambiente compartilhado da organização** (TI).
- **Rede de segurança do Delete** (tolerância a inconsistência eventual do SharePoint sob concorrência) — confirmar.
- **Atalhos OneDrive** das pastas ENTRADA/SAIDA para o operador (File Explorer).

---

## Dependências e roadmap

```
Estágio 1 (BI) ──► Estágio 3 (Power Automate)
        │                    ▲
        └── dataset classificado alimenta o fluxo
Estágio 2 (Synchro) ····► entrega PDFs na ENTRADA (opcional/futuro; hoje é manual)
```

- **Estágios 1 + 3** entregam o valor principal e **já funcionam juntos** (com download manual).
- **Estágio 2** é uma **otimização futura** que remove o único passo manual restante, sem alterar 1 e 3.

## Pendências gerais (governança)
- Promoção **DEV → PROD** dos dataflows/modelo/relatório (com backup e janela de baixa operação).
- Mover **fluxos** para o ambiente org.
- Decisão do **`DaysText`** (janela de refresh do WSH_DOC_CUR).

## Referências
- Contexto técnico completo: [`05_Implementacao/HANDOFF.md`](05_Implementacao/HANDOFF.md)
- Manual do operador: [`../05_Control/05_Manual_Operador.md`](../05_Control/05_Manual_Operador.md)
- Catálogo de regras: [`07_Mapa_de_Regras.md`](07_Mapa_de_Regras.md)
