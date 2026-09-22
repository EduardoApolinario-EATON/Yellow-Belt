# 🚨 Tratamento de Erros

> O que fazer quando algo dá errado no fluxo.  
> **Último update:** 2026-06-22

---

## 🎯 Cenários de Erro

| Erro | Causa | Ação |
|---|---|---|
| **OCR falha** | PDF corrompido / imagem baixa qualidade | Move para `/FAILED/ocr/` |
| **CHAVE_ACESSO não encontrada** | OCR não conseguiu extrair | Move para `/FAILED/chave_nao_encontrada/` |
| **CHAVE não existe no dataset** | PDF de NF cancelada / deletada | Move para `/FAILED/chave_nao_existe_dataset/` |
| **Arquivo já existe no destino** | Duplicado do ciclo anterior | Append timestamp ao nome |
| **Sem permissão na pasta** | Problema autenticação SharePoint | Log + retry 3x |
| **Timeout (>30s por PDF)** | Fluxo muito lento | Dividir em múltiplos fluxos paralelos |

---

## 📋 Fluxo de Tratamento

### **Scenario 1: OCR Falha**

```
IF ocr_response.status != "success":
  
  // Log erro
  append_to_log(
    timestamp = now(),
    file = pdf_filename,
    error_type = "OCR_FAILED",
    error_msg = ocr_response.error_details,
    status = "FAILED"
  )
  
  // Move para pasta de retrabalho
  create_folder_if_not_exists("/FAILED/ocr/")
  move_file(
    source = "/INPUT/" + pdf_filename,
    destination = "/FAILED/ocr/" + pdf_filename
  )
  
  // Continue próximo arquivo
  continue
```

---

### **Scenario 2: CHAVE_ACESSO Não Encontrada**

```
IF not regex_match(ocr_text, /\d{44}/):
  
  // Log
  append_to_log(
    timestamp = now(),
    file = pdf_filename,
    error_type = "CHAVE_NAO_ENCONTRADA",
    error_msg = "Regex /\d{44}/ não encontrou match",
    ocr_text_preview = ocr_text.substring(0, 100),
    status = "FAILED"
  )
  
  // Move
  create_folder_if_not_exists("/FAILED/chave_nao_encontrada/")
  move_file(
    source = "/INPUT/" + pdf_filename,
    destination = "/FAILED/chave_nao_encontrada/" + pdf_filename
  )
  
  // Continue
  continue
```

---

### **Scenario 3: CHAVE Não Existe no Dataset**

```
IF chave_acesso not in dataset:
  
  // Log
  append_to_log(
    timestamp = now(),
    file = pdf_filename,
    chave_acesso = extracted_chave,
    error_type = "CHAVE_NAO_EXISTE_DATASET",
    error_msg = "Chave não encontrada em Power BI",
    status = "FAILED"
  )
  
  // Move
  create_folder_if_not_exists("/FAILED/chave_nao_existe_dataset/")
  move_file(
    source = "/INPUT/" + pdf_filename,
    destination = "/FAILED/chave_nao_existe_dataset/" + pdf_filename
  )
  
  // Continue
  continue
```

**Possível causa:** NF cancelada/deletada entre query Power BI e processamento PDF.  
**Investigação:** Operador confere se NF estava prevista no ciclo.

---

### **Scenario 4: Arquivo Duplicado**

```
IF file_exists("/PROCESSADO/prisma_" + sub_loc + "/" + new_filename):
  
  // Append timestamp para diferenciar
  timestamp_suffix = now().format("HHmmss")
  new_filename_unique = prefixo + "_" + nf + "_" + timestamp_suffix + ".pdf"
  
  // Log (WARNING, não ERROR)
  append_to_log(
    timestamp = now(),
    file = pdf_filename,
    error_type = "DUPLICADO",
    error_msg = "Arquivo já existe; renomeado com timestamp",
    filename_original = new_filename,
    filename_final = new_filename_unique,
    status = "SUCCESS_WITH_WARNING"
  )
  
  // Move com novo nome
  move_file(
    source = "/INPUT/" + pdf_filename,
    destination = "/PROCESSADO/prisma_" + sub_loc + "/" + new_filename_unique
  )
```

---

### **Scenario 5: Sem Permissão**

```
IF error.type == "UNAUTHORIZED" or "403":
  
  // Retry 3 vezes com backoff
  for retry = 1 to 3:
    try:
      move_file(...)
      break
    catch error:
      if retry < 3:
        wait(5 * retry)  // 5s, 10s, 15s
      else:
        throw error
  
  // Se falhar 3 vezes, log e move para FAILED
  append_to_log(
    timestamp = now(),
    file = pdf_filename,
    error_type = "PERMISSION_DENIED",
    error_msg = error.message,
    retry_attempts = 3,
    status = "FAILED"
  )
  
  move_file(
    source = "/INPUT/" + pdf_filename,
    destination = "/FAILED/permission_denied/" + pdf_filename
  )
```

