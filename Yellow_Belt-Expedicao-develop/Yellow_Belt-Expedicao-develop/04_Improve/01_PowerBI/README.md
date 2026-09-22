# 📊 Power BI — Overview

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
