# 🗂️ Armazenamento de PDFs — Opção A vs Investigação Paralela

> Decisão crítica: Como operador salva PDFs para que Power Automate acesse?  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

**Problema:** Operador baixa PDFs do Synchro em pasta local (`Downloads/`).  
Power Automate Cloud Free só acessa OneDrive/SharePoint (não pasta local).

**Solução:** Dois caminhos paralelos.

---

## 🚀 OPÇÃO A: Manual Upload → OneDrive/SharePoint

### **Fluxo Operador (TO-BE, Opção A):**

```
1. Operador acessa Synchro → Downloads PDFs
   (mesma coisa de hoje)
   
2. Operador sobe PDFs para OneDrive/SharePoint
   /Shared Documents/EXPEDICAO/INPUT/
   (via drag-drop, upload web, ou PowerShell)
   
3. Power Automate detecta novos arquivos em /INPUT/
   (trigger: "When a file is created")
   
4. Power Automate classifica + renomeia + organiza
   
5. Operador abre SharePoint
   /EXPEDICAO/PROCESSADO/prisma_STG.A12.001/
   
6. Operador imprime PDFs na ordem (001_, 002_, ...)
```

---

### **Vantagens:**

✅ **Simples:** Operador só faz 1 passo a mais (upload)  
✅ **Funciona hoje:** OneDrive/SharePoint já está disponível  
✅ **Sem RPA:** Não precisa estudar macro velha ou API Synchro  
✅ **Cloud-native:** Alinhado com Microsoft stack  
✅ **Testável:** Começar com 5 PDFs amanhã  

---

### **Desvantagens:**

❌ **Mais um passo operador:** Não é 100% automático  
❌ **Risco human error:** Operador esquece upload?  
❌ **Menos eficiente:** Copia arquivo 2x (local → OneDrive, OneDrive → Processado)  

---

### **Implementação Imediata (Semana 1):**

```
1. Criar estrutura em SharePoint:
   /Shared Documents/EXPEDICAO/
     ├─ INPUT/              (operador upload aqui)
     ├─ PROCESSADO/         (fluxo salva aqui)
     │   ├─ prisma_STG.A12.001/
     │   ├─ prisma_STG.A12.002/
     │   └─ ...
     ├─ FAILED/             (PDFs com erro)
     └─ LOGS/               (CSV de execução)

2. Criar fluxo Power Automate:
   Trigger: "When a file is created in SharePoint"
   (folder: EXPEDICAO/INPUT)

3. Testar com 5 PDFs

4. Go-live com operador fazendo upload manual
```

---

## 🔍 OPÇÃO B (Paralela): Investigação — Synchro → SharePoint Automático

### **Objetivo:** Remover o passo manual do operador

**Perguntas pendentes:**

1. **Synchro tem API para download automatizado?**
   - Se SIM: Pode Power Automate chamar endpoint Synchro?
   - Docs: `03_Synchro_Integration.md`

2. **Synchro consegue salvar direto em SharePoint?**
   - Se SIM: Configurar como local padrão?
   - Pesquisar: Configurações Synchro × SharePoint integration

3. **Existe macro/script que baixa + sube?**
   - Se SIM: Pode adaptar para PowerShell?
   - Se NÃO: Vale a pena criar?

---

### **Timeline de Investigação (Semana 2-3):**

```
Semana 2:
  ✓ Agendar call com pessoal Synchro
  ✓ Perguntas: API? webhooks? auto-save options?
  ✓ Pedir documentação de endpoints
  ✓ Pedir acesso a sandbox Synchro

Semana 3:
  ✓ Se API encontrada: criar PoC Power Automate
  ✓ Se não: documentar decisão "INVIÁVEL"
```

---

### **Vantagens (se conseguir):**

✅ **100% automático:** Sem intervenção operador  
✅ **Mais eficiente:** Fluxo contínuo Synchro → Processado  
✅ **Escala:** Se crescer volume, já preparado  

---

### **Desvantagens:**

❌ **Risco:** Pode não ter API  
❌ **Dependência externa:** Sincronia Synchro × SharePoint  
❌ **Timing:** Semana 2-3 (demora)  

---

## 📊 Decisão: Implementar Opção A AGORA, Investigação PARALELA

```
Semana 1:
  ├─ Implement Opção A (manual upload) ← PRONTO PARA TESTE
  └─ Começar investigação Opção B (paralelo)

Semana 2:
  ├─ Testes Opção A com operador
  └─ Call Synchro + docs API

Semana 3:
  ├─ Refinements Opção A
  └─ PoC Opção B (se viável)

Semana 4:
  ├─ Go-live Opção A (com operador upload)
  └─ Se Opção B pronta: beta test com 10 PDFs

Pós-go-live:
  └─ Migrar para Opção B quando estável
```

---

## 🎯 Critérios para Migrar A → B

Só migra se TODOS os critérios forem atendidos:

1. ✅ API Synchro completamente documentada e testada
2. ✅ Power Automate conecta com sucesso (auth, endpoints)
3. ✅ PoC roda com 50+ PDFs sem erro
4. ✅ Timing é consistente (Synchro → SharePoint < 2 min)
5. ✅ Zero falhas de sincronização
6. ✅ Operador concorda com novo fluxo

---

## 💾 Estrutura SharePoint (para Opção A & B)

```
Shared Documents/EXPEDICAO/
│
├─ INPUT/
│   └─ (operador ou Synchro sobe aqui)
│
├─ PROCESSADO/
│   ├─ prisma_STG.A12.001/
│   │   ├─ 001_565271.pdf
│   │   ├─ 002_565272.pdf
│   │   └─ 003_565273.pdf
│   │
│   ├─ prisma_STG.A12.002/
│   │   ├─ 001_565274.pdf
│   │   └─ 002_565275.pdf
│   │
│   └─ (outras prismas...)
│
├─ FAILED/
│   ├─ ocr/
│   │   └─ (PDFs com OCR failed)
│   │
│   ├─ chave_nao_encontrada/
│   │   └─ (PDFs sem CHAVE_ACESSO)
│   │
│   ├─ chave_nao_existe_dataset/
│   │   └─ (PDFs de NF cancelada)
│   │
│   └─ (outras categorias)
│
└─ LOGS/
    └─ ciclo_2026-06-22_1400.csv
    └─ ciclo_2026-06-23_1400.csv
    └─ ...
```

---

## ✅ Checklist Implementação (Opção A)

- [ ] SharePoint site criado (ou usando existente)
- [ ] Estrutura de pastas criada
- [ ] Permissões: operador pode upload/view, Power Automate pode read/write
- [ ] Power Automate conectado a SharePoint
- [ ] Trigger testado (cria arquivo de teste em INPUT, detecta?)
- [ ] Renaming + moving testado (5 PDFs)
- [ ] Notificação final (email) testada
- [ ] Operador testou upload manual
- [ ] Rollback plan documentado (voltar para manual em caso de erro)

---

## 🔗 Referência

- [`../06_RPA_Synchro/02_Caminho_B_RPA_SYNCHRO_API.md`](../06_RPA_Synchro/02_Caminho_B_RPA_SYNCHRO_API.md) — resultados da investigação
- [`../02_PowerAutomate/01_Fluxo_Classificador.md`](../02_PowerAutomate/01_Fluxo_Classificador.md) — como fluxo acessa INPUT
