# 📥 RPA / Synchro — Os Dois Caminhos

> **Índice revisado: 2026-10-14.** Estudos de obtenção de PDFs; funcionamento confirmado refere-se à classificação em SharePoint, não ao download via API/RPA. Procedimento atual de download: a confirmar.

Não tratar endpoint, licença ou RPA como disponíveis. Futuras integrações exigem TI/Compliance, segurança, contrato de chave/arquivo e testes; não são escopo desta revisão. Usar [Manual do Operador](../../05_Control/05_Manual_Operador.md) e [P18](../../03_Analyze/07_Open_Questions.md).

> Estratégia dual para ingesta de PDFs: imediato (Opção A) vs. futuro (Opção B).  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Explicar como os PDFs chegam da plataforma SYNCHRO ao sistema de roteamento:
1. **Opção A (Launch):** Operador faz download manual → OneDrive/SharePoint
2. **Opção B (Futuro):** RPA/Desktop + SYNCHRO API (futura investigação)

Ambas as opções alimentam o mesmo **Power Automate Flow #2 (Classificador)**.

---

## ✅ Opção A: Download Manual (TO-BE Imediato)

### Fluxo

```
SYNCHRO
  ├─ Operador acessa plataforma (browser)
  ├─ Seleciona PDFs (50-350 NFs)
  ├─ Clica "Download" → arquivo ZIP
  ├─ Extrai ZIP localmente
  └─ Upload manual → OneDrive pasta "Entrada_PDFs"
       ↓
Power Automate Flow #2
  ├─ Dispara (file trigger: novo PDF em "Entrada_PDFs")
  ├─ Extrai CHAVE_ACESSO (OCR)
  ├─ Busca NF no dataset (PBI)
  ├─ Calcula roteamento
  └─ Move para pasta destino (SUB_LOC + PAGA_GUIA + DELIVERY)
```

### Vantagens

- ✅ **Zero dependências externas** — SYNCHRO já existe, nada novo a conectar
- ✅ **Rápido de implantar** — Manual para "teste" é válido
- ✅ **Segurança garantida** — Operador controla quais PDFs entram
- ✅ **Reversível** — Se PA falha, operador tem os PDFs originais
- ✅ **Rastreável** — OneDrive logs tudo

### Desvantagens

- ❌ **Manual (5-10 min/dia)** — Operador ainda precisa fazer download + upload
- ❌ **Não escalável** — Se volumetria cresce (1000 NFs), fica lento
- ❌ **Propenso a erro** — Pode esquecer de fazer upload em algum dia

### Critério de Entrada (Semana 1-Go-live)

- Power Automate Cloud Free confirmado (6k actions/dia OK)
- Operador treinado no manual
- Testes end-to-end com 5-10 PDFs OK
- Opção B não pronta (API SYNCHRO não documentada)

### Responsabilidades

| Quem | O quê | Quando |
|---|---|---|
| **Operador** | Download SYNCHRO → ZIP | Diariamente 7h |
| **Operador** | Upload ZIP → OneDrive | Diariamente 7h15m |
| **Admin SP** | Monitorar pasta (alertas) | Contínuo |
| **PA Dev** | Manter Flow #2 | Contínuo |

---

## ⏳ Opção B: RPA + SYNCHRO API (Investigação Paralela)

### Fluxo (Futuro)

```
SYNCHRO API
  ├─ Power Automate Desktop (RPA)
  │   └─ Conexão OAuth → SYNCHRO
  │   └─ GET /api/invoices?day=today
  │   └─ Download automaticamente
  │   └─ Parse + move to SharePoint
  └─ Dispara Flow #2 (classificador)
```

### Vantagens

- ✅ **Totalmente automático** — Zero input operador
- ✅ **Escalável** — Suporta 1000+ NFs/dia
- ✅ **Rastreável via API logs** — Auditoria integrada

### Desvantagens

- ❌ **Depende API SYNCHRO** — Precisa ser documentada + testada
- ❌ **RPA requer investimento** — Desktop ou vendor específico
- ❌ **Mais complexo** — Mais pontos de falha
- ❌ **Demora investigação** — ~4-6 semanas para viabilidade

### Critério de Entrada (Go + 1 mês)

