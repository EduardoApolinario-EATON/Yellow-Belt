# 🔄 Fluxo Classificador — Power Automate

> Steps detalhados do fluxo que classifica PDFs automaticamente.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Transformar esta rotina manual:
```
1. Operador baixa PDFs do Synchro
2. Operador abre cada PDF, extrai CHAVE_ACESSO
3. Busca a CHAVE_ACESSO no dataset (Oracle)
4. Identifica SUB_LOC (prisma)
5. Renomeia arquivo com prefixo
6. Move para pasta /prisma_STG.XXX.NNN/
7. Repete ~350 vezes
```

Em automação:
```
→ Trigger agendado (14h)
→ Fluxo classifica ~350 PDFs em ~2-5 min
→ Operador apenas verifica resultado
```

---

## 📐 Arquitetura do Fluxo

```
┌─────────────────────────────────────────────┐
│ Trigger: Schedule (diário, 14h)             │
└──────────────┬──────────────────────────────┘
               ↓
┌─────────────────────────────────────────────┐
│ Step 1: Query Power BI Dataset              │
│ (REST API: List tables + filter by date)    │
└──────────────┬──────────────────────────────┘
               ↓
┌─────────────────────────────────────────────┐
│ Step 2: Parse resposta JSON                 │
│ (22 linhas = 23 colunas - 1 cabeçalho)     │
└──────────────┬──────────────────────────────┘
               ↓
┌─────────────────────────────────────────────┐
│ Step 3: List files in /INPUT folder         │
│ (OneDrive/SharePoint)                       │
└──────────────┬──────────────────────────────┘
               ↓
┌─────────────────────────────────────────────┐
│ Step 4: Loop for each PDF                   │
│ ├─ Extract CHAVE_ACESSO                     │
│ ├─ Match com dataset                        │
│ ├─ Rename com prefixo                       │
│ ├─ Create folder /prisma_SUB_LOC/           │
│ └─ Move arquivo                             │
└──────────────┬──────────────────────────────┘
               ↓
┌─────────────────────────────────────────────┐
│ Step 5: Log resultado (CSV ou SharePoint)   │
└──────────────┬──────────────────────────────┘
               ↓
┌─────────────────────────────────────────────┐
│ Step 6: Notificação (Slack, Teams, email)   │
└─────────────────────────────────────────────┘
```

---

## 🔧 Steps Detalhados

### **Step 1: Query Power BI Dataset**

```
Ação: "List tables" (Power BI connector)
Ou: HTTP POST (mais controle)

Endpoint: 
https://analysis.windows.net/metadata/json/datasets/{datasetId}/tables/{tableName}

Query Parameters:
  ?$filter=TRX_DATE eq today()
  &$select=NF,CHAVE_ACESSO,SUB_LOC,DELIVERY,NOTA_MAE,PAGA_GUIA,ORDEM_CLASSIFICACAO,STATUS_FISCAL,CASE_RILA

Saída esperada:
{
  "value": [
    { "NF": "565271", "CHAVE_ACESSO": "123456789...44chars", "SUB_LOC": "STG.A12.001", "DELIVERY": null, "NOTA_MAE": true, "PAGA_GUIA": false, "ORDEM_CLASSIFICACAO": "A1", "STATUS_FISCAL": "FINALIZADO", "CASE_RILA": "OK" },
    { "NF": "565272", "CHAVE_ACESSO": "987654321...44chars", "SUB_LOC": "STG.A12.001", "DELIVERY": 1, "NOTA_MAE": false, "PAGA_GUIA": false, "ORDEM_CLASSIFICACAO": "A2", "STATUS_FISCAL": "FINALIZADO", "CASE_RILA": "OK" },
    ...
  ]
}
```

**Pseudocódigo:**
```
dataset = queryPowerBI()  // 23 colunas filtradas por data
indexByChave = createIndex(dataset, "CHAVE_ACESSO")  // lookup rápido
indexByNF = createIndex(dataset, "NF")
```

---

### **Step 2: Parse Resposta JSON**

```
Ação: "Parse JSON"

Schema (auto-gen from output Step 1):
{
  "type": "object",
  "properties": {
    "value": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "NF": { "type": "string" },
          "CHAVE_ACESSO": { "type": "string" },
          "SUB_LOC": { "type": "string" },
          "DELIVERY": { "type": "integer" },
          "NOTA_MAE": { "type": "boolean" },
          "PAGA_GUIA": { "type": "boolean" },
          "ORDEM_CLASSIFICACAO": { "type": "string" },
          "STATUS_FISCAL": { "type": "string" },
          "CASE_RILA": { "type": "string" }
          // ... outras 17 colunas
        }
      }
    }
  }
}
```

