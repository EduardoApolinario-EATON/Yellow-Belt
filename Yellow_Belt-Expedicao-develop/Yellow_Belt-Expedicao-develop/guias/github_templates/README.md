# GitHub Templates — Como usar (Power BI)

Arquivos prontos para copiar para o repositório corporativo em `.github/`

---

## 📋 Arquivos inclusos

| Arquivo | Destino | O que faz |
|---|---|---|
| `CODEOWNERS` | `.github/CODEOWNERS` | Define quem aprova mudanças (você) |
| `pull_request_template.md` | `.github/pull_request_template.md` | Template simplificado para PRs (validações manuais) |
| `bug_report.md` | `.github/ISSUE_TEMPLATE/bug_report.md` | Template para reportar bugs em dashboards |
| `feature_request.md` | `.github/ISSUE_TEMPLATE/feature_request.md` | Template para sugerir novos dashboards/medidas |

---

## 🚀 Setup passo a passo

### 1. Clone do repo corporativo

```bash
cd seu-repo-corporativo
```

### 2. Criar estrutura `.github/`

```bash
mkdir -p .github/ISSUE_TEMPLATE .github/workflows
```

### 3. Copiar arquivos

```bash
# CODEOWNERS
cp /caminho/para/guias/github_templates/CODEOWNERS .github/

# PR template
cp /caminho/para/guias/github_templates/pull_request_template.md .github/

# Issue templates
cp /caminho/para/guias/github_templates/bug_report.md .github/ISSUE_TEMPLATE/
cp /caminho/para/guias/github_templates/feature_request.md .github/ISSUE_TEMPLATE/
```

### 4. Customizar

#### `CODEOWNERS`
- Trocar `@seu-usuario-github` pelo seu username GitHub real
- Adicionar nomes de devs/times que também devem revisar
- Definir quem revisa que pasta

**Exemplo:**
```
* @seu-username-github
docs/ @seu-username-github
src/backend/ @dev-backend-username
tests/ @qa-team
```

#### `.github/workflows/ci.yml`
- Customizar conforme linguagem do projeto
- Remover jobs que não se aplicam (ex: Python se usar NodeJS)
- Adicionar step de deploy se necessário

#### `CODEOWNERS`, `pull_request_template.md`
- Adicionar links/referências específicos do seu projeto
- Customizar checklist conforme padrões da empresa

### 5. Commit

```bash
git add .github/
git commit -m "chore: adiciona templates e CI/CD GitHub"
git push origin develop
```

### 5. Habilitar branch protection (no GitHub UI)

Vá para **Settings → Branches → Branch protection rules** e configure:

Para `main`:
- ✅ Require a pull request before merging
- ✅ Require code reviews from CODEOWNERS: **1 approval**
- ✅ Include administrators (aplicar a si mesmo)

Para `develop`:
- ❌ Sem proteção (movimento rápido)

---

## 📝 Como cada arquivo é usado

### CODEOWNERS
Quando um PR é aberto, GitHub automaticamente:
1. Lê `.github/CODEOWNERS`
2. Identifica arquivos que mudaram
3. Adiciona pessoas/times como **reviewers obrigatórios**
4. PR não pode ser mergeado sem aprovação deles

### pull_request_template.md
Quando alguém clica em "New Pull Request", GitHub mostra automaticamente esse template no campo de descrição. O dev preenche e GitHub valida a qualidade das PRs.

### bug_report.md, feature_request.md
Quando alguém clica em "New Issue" → "Choose a template", GitHub oferece opções. Escolher "Bug Report" mostra esse template estruturado.

### ci.yml
Toda vez que há push ou PR em `main` ou `develop`:
1. GitHub Actions automaticamente roda o workflow
2. Executa testes, lint, security scans
3. Se algum falhar, PR fica vermelha
4. Branch protection impede merge até tudo passar

---

## 🎯 Fluxo visual após setup

```
1. Dev cria branch feature/...
2. Dev faz commits, push
3. Dev abre PR (GitHub mostra template)
4. GitHub Actions roda CI automaticamente
5. GitHub identifica arquivos mudados + CODEOWNERS
6. Seu usuário é adicionado como reviewer obrigatório
7. Você faz review + aprova
8. CI passa ✅
9. Dev faz merge
10. Deploy automático de develop → main (opcional)
```

---

## ⚙️ Customizações

Para Power BI, customizações mínimas:

### CODEOWNERS
- Trocar `@seu-usuario-github` pelo seu username GitHub real
- Se mais tarde tiver outro dev Power BI, adicionar:
  ```
  * @seu-usuario-github
  *.pbip @dev-power-bi-2
  ```

### pull_request_template.md
- Adaptar lista de tipos (se não faz Dashboard, altere)
- Adicionar links para guias de design / medidas padrão da empresa

---

## 🔍 Validação

Após setup, teste com uma PR teste:

```bash
git checkout -b test/validar-templates
echo "teste" > test.txt
git add .
git commit -m "test: validar templates"
git push origin test/validar-templates

# No GitHub, abrir PR develop → main
# Deve mostrar seu template
# Deve adicionar você como reviewer (via CODEOWNERS)
```

Se tudo aparecer, ✅ está funcionando!

---

## 📚 Referências

- [GitHub CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [GitHub PR Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)

---

**Dúvidas? Ver `Git-Workflow-Empresarial.md` para detalhes completos.**
