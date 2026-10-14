# Yellow Belt - Automação de Expedição (Eaton Valinhos)

> **Índice vigente: 2026-10-14.** A documentação foi reconciliada com a cópia atual do Power BI e com a confirmação do responsável. O índice antigo está preservado como histórico, não como status de entrega.

## Comece pelo seu papel

| Público | Documento principal | Complemento |
|---|---|---|
| Operador | [Guia rápido](docs_ferramenta/02_Modo_de_Uso_Operador.md) | [Manual completo](05_Control/05_Manual_Operador.md) |
| Supervisor | [Plano de controle](05_Control/01_Plano_de_Controle.md) | [Dashboard e leitura de indicadores](05_Control/02_Dashboard_Gestao.md) |
| TI/BI/Automação | [Manual técnico](docs_ferramenta/01_Documentacao_Tecnica.md) | [Handoff](04_Improve/05_Implementacao/HANDOFF.md) |
| Fiscal/Armazém | [Regras](01_Define/04_Regras_Negocio.md) | [Mapa de regras e diferenças do legado](04_Improve/07_Mapa_de_Regras.md) |
| Gestão Yellow Belt | [Baseline](02_Measure/01_Baseline_AS_IS.md) | [Pendências e homologação](03_Analyze/07_Open_Questions.md) |

## Estado comprovado

Power BI, atualização do modelo, paga guias e processamento de PDFs em SharePoint estão funcionais conforme o responsável. O modelo possui 39 colunas em NotasFiscais, 12 medidas e relatório de sete páginas. Ambiente produtivo, contatos, caminhos operacionais, fluxos exportados, SLAs e ganhos medidos: a confirmar.

[Dataset](../../Dataset/README.md) é cópia de referência. O PBIP oficial permanece no repositório `mobility-powerbi-architecture`, em `reports/EXPEDICAO_AFT/`. As queries e a macro são referências de paridade; não substituem a descrição do comportamento atual nem o aceite fiscal.

## Fases DMAIC

- [Define](01_Define/README.md): problema, escopo, papéis e regras.
- [Measure](02_Measure/README.md): baseline histórico e plano de medição; metas não são resultados.
- [Analyze](03_Analyze/README.md): diagnóstico do legado e pendências atuais.
- [Improve](04_Improve/README.md): implementação observada, contratos e propostas separadas.
- [Control](05_Control/README.md): operação, suporte, auditoria e aceite.

## Governança documental

Entrega atual somente em Markdown. Os PDFs já existentes não foram regenerados e não são a versão vigente. Manuais e contratos atuais são identificados pela revisão de 2026-10-14. Documentos de estudo preservam sua data original e recebem indicação de histórico/proposta; não representam funcionalidades homologadas.

Não publicar credenciais, caches Power BI ou amostras reais de NF-e/CNPJ/chaves. Não alterar tabelas, fluxos, regras fiscais ou estrutura de pastas para apenas adequar a documentação. Validar P01-P19 e [checklist de transferência](04_Improve/05_Implementacao/02_Checklist.md) antes de liberar rotina ou promover versão.

<details>
<summary>Índice de agosto/2026: histórico, substituído</summary>

> Automação do processo de classificação de notas fiscais para expedição usando Power BI + Power Automate.
> **Última atualização:** 2026-08-14

---

## 🎯 O Desafio

**Hoje:** 4h/ciclo → operador classifica manualmente **350 NFs por prisma** em ~1h30  
**Meta:** Automatizar classificação com Power BI + Power Automate (Cloud Free)

---

## ✅ Stack Tecnológico

| Camada | Ferramenta | Função |
|---|---|---|
| **Dados** | Oracle (tabelas-base via dataflow) | ~350 NFs/ciclo |
| **Modelo** | Power BI Pro | Dataset com 23 colunas |
| **Automação** | Power Automate Cloud Free | Classificação de PDFs |
| **Armazenamento** | OneDrive / SharePoint | PDFs intermediários |

---

## 🚀 Solução

```
Oracle (tabelas-base)
    ↓
Dataflow de ingestão → Power BI Dataset (relacionamentos + M/DAX)
    ↓
Power Automate (classificação automática)
    ↓
PDFs organizados por prisma
    ↓
Operador imprime na ordem certa
```

**Resultado:** Reduz ~1h30 de trabalho manual → ~5 min (operador apenas upload + impressão)

---

## 📚 Como Navegar

### 👤 Novo no projeto?
1. [`01_Define/01_Project_Charter.md`](01_Define/01_Project_Charter.md) — O quê e por quê
2. [`01_Define/04_Regras_Negocio.md`](01_Define/04_Regras_Negocio.md) — Lógica de classificação
3. [`04_Improve/00_Estrategia_TO_BE.md`](04_Improve/00_Estrategia_TO_BE.md) — Visão geral
4. [`04_Improve/07_Mapa_de_Regras.md`](04_Improve/07_Mapa_de_Regras.md) — Catálogo completo das regras (AS-IS → solução)
5. [`04_Improve/10_Exemplo_Fluxo_Prisma.md`](04_Improve/10_Exemplo_Fluxo_Prisma.md) — Exemplo ponta a ponta de um prisma

