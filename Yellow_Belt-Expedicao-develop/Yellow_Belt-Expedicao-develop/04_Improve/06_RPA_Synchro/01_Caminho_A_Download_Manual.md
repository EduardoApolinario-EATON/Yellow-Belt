# 📥 Caminho A: Download Manual → OneDrive/SharePoint

> **Revisão: 2026-10-14.** Roteiro proposto/histórico; sequência e export atual do SYNCHRO não foram confirmados nesta revisão. Não prometer nome DFE/chave, lote ZIP ou compatibilidade sem amostra autorizada.

Na rotina aprovada, conferir arquivos na biblioteca online e conciliar por chave antes de PROCESSAR PDFs. Ícone de nuvem pode representar arquivo disponível online; não é necessariamente upload pendente. Ver [Manual do Operador](../../05_Control/05_Manual_Operador.md) e [P02/P18](../../03_Analyze/07_Open_Questions.md).

> Procedimento operacional para ingesta de PDFs (TO-BE imediato).  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

O operador faz download de PDFs do SYNCHRO e os coloca em uma pasta OneDrive/SharePoint que dispara o **Flow #2 (Classificador)** automaticamente.

**Tempo:** ~10 min/dia (operador) + 15 min automático (sistema).

---

## 1. Pré-requisitos

- [ ] Operador tem acesso a SYNCHRO (browser login OK)
- [ ] Operador tem conta OneDrive/SharePoint
- [ ] SharePoint pasta "Entrada_PDFs" criada e compartilhada
- [ ] Power Automate Flow #2 ativo e testado
- [ ] Operador treinou com 5-10 PDFs em staging

---

## 2. Passo-a-Passo Diário (Operador)

### **7:00 AM — Acesso SYNCHRO**

