# 📝 Estratégia de Renaming — Prefixos para Impressão

> Como garantir que PDFs sejam impressos na ordem correta usando prefixos.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

**Problema:** Windows imprime PDFs em **ordem alfabética**, não numérica.  
```
NOTA_1.pdf  → imprime ANTES de NOTA_10.pdf ❌
001_NOTA_1.pdf → imprime ANTES de 002_NOTA_10.pdf ✅
```

**Solução atual:** usar o campo `ORDEM_CLASSIFICACAO` calculado no Power BI após o sort final e prefixar o PDF com esse valor.

Padrão oficial para o piloto:

```text
EXPEDICAO_{ORDEM_CLASSIFICACAO}_NF_{NF}.pdf
```

Exemplos:

```text
EXPEDICAO_A1_NF_565271.pdf
EXPEDICAO_B10_NF_565272.pdf
EXPEDICAO_C100_NF_565273.pdf
```

O padrão `001_`, `002_`, etc. fica como alternativa futura se a operação decidir reiniciar a contagem por prisma. Para o piloto, evitar calcular prefixo dentro do Power Automate.

---

## 📋 Regras de Prefixo

### **Regra 1: Dentro de cada PRISMA (SUB_LOC)**

Cada prisma é uma pasta separada. Dentro dela:
- Arquivo 1º imprime = `001_NF.pdf`
- Arquivo 2º imprime = `002_NF.pdf`
- Arquivo 3º imprime = `003_NF.pdf`
- E assim por diante...

```
Estrutura:
/EXPEDICAO/PROCESSADO/
  ├─ prisma_STG.A12.001/
  │   ├─ 001_565271.pdf  (NOTA_MAE)
  │   ├─ 002_565272.pdf  (DELIVERY 1)
  │   └─ 003_565273.pdf  (DELIVERY 2)
  │
  └─ prisma_STG.A12.002/
      ├─ 001_565274.pdf  (NOTA_MAE)
      └─ 002_565275.pdf  (DELIVERY 1)
```

**Resultado:** Operador abre cada pasta, imprime de cima para baixo — tudo em ordem!

---

### **Regra 2: Ordenação Dentro da Pasta**

**Ordem de prioridade (para calcular o número):**

1. **PAGA_GUIA (DESC)** — NFs de estados que pagam guia vêm primeiro
   - `PAGA_GUIA = true` → `001_`, `002_`, ...
   - `PAGA_GUIA = false` → `xxx_`, `xxx_`, ...

2. **NOTA_MAE (filhas depois)**
   - `NOTA_MAE = true` (DELIVERY = null) → número menor (1º lugar)
   - `NOTA_MAE = false` (DELIVERY ≠ null) → número maior (2º, 3º, ...)

3. **DELIVERY (ASC)** — dentro das filhas, pela ordem de entrega
   - `DELIVERY = 1` → `002_`
   - `DELIVERY = 2` → `003_`
   - `DELIVERY = 3` → `004_`

---

## 🔢 Algoritmo de Cálculo

### **Pseudocódigo:**

```javascript
// Entrada: dataset filtrado por SUB_LOC, ordenado por PAGA_GUIA DESC, DELIVERY ASC
dataset_sorted = sort_by(
  dataset.filter(row => row.SUB_LOC == "STG.A12.001"),
  ["PAGA_GUIA DESC", "NOTA_MAE DESC", "DELIVERY ASC"]
)

// Calcular prefixo sequencial
counter = 1
for each row in dataset_sorted:
  prefixo = pad_left(counter, 3, "0")  // "001", "002", "003", ...
  filename = prefixo + "_" + row.NF + ".pdf"
  counter += 1

// Resultado:
// 001_565271.pdf (NOTA_MAE)
// 002_565272.pdf (DELIVERY 1)
// 003_565273.pdf (DELIVERY 2)
```

### **Exemplo Prático:**

| # | NF | SUB_LOC | DELIVERY | NOTA_MAE | PAGA_GUIA | Prefixo | Filename |
|---|---|---|---|---|---|---|---|
| 1 | 565271 | STG.A12.001 | null | true | false | 001_ | 001_565271.pdf |
| 2 | 565272 | STG.A12.001 | 1 | false | false | 002_ | 002_565272.pdf |
| 3 | 565273 | STG.A12.001 | 2 | false | false | 003_ | 003_565273.pdf |
| 4 | 565274 | STG.A12.001 | 3 | false | false | 004_ | 004_565274.pdf |
| 5 | 565275 | STG.A12.002 | null | true | false | 001_ | 001_565275.pdf |
| 6 | 565276 | STG.A12.002 | 1 | false | false | 002_ | 002_565276.pdf |

**Observação:** Cada prisma reinicia a contagem em `001_`.

---

