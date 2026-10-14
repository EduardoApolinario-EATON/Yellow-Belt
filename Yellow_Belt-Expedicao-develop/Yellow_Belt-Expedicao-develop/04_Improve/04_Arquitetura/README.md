# 🏗️ Arquitetura — Decisões Técnicas

> **Índice revisado: 2026-10-14.** Decisão observada: tabelas-base via múltiplos Bronze e joins M; sem acesso direto às views pelo modelo. A opção histórica não comprova todas as permissões/licenças propostas.

WSH atual: WSH_DOC, corte local 45 dias e deduplicação; não orientar ajustes exclusivos em WSH_DOC_CUR. Fonte oficial no orquestrador, Dataset é cópia. Ver [arquitetura e fronteiras atuais](../../docs_ferramenta/01_Documentacao_Tecnica.md) e [pendências de refresh/tenant](../../03_Analyze/07_Open_Questions.md).

> Fundação técnica da solução TO-BE.  
> **Último update:** 2026-06-23

---

## 📚 Documentos

| Doc | Função |
|---|---|
| [01_Opcao_D_Refatoracao.md](01_Opcao_D_Refatoracao.md) | Por que tabelas base, não views? Decisão arquitetural. |

> Conteúdos relacionados ficam nas pastas próprias:
> - Modelo semântico e paridade → [`../01_PowerBI/03_Modelo_Semantico.md`](../01_PowerBI/03_Modelo_Semantico.md) · [`../../03_Analyze/06_Restricao_PowerBI_Views.md`](../../03_Analyze/06_Restricao_PowerBI_Views.md)
> - Fluxos Power Automate → [`../02_PowerAutomate/`](../02_PowerAutomate/)
> - Armazenamento de PDFs → [`../03_Integracao/02_Armazenamento_PDFs.md`](../03_Integracao/02_Armazenamento_PDFs.md)

---

## 🎯 Pilares Arquiteturais

### **Pilar 1: Dados (Power BI)**
- ✅ 11 tabelas base Oracle (RA, HZ, CLL, WSH, MTL)
- ✅ Sem views (evita policy context)
- ✅ WHERE explícito (ORG_ID=1344, STATUS NOT IN ('4','6'))
- ✅ Relacionamentos em modelo (não em query)
- ✅ DAX para cálculos (PAGA_GUIA, NOTA_MAE, ORDEM_CLASSIFICACAO)

### **Pilar 2: Orquestração (Power Automate Cloud Free)**
- ✅ Flow #1: Sync diariamente 8h (PBI → Lista SharePoint)
- ✅ Flow #2: Monitora PDFs (OCR + Matching + Roteamento)
- ✅ Limite: 6.000 actions/dia (cobre ~350 NFs)
- ✅ Sem RPA inicial (Opção A manual)

### **Pilar 3: Armazenamento (SharePoint + OneDrive)**
- ✅ 3 Listas: EXP_NF_DATASET, EXP_CICLOS_LOG, EXP_FALHAS_LOG
- ✅ Pasta "Entrada_PDFs" monitora novos arquivos
- ✅ Pastas de saída por prisma (OLEO, MONITOR, etc.)
- ✅ Backup automático (OneDrive)

### **Pilar 4: Ingesta PDFs (Dual Path)**
- ✅ Opção A (now): Manual download → OneDrive
- ⏳ Opção B (later): RPA + SYNCHRO API (investigação)

---

## 🔗 Referência

- [`00_Estrategia_TO_BE.md`](../00_Estrategia_TO_BE.md) — Visão geral 1-pager
- [`08_Plano_de_Acao.md`](../08_Plano_de_Acao.md) — Timeline 4 semanas
