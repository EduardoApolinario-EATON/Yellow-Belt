# ⏳ Caminho B: RPA + SYNCHRO API (Investigação)

> Especificação técnica da automatização futura via API SYNCHRO.  
> **Status:** Investigação paralela (após Go-live Opção A).  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Eliminar a etapa manual (Opção A) automatizando download de PDFs via API SYNCHRO + RPA, resultando em ciclo **totalmente automático**.

**Tempo TO-BE:** ~30 min (sem input operador).

---

## 1. Arquitetura Proposta

```
SYNCHRO API
  ├─ OAuth 2.0 (login via token)
  └─ GET /v2/invoices?status=PRONTO,PROCESSANDO&org_id=1344&date=TODAY
      └─ Retorna JSON: [{ invoice_id, chave_acesso, pdf_url, ... }]
         ↓
Power Automate Desktop (RPA)
  ├─ Schedule: Daily 7 AM
  ├─ Step 1: Autenticar SYNCHRO API
  ├─ Step 2: Get lista invoices (JSON)
  ├─ Step 3: Para cada invoice:
  │   ├─ Download PDF (GET /pdf/{invoice_id})
  │   └─ Upload → SharePoint/Entrada_PDFs/
  └─ Step 4: Log execution
      ↓
Power Automate Cloud (Flow #2)
  └─ Dispara para cada PDF (como em Opção A)
      ↓
SAÍDA: PDFs classificados
```

---

## 2. Pré-requisitos Técnicos

### **Do Lado SYNCHRO**

- [ ] API documentada (Swagger/OpenAPI)
- [ ] Endpoints: GET /invoices, GET /pdf/{id}
- [ ] Auth: OAuth 2.0 ou API Key (preferir OAuth)
- [ ] Rate limits documentados (ex: 1000 req/min)
- [ ] PDF URLs estáveis (não expiram em < 1 hora)
- [ ] Teste sandbox disponível

### **Do Lado Empresa**

- [ ] Power Automate Desktop instalado (licença ou trial)
- [ ] Acesso RPA Policy aprovado por IT
- [ ] ServicePrincipal ou user account para RPA
- [ ] Certificado SSL se necessário (on-premises)

---

## 3. Fluxo Técnico Detalhado

### **Step 1: Autenticação SYNCHRO API**

```
POST /oauth/token
{
  "grant_type": "client_credentials",
  "client_id": "{APP_ID}",
  "client_secret": "{APP_SECRET}"
}

Response:
{
  "access_token": "eyJhbGc...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

**Em RPA:** Armazenar token em variável (cache por 50 min).

---

### **Step 2: Query Invoices**

```
GET https://api.synchro.platform/v2/invoices
  ?status=PRONTO,PROCESSANDO
  &org_id=1344
  &date=2026-06-22
  &limit=1000

Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Response: JSON array [
  {
    "invoice_id": "INV_001",
    "nf_number": "123456",
    "chave_acesso": "35210612345678901234567890123456789012",
    "pdf_url": "https://files.synchro/pdfs/INV_001.pdf",
    "status": "PRONTO",
    "org_id": 1344,
    "created_at": "2026-06-22T07:00:00Z"
  },
  ...
]
```

**Em RPA:** Loop por cada invoice_id.

---

### **Step 3: Download + Upload PDF**

```
Para cada invoice:

a) Download PDF:
   GET https://files.synchro/pdfs/{invoice_id}.pdf
   Headers: Authorization: Bearer {access_token}
   Salvar localmente: C:\RPA_Temp\INV_001.pdf

b) Upload SharePoint:
   PUT https://graph.microsoft.com/v1.0/
       /sites/{site_id}/drive/items/{folder_id}:/{filename}:/content
   Headers: Authorization: Bearer {sp_token}
   Body: arquivo PDF (multipart/form-data)

c) Na sequência, Flow #2 dispara (file trigger)
```

**Em RPA:** Usar connectors "HTTP Request" ou "REST Client".

---

### **Step 4: Log + Error Handling**

```
Para cada invoice processado:

✅ Success:
   - Log: "INV_001 downloaded → SharePoint OK (7.2 MB)"
   - Atualizar tabela EXP_CICLOS_LOG (item = INV_001, status = SUCCESS)

❌ Failure (download):
   - Log: "INV_001 download FALHOU (401 Unauthorized)"
   - Move para retry (up to 3x)
   - Se 3 falhas, log para EXP_FALHAS_LOG (reason = "API_ERROR")

❌ Failure (upload):
   - Log: "INV_001 upload FALHOU (no space)"
   - Notificar admin via email
   - Log para EXP_FALHAS_LOG (reason = "STORAGE_ERROR")
```

---

## 4. Implementação em Power Automate Desktop

### **Pseudocódigo RPA**

```
// Power Automate Desktop (RPA Flow)

DECLARE variables:
  synchro_token = ""
  synchro_url = "https://api.synchro.platform"
  sp_site_id = "site-123"
  sp_folder = "Entrada_PDFs"
  invoice_list = []
  success_count = 0
  fail_count = 0

// Step 1: Autenticar
HTTP_POST(
  url: synchro_url + "/oauth/token",
  body: { client_id, client_secret, grant_type },
  on_success: synchro_token = response.access_token
)

