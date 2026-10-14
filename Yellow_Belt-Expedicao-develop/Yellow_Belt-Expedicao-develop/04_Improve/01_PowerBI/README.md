# 📊 Power BI — Overview

> **Índice revisado: 2026-10-14.** O contrato vigente é o [Dicionário de 39 colunas](01_Dataset_Schema.md), não a proposta de 23. [Modelo Semântico](03_Modelo_Semantico.md) separa arquitetura atual do estudo original.

Fontes, medidas, sete telas e manutenção: [Manual Técnico](../../docs_ferramenta/01_Documentacao_Tecnica.md). O prompt e os arquivos de teste_offline são recursos de construção/simulação, não modelo publicado nem prova de paridade. PBIP oficial no orquestrador; Dataset é cópia de referência. Não alterar M/TMDL por exemplos antigos sem comparar com o oficial.

> Criação do dataset consolidado de 23 colunas.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Construir o dataset de 23 colunas **a partir de um dataflow de ingestão** das tabelas-base, com a lógica das 3 queries replicada em Power Query (M) e DAX.

---

## 📚 Documentos

| Doc | Função |
|---|---|
| **01_Dataset_Schema.md** | ⭐ CRÍTICO — 23 colunas, origem, transformações |
| **02_Query_Oracle.md** | Lógica das queries → dataflow + M/DAX |
| **03_Transformacoes_DAX.md** | Measures e colunas calculadas |
| **04_Dashboard_Operacional.md** | Visuais para operador |

---

## 🚀 Fluxo

```
Oracle (tabelas-base)
    ↓
Dataflow dedicado DF_Expedicao_Base (ingestão via Power Query/M)
    ↓
Dataset com 23 colunas (relacionamentos + M/DAX, modo Import)
    ↓
Dashboard (cards informativos)
    ↓
Power Automate ("Run a query against a dataset", DAX EVALUATE)
```

---

## 🔗 Referência

- [`01_Dataset_Schema.md`](01_Dataset_Schema.md) — 23 colunas
- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md) — regras de negócio