1. Abrir navegador → [synchro.plataforma.com](https://synchro.plataforma.com)
2. Login com credentials
3. Navegar para: **Relatórios** → **Impressão** → **Pendentes de Hoje**
4. Aparece lista de NFs (tipicamente 50-350/dia)

```
Exemplo de lista:
  NF 001-123456  | Status: PROCESSANDO | CHAVE: 35210612345678901234567890123456789012
  NF 001-123457  | Status: PRONTO     | CHAVE: 35210612345678901234567891234567890123
  ...
```

### **7:05 AM — Download em Lote**

5. Selecionar **"Todos"** (checkbox header) ou marcar manualmente
   - Ou: Filtrar status = "PRONTO" + "PROCESSANDO" (exclui CANCELADO)
6. Clicar **"Download ZIP"** (botão verde)
7. Salvar arquivo como: `NF_ENTRADA_20260622.zip` (com data de hoje)
   - Local: `C:\Usuarios\operador\Downloads\`

```
Resultado esperado:
  NF_ENTRADA_20260622.zip (~50-200 MB típico)
  └─ contem ~350 PDFs
```

### **7:10 AM — Extração Local**

8. Clicar direito no ZIP → **"Extrair Para"**
9. Selecionar destino: `C:\Usuarios\operador\Entrada_PDFs_Temp\`
10. Aguardar conclusão (~2-3 min se lento)

```
Resultado:
  C:\Usuarios\operador\Entrada_PDFs_Temp\
  ├─ NF_123456_20260622.pdf
  ├─ NF_123457_20260622.pdf
  ├─ NF_123458_20260622.pdf
  └─ ... (até 350 arquivos)
```

### **7:15 AM — Upload para OneDrive/SharePoint**

11. Abrir **OneDrive** ou **SharePoint** (navegador ou app)
12. Navegar para pasta: **Entrada_PDFs** (compartilhada com equipe)
13. Selecionar todos os PDFs extraídos
14. **Drag & drop** ou **Upload** (botão azul)
15. Aguardar upload completar (~5 min para 350 arquivos)

```
Resultado no OneDrive:
  Entrada_PDFs/
  ├─ NF_123456_20260622.pdf ← Trigger Flow #2!
  ├─ NF_123457_20260622.pdf ← Trigger Flow #2!
  ├─ NF_123458_20260622.pdf ← Trigger Flow #2!
  └─ ... (até 350 arquivos)
```

---

## 3. O Que Acontece Depois (Automático)

Uma vez que o primeiro PDF chega em `Entrada_PDFs/`, o **Flow #2** dispara:

```
7:15 AM +1s: PDF chega
  ├─ Step 1: Trigger dispara (file event)
  ├─ Step 2: Extrai CHAVE_ACESSO (OCR)
  ├─ Step 3: Query ao dataset Power BI
  │   └─ Lookup "NF existe? Qual SUB_LOC?"
  ├─ Step 4: Calcula ORDEM_CLASSIFICACAO (prefixo)
  │   └─ Exemplo: 001_NF_123456.pdf
  ├─ Step 5: Cria pasta destino em SharePoint
  │   └─ Caminho: OLEO/PAGA_GUIA_SIM/001_NF_123456.pdf
  └─ Step 6: Move PDF + notifica

7:45 AM: Todos os 350 PDFs processados ✅
  └─ Operador pode verificar em SharePoint > Prismas > OLEO
```

---

## 4. Checagem Diária (Operador)

### **8:00 AM — Validação Rápida**

16. Abrir **SharePoint** → Pasta **"Prismas"** (saída)
17. Verificar subpastas por PRISMA:
    - OLEO_PAGA_GUIA_SIM/
    - OLEO_PRONTO/
    - MONITOR_DELIVERY/
    - etc.
18. Contar PDFs: deve estar ≈ número de PDFs que entrou

```
Exemplo:
  Entrada_PDFs/: 350 PDFs
  Saída (Prismas):
    OLEO_PAGA_GUIA_SIM/: 120 PDFs ✅
    OLEO_PRONTO/:        80 PDFs ✅
    MONITOR_DELIVERY/:   130 PDFs ✅
    FALHAS/:             20 PDFs ⚠️ (checar)
  Total: 350 ✅
```

### **8:30 AM — Se Houver Falhas**

19. Entrar pasta **"FALHAS/"**
20. Abrir cada PDF que falhou
21. Verificar:
    - Arquivo corrompido? → Pedir re-download
    - CHAVE ilegível? → Extrair manual e renomear
    - NF não encontrada no dataset? → Contatar BI team
22. Mover manualmente para pasta correta se possível

---

## 5. Tratamento de Erros Comuns

| Erro | Solução |
|---|---|
| **"Arquivo não encontrado no dataset"** (FALHAS/) | Contatar BI: NF pode estar com status ERRO ou não existe nessa org |
| **"OCR não consegue ler CHAVE"** (FALHAS/) | Arquivo PDF de baixa qualidade. Rename manualmente com base em impressão, mova para destino |
| **ZIP não baixa** | Tentar novamente. Se persistir, contatar SYNCHRO support |
| **Upload muito lento** | Dividir em 2-3 ZIPs menores. Upload paralelo. |
| **Flow #2 não dispara** | Verificar se arquivo está em "Entrada_PDFs" (não em subpasta). Contatar PA dev. |

---

## 6. Passos de Fallback (Se Algo Quebrar)

### **Flow #2 parado?**

1. Não fazer upload para SharePoint ainda
2. Contatar PA Dev (Teams urgent): "Flow #2 não dispara"
3. Manter PDFs locais em `Entrada_PDFs_Temp\`
4. Quando Flow voltar, fazer upload que faltou

### **SYNCHRO fora do ar?**

1. Não há PDFs novos a processar
2. Informar Project Manager
3. Reagendar ciclo para próximo dia útil

### **OneDrive/SharePoint fora do ar?**

1. Manter PDFs em pasta local: `C:\Entrada_PDFs_Backup\`
2. Quando SharePoint voltar, fazer upload em lote
3. (Risco: se demorarem >1 dia, PDFs podem expirar em SYNCHRO)

---

## 7. Métricas para Monitorar

| Métrica | Alvo | Frequência |
|---|---|---|
| **Tempo upload** | < 15 min | Diário |
| **Taxa sucesso (PDF → destino correto)** | > 98% | Diário |
| **Taxa falha (PDF → FALHAS/)** | < 2% | Diário |
| **Retrabalho manual** | < 5 min/dia | Diário |
| **Uptime Flow #2** | > 99% | Semanal |

---

## 8. Comunicação

### **Quem Contatar**

| Problema | Contato | Via |
|---|---|---|
| Flow #2 parado | PA Dev Team | Teams #padev-expedicao |
| NF não encontrada no dataset | BI Team | Teams #bi-data |
| SYNCHRO acesso recusado | SYNCHRO Admin | Email synchro-support@empresa |
| Erro upload SharePoint | IT SharePoint | Ticket Service Now |

### **Relatório Diário (Operador)**

Enviar todo dia 8h15 via email:

```
📋 Relatório Ciclo de Impressão — 2026-06-22

Entrada SYNCHRO:    350 PDFs
Upload → SharePoint: 350 PDFs ✅
Processadas:        342 PDFs (97.7%) ✅
Falhas (FALHAS/):    8 PDFs (2.3%)
  - 5x OCR ilegível
  - 2x NF não encontrada
  - 1x Arquivo corrompido

Ação pendente:
  - Contactar BI sobre NF não encontrada
  - Rename manual 5 PDFs (ilegível)

Tempo total: 25 min ✅
```

---

## 📌 Checklist Diário (Copie para seu Outlook)

```
☐ 7:00 AM  — Acesso SYNCHRO OK
☐ 7:05 AM  — Download ZIP iniciado
☐ 7:10 AM  — ZIP extraído localmente
☐ 7:15 AM  — Upload iniciado (OneDrive)
☐ 7:20 AM  — Upload completou
☐ 8:00 AM  — Flow #2 processado todos PDFs?
☐ 8:05 AM  — Verificar FALHAS/
☐ 8:15 AM  — Relatório diário enviado
☐ 8:20 AM  — Operador pronto para próxima etapa (impressão)
```

---

## 🔗 Referência

- [`README.md`](README.md) — Opção A vs. B
- [`../02_PowerAutomate/01_Fluxo_Classificador.md`](../02_PowerAutomate/01_Fluxo_Classificador.md) — O que Flow #2 faz
- [`../02_PowerAutomate/02_Algoritmo_Matching.md`](../02_PowerAutomate/02_Algoritmo_Matching.md) — OCR + Matching detalhe