## 🎨 Padrão Final de Nome

```
{PREFIXO}_{NF}.pdf

Componentes:
  PREFIXO = 3 dígitos (001, 002, ..., 999)
  NF = número da nota (465271, 465272, ...)
  
Exemplos:
  001_565271.pdf
  002_565272.pdf
  003_565273.pdf
  099_565399.pdf
  100_565400.pdf
```

---

## 🚨 Casos Especiais

### **Caso 1: Mais de 999 PDFs em um prisma**

```
Se counter > 999:
  prefixo = pad_left(counter, 4, "0")  // "1000", "1001", ...
  
Resultado:
  999_565399.pdf
  1000_565400.pdf
  1001_565401.pdf
```

**Windows ainda imprime em ordem alfabética:**
```
999_565399.pdf  → imprime 1º
1000_565400.pdf → imprime 2º ✅ (porque "1" > "9" alfabeticamente? NÃO)
```

❌ **PROBLEMA:** Ordem alfabética quebra!
```
"1000..." < "999..." (string comparison)
```

**Solução para futuro:** Usar prefixo com até 3 dígitos garante ordem alfabética:
```
001 < 002 < ... < 999
```

Se precisar de >999, implementar:
```
A001, A002, ..., A999, B001, B002, ...
```

Por enquanto, assumimos **< 999 por prisma** ✅ (350 PDFs / ~10 prismas = ~35 por prisma).

---

## 💻 Power Automate Implementation

> Decisão atual: o Power Automate **não ordena** e **não calcula contador**. Ele usa `ORDEM_CLASSIFICACAO` recebido do dataset Power BI.

### **Step 1: Receber ORDEM_CLASSIFICACAO do dataset**

```
Campos mínimos da linha encontrada por CHAVE_ACESSO:
  NF
  SUB_LOC
  CHAVE_ACESSO
  ORDEM_CLASSIFICACAO
  PAGA_GUIA
  STATUS_FISCAL
  CASE_RILA
```

### **Step 2: Montar nome final**

```
filename = "EXPEDICAO_" + row.ORDEM_CLASSIFICACAO + "_NF_" + row.NF + ".pdf"
```

---

## Alternativa futura: contador por prisma

O trecho abaixo descreve a alternativa de contagem `001_`, `002_`, etc., mas não é a decisão atual do piloto.

### **Step 1: Sort dataset por PAGA_GUIA, DELIVERY**

```
Ação: "Compose" (ou "Sort array" se disponível)

Input: dataset (23 colunas)
Output: sorted_dataset (mesmo dataset, ordenado)

Pseudo:
sorted = SortByMultipleFields(
  dataset,
  [
    Field("PAGA_GUIA", "DESC"),
    Field("NOTA_MAE", "DESC"),
    Field("DELIVERY", "ASC")
  ]
)
```

### **Step 2: Loop e incrementar counter**

```
Ação: "Apply to each"

Variável: counter (tipo integer, inicial = 1)

Para cada linha do dataset sorteado:
  prefixo = pad_left(counter, 3, "0")
  filename = prefixo + "_" + row.NF + ".pdf"
  counter = counter + 1
  
  (continua com rename/move)
```

---

## 📊 Validação

### **Teste com 5 PDFs:**

```
INPUT:
  001. NF 565271 (NOTA_MAE, DELIVERY = null, PAGA_GUIA = false) → prisma A12.001
  002. NF 565272 (FILHA, DELIVERY = 1, PAGA_GUIA = false) → prisma A12.001
  003. NF 565273 (FILHA, DELIVERY = 2, PAGA_GUIA = false) → prisma A12.001
  004. NF 565274 (NOTA_MAE, DELIVERY = null, PAGA_GUIA = true) → prisma A12.002
  005. NF 565275 (FILHA, DELIVERY = 1, PAGA_GUIA = true) → prisma A12.002

OUTPUT (após fluxo):
  /prisma_STG.A12.001/
    001_565271.pdf
    002_565272.pdf
    003_565273.pdf
  
  /prisma_STG.A12.002/
    001_565274.pdf
    002_565275.pdf

IMPRESSÃO (operador abre cada pasta e imprime):
  Pasta 1:
    001_565271.pdf → imprime 1º ✅
    002_565272.pdf → imprime 2º ✅
    003_565273.pdf → imprime 3º ✅
  
  Pasta 2:
    001_565274.pdf → imprime 4º ✅
    002_565275.pdf → imprime 5º ✅

RESULTADO: Todos em ordem! ✅
```

---

## 🔗 Referência

- [`01_Fluxo_Classificador.md`](01_Fluxo_Classificador.md) — Step 4.3 usa esse algoritmo
- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md) — ORDEM_CLASSIFICACAO, PAGA_GUIA, NOTA_MAE
