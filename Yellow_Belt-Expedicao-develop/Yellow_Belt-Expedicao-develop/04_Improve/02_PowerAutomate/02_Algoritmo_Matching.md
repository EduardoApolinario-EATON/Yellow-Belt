# 🎯 Algoritmo de Matching — CHAVE_ACESSO

> **Revisão: 2026-10-14.** Algoritmo proposto, não comprovado no export atual. Não assumir OCR/leitura de conteúdo: origem da chave e padrão dos PDFs devem ser confirmados no fluxo.

No modelo CHAVE_ACESSO é bruta; CHAVE_LEN mede comprimento bruto; CHAVE_44 faz trim/remove DFE; nenhuma garante dígitos/DV. Conciliar por chave autorizada, detectar ambiguidades/duplicados e testar chave ausente, prefixada ou fora do universo. Licenciamento e compliance de serviços externos exigem aprovação. Ver [contrato atual](../01_PowerBI/01_Dataset_Schema.md) e [P02-P04/P13](../../03_Analyze/07_Open_Questions.md).

> Como extrair a CHAVE_ACESSO de cada PDF e fazer match com o dataset.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

**Problema:** 350 PDFs nomeados como "NOTA_565271.pdf" chegam sem padrão definido.  
**Solução:** Extrair CHAVE_ACESSO (44 dígitos) de dentro do PDF e usar como chave de lookup no dataset Power BI.

---

## 📋 O que é CHAVE_ACESSO?

```
Origem Oracle: JL_BR_AR_*DOCUMENT_DETAILS.ACCESS_KEY
Formato: 44 dígitos (sequência numérica)
Exemplo: 12345678901234567890123456789012345678901234

Localização no PDF:
  - Normalmente em seção "Chave de Acesso" ou "Access Key"
  - Pode estar em diferentes posições (topo, meio, rodapé)
  - Pode estar em múltiplos formatos (com/sem espaços, formatado)
```

---

## 🔧 Opções de Extração

### **OPÇÃO A: OCR + Azure Document Intelligence** ✅ RECOMENDADA

```
Fluxo:
  1. Power Automate read file (PDF binário)
  2. Envia para Azure Document Intelligence (OCR)
  3. Extrai todo texto da página
  4. Regex: busca 44 dígitos consecutivos
  5. Retorna CHAVE_ACESSO

Vantagem:
  ✅ Não requer conhecer posição da chave no PDF
  ✅ Robusto a variações de layout
  ✅ Parte do Power Automate standard

Desvantagem:
  ❌ Primeiro uso gera delay (instância warm-up)
  ❌ Custo de ação: ~4-5 ações por PDF
  ❌ Limite Cloud Free: 6.000 ações/dia
     (350 PDFs × 5 ações = 1.750 ações → OK)
  ❌ OCR pode falhar com PDFs de imagem baixa qualidade
```

**Pseudocódigo:**
```
pdf_bytes = read_file("NOTA_565271.pdf")
text = azure_document_intelligence_ocr(pdf_bytes)
chave_acesso = regex_extract(text, /\d{44}/)

if not chave_acesso:
  log_error("OCR falhou ou CHAVE não encontrada", file)
```

**Power Automate Steps:**
1. "Get file content" → `{$select: 'body'}`
2. "Send an HTTP request" → endpoint Azure Document Intelligence
3. "Parse JSON" → resposta OCR
4. "Compose" → regex extract 44 dígitos

---

### **OPÇÃO B: Heurística Simples** ❌ NÃO RECOMENDADA

```
Fluxo:
  1. Extrai nome arquivo (Ex: "NOTA_565271.pdf")
  2. Regex busca qualquer sequência de 44 dígitos no nome
  3. Se encontra, assume que é CHAVE_ACESSO
  4. Se não encontra, busca no diretório de origem

Vantagem:
  ✅ Muito rápido
  ✅ Sem custos de ação adicional

Desvantagem:
  ❌ Assume que CHAVE_ACESSO vem no nome — nem sempre é verdade
  ❌ Frágil a mudanças de nomenclatura
  ❌ Muitas falhas de matching
```

---

### **OPÇÃO C: Power BI Query Direta (SEM extração)** ❌ INVIÁVEL

