# 📈 Ganho Esperado — Antes vs. Depois

> **Revisão: 2026-10-14.** Todos os ganhos abaixo são projeções históricas, não resultado medido da versão atual. Não apresentar tempo “5 min”, redução percentual ou economia como compromisso operacional.

Baseline qualitativo registra 2h12 de organização manual; outros documentos usavam 1h30 com escopo diferente/não reconciliado. Medir antes/depois por rodada e separar processamento, espera, trabalho humano e impressão física; registrar volume, mix, período e aprovação. Ver [Baseline](../02_Measure/01_Baseline_AS_IS.md), [Coleta](../02_Measure/03_Coleta_de_Dados.md) e [P17](../03_Analyze/07_Open_Questions.md).

> Impacto quantificado da solução.  
> **Último update:** 2026-06-22

---

## 1. Tempo de Ciclo

### Cenário AS-IS (Macro + Manual)

```
Bloco 1: Impressão OLEO      0h30m (automático)
Bloco 2: Impressão MONITOR   0h35m (automático)
Bloco 3: Separação Guia      0h30m (manual, legível)
Bloco 4: Organização Prismas 0h50m (manual, tediante)
Bloco 5: Classificação Final  2h12m (manual, lento — 55% do tempo!)
─────────────────────────────────
TOTAL:  ~4h/ciclo
```

### Cenário TO-BE (Power BI + Power Automate)

```
Bloco 1: Query consolid.     0h05m (Oracle)
Bloco 2: Power BI calc.      0h02m (DAX em memória)
Bloco 3: Sync dataset        0h03m (automático 8h AM)
Bloco 4: OCR + Matching      0h10m (automático, 350 NFs)
Bloco 5: Roteamento + move   0h08m (automático)
─────────────────────────────────
TOTAL:  ~0h30m/ciclo (2 horas se incluso validação manual)
```

**Redução:** 4h → 0h30m = **87.5% mais rápido** (ou **8.5x** se ciclo=correr).

---

## 2. Horas por Mês (250 dias úteis)

| Métrica | AS-IS | TO-BE | Ganho |
|---|---|---|---|
| **Ciclos/mês** | 1 | 4 | +3 |
| **Tempo operador/ciclo** | 4h | 0h30m | -3h30m |
| **Tempo operador/mês** | 4h | 2h | **-50h/mês** |
| **Tempo sistema/mês** | ~0.5h | ~2h | -1.5h (sistema mais usado) |

**Economia ao operador:** **50 horas/mês** = **~1.25 FTE** para reatribuição.

---

## 3. Qualidade

| Métrica | AS-IS | TO-BE | Impacto |
|---|---|---|---|
| **Precisão roteamento** | 85% (erros manuais) | >99% (lógica PBI) | -1.5% defeitos |
| **Taxa retrabalho** | ~15% | <1% | Reduz revisões |
| **Bloqueios não identificados** | ~50 NFs/mês | ~5 NFs/mês | Menos exceções |
| **Auditoria compliance** | Manual (lento) | Automática via log | Rastreabilidade 100% |

---

## 4. Risco Operacional

| Risco | AS-IS | TO-BE | Mitigation |
|---|---|---|---|
| **Perda de PDF** | Médio (pastas locais) | Baixo (SharePoint backup) | Sincronização automática |
| **Erro humano (digitação)** | Alto (teclagem 4h) | Mínimo (OCR + matching) | Validação automática |
| **Indisponibilidade operador** | CRÍTICO (sem substitute) | Baixa (processos automáticos) | Cross-training simplificado |
| **Conformidade fiscal** | Difícil provar | Fácil (audit trail Power Automate) | ✅ Log + timestamps |

---

## 5. Investimento vs. Retorno

### Investimento (one-time)

| Item | Custo | Obs |
|---|---|---|
| **Licenças (4 semanas)** | R$ 0 | Power BI Pro + PA Cloud Free já contratados |
| **Desenvolvimento** | 80h eng @ R$150/h | ~R$ 12.000 |
| **Testes + QA** | 30h @ R$100/h | ~R$ 3.000 |
| **Treinamento operador** | 4h | Incluído no manual |
| **TOTAL ONE-TIME** | **~R$ 15.000** | — |

### Retorno (mensal)

| Item | Ganho |
|---|---|
| **Horas operador economizadas** | 50h/mês × R$50/h = **R$ 2.500** |
| **Redução retrabalho fiscal** | ~15 NFs × R$200/audit = **R$ 3.000** |
| **Eficiência logística (menos demora)** | Estimado **R$ 1.000** |
| **TOTAL MENSAL** | **R$ 6.500** |

### Payback

```
ROI = Ganho mensal / Investimento inicial
    = R$ 6.500 / R$ 15.000
    = 43.3% ao mês

Payback = 1 / 0.433 = ~2.3 meses
```

**Resultado:** Investimento recuperado em **2-3 meses**.

---

## 6. Impacto Estratégico

| Área | Hoje | Futuro |
|---|---|---|
| **Escalabilidade** | Limitada a 1 operador | Ilimitada (automação) |
| **Tempo para novo processo** | Reescrever macro (2-3 sem) | Ajustar DAX (2 horas) |
| **Rastreabilidade** | Débil (pastas) | Forte (Power Automate logs + audit trail) |
| **Integração com BI** | Nenhuma (macro standalone) | Total (Power BI nativo) |
| **Conformidade** | Manual | Automática + documentada |

---

## 7. Ganhos Não-Financeiros

- ✅ **Liberação cognitiva:** Operador sai do modo "executor" para "supervisor"
- ✅ **Redução stress:** Fim da separação manual tediante (Bloco 5)
- ✅ **Conhecimento:** Stack Power BI/PA reutilizável em outros projetos
- ✅ **Compliance:** Auditoria fácil = menos risco legal
- ✅ **Inovação:** Porta aberta para RPA, ML, previsão de erros

---

## 8. Cenários Sensibilidade

### Cenário Pessimista (OCR falha 20% do tempo)

```
Manuais extra = 20% × 350 = 70 NFs/mês × 15 min = 17.5h
Tempo TO-BE = 30 min - 5 min (menos automação) = 25 min/ciclo
Economia = 4h - 25 min = 3h35m/ciclo = 65% melhoria
```

### Cenário Otimista (OCR perfeito + 500 NFs/ciclo)

```
Escala = 500/350 = 1.43×
Tempo = 30 min × 1.43 = 43 min (cresce pouco, rápido)
Operador = 1h/ciclo vs. 4h atual = 75% redução
ROI mensal = 75h × R$50 = R$ 3.750 extra
Payback = 1.8 meses
```

---

## 📊 Resumo Executivo

| Métrica | Valor |
|---|---|
| **Redução tempo ciclo** | 87.5% (4h → 30 min) |
| **Economia operador** | 50 horas/mês |
| **Melhoria precisão** | 85% → >99% |
| **Payback** | 2-3 meses |
| **ROI anual** | ~520% |

---

## 🔗 Referência

- [`00_Estrategia_TO_BE.md`](00_Estrategia_TO_BE.md) — Solução técnica
- [`08_Plano_de_Acao.md`](08_Plano_de_Acao.md) — Cronograma e ações
- [`01_Baseline_AS_IS.md`](../02_Measure/01_Baseline_AS_IS.md) — Dados AS-IS