---

### **Scenario 6: Timeout**

```
IF execution_time_per_file > 30_seconds:
  
  // Log
  append_to_log(
    timestamp = now(),
    file = pdf_filename,
    error_type = "TIMEOUT",
    error_msg = "Processamento > 30s (OCR lento?)",
    execution_time = execution_time_per_file,
    status = "TIMEOUT"
  )
  
  // Requeue para próximo ciclo
  move_file(
    source = "/INPUT/" + pdf_filename,
    destination = "/REQUEUE/" + pdf_filename
  )
```

---

## 📊 Estrutura de Log

### **Campo: ERROR_TYPE**

```
OCR_FAILED                    → Falha no OCR
CHAVE_NAO_ENCONTRADA         → OCR extraiu mas regex não encontrou
CHAVE_NAO_EXISTE_DATASET      → Chave não está em Power BI
DUPLICADO                     → Arquivo já existe (WARNING)
PERMISSION_DENIED            → Sem permissão SharePoint
TIMEOUT                       → Processamento > 30s
NETWORK_ERROR                 → Erro conexão
FILE_CORRUPTED                → Arquivo corrompido
UNKNOWN                       → Erro indefinido
```

### **Campo: STATUS**

```
SUCCESS                       → Processado corretamente
SUCCESS_WITH_WARNING          → Processado mas com aviso
FAILED                        → Erro — arquivo não processado
TIMEOUT                       → Pendente retry
```

---

## 🔄 Retry Policy

### **Erros temporários (com retry):**

- `TIMEOUT` (OCR lento)
- `PERMISSION_DENIED` (autenticação temporária)
- `NETWORK_ERROR`

**Politica:**
```
Tentativa 1: Imediato
Tentativa 2: +5s de espera
Tentativa 3: +10s de espera

Se falhar 3x: Mover para /FAILED/ e log
```

### **Erros permanentes (sem retry):**

- `OCR_FAILED` (arquivo corrompido)
- `CHAVE_NAO_ENCONTRADA` (PDF inválido)
- `CHAVE_NAO_EXISTE_DATASET` (NF deletada)

**Politica:**
```
Log imediatamente e move para /FAILED/
```

---

## 📧 Notificação de Erros

### **Se % de falha > 5%:**

```
Enviar email para: operador@eaton.com

Assunto: ⚠️ [YB-EXPEDICAO] Ciclo com falhas detectadas

Corpo:
  Taxa de falha: 7% (25 PDFs falharam de 350)
  
  Resumo de erros:
    - OCR_FAILED: 10
    - CHAVE_NAO_ENCONTRADA: 8
    - CHAVE_NAO_EXISTE_DATASET: 5
    - DUPLICADO: 2
  
  Recomendação:
    1. Verifique /FAILED/ para details
    2. Investigue qualidade dos PDFs
    3. Confirme se NFs estão ativas em Oracle
  
  Log completo: /EXPEDICAO/LOGS/ciclo_2026-06-22_1400.csv
```

### **Se 100% de falha (fluxo quebrado):**

```
Enviar email URGENTE + alert Slack para admin

Assunto: 🚨 CRÍTICO: Fluxo Power Automate falhou completamente

Corpo:
  Nenhum arquivo foi processado no ciclo de 14h.
  Possível causa:
    - Power BI dataset desconectado
    - API Document Intelligence offline
    - Folder /INPUT não acessível
  
  Ação imediata:
    1. Verifique status Power BI Service
    2. Verifique permissões SharePoint
    3. Execute manual (Opção B: download)
```

---

## 🗑️ Limpeza de Pasta /FAILED/

### **Política de retenção:**

```
Manter arquivos em /FAILED/ por 30 dias
Após 30 dias, arquivar em /FAILED/ARQUIVO/2026-06-XX/
```

### **Manual de resolução (para operador):**

```
/FAILED/ocr/
  → PDF corrompido? Peça ao Synchro para rescarregar.

/FAILED/chave_nao_encontrada/
  → OCR não reconheceu a chave? Tente extrair manualmente.

/FAILED/chave_nao_existe_dataset/
  → NF cancelada? Confirme no Oracle, deletar PDF.

/FAILED/permission_denied/
  → Permissão negada. Contact: IT-SharePoint-Admin
```

---

## 🔗 Referência

- [`01_Fluxo_Classificador.md`](01_Fluxo_Classificador.md) — onde os erros podem ocorrer
- [`05_Calculo_Acoes.md`](05_Calculo_Acoes.md) — impact nos limites
