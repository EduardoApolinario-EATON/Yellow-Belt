# ✅ Checklist — Pré-Go-Live

> Validação final antes do primeiro ciclo em produção.  
> **Último update:** 2026-06-22

---

## 🎯 Objetivo

Garantir que tudo está pronto para o operador usar no ciclo 14h da Semana 4.

---

## 🔌 Infraestrutura

### **Power BI**
- [ ] Dataset publicado em Power BI Service
- [ ] Dataflow de ingestão executado com sucesso (tabelas-base)
- [ ] 23 colunas presente e validadas
- [ ] `CHAVE_ACESSO` normalizada com 44 dígitos, sem prefixo `DFE`
- [ ] `ORDEM_CLASSIFICACAO` calculada após sort final, sem uso de `ROW()` em DAX
- [ ] Paridade validada entre amostra da Query 2 e dataset final
- [ ] Decisão registrada: processar apenas `FINALIZADO/OK` no piloto ou também rotear exceções
- [ ] Dados do dia (TRX_DATE = SYSDATE) aparecem
- [ ] Dashboard com cards operacionais (no. de NFs, warnings, etc.)

### **SharePoint**
- [ ] Site criado / estrutura configurada
- [ ] Pastas /INPUT/, /PROCESSADO/, /FAILED/, /LOGS/ existem
- [ ] Permissões: Operador (upload/view), Power Automate (read/write)
- [ ] Estrutura sub-prismas criada (prisma_STG.A12.001/, etc.)

### **Power Automate**
- [ ] Fluxo "Classificador_YB_Expedicao" criado e publicado
- [ ] Trigger testado (cria arquivo em /INPUT → detecta?)
- [ ] Azure Document Intelligence conectado (OCR funciona)
- [ ] Log (array) configurado
- [ ] Notificação (email) testada

---

## 🧪 Testes

### **Teste Unitário (componentes isolados)**
- [ ] OCR extrai CHAVE_ACESSO corretamente (5 PDFs)
- [ ] Regex /\d{44}/ encontra 44 dígitos (não falso positivo)
- [ ] Match com dataset Power BI funciona
- [ ] Rename usa `ORDEM_CLASSIFICACAO` do dataset (`EXPEDICAO_A1_NF_...`)
- [ ] Move file funciona (origem → /PROCESSADO/prisma_XXX/)
- [ ] Log escreve corretamente

### **Teste E2E (fluxo completo)**
- [ ] 5 PDFs processados de ponta a ponta
- [ ] Resultado em /PROCESSADO/ com nomes corretos
- [ ] Falhas (se houver) em /FAILED/ com log
- [ ] Email notificação recebido

### **Teste de Performance**
- [ ] 100+ PDFs levam < 10 min (ou documentar timeline)
- [ ] Sem timeout (OCR, move, etc.)
- [ ] Power Automate actions < 70% do limite (~ 4.200 ações)

### **Teste de Operador (User Acceptance Test)**
- [ ] Operador consegue fazer upload de PDFs
- [ ] Operador entende notificação (email)
- [ ] Operador encontra resultado em SharePoint
- [ ] Operador consegue imprimir PDFs (ordem correta)

---

## 📚 Documentação

- [ ] README.md (raiz) — contexto para novo dev
- [ ] 01_Define/04_Regras_Negocio.md — regras claras
- [ ] 04_Improve/01_PowerBI/01_Dataset_Schema.md — schema 23 colunas
- [ ] 04_Improve/02_PowerAutomate/01_Fluxo_Classificador.md — steps do fluxo
- [ ] 04_Improve/02_PowerAutomate/02_Algoritmo_Matching.md — como extrair CHAVE
- [ ] 04_Improve/03_Integracao/01_Fluxo_Operador.md — passo-a-passo operador
- [ ] 04_Improve/03_Integracao/02_Armazenamento_PDFs.md — Opção A vs investigação
- [ ] 05_Control/05_Manual_Operador.md — troubleshooting rápido

---

## 🚨 Riscos Mitigados

| Risco | Mitigação | Status |
|---|---|---|
| OCR falha com PDF de baixa qualidade | Teste com 10+ PDFs reais, documentar fallback | [ ] |
| CHAVE_ACESSO não encontrada | Categoria de erro em /FAILED/, log detalhado | [ ] |
| Timeout (>30s/PDF) | Documentar timeline, avaliar paralelização | [ ] |
| Permissão negada SharePoint | IT validar antes, testar com operador | [ ] |
| Dataset Power BI desconectado | Agendado 13h (antes do ciclo 14h) | [ ] |
| Operador não sabe usar novo fluxo | Training sessão, manual, suporte standby | [ ] |
| Duplicatas (ciclos anteriores) | Arquivo timestamp naming if exists | [ ] |

---

## 📊 Métricas de Sucesso (Ciclo 1)

Após go-live Semana 4:

- **Taxa de sucesso:** ≥ 95% PDFs processados
- **Tempo fluxo:** ≤ 10 min para 350 PDFs
- **Operador tempo:** ≤ 1h ciclo (vs 4h AS-IS)
- **Erros:** < 5% em categorias conhecidas (/FAILED/)
- **Operador conforto:** Score ≥ 7/10 no feedback

---

## 📋 Sign-off

```
Preparado por:      ________________  Data: ___________
Testado por:        ________________  Data: ___________
Aprovado por:       ________________  Data: ___________
Operador OK:        ________________  Data: ___________
```

---

## 🔗 Referência

- [`01_Fases.md`](01_Fases.md) — timeline 4 semanas
- [`../../05_Control/05_Manual_Operador.md`](../../05_Control/05_Manual_Operador.md) — troubleshooting