// Step 2: Query invoices
HTTP_GET(
  url: synchro_url + "/v2/invoices?status=PRONTO,PROCESSANDO&date=TODAY",
  headers: { Authorization: "Bearer " + synchro_token },
  on_success: invoice_list = response.data
)

// Step 3: Loop e processa
FOR EACH invoice IN invoice_list:
  invoice_id = invoice.invoice_id
  pdf_url = invoice.pdf_url
  
  // Download
  TRY:
    FILE_DOWNLOAD(
      url: pdf_url,
      headers: { Authorization: "Bearer " + synchro_token },
      save_to: "C:\\RPA_Temp\\" + invoice_id + ".pdf",
      on_success: 
        // Upload SharePoint
        HTTP_PUT(
          url: "https://graph.microsoft.com/v1.0/sites/{sp_site_id}/drive/items/{sp_folder}/{invoice_id}.pdf/content",
          headers: { Authorization: "Bearer " + sp_token },
          file: C:\\RPA_Temp\\{invoice_id}.pdf,
          on_success:
            LOG("SUCCESS: " + invoice_id)
            success_count++
            CREATE_LOG_ENTRY(table: EXP_CICLOS_LOG, status: SUCCESS)
        )
    )
  CATCH error:
    LOG("FAIL: " + invoice_id + " / " + error.message)
    fail_count++
    CREATE_LOG_ENTRY(table: EXP_FALHAS_LOG, reason: error.type)
    SEND_EMAIL(admin: "operador@empresa", subject: "RPA Falha")

// Step 4: Notificação final
SEND_EMAIL(
  subject: "RPA Ciclo " + TODAY,
  body: "Processados: " + success_count + " / " + (success_count + fail_count)
)
```

---

## 5. Alternativas de Plataforma RPA

| Opção | Setup | Custo | Complexidade | Recomendação |
|---|---|---|---|---|
| **Power Automate Desktop** | Native PA / Local | Incluido em lic. | Média | ✅ 1ª opção |
| **UiPath Community** | Download + server | Gratuito | Alta | Se já têm expertise |
| **Blue Prism** | Enterprise | Alto | Muito alta | Overkill |
| **Python + Scheduler** | Local / Azure | Baixo | Média | Alternativa |

**Recomendação:** Power Automate Desktop (integração nativa com PA Cloud).

---

## 6. Critérios de Viabilidade

| Critério | Status | Bloqueador |
|---|---|---|
| API SYNCHRO documentada | ❌ TBD | SIM |
| Teste de conectividade OK | ❌ Pending | SIM |
| Sandbox env. disponível | ❌ TBD | SIM |
| Taxa limite (req/min) > 200 | ❌ TBD | NÃO (retry) |
| PDF URLs estáveis 24h | ❌ TBD | SIM |
| RPA policy aprovada IT | ❌ Pending | SIM |
| Power Automate Desktop lic. | ⏳ In negotiation | NÃO (fallback PA Cloud) |

**Viabilidade atual:** **NÃO. Aguardando API SYNCHRO.**

---

## 7. Timeline Estimada

| Fase | Semanas | Owner |
|---|---|---|
| **Solicitar spec API** | 1 | Arquiteto + SYNCHRO |
| **Receber + revisar API** | 2-3 | Tech Lead |
| **Prototipar conexão** | 2 | PA Dev |
| **Testes sandbox** | 2 | QA |
| **Testes prod (paralelo)** | 1-2 | QA + Ops |
| **Deploy RPA** | 1 | DevOps |
| **Total** | **9-12 semanas** | — |

**Timing:** Go-live Opção A (semana 4) + 8 semanas = **Opção B em semana 12 (±)**.

---

## 8. Riscos + Mitigação

| Risco | Impacto | Mitigation |
|---|---|---|
| **API SYNCHRO não disponibilizada** | CRÍTICO | Manter Opção A indefinidamente |
| **PDF URLs expiram < 1h** | ALTO | Incrementar retry; download imediato |
| **Rate limit 100 req/min (insuficiente)** | MED | Batch em chunks; schedule off-peak |
| **RPA policy recusada IT** | MED | Usar Power Automate Cloud em vez de Desktop |
| **Certificado SSL expirado** | MÉDIO | Alertas + auto-renewal |

---

## 9. Plano de Testes (após viabilidade)

### **Fase 1: Unit Testing (Sandbox)**

```
✅ Autenticação SYNCHRO OK
✅ GET invoices retorna 10+ registros
✅ Download PDF 1 MB OK
✅ Upload SharePoint OK
✅ Log criado em EXP_CICLOS_LOG
```

### **Fase 2: Integration Testing (Produção, paralelo)**

```
✅ Rodar Opção A + Opção B lado-a-lado por 2 semanas
✅ Comparar resultado (mesmos PDFs, mesma classificação)
✅ Medir tempo: tempo_B < tempo_A?
✅ Medir falhas: fail_rate_B < 1%?
```

### **Fase 3: Cutover**

```
✅ Desativar Opção A (backup 7 dias)
✅ Ativar Opção B 100%
✅ Monitorar primeiras 2 semanas (alertas ativas)
```

---

## 🔗 Referência

- [`README.md`](README.md) — Opção A vs. B
- [`03_Decisao_e_Trigger.md`](03_Decisao_e_Trigger.md) — Critério de migração
- [`../02_PowerAutomate/01_Fluxo_Classificador.md`](../02_PowerAutomate/01_Fluxo_Classificador.md) — Flow #2 (saída comum)
