# 🤖 Power Automate — Classificação Automática

> Automatizar a classificação e organização de PDFs usando Power Automate Cloud Free.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Substituir a macro VBA (7 módulos) por um fluxo Power Automate que:
1. **Lê o dataset Power BI** (23 colunas consolidadas)
2. **Extrai CHAVE_ACESSO** dos PDFs armazenados
3. **Faz match** entre PDF e linha do dataset
4. **Renomeia** PDFs com prefixo correto (001_, 002_, ...)
5. **Move** para pasta correta por prisma (SUB_LOC)
6. **Registra** falhas e sucesso em log

---

## 📚 Documentos Críticos

| Doc | Função |
|---|---|
| **01_Fluxo_Classificador.md** | ⭐ **CRÍTICO** — Steps do fluxo + pseudocódigo |
| **02_Algoritmo_Matching.md** | Como extrair CHAVE_ACESSO e fazer match |
| **03_Estrategia_Renaming.md** | Padrão de prefixos (001_, 002_, ...) |
| **04_Tratamento_Erros.md** | O que fazer se PDF não encontrado |
| **05_Calculo_Acoes.md** | 6.000 ações/dia — é suficiente? |

---

## 🔧 Stack Tecnológico

- **Trigger:** Agendado (14h) ou manual
- **Input:** OneDrive / SharePoint (Opção A)
- **Query:** Power BI REST API (`List tables`)
- **Processamento:** Loop, condition, compose, append to array
- **Output:** SharePoint / OneDrive organisado por prisma
- **Limite Cloud Free:** 6.000 ações/dia (suficiente? vide 05_Calculo_Acoes.md)

---

## 🚀 Fluxo Alto-Nível

```
Power BI Dataset (23 colunas)
    ↓
Power Automate Query (via REST API)
    ↓
Loop: Para cada PDF em OneDrive INPUT
    ↓
Extrai CHAVE_ACESSO (OCR ou parsing)
    ↓
Busca no dataset filtrado
    ↓
Se encontrado:
  ├─ Calcula SUB_LOC + DELIVERY
  ├─ Renomeia: 001_NF.pdf, 002_NF.pdf, ...
  ├─ Cria pasta /prisma_<SUB_LOC>/
  └─ Move arquivo
    ↓
Se não encontrado:
  ├─ Registra em EXP_FALHAS_LOG
  └─ Move para /FAILED/
    ↓
Fim do ciclo → Relatório de execução
```

---

## 📋 Próximos Passos

1. **Estude 01_Fluxo_Classificador.md** — entenda os 6 steps
2. **Estude 02_Algoritmo_Matching.md** — decisão sobre extração CHAVE_ACESSO
3. **Estude 03_Estrategia_Renaming.md** — padrão final de prefixo
4. **Crie fluxo em Power Automate Web** — pode exportar JSON depois
5. **Teste com 5 PDFs** — vide Checklist

---

## 🔗 Referência

- [`01_Fluxo_Classificador.md`](01_Fluxo_Classificador.md) — steps detalhados
- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md) — NOTA_MAE, PAGA_GUIA
- [`../01_PowerBI/01_Dataset_Schema.md`](../01_PowerBI/01_Dataset_Schema.md) — 23 colunas