- [ ] SYNCHRO API documentada (endpoints, auth, rate limits)
- [ ] Teste de conectividade bem-sucedido
- [ ] Política RPA aprovada pelo IT
- [ ] Opção A já operacional e estável (1 mês dados)
- [ ] Decision: migrar ou continuar com A?

### Responsabilidades

| Quem | O quê | Timeline |
|---|---|---|
| **Arquiteto** | Solicitar doc SYNCHRO API | Semana 1 |
| **Tech Lead SYNCHRO** | Fornecer API spec | Semana 2-3 |
| **PA Dev** | Prototipar conexão | Semana 4-6 |
| **QA** | Validar integração | Semana 6-8 |
| **IT** | Aprovar RPA policy | Paralelo |

---

## 🔀 Matriz de Decisão: Quando Migrar de A → B?

| Critério | Limite A | Limite B | Ação |
|---|---|---|---|
| **NFs/dia** | < 500 | > 500 | Se > 500, ativar B |
| **Taxa falha OCR** | < 5% | > 5% | Se > 5%, investigar A antes de B |
| **API SYNCHRO** | Não documented | Documentada | Quando doc chegar, avaliar |
| **Tempo operador/dia** | < 15 min | > 30 min | Se > 30, urgência em B |
| **Uptime necessário** | 95% | 99%+ | Se >99%, RPA + failover |

---

## 📋 Checklist — Decisão A vs. B

### Para **manter Opção A** (recomendado até semana 4+1):

- [ ] Operador reporta: "Upload leva < 10 min/dia"
- [ ] Taxa erro flow #2: < 2%
- [ ] Falha OCR: < 3%
- [ ] Zero reclamações sobre tempo
- [ ] Escalação: próximas 4 semanas = mesma volumetria

### Para **investigar Opção B** (semana 4+2 em diante):

- [ ] SYNCHRO API documentada + disponível
- [ ] Teste de auth bem-sucedido
- [ ] Teste de GET /invoices retorna dados
- [ ] Volume real: decisão de investimento
- [ ] RPA vs. PA Desktop vs. Logic Apps: avaliação

---

## 🚨 Fallback Se Ambas Falham

Se nem A nem B funcionar:

```
Manual 100%: Operador recebe email com lista de NFs
  ├─ Busca manualmente no SYNCHRO
  ├─ Faz download PDFs individuais
  ├─ Flow #1 classifica manualmente (sem OCR)
  └─ Roteamento manual (volta ao AS-IS)

Timeline: 2-4h vs. 30 min (TO-BE)
Isso é fallback, não solução final.
```

---

## 📊 Comparativo Visual

```
┌──────────────────────────────────────────────────────────────┐
│ OPÇÃO A: Download Manual (Agora)                             │
├──────────────────────────────────────────────────────────────┤
│ Setup        │ Treinar operador (1h)                        │
│ Automação    │ 10% (Flow #2 classifica)                      │
│ Escalabilidade│ Até ~500 NFs/dia                             │
│ Tempo opera  │ 10-15 min/dia                                 │
│ Custo invest │ R$0                                           │
│ Timeline     │ Go-live semana 4                              │
│ Risco        │ Baixo (já existe SYNCHRO)                     │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ OPÇÃO B: RPA + API (Futuro)                                  │
├──────────────────────────────────────────────────────────────┤
│ Setup        │ Documentar API + desenvolver RPA (~40h)       │
│ Automação    │ 100% (totalmente automático)                  │
│ Escalabilidade│ Ilimitada (até limites SYNCHRO)             │
│ Tempo opera  │ 0 min/dia (automático)                        │
│ Custo invest │ R$ 5-10k (RPA/PA Desktop)                     │
│ Timeline     │ Go + 4-6 semanas                              │
│ Risco        │ Médio (depende SYNCHRO API)                   │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔗 Referência

- [`01_Caminho_A_Download_Manual.md`](01_Caminho_A_Download_Manual.md) — Passo-a-passo operador
- [`02_Caminho_B_RPA_SYNCHRO_API.md`](02_Caminho_B_RPA_SYNCHRO_API.md) — Especificação futuro
- [`03_Decisao_e_Trigger.md`](03_Decisao_e_Trigger.md) — Critério de migração
- [`../03_Integracao/02_Armazenamento_PDFs.md`](../03_Integracao/02_Armazenamento_PDFs.md) — Visão geral storage
