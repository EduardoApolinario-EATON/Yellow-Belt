# guias/ — Git Workflow para Power BI / Analytics

> Documentos e templates para trabalho colaborativo no repositório corporativo.
> Otimizado para ambientes de BI (dataflows, modelos semânticos, reports).
> Última atualização: 2026-05-28

---

## 📚 Documentos

| Documento | Descrição |
|---|---|
| [`Git-Workflow-PowerBI.md`](Git-Workflow-PowerBI.md) | **Guia completo** para Git + Power BI — estrutura simples, 1 approval, sem CI/CD |

---

## 📁 Templates prontos para copiar

Pasta: [`github_templates/`](github_templates/)

| Arquivo | Destino | O que faz |
|---|---|---|
| `CODEOWNERS` | `.github/CODEOWNERS` | Define você como approver |
| `pull_request_template.md` | `.github/pull_request_template.md` | Template de PR (checklist de validações) |
| `bug_report.md` | `.github/ISSUE_TEMPLATE/bug_report.md` | Template para reportar bugs |
| `feature_request.md` | `.github/ISSUE_TEMPLATE/feature_request.md` | Template para sugerir features |

---

## 🚀 Como usar

### Passo 1: Ler o guia completo
Abra [`Git-Workflow-PowerBI.md`](Git-Workflow-PowerBI.md) (20 min).

### Passo 2: Entender a estrutura
- 3 branches: `main` (produção) ← `develop` (sandbox) ← `feature/*` (trabalho)
- 1 approval em `main` (você)
- Nenhuma proteção em `develop` (rápido)
- Sem CI/CD (não faz sentido para Power BI)

### Passo 3: Setup no repo corporativo
Abra [`github_templates/README.md`](github_templates/README.md) e siga "Setup passo a passo".

### Passo 4: Testar
Crie uma PR teste seguindo o fluxo.

---

## 📖 Resumo do guia

| Seção | Assunto |
|---|---|
| 1-2 | Visão geral e estrutura (simples) |
| 3-4 | Branch protection + CODEOWNERS |
| 5-6 | Workflow prático + PR template |
| 7 | Fluxo visual end-to-end |
| 8 | Boas práticas |
| 9-11 | Proteção de dados, equipe, comparação |
| 12-15 | Checklist, troubleshooting, exemplo real |

---

## 💡 Diferenças vs Backend

| Aspecto | Backend | Power BI |
|---|---|---|
| Approvals em main | 2 | **1** |
| Testes automáticos | Sim | Não |
| CI/CD pipeline | Sim | Não |
| Merge conflicts | Frequentes | Raros |
| Code review | Rigoroso (dias) | Rápido (min) |
| Approval em develop | Sim | Não |

---

## ✅ Estrutura final no repo corporativo

```
seu-repo-corporativo/
├── .github/
│   ├── CODEOWNERS
│   ├── pull_request_template.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
├── .gitignore (credenciais, dados sensíveis)
├── README.md (instruções setup)
├── main (branch protegida — produção)
├── develop (branch — sandbox)
└── [seus dataflows, modelos, reports em .pbip]
```

---

## 🎯 Próximos passos

1. ✅ Ler `Git-Workflow-PowerBI.md` completo
2. ✅ Customizar templates conforme seu projeto
3. ✅ Copiar para repo corporativo
4. ✅ Habilitar branch protection (1 approval em main)
5. ✅ Fazer 1ª PR teste
6. ✅ Documentar padrões de commits para o time

---

**Perguntas?** Consulte `Git-Workflow-PowerBI.md` seção 13 (troubleshooting).