---

### **Step 3: List Files from OneDrive INPUT**

```
Ação: "List files in folder"

Connector: OneDrive for Business (ou SharePoint)
Folder: /Shared Documents/EXPEDICAO/INPUT/

Filter: 
  Include only .pdf files
  Created >= TODAY (opcional)

Saída:
[
  { "Id": "abc123", "Name": "NOTA_565271.pdf", "Size": 150000, "Created": "2026-06-22T09:00:00Z" },
  { "Id": "def456", "Name": "NOTA_565272.pdf", "Size": 160000, "Created": "2026-06-22T09:05:00Z" },
  ...
]
```

**Pseudocódigo:**
```
files = listFilesInFolder("/INPUT")
for each file in files:
  if file.extension != ".pdf":
    skip
```

---

### **Step 4: Loop — Classificar Cada PDF**

```
Ação: "Apply to each"

Para cada PDF:
  ├─ Step 4.1: Extrair CHAVE_ACESSO do PDF
  ├─ Step 4.2: Match com dataset
  ├─ Step 4.3: Montar nome final com ORDEM_CLASSIFICACAO
  ├─ Step 4.4: Criar pasta /prisma_SUB_LOC/
  ├─ Step 4.5: Renomear arquivo
  └─ Step 4.6: Mover arquivo
```

#### **Step 4.1: Extrair CHAVE_ACESSO do PDF**

```
OPÇÃO A (OCR simples - 4 blocos)
  ├─ Get file content (binário)
  ├─ Azure Document Intelligence (OCR) → extrai texto
  ├─ Regex: match 44 dígitos consecutivos
  └─ chave_acesso = resultado

OPÇÃO B (PDF text layer)
  ├─ Get file content (texto se disponível)
  ├─ Busca texto que pareça CHAVE_ACESSO (44 dígitos)
  └─ chave_acesso = resultado

DECISÃO PENDENTE: vide 02_Algoritmo_Matching.md
```

**Pseudocódigo:**
```
pdf_content = readFile(file)
text = extractText(pdf_content)  // OCR ou parsing
chave_acesso = regex_match(text, "\\d{44}")  // 44 dígitos

if not chave_acesso:
  log_error("CHAVE_ACESSO não encontrada", file)
  move_to_failed(file)
  continue
```

---

#### **Step 4.2: Match com Dataset**

```
Ação: "Condition"

if chave_acesso in indexByChave:
  row = indexByChave[chave_acesso]
  
  // Extrair colunas necessárias
  nf = row["NF"]
  sub_loc = row["SUB_LOC"]
  delivery = row["DELIVERY"]
  nota_mae = row["NOTA_MAE"]
  ordem_classificacao = row["ORDEM_CLASSIFICACAO"]
  status_fiscal = row["STATUS_FISCAL"]
  case_rila = row["CASE_RILA"]
  
  // Próximo step
else:
  log_error("CHAVE_ACESSO não encontrada no dataset", chave_acesso)
  move_to_failed(file)
  continue
```

**Pseudocódigo:**
```
match = dataset.find(row => row.CHAVE_ACESSO === chave_acesso)

if match:
  { nf, sub_loc, delivery, nota_mae, paga_guia, ordem_classificacao, status_fiscal, case_rila } = match
  goto Step 4.3
else:
  goto FAILED
```

---

#### **Step 4.3: Montar Nome Final com ORDEM_CLASSIFICACAO**

```
Ação: "Compose"

Regra:
  O Power BI já entrega ORDEM_CLASSIFICACAO calculada após o sort final.
  O Power Automate apenas concatena prefixo + NF.
```

**Exemplo:**
```
NF 565271 (DELIVERY = null, NOTA_MAE = true)
  → ORDEM_CLASSIFICACAO: A1
  → Nome final: EXPEDICAO_A1_NF_565271.pdf

NF 565271.001 (DELIVERY = 1, NOTA_MAE = false)
  → ORDEM_CLASSIFICACAO: A2
  → Nome final: EXPEDICAO_A2_NF_565271.001.pdf

NF 565271.002 (DELIVERY = 2, NOTA_MAE = false)
  → ORDEM_CLASSIFICACAO: A3
  → Nome final: EXPEDICAO_A3_NF_565271.002.pdf
```

