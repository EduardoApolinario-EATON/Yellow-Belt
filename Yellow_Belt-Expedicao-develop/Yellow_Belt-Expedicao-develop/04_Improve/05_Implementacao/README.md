# 🚀 Implementação — Overview

> **Índice revisado: 2026-10-14.** O roadmap original não é cronograma vigente nem prova de conclusão. Há modelo e três ações funcionais confirmadas; produção, aceite e transferência precisam de evidências.

Usar [Handoff atual](HANDOFF.md), [Checklist de aceite](02_Checklist.md) e [P01-P19](../../03_Analyze/07_Open_Questions.md). Não publicar pela cópia Dataset nem por exemplos antigos; comparar com o PBIP oficial do orquestrador.

> Roadmap: como levar a solução à produção.  
> **Último update:** 2026-06-22

---

## 📅 Timeline: 4 Semanas

| Semana | Foco |
|---|---|
| **1** | Setup Power BI (dataflow + dataset) |
| **2** | Implementar Power Automate |
| **3** | Testes + Ajustes |
| **4** | Go-live |

---

## 📚 Documentos

| Doc | Função |
|---|---|
| **HANDOFF.md** | Contexto completo do projeto (decisões, GUIDs, estado) — leia primeiro |
| **01_Fases.md** | Detalhamento Semana 1-4 |
| **02_Checklist.md** | Pré-go-live |

---

## 🧩 Modelo Power BI (fonte única)

O projeto Power BI (PBIP) **oficial** vive no repositório do orquestrador
(`mobility-powerbi-architecture`), em **`reports/EXPEDICAO_AFT/`**. Não mantemos cópia do
PBIP aqui para evitar dois modelos divergindo. A query PL/SQL original que o modelo replica
está em [`queries/QUERY_AFTK_ORIGINAL.sql`](../../queries/QUERY_AFTK_ORIGINAL.sql).

---

## 🔗 Referência

- Roadmap completo em [`01_Fases.md`](01_Fases.md)
