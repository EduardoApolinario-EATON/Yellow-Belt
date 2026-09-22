# 👤 Fluxo do Operador — TO-BE

> Passo-a-passo: o que o operador faz no novo processo.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Documentar mudança do fluxo operador:

```
AS-IS (4h/ciclo):
  1. Download PDFs do Synchro (5 min)
  2. Abre cada PDF, extrai CHAVE_ACESSO
  3. Busca em dataset Oracle/Excel (90 min)
  4. Classifica por prisma + renomeia + move (90 min)
  5. Imprime por prisma (30 min)

TO-BE (~1h/ciclo):
  1. Download PDFs do Synchro (5 min)
  2. Upload para OneDrive/SharePoint (10 min)
  3. Aguarda Power Automate processar (5 min)
  4. Verifica resultado em SharePoint (5 min)
  5. Imprime PDFs (ordem já correta)
```

---

## 📋 TO-BE: Passo-a-Passo

### **Pré-requisitos:**
- OneDrive/SharePoint acesso
- Pasta compartilhada EXPEDICAO estruturada
- Power Automate fluxo ativo

---

### **Passo 1: Download do Synchro (IGUAL)**

```
1. Abrir Synchro (ferramenta existente)
2. Autenticação (mesmo processo)
3. Buscar NFs do dia (SYSDATE)
4. Download para pasta local: C:\Users\[user]\Downloads\
   (mesmo que hoje)

Tempo: ~5 min
Resultado: ~350 PDFs em local
```

---

### **Passo 2: Upload para SharePoint (NOVO)**

```
1. Abrir OneDrive / SharePoint (browser ou app)
   https://eaton.sharepoint.com/...
   
2. Navegar para: /Shared Documents/EXPEDICAO/INPUT/

3. Upload PDFs (3 opções):
   
   Opção A (mais fácil): Drag-drop
     ├─ Abrir explorer em C:\Downloads\
     ├─ Abrir browser em /INPUT/
     ├─ Arrastar PDFs para browser
     └─ Aguardar upload terminar (~30s por 100 PDFs)
   
   Opção B: Upload button
     ├─ Clicar "Upload"
     ├─ Selecionar arquivos
     └─ Confirmar
   
   Opção C: PowerShell (script)
     └─ (Se IT preparar script de upload em batch)

Tempo: ~10 min para 350 PDFs
Verificação: Todos aparecem em /INPUT/ com checkmark verde
```

---

### **Passo 3: Monitorar Fluxo (NOVO)**

```
1. Fluxo Power Automate inicia automaticamente
   (Trigger: "When a file is created")

2. Operador pode:
   
   Opção A: Apenas aguardar
     └─ Volver em ~5 min → pasta /PROCESSADO/ já terá resultado
   
   Opção B: Acompanhar em tempo real
     ├─ Abrir Power Automate web
     ├─ Clicar no fluxo "Classificador_YB_Expedicao"
     ├─ Ver "Recent runs"
     └─ Acompanhar status (Running → Succeeded/Failed)

Tempo: 5 min (fluxo executa em background)
Resultado: Emails notificação quando terminar
```

---

### **Passo 4: Verificar Resultado (NOVO)**

```
1. Abrir SharePoint /EXPEDICAO/PROCESSADO/

2. Conferir estrutura por prisma:
   /prisma_STG.A12.001/
   /prisma_STG.A12.002/
   /prisma_STG.B07.001/
   ...

3. Abrindo um prisma, ver PDFs renomeados:
   001_565271.pdf  ← NOTA_MAE
   002_565272.pdf  ← DELIVERY 1
   003_565273.pdf  ← DELIVERY 2

4. Se houver erros:
   ├─ Verificar /FAILED/ (pastacom PDFs que não processaram)
   └─ Ver arquivo de log: /LOGS/ciclo_YYYY-MM-DD_HHHH.csv

Tempo: 5 min
Problemas típicos → vide 05_Manual_Operador.md (Troubleshooting)
```

---

### **Passo 5: Imprimir (SIMILAR)**

