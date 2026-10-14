# 🔀 Decisão e Trigger: Quando Migrar A → B?

> **Revisão: 2026-10-14.** Critérios históricos de evolução, não trigger comprovado do processo atual. O relatório contém botões manuais; detecção automática de fim de bipagem não foi demonstrada.

Confirmar download e cadência reais antes de decidir migração. Não confundir opções de acesso Oracle com A/B de obtenção de PDF. Critérios futuros devem usar ganho medido, segurança, licença e confiabilidade aprovados; ver [P12/P17/P18](../../03_Analyze/07_Open_Questions.md).

> Critério objetivo para passar de Manual (A) para RPA (B).  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Definir com clareza o momento em que a operação vai de **Opção A (Manual)** para **Opção B (RPA/API)**, evitando indecisão e mudanças ad-hoc.

---

## 📊 Matriz de Decisão

| Critério | Limite Mínimo para Manter A | Trigger Investigar B | Trigger Migrar para B |
|---|---|---|---|
| **Volume NFs/dia** | < 500 | 600+ (por 3 dias) | 1000+ (por 5 dias) |
| **Tempo manual/dia** | < 15 min | 20-30 min | > 30 min |
| **Taxa erro OCR** | < 5% | 5-10% | > 10% |
| **Taxa FALHAS/** | < 2% | 2-5% | > 5% (não resolve em A) |
| **Queixa operador** | Nenhuma | "Tome tempo demais" | "Insustentável" |
| **API SYNCHRO status** | Não docs | Docs draft disponível | Docs final + tested |
| **RPA policy IT** | Não avaliada | Em discussão | Aprovada |
| **Payback investimento** | N/A | ROI > 50%/mês | ROI > 100%/mês |

---

## 🚦 Estados da Solução

```
┌─────────────────────────────────────────────────────────────────┐
│ ESTADO 0: PRÉ-LAUNCH (Semana 1-4)                              │
├─────────────────────────────────────────────────────────────────┤
│ Status: Opção A sendo preparada e testada                      │
│ Ação: Nenhuma (Opção B não é foco ainda)                       │
│ Próximo: Go-live Opção A                                       │
└─────────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────────┐
│ ESTADO 1: STEADY (Go-live +1 mês = Semana 8)                  │
├─────────────────────────────────────────────────────────────────┤
│ Status: Opção A operacional, métricas coletadas                │
│ Ação: Monitorar diariamente (ver tabela abaixo)                │
│ Decisão Point: Fim da semana 8                                 │
│ Próximo: ESTADO 2 ou ESTADO 3                                  │
└─────────────────────────────────────────────────────────────────┘
          ↓
   ┌──────────┬──────────┐
   ↓          ↓
┌────────────────────────┐  ┌──────────────────────────────┐
│ ESTADO 2: INVESTIGAR   │  │ ESTADO 3: MIGRAR para B      │
│ (Se métricas ok)       │  │ (Se problemas em A)          │
├────────────────────────┤  ├──────────────────────────────┤
│ Status: Opção A mantém │  │ Status: Iniciar RPA/API dev  │
│ Ação: Solicitar API    │  │ Ação: Ativar Opção B design  │
│   SYNCHRO docs         │  │ Timeline: 8-12 semanas       │
│ DueDate: Week 10       │  │ Paralelo: Opção A fallback   │
│ Próximo: If docs OK→4  │  │ Próximo: Testing paralelo    │
│           Else → 1     │  │          em week 10-14       │
└────────────────────────┘  └──────────────────────────────┘
   ↓                               ↓
┌────────────────────────────────────────────────────────────────┐
│ ESTADO 4: CUTOVER (Semana 12-14)                               │
├────────────────────────────────────────────────────────────────┤
│ Status: Opção B testado, pronto para produção                  │
│ Ação: Deploy Opção B, keep A como fallback por 7 dias         │
│ Decisão: Desativar A após 7 dias com 0 falhas em B             │
│ Próximo: ESTADO 5                                              │
└────────────────────────────────────────────────────────────────┘
          ↓
┌────────────────────────────────────────────────────────────────┐
│ ESTADO 5: B OPERACIONAL (Semana 15+)                           │
├────────────────────────────────────────────────────────────────┤
│ Status: Opção B em produção 100%                               │
│ Ação: Monitored B diariamente; A offline                       │
│ Métricas: Ciclo 30 min, 0 input operador                       │
│ SUCESSO ✅                                                     │
└────────────────────────────────────────────────────────────────┘
```

---

## 📋 Checklist de Monitoramento (Semanal)

Cada sexta-feira, preencha:

```
SEMANA 8 (Go-live + 1 mês):

[ ] Volume NFs/dia (média semana):     _____ NFs
    ├─ Manter A se < 500
    ├─ Investigar B se 500-1000
    └─ Migrar se > 1000

[ ] Tempo manual/dia (média):          _____ minutos
    ├─ OK se < 15 min
    ├─ Atenção se 15-30 min
    └─ Urgência se > 30 min

[ ] Taxa erro OCR (% de PDFs falhando): _____ %
    ├─ OK se < 5%
    ├─ Atenção se 5-10%
    └─ Problema se > 10%

[ ] Taxa FALHAS/ (% de FALHAS/):        _____ %
    ├─ OK se < 2%
    ├─ Atenção se 2-5%
    └─ Urgência se > 5%

[ ] Reclamação operador (Y/N):          [ ]
[ ] Uptime Flow #2 (% disponibilidade): _____ %

DECISÃO:
  [ ] Continuar em A (próxima revisão semana 12)
  [ ] Solicitar API SYNCHRO docs (semana 9)
  [ ] Urgência: Iniciar Opção B design agora
```

---

## 🎯 Triggers de Ação Imediata

### **Trigger 1: Volume > 1000 NFs/dia (3 dias consecutivos)**

**Ação:** Iniciar investigação Opção B imediatamente.

```
Dia 1: 1200 NFs → "vamos monitorar"
Dia 2: 1150 NFs → "padrão emergindo"
Dia 3: 1300 NFs → TRIGGER ACIONADO

↓
Semana X: Solicitar API SYNCHRO docs
Semana X+2: Prototipar RPA
Semana X+6: Testes paralelos (A + B)
Semana X+8: Cutover
```

### **Trigger 2: Tempo manual > 45 min/dia**

**Ação:** Problema em Opção A. Investigar antes de migrar.

```
Se tempo > 45 min:
  └─ Checar se é:
     ├─ ZIP download lento? → Pedir ao SYNCHRO melhor compressão
     ├─ Upload lento? → Aumentar bandwidth / split em chunks
     ├─ Flow #2 lento? → Otimizar DAX / relacionamentos PBI
     └─ Ambos? → Opção B pode ajudar, mas precisa de API

Não migrar só por tempo sem entender root cause.
```

### **Trigger 3: Taxa OCR > 15% por 2 dias**

**Ação:** Problema de qualidade PDF ou OCR. Avaliar.

```
Se OCR falha > 15%:
  ├─ Verificar PDFs de qualidade (SYNCHRO gerando ruim?)
  ├─ Se SYNCHRO culpado: reclamar + solicitar melhor PDF
  ├─ Se OCR culpado: tentar outro provider (Document Intelligence v2)
  └─ NÃO é razão para migrar para Opção B
     (RPA também terá OCR, mesmo problema)
```

### **Trigger 4: API SYNCHRO specs disponíveis**

**Ação:** Iniciar investigação B (paralelo, sem parar A).

```
Semana X: Recebemos API docs
  ├─ Tech Lead revisa (1 dia)
  ├─ Assess viabilidade (1 dia)
  ├─ Montar plano dev RPA (2 dias)
  └─ Início codificação RPA

Não é urgência, mas oportunidade de preparar Opção B.
```

### **Trigger 5: RPA policy aprovada IT**

**Ação:** Remover bloqueador técnico. Opção B fica viável.

```
IT aprova RPA → Ativa Opção B timeline
  └─ Se API docs já disponível: foco em dev
     Se API docs não: foco em adquirir docs
```

---

## 📅 Timeline de Decisão (sem surpresas)

```
SEMANA 4:  Go-live Opção A
           └─ Manual download OK

SEMANA 8:  1ª Revisão (Go-live + 1 mês)
           ├─ Métricas OK? → Continuar A
           ├─ Problemas? → Investigar
           └─ Urgência? → Iniciar B

SEMANA 10: Paralelo investigation
           ├─ Tech Lead solicita API SYNCHRO
           ├─ RPA policy entra em discussão IT
           └─ Plano B detalhado se viável

SEMANA 12: 2ª Revisão (Go-live + 2 meses)
           ├─ API docs OK + aprovação IT?
           │   └─ SIM → Iniciar dev Opção B
           │   └─ NÃO → Continuar A por mais 1 mês
           └─ Problemas em A pioraram?
               └─ SIM → URGÊNCIA, acelerar B

SEMANA 14: Testes paralelos (A + B)
           ├─ Opção B em staging
           ├─ Compare resultados (PDFs iguais?)
           └─ Métricas (tempo, precisão, erros)

SEMANA 15: Cutover decision
           ├─ Opção B OK em staging? → Deploy prod
           ├─ Opção B problemas? → Investigar mais
           └─ Opção A falhas? → Fallback completo

SEMANA 16+: Opção B em produção
            └─ Monitore por 2 semanas antes de desativar A
```

---

## ✅ Checklist Final (antes de migrar A → B)

**Não inicie cutover sem confirmar TODOS:**

- [ ] Volume/tempo em A estável por 2 semanas
- [ ] Opção B testado em staging por 5+ dias
- [ ] Comparação A vs B: PDFs iguais (auditoria 100 NFs)?
- [ ] Taxa erro B < Taxa erro A
- [ ] Uptime B > 99% em staging
- [ ] Operador treinado (zero input novo em B)
- [ ] Fallback plan: como revert se B quebra?
- [ ] IT aprova RPA / infra
- [ ] Project Manager autoriza cutover
- [ ] Backup 7 dias: A ativo, B pronto para switch

---

## 🔗 Referência

- [`README.md`](README.md) — Opção A vs. B (overview)
- [`01_Caminho_A_Download_Manual.md`](01_Caminho_A_Download_Manual.md) — Procedimento A
- [`02_Caminho_B_RPA_SYNCHRO_API.md`](02_Caminho_B_RPA_SYNCHRO_API.md) — Especificação B
- [`../08_Plano_de_Acao.md`](../08_Plano_de_Acao.md) — Timeline geral
