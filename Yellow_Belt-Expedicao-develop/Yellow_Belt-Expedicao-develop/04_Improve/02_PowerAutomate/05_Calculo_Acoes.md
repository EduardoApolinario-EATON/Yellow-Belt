# 💰 Cálculo de Ações — Power Automate Cloud Free

> **Revisão: 2026-10-14.** Estimativa histórica, não garantia de direitos de uso, cota ou capacidade. Números de volume/cadência não foram reconfirmados; o tenant/licenças devem ser auditados por TI.

Recalcular pelo export e histórico de execução atuais: ações por arquivo, chamadas/consulta, loops, retries, concorrência, paginação, limites de conectores e refresh. Não declarar que Free atende apenas pela contagem estimada. Validar [P12/P17](../../03_Analyze/07_Open_Questions.md) antes de dimensionar ou licenciar.

> Análise de custo em ações/dia e viabilidade do plano Cloud Free.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

**Pergunta:** Power Automate Cloud Free tem limite 6.000 ações/dia. Com 350 PDFs, consegue processar?

**Resposta:** ✅ SIM, com margem de segurança.

---

## 📊 Contagem de Ações

### **Definição: O que conta como 1 ação?**

Em Power Automate Cloud Free:

```
1 ação = 1 step que envolve API call, processamento de dados, ou I/O

Exemplos de 1 ação:
  ✅ Read file (OneDrive)
  ✅ Send HTTP request (Azure OCR)
  ✅ Parse JSON
  ✅ Create folder (SharePoint)
  ✅ Move file
  ✅ Rename file
  ✅ Send email
  ✅ Append to array

Que NÃO conta:
  ❌ Condition (IF/ELSE — lógica pura)
  ❌ Compose (transformação de dados)
  ❌ Comment (apenas anotação)
  ❌ Trigger (primeiro step, grátis)
```

---

## 🔢 Fluxo: Ações por PDF

**Assumindo:** 350 PDFs por ciclo, processamento sequencial (1 fluxo)

### **Loop Body (por PDF):**

```
1. Get file content (OneDrive)                    ← 1 ação
2. Send HTTP (Azure Document Intelligence OCR)  ← 1 ação (pode custar 2-3 se complexo)
3. Parse JSON (resposta OCR)                      ← 1 ação
4. Condition (if chave encontrada?)              ← 0 ações (lógica pura)
5. Compose (extract regex 44 dígitos)           ← 0 ações
6. Condition (if chave existe em dataset?)       ← 0 ações
7. Create folder (/prisma_<SUB_LOC>/)            ← 1 ação
8. Rename file                                    ← 1 ação
9. Move file                                      ← 1 ação
10. Append to array (log)                         ← 1 ação
```

**Subtotal por PDF (caminho feliz):** **~7 ações**

---

### **Caminho com erro (se falha):**

```
1. Get file content                              ← 1 ação
2. Send HTTP (OCR)                               ← 1 ação
3. Parse JSON                                     ← 1 ação
4. Condition (erro ocr?)                         ← 0 ações
5. Move file (/FAILED/ocr/)                      ← 1 ação
6. Append to array (log erro)                    ← 1 ação

Subtotal (caminho erro): ~5 ações
```

---

## 📈 Cálculo Total

### **Cenário: 350 PDFs, 95% sucesso, 5% falha**

```
PDFs com sucesso:    350 × 95% = 332 PDFs × 7 ações = 2.324 ações
PDFs com falha:      350 × 5%  = 18 PDFs × 5 ações  =    90 ações

Overhead (triggers, loops, logging):
  - Trigger (Schedule):                          0 ações
  - Loop container (Apply to each):              0 ações
  - Notificação final (Send email):              1 ação

TOTAL POR CICLO:  2.324 + 90 + 1 = 2.415 ações
```

---

## 🚨 Verificação contra Limite

| Limite Cloud Free | Uso Calculado | Margem |
|---|---|---|
| 6.000 ações/dia | 2.415 ações | **3.585 ações sobrando** |
| **Ocupação** | **40%** | **✅ SEGURO** |

**Conclusão:** ✅ Cloud Free é suficiente com confortável margem de segurança.

---

## 📊 Cenários Alternativos

### **Cenário A: Pior caso (30% falha)**

```
PDFs sucesso:  350 × 70% = 245 × 7 = 1.715 ações
PDFs falha:    350 × 30% = 105 × 5 =   525 ações
Overhead:                             =     1 ação

TOTAL: 1.715 + 525 + 1 = 2.241 ações (~37% do limite)
```

✅ Ainda seguro.

---

### **Cenário B: Com OCR custando 3 ações (em vez de 1)**

```
Se Azure Document Intelligence for mais complexo:
  PDFs sucesso: 350 × 95% = 332 × (7 + 2 extra) = 332 × 9 = 2.988 ações
  PDFs falha:   350 × 5%  = 18 × 5 =   90 ações
  Overhead:                            =   1 ação

TOTAL: 2.988 + 90 + 1 = 3.079 ações (~51% do limite)
```

✅ Ainda seguro.

---

### **Cenário C: Parallelization (múltiplos fluxos)**

Se quiser processar mais rápido (paralelo em vez de sequencial):

```
Exemplo: 7 fluxos paralelos
  Cada fluxo: ~350 / 7 = 50 PDFs
  Custo por fluxo: 50 × 7 = 350 ações
  Total paralelo: 7 × 350 = 2.450 ações

Benefit: Tempo de execução: ~15 min (paralelo) vs ~20-25 min (sequencial)
Trade-off: Complexity, requires more engineering

Recommendation: Comece com 1 fluxo. Se timeout/slowness → migre para paralelo depois.
```

---

## 💡 Estratégias de Otimização

Se precisar reduzir ações (para futuro com mais ciclos):

### **1. Remover log detalhado**

```
Ação atual: Append to array para cada PDF
Economia: ~1 ação × 350 = 350 ações

Alternativa: Log apenas erros
Nova economia: 350 × 5% de falhas = ~18 ações só
```

### **2. Cache Power BI (query uma vez)**

```
Ação atual: Query Power BI a cada ciclo
Economia: ~1 ação (se compartilhar dataset entre múltiplos fluxos)

Implement: "Parse JSON" guarda resultado globalmente
```

### **3. Batch OCR (se disponível)**

```
Ação atual: 1 OCR call por PDF
Alternativa: API batch (se Azure suportar)

Economia: Potencial 50% se bundling de PDFs
```

---

## 🚀 Recomendação Final

**Usar Power Automate Cloud Free:**

✅ Suficiente para 350 PDFs/ciclo (~40% uso)  
✅ Espaço para crescimento (2-3x volume ainda OK)  
✅ Sem custo adicional  
✅ Migrar para Premium só se > 1.500 PDFs/ciclo ou múltiplos ciclos/dia

**Próximo passo:** Testar com 5 PDFs reais e medir ações exatas em Power Automate analytics.

---

## 📋 Monitoramento

### **Adicionar ao dashboard de Control:**

- Ações usadas/dia (vs 6.000 limite)
- Ações por PDF (média)
- Tendência (crescendo? decrescendo?)
- Alert: se ações > 70% do limite

---

## 🔗 Referência

- [`01_Fluxo_Classificador.md`](01_Fluxo_Classificador.md) — steps exatos
- Power Automate Limits: [Microsoft Docs](https://learn.microsoft.com/en-us/power-automate/limits-and-config)
