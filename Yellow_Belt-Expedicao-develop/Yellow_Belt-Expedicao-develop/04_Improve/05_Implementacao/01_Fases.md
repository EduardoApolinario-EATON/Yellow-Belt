# 📅 Fases — Roadmap 4 Semanas

> **Revisão: 2026-10-14.** Roadmap histórico estimado; datas, esforço e conclusão não foram reconfirmados. Não reiniciar a ferramenta existente como se estivesse sem implementação.

Etapa atual de entrega: reconciliar documentação, obter exports/configurações, homologar regras/filtros/impressão, fechar controles e transferir a TI. Cronograma e responsáveis nominais: a confirmar. Consultar [Handoff](HANDOFF.md) e [Checklist vigente](02_Checklist.md).

> Detalhamento semana-a-semana da implementação.  
> **Último update:** 2026-06-22

---

## 📊 Visão Geral

```
Semana 1: Setup infra + dados
  └─ Dataflow de ingestão + Power BI dataset

Semana 2: Implementação core
  └─ Power Automate fluxo classificador

Semana 3: Testes + Refinement
  └─ 5 PDFs reais, debugging, performance

Semana 4: Go-live + Suporte
  └─ Operador training + primeiro ciclo produção
```

---

## 🔧 SEMANA 1: Setup Dataflow + Power BI Dataset

### **Objetivos:**
- [ ] Ambiente Power BI Pro criado
- [ ] Dataflow de ingestão das tabelas-base publicado
- [ ] Dataset com 23 colunas funcionando
- [ ] 1ª visualização (cards) testada

### **Atividades:**

| Atividade | DH | Owner | Status |
|---|---|---|---|
| Criar workspace Power BI | 0,5h | [Admin] | Pending |
| Configurar dataflow + conexão Oracle (gateway) | 1h | [Dev PBI] | Pending |
| Ingerir tabelas-base no dataflow (M) | 2h | [Dev PBI] | Pending |
| Construir dataset a partir do dataflow | 1h | [Dev PBI] | Pending |
| Validar 23 colunas | 1h | [Dev PBI] | Pending |
| Criar dashboard inicial | 1h | [Dev PBI] | Pending |
| **Subtotal** | **6,5h** | | |

### **Deliverables:**
- Dataset Power BI com 23 colunas ✅
- Dataflow testado com dados reais ✅
- Dashboard com 5 cards (contar NFs, flagMissingChaves, etc.)

### **Go/No-go:** Se o dataset (via dataflow) bate com a amostra Oracle → GREEN

---

## 🤖 SEMANA 2: Implementar Power Automate

### **Objetivos:**
- [ ] Power Automate fluxo classificador criado
- [ ] 5 PDFs passam pelo fluxo end-to-end
- [ ] Renaming + moving funciona
- [ ] Erros logam corretamente

### **Atividades:**

| Atividade | DH | Owner | Status |
|---|---|---|---|
| Criar SharePoint structure | 1h | [Admin] | Pending |
| Criar fluxo PA base (trigger + loop) | 1h | [Dev PA] | Pending |
| Integrar OCR (Azure Doc Intel) | 2h | [Dev PA] | Pending |
| Regex + matching CHAVE_ACESSO | 1h | [Dev PA] | Pending |
| Renaming + moving files | 1h | [Dev PA] | Pending |
| Logging (array + CSV) | 1h | [Dev PA] | Pending |
| Notificação final (email) | 0,5h | [Dev PA] | Pending |
| Teste com 5 PDFs | 1h | [Dev PA + Operador] | Pending |
| **Subtotal** | **8,5h** | | |

### **Deliverables:**
- Fluxo Power Automate em desenvolvimento (não publicado)
- 5 PDFs manualmente processados (prototipo)
- Log testado
- Notificação funciona

### **Go/No-go:** 5 PDFs aparecem em /PROCESSADO/ com nomes corretos → GREEN

---

## 🧪 SEMANA 3: Testes + Refinement

### **Objetivos:**
- [ ] Fluxo processado 100+ PDFs reais
- [ ] Performance aceitável (< 30s/PDF)
- [ ] Erros tratados corretamente
- [ ] Operador fez 1 ciclo de teste completo

### **Atividades:**

| Atividade | DH | Owner | Status |
|---|---|---|---|
| Preparar 100 PDFs de teste | 1h | [Operador] | Pending |
| Run fluxo com 100 PDFs | 1h | [Dev PA] | Pending |
| Análise de erros | 1h | [Dev PA + Operador] | Pending |
| Optimization OCR (cache, retry) | 2h | [Dev PA] | Pending |
| Teste manual operador | 2h | [Operador] | Pending |
| Documentação de troubleshooting | 1h | [Dev PA] | Pending |
| Training operador | 1h | [Dev PA + Operador] | Pending |
| **Subtotal** | **9h** | | |

### **Deliverables:**
- Fluxo publicado em produção (teste)
- 100 PDFs classificados com sucesso (ou documentado por que falharam)
- Manual operador atualizado
- Operador confortável com processo

### **Go/No-go:** Taxa sucesso > 95%, operador confortável → GREEN

---

## 🚀 SEMANA 4: Go-Live + Suporte

### **Objetivos:**
- [ ] Primeiro ciclo em produção
- [ ] 350 PDFs reais processados
- [ ] Operador usando novo fluxo
- [ ] Suporte em standby

### **Atividades:**

| Atividade | DH | Owner | Status |
|---|---|---|---|
| Last-minute checklist | 1h | [Admin] | Pending |
| Executar 1º ciclo (14h) | 2h | [Operador + Support] | Pending |
| Monitorar fluxo em tempo real | 2h | [Dev PA] | Pending |
| Troubleshooting on-demand | 2h | [Dev PA] | Pending |
| Post-ciclo analysis | 1h | [Dev PA] | Pending |
| Ajustes finais (se necessário) | 2h | [Dev PA] | Pending |
| Documentação de go-live | 1h | [Dev PA] | Pending |
| **Subtotal** | **11h** | | |

### **Deliverables:**
- 1º ciclo produção completo
- Log de execução + lessons learned
- Fluxo estável
- Suporte documentado para próximo operador

### **Go/No-go:** Ciclo executado com sucesso, operador imprimiu PDFs → GREEN ✅

---

## 📊 Ganho Esperado (Semana 4 onwards)

```
AS-IS: 4h/ciclo
TO-BE: ~1h/ciclo

Redução: 3h/ciclo = ~75% economia de tempo

Em 1 mês (20 ciclos):
  AS-IS: 20 × 4h = 80h/mês
  TO-BE: 20 × 1h = 20h/mês
  Redução: 60h/mês = 1.5 pessoas/mês economizadas
```

---

## 🔗 Referência

- [`02_Checklist.md`](02_Checklist.md) — pré-go-live
- [`../../04_Improve/02_PowerAutomate/01_Fluxo_Classificador.md`](../../04_Improve/02_PowerAutomate/01_Fluxo_Classificador.md)