**Pseudocódigo:**
```
new_filename = "EXPEDICAO_" + ordem_classificacao + "_NF_" + nf + ".pdf"
```

---

#### **Step 4.4: Criar Pasta /prisma_SUB_LOC/**

```
Ação: "Create folder"

Connector: OneDrive / SharePoint
Parent folder: /EXPEDICAO/PROCESSADO/

Folder name: "prisma_" + sub_loc
  Exemplo: "prisma_STG.A12.001", "prisma_STG.A12.002"

Resultado:
/EXPEDICAO/PROCESSADO/prisma_STG.A12.001/  ← criada se não existir
```

**Pseudocódigo:**
```
folder_name = "prisma_" + sub_loc
folder_path = "/EXPEDICAO/PROCESSADO/" + folder_name

if not folder_exists(folder_path):
  create_folder(folder_path)
```

---

#### **Step 4.5: Renomear Arquivo**

```
Ação: "Rename file"

Old name: file.Name  // Ex: "NOTA_565271.pdf"
New name: new_filename  // Ex: "001_565271.pdf"

Resultado:
/EXPEDICAO/INPUT/NOTA_565271.pdf
    ↓ (renomeia)
/EXPEDICAO/INPUT/001_565271.pdf
```

**Pseudocódigo:**
```
rename_file(file, new_filename)
```

---

#### **Step 4.6: Mover Arquivo**

```
Ação: "Move file"

Source: /EXPEDICAO/INPUT/
File: new_filename
Destination: /EXPEDICAO/PROCESSADO/prisma_<SUB_LOC>/

Resultado:
/EXPEDICAO/PROCESSADO/prisma_STG.A12.001/001_565271.pdf
```

**Pseudocódigo:**
```
move_file(
  source: file,
  destination: folder_path + new_filename
)
```

---

### **Step 5: Log Resultado**

```
Ação: "Append to array variable" + "Create CSV table"

Estrutura de log:

[
  { 
    "timestamp": "2026-06-22T14:00:15Z",
    "file_original": "NOTA_565271.pdf",
    "chave_acesso": "1234567890123456789012345678901234567890",
    "nf": "565271",
    "sub_loc": "STG.A12.001",
    "prefixo": "001",
    "file_renamed": "001_565271.pdf",
    "status": "SUCCESS",
    "msg": ""
  },
  {
    "timestamp": "2026-06-22T14:00:20Z",
    "file_original": "NOTA_UNKNOWN.pdf",
    "chave_acesso": "NOT_FOUND",
    "nf": null,
    "sub_loc": null,
    "prefixo": null,
    "file_renamed": null,
    "status": "FAILED",
    "msg": "CHAVE_ACESSO não encontrada"
  },
  ...
]
```

**Salvar em:**
- SharePoint List: `EXP_CICLOS_LOG`
- OneDrive CSV: `/EXPEDICAO/LOGS/ciclo_2026-06-22_1400.csv`

---

### **Step 6: Notificação Final**

```
Ação: "Send an email" (ou Slack, Teams)

Para: operador@eaton.com

Assunto: [YB-EXPEDICAO] Classificação concluída — 2026-06-22 14h

Corpo:
Ciclo de 2026-06-22 14:00 concluído com sucesso!

✅ Processados: 348 PDFs
❌ Falhas: 2 PDFs
⏱️ Tempo: 4 min 12 seg

PDFs com falha:
  - NOTA_UNKNOWN.pdf (CHAVE_ACESSO não encontrada)
  - NOTA_XXX.pdf (arquivo corrompido)

Próximos passos:
1. Abra SharePoint: /EXPEDICAO/PROCESSADO/
2. Verifique pastas por prisma
3. Imprima na ordem certa (001_, 002_, 003_, ...)

Log completo: /EXPEDICAO/LOGS/ciclo_2026-06-22_1400.csv
```

---

## 🚨 Tratamento de Erros

Ver [`04_Tratamento_Erros.md`](04_Tratamento_Erros.md)

---

## 📊 Limites & Capacidade

Ver [`05_Calculo_Acoes.md`](05_Calculo_Acoes.md)

---

## 🔗 Referência

- [`02_Algoritmo_Matching.md`](02_Algoritmo_Matching.md) — decisão sobre extração CHAVE_ACESSO
- [`03_Estrategia_Renaming.md`](03_Estrategia_Renaming.md) — padrão final de nomes
- [`../../01_Define/04_Regras_Negocio.md`](../../01_Define/04_Regras_Negocio.md) — NOTA_MAE, SUB_LOC