```
Antes (AS-IS):
  1. Abrir pasta local com PDFs já renomeados
  2. Selecionar todos
  3. Imprimir

Depois (TO-BE):
  1. Abrir SharePoint /PROCESSADO/prisma_STG.A12.001/
  2. PDFs já estão renomeados (001_, 002_, 003_, ...)
  3. Selecionar todos
  4. Download ou imprimir direto do browser
  
  Opção A: Download para impressora local
    └─ Download → Print na impressora

  Opção B: Imprimir direto browser
    └─ Ctrl+P → selecionar impressora → imprimir

Tempo: ~30 min (mesmo que hoje, só que automático agora)
Benefício: Não precisa mais renomear manualmente
```

---

## 🎯 Comparativo

| Passo | AS-IS | TO-BE | Tempo Redução |
|---|---|---|---|
| 1. Download Synchro | Manual (5 min) | Igual (5 min) | 0 min |
| 2. Extração CHAVE_ACESSO | Manual (45 min) | Automático | -45 min |
| 3. Busca dataset | Manual (45 min) | Automático | -45 min |
| 4. Classificação | Manual (45 min) | Automático | -45 min |
| 5. Renomeação | Manual (15 min) | Automático | -15 min |
| 6. Upload + Espera | N/A | 15 min | N/A |
| 7. Impressão | Manual (30 min) | Manual (30 min) | 0 min |
| **TOTAL** | **4h** | **~1h** | **-3h** |

---

## 📧 Notificações

### **Email ao fim do ciclo:**

```
De: Power Automate <no-reply@powerautomate.com>
Para: operador@eaton.com
Assunto: [YB-EXPEDICAO] Classificação concluída — 2026-06-22 14h

---

Ciclo de 2026-06-22 14:00 processado com sucesso! ✅

📊 Resumo:
  ✅ Processados: 348 PDFs
  ❌ Falhas: 2 PDFs
  ⏱️ Tempo: 4 min 12 seg

📂 Estrutura criada:
  /prisma_STG.A12.001/   (45 PDFs)
  /prisma_STG.A12.002/   (48 PDFs)
  /prisma_STG.B07.001/   (52 PDFs)
  ... (10 prismas no total)

❌ PDFs com falha:
  - NOTA_UNKNOWN.pdf (CHAVE_ACESSO não encontrada)
  - NOTA_CORRUPT.pdf (arquivo corrompido)

Próxima ação:
  1. Abra SharePoint: /EXPEDICAO/PROCESSADO/
  2. Imprima por prisma (ordem já está correta!)
  3. Se tiver dúvida: vide 05_Manual_Operador.md

Log completo: /EXPEDICAO/LOGS/ciclo_2026-06-22_1400.csv
```

---

## 🚨 Troubleshooting

| Problema | Solução |
|---|---|
| **Upload lento** | Usar upload button (não drag-drop) se drag-drop travar |
| **Fluxo não executou** | Confirmar se arquivo foi criado com sucesso em INPUT |
| **PDFs em /FAILED/ (muitos)** | Verificar qualidade dos PDFs (corrompidos?) |
| **Pasta /prisma_XXX/ vazia** | Conferir no dataset Power BI se NF realmente existe |
| **PDF não renomeado** | Provavelmente em /FAILED — conferir motivo no log |
| **Permissão negada (403)** | Contactar IT — validar permissões SharePoint |

---

## 📅 Training (antes de go-live)

### **Sessão 1: Demonstração (30 min)**
- Operador acompanha flow de 5 PDFs
- Vê resultado em SharePoint
- Pergunta/respostas

### **Sessão 2: Hands-on (30 min)**
- Operador faz upload de 5 PDFs sozinho
- Monitora fluxo
- Verifica resultado
- Print test

### **Sessão 3: Suporte**
- IT fica de standby 1ª semana
- Troubleshooting on-demand

---

## 🔗 Referência

- [`02_Armazenamento_PDFs.md`](02_Armazenamento_PDFs.md) — Opção A (upload manual)
- [`../../05_Control/05_Manual_Operador.md`](../../05_Control/05_Manual_Operador.md) — Troubleshooting detalhado