```
Fluxo:
  1. Lista todos os PDFs em /INPUT
  2. Para cada PDF, procura um match no dataset
     PROBLEM: Como fazer matching sem CHAVE_ACESSO?
  
Cenários de fallback:
  - Match por tamanho de arquivo? → Não confiável
  - Match por tempo criação? → Ambíguo
  - Match por NF (mas NF não está no nome do arquivo)? → Impossível

Resultado: Inviável sem informação única de identificação.
```

---

## ✅ DECISÃO: Usar OPÇÃO A (OCR)

### Razão:

1. **Robustez:** Não importa como o PDF é nomeado, extrai a CHAVE_ACESSO do conteúdo
2. **Precisão:** 44 dígitos é pattern único — baixa chance de falso positivo
3. **Capacidade:** 350 PDFs × ~5 ações/PDF = 1.750 ações/dia << 6.000 limite Cloud Free
4. **Cobertura:** Todos os PDFs já têm CHAVE_ACESSO (vem de Oracle para PDF fiscais)

### Fallback (se CHAVE_ACESSO não encontrada):

```
if ocr_chave_acesso not found:
  → Move para /FAILED/
  → Log: "CHAVE_ACESSO não encontrada no PDF"
  → Operador investiga manualmente depois
```

---

## 🔍 Regex Pattern

```regex
\d{44}
```

**Explicação:**
- `\d` = qualquer dígito (0-9)
- `{44}` = exatamente 44 vezes

**Teste:**
```
String: "Chave de Acesso: 12345678901234567890123456789012345678901234"
Match: 12345678901234567890123456789012345678901234 ✅

String: "Chave: 123456789012345678901234567890123456789012345"  (43 dígitos)
Match: None ❌ (correto — não é válido)

String: "Nota nº 12345"
Match: None ✅ (correto — não é CHAVE_ACESSO)
```

---

## 🗂️ Fluxo Completo (com OCR)

```
INPUT: /EXPEDICAO/INPUT/NOTA_565271.pdf

Step 1: Get file content (PDF binário)
   ↓
Step 2: Send HTTP POST to Azure Document Intelligence
   Endpoint: https://westus.api.cognitive.microsoft.com/formrecognizer/v3.0/analyze
   Body: pdf_bytes (binário)
   ↓
Step 3: Parse resposta JSON (texto extraído)
   Response: { "analyzeResult": { "readResults": [ { "lines": [ { "text": "..." }, ... ] } ] } }
   ↓
Step 4: Compose - extrai todo texto num string
   text = join(all lines, "\n")
   ↓
Step 5: Condition - regex \d{44}
   chave_acesso = regex_match(text, /\d{44}/)
   ↓
IF found:
   Step 6: Query dataset Power BI (match por CHAVE_ACESSO)
   Step 7: Rename/Move (vide 01_Fluxo_Classificador.md)
ELSE:
   Step 6: Move para /FAILED/
   Step 7: Log erro
```

---

## 📊 Casos de Sucesso & Falha

| Cenário | CHAVE_ACESSO | Resultado |
|---|---|---|
| PDF normal (NF fiscal) | `12345678901234567890123456789012345678901234` | ✅ Match → classifica |
| PDF corrompido / imagem baixa | Não legível | ❌ Move para /FAILED/ |
| NF cancelada (sem CHAVE) | None | ❌ Move para /FAILED/ |
| PDF duplicado (mesma CHAVE) | `12345678901234567890123456789012345678901234` | ✅ Match → classifica como filha |

---

## 🚨 Questões Aberta

1. **OCR com acurácia suficiente?**  
   → Testar com 10 PDFs reais, validar acurácia

2. **Múltiplas CHAVE_ACESSO no mesmo PDF?**  
   → Tomar a primeira? Último? Regex é ambíguo?
   → Solução: validar com time — qual é o padrão?

3. **Timeout no OCR?**  
   → Azure Document Intelligence pode levar 2-3s por PDF
   → Com 350 PDFs sequencial = 15-20 min total
   → Se problema, considerar processamento paralelo (múltiplos fluxos)

4. **Custo OCR?**  
   → Azure Document Intelligence: ~R$ 0.50-1.00 por 100 páginas
   → 350 PDFs × 1 página = R$ 1.75-3.50 por ciclo
   → Viável? (Depende orçamento Cloud)

---

## 🔗 Referência

- [`01_Fluxo_Classificador.md`](01_Fluxo_Classificador.md) — Step 4.1 usa esse algoritmo
- [`02_Algoritmo_Matching.md`](02_Algoritmo_Matching.md) — este documento
- Azure Document Intelligence: [Microsoft Docs](https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/overview)