### 💻 Implementando?
- **Power BI** → [`04_Improve/01_PowerBI/`](04_Improve/01_PowerBI/)
- **Power Automate** → [`04_Improve/02_PowerAutomate/`](04_Improve/02_PowerAutomate/)
- **Integração** → [`04_Improve/03_Integracao/`](04_Improve/03_Integracao/)

### 📊 Baseline e Métricas?
- [`02_Measure/01_Baseline_AS_IS.md`](02_Measure/01_Baseline_AS_IS.md)
- [`05_Control/01_Plano_de_Controle.md`](05_Control/01_Plano_de_Controle.md)

### 🔍 Precisei de Referência?
- Macro legada → [`referencias/macro_antiga/`](referencias/macro_antiga/)
- Exemplos históricos → pasta local não disponível nesta cópia; usar apenas amostras autorizadas e anonimizadas.

---

## ⭐ Documentos Críticos

| Doc | Por quê |
|---|---|
| [`01_Define/04_Regras_Negocio.md`](01_Define/04_Regras_Negocio.md) | Define NOTA_MAE, PAGA_GUIA, ORDEM_CLASSIFICACAO |
| [`04_Improve/07_Mapa_de_Regras.md`](04_Improve/07_Mapa_de_Regras.md) | Catálogo exaustivo de todas as regras + status de implementação |
| [`04_Improve/01_PowerBI/01_Dataset_Schema.md`](04_Improve/01_PowerBI/01_Dataset_Schema.md) | 23 colunas do dataset |
| [`04_Improve/02_PowerAutomate/01_Fluxo_Classificador.md`](04_Improve/02_PowerAutomate/01_Fluxo_Classificador.md) | Steps do fluxo |
| [`04_Improve/02_PowerAutomate/02_Algoritmo_Matching.md`](04_Improve/02_PowerAutomate/02_Algoritmo_Matching.md) | Como buscar PDF por CHAVE_ACESSO |

---

## 📂 Estrutura do Repositório

```
01_Define/              Define do projeto
02_Measure/             Baseline e KPIs
03_Analyze/             Análise da macro e API
04_Improve/             Solução (PBI + PA)
  ├─ 01_PowerBI/        Dataflow + Dataset
  ├─ 02_PowerAutomate/  Classificador + Algoritmos
  ├─ 03_Integracao/     Fluxo operador + armazenamento
  └─ 05_Implementacao/  Phases + Checklist
05_Control/             Métricas + Manual operador
referencias/            Macro legada + exemplos
```

---

## 🧭 Padrão de Arquitetura do Repositório

Este repositório segue a estrutura **DMAIC** (Define → Measure → Analyze → Improve → Control) como espinha dorsal. Regras do padrão:

- **Documentação em Markdown** é a fonte primária — cada fase tem seu `README.md` de índice.
- **Somente material útil e não sensível** é versionado. Amostras de dados reais (PDFs de NF-e, planilhas com CNPJ/chave de acesso) ficam **apenas locais** e são bloqueadas no `.gitignore`.
- **Fonte única do modelo Power BI:** o projeto Power BI (PBIP) oficial vive no repositório do **orquestrador** (`mobility-powerbi-architecture`), em `reports/EXPEDICAO_AFT/`. Aqui mantemos apenas documentação e ponteiros, para evitar dois modelos divergindo.
- **Binários de entrega** pequenos (apresentação `.pptx`, BPI `.xlsx`, `Manual_AS_IS.pdf`) são mantidos por serem entregáveis do projeto.

---

## 🔄 Fluxo Operador (Opção A)

```
1. Operador baixa PDFs do Synchro (Downloads)
2. Operador sobe PDFs para OneDrive/SharePoint (INPUT)
3. Power Automate Cloud lê de lá
4. Power Automate classifica + renomeia + organiza
5. Operador abre SharePoint e imprime por prisma
```

**Investigação paralela:** Pode Synchro salvar direto em SharePoint? (Veja `04_Improve/03_Integracao/02_Armazenamento_PDFs.md`)

---

## 📅 Timeline (Estimado)

| Semana | Atividade |
|---|---|
| 1 | Setup Power BI (dataflow + dataset) |
| 2 | Implementar Power Automate Fluxo |
| 3 | Testes + Ajustes |
| 4 | Piloto + Go-live |

---

## 👥 Autor

**Eduardo Apolinario** — Yellow Belt Candidato, Eaton Valinhos  
**Email:** eduardoapolinario@eaton.com

</details>
