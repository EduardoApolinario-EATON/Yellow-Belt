# Git Workflow Empresarial — Guia Prático

> **Contexto do projeto revisado: 2026-10-14.** O guia abaixo é referência geral, não estado confirmado de proteções, revisores ou pipeline. Nomes/exemplos e comandos devem ser adaptados ao processo corporativo autorizado.

O PBIP oficial permanece no orquestrador; não criar fonte concorrente em Dataset. Não commitar dados fiscais/caches/segredos nem publicar em PROD sem aceite. Para a ferramenta, seguir [Handoff vigente](../04_Improve/05_Implementacao/HANDOFF.md); branches, políticas e proprietários devem ser confirmados com TI.

> Fluxo colaborativo com controle de branch, approvals e release management.
> Para aplicar no repositório corporativo da empresa.
> Última atualização: 2026-05-28

---

## 1. Visão geral do modelo

```
┌─────────────────────────────────────────────────────┐
│ main (protegida — só via PR aprovado)              │ ← PRODUÇÃO
│ └─ tags: v1.0.0, v1.1.0 (releases)                 │
└─────────────────────────────────────────────────────┘
        ↑ PR + Code Review (1-2 aprovações)
        │
┌─────────────────────────────────────────────────────┐
│ develop (integração — acumula features)            │ ← STAGING
│ └─ merges de feature/* + hotfixes                   │
└─────────────────────────────────────────────────────┘
        ↑ PR + testes passam (1 aprovação)
        │
┌─────────────────────────────────────────────────────┐
│ feature/*, bugfix/*, hotfix/* (branches pessoais)  │ ← TRABALHO
│ └─ cada dev trabalha aqui                           │
└─────────────────────────────────────────────────────┘
```

**Fluxo:** Dev cria branch → trabalha → abre PR em develop → review + testes → merge → quando pronto, PR de develop → main → release.

---

## 2. Estrutura de branches

| Branch | Propósito | Criado de | Merge em | Proteção |
|---|---|---|---|---|
| `main` | Produção, estável | — | — | ✅ Exige PR + 1-2 approvals |
| `develop` | Integração contínua | main | main | ✅ Exige PR + 1 approval |
| `feature/*` | Nova funcionalidade | develop | develop | ❌ Sem proteção |
| `bugfix/*` | Correção não-urgente | develop | develop | ❌ Sem proteção |
| `hotfix/*` | Correção urgente prod | main | main + develop | ⚠️ Merge direto em main, depois em develop |

### Convenção de nomes
```
feature/nome-descritivo       # feature/automacao-nfs
bugfix/problema-encontrado   # bugfix/fix-timezone-issue
hotfix/urgencia              # hotfix/crash-impressao
```

---

## 3. Setup de proteção de branch (GitHub)

### 3.1 Habilitar Branch Protection Rules

No GitHub, vá para: **Settings → Branches → Branch protection rules**

**Para `main`:**
- ✅ **Require a pull request before merging**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require status checks to pass before merging (CI/testes)
  - ✅ Require branches to be up to date before merging
- ✅ **Require code reviews before merging**
  - Número de approvals: **2** (você + 1 outro)
  - ✅ Dismiss stale pull request reviews when new commits are pushed
  - ✅ Require review from Code Owners (CODEOWNERS)
- ✅ **Require status checks to pass before merging**
  - Adicionar: `build`, `test`, `lint` (se tiver CI/CD)
- ✅ **Include administrators** (aplicar regras até pra você)

**Para `develop`:**
- ✅ Require a pull request before merging
  - ✅ Require status checks to pass before merging
- ✅ Require code reviews before merging
  - Número de approvals: **1**
  - ✅ Require review from Code Owners

---

## 4. CODEOWNERS — Definir aprovadores obrigatórios

Crie arquivo `.github/CODEOWNERS` (sem extensão):

```
# Padrão: /caminho/arquivo @usuario

# Tudo requer seu review
* @seu-usuario-github

# Documentação requer seu review
docs/ @seu-usuario-github
*.md @seu-usuario-github

# Workflows CI/CD requer seu review
.github/workflows/ @seu-usuario-github

# Opcional: outro dev para partes específicas
src/modules/api/ @outro-dev
tests/ @outro-dev

# Exemplos:
# * @seu-usuario-github
# *.sql @seu-dba
# src/frontend/ @dev-frontend
# src/backend/ @dev-backend
```

**Efeito:** GitHub força que pessoas listadas aqui aprovem antes de merge.

---

## 5. Pull Request Workflow (passo a passo)

### 5.1 Dev começa trabalho

```bash
# 1. Sincronizar develop local
git checkout develop
git pull origin develop

# 2. Criar branch de feature
git checkout -b feature/minha-funcionalidade

# 3. Fazer commits
git add .
git commit -m "feat: adiciona classificador de PDFs"
git commit -m "test: adiciona testes do classificador"

# 4. Push para origin
git push origin feature/minha-funcionalidade
```

### 5.2 Abrir Pull Request

No GitHub:
- Botão "New Pull Request"
- **Base:** develop (padrão)
- **Compare:** feature/minha-funcionalidade
- **Título:** `feat: classificador de PDFs`
- **Descrição:** preencher template (ver seção 6)
- **Reviewers:** GitHub sugere automaticamente via CODEOWNERS
- **Labels:** `enhancement`, `bug`, `documentation`, etc.

### 5.3 Code Review & CI

- ✅ Testes rodarem automaticamente (GitHub Actions)
- ✅ Linter passar (sem erros de estilo)
- ✅ Reviewer(s) analisar código
- ❌ Se não passar, dev corrige e faz novo push

### 5.4 Merge para develop

Quando aprovado:
- Botão "Squash and merge" (1 commit limpo) **ou**
- Botão "Create a merge commit" (preservar histórico)

Recomendação: **squash** para develop, **merge commit** para main.

---

## 6. Pull Request Template

Arquivo: `.github/pull_request_template.md`

```markdown
## Descrição
Descreva brevemente o que foi feito.

## Tipo de mudança
- [ ] Feature (nova funcionalidade)
- [ ] Bug fix (correção de bug)
- [ ] Refactoring (código, sem mudança de comportamento)
- [ ] Documentação
- [ ] Infraestrutura / CI-CD

## Checklist
- [ ] Testes adicionados / atualizados
- [ ] Documentação atualizada
- [ ] Sem breaking changes
- [ ] Build passa sem warnings
- [ ] Testei localmente

## Como testar
Instruções passo-a-passo para testar a mudança:
1. ...
2. ...

## Related Issues
Closes #123 (se houver)

## Screenshots (se aplicável)
```

---

## 7. Release Management (deploy para main)

### Quando a feature em develop está pronta para produção:

```bash
# 1. Criar branch de release
git checkout -b release/v1.2.0 develop

# 2. Bump version (no README, package.json, etc)
# Editar versão → commit
git commit -m "chore: bump to v1.2.0"

# 3. Push release branch
git push origin release/v1.2.0

# 4. Abrir PR: release/v1.2.0 → main
# (requer 2 approvals conforme proteção de branch)

# 5. Merge em main
# GitHub sugere deletar branch

# 6. Criar tag (opcional automático)
git tag v1.2.0
git push origin v1.2.0
```

**Alternativa com GitHub Releases:** Use a interface de Releases do GitHub para criar versão + notes automaticamente.

---

## 8. Hotfix (correção urgente em produção)

Se bug crítico em main:

```bash
# 1. Branch de hotfix de main
git checkout -b hotfix/crash-urgente main

# 2. Corrigir + commit
git commit -m "fix: resolve crash na impressão"

# 3. Push
git push origin hotfix/crash-urgente

# 4. Abrir PR: hotfix/* → main
# (com label "HOTFIX" ou "URGENT")

# 5. Merge em main (rápido, 1-2 approvals)

# 6. IMPORTANTE: Fazer PR de hotfix → develop
# para que develop tenha a correção também
git checkout develop
git pull origin develop
git merge hotfix/crash-urgente  # ou criar PR
git push origin develop
```

---

## 9. Boas práticas

### Commits
```
❌ Ruim:
git commit -m "ajustes"
git commit -m "fix"

✅ Bom (Conventional Commits):
git commit -m "feat: adiciona campo SUB_LOC ao dataset"
git commit -m "fix: corrige regex de extração de chave"
git commit -m "docs: atualiza manual do operador"
git commit -m "refactor: simplifica lógica do classificador"
git commit -m "test: adiciona testes de paridade Oracle"

Prefixos:
- feat: nova feature
- fix: correção de bug
- refactor: mudança no código, sem mudança de comportamento
- test: testes
- docs: documentação
- chore: tarefas (bump version, deps, etc)
```

### Code Review
```
✅ Bom feedback:
"Esta regex pode não capturar CNPJ com zeros à esquerda. 
Considere usar \d{2}\.?\d{3}\.?\d{3}/?\d{4}-?\d{2} 
Veja exemplo em https://regexr.com/..."

❌ Ruim:
"Isso tá errado"
"Por que fez assim?"
```

### Antes de mergear
- [ ] Branch está atualizada com develop/main
- [ ] Testes passam localmente
- [ ] Sem merge conflicts
- [ ] Squash commits desnecessários
- [ ] Mensagens de commit claras

---

## 10. Fluxo visual completo

```
Dev A começa: feature/dashboard
  ↓
faz 3 commits → push
  ↓
abre PR em develop
  ↓
GitHub Actions roda testes → ✅ passa
  ↓
você (dono) review → aprova
  ↓
Dev A clica "Squash and merge" em develop
  ↓
[ 1 semana depois ]
decide fazer release v1.2.0
  ↓
cria branch release/v1.2.0 de develop
  ↓
bump version → abre PR em main
  ↓
GitHub Actions roda testes + status checks → ✅
  ↓
você aprova PR de release
  ↓
requer 2ª aprovação (CODEOWNERS) → você aprova de novo
  ↓
Dev A (ou você) clica "Merge pull request" em main
  ↓
GitHub cria tag v1.2.0 automaticamente (com Actions)
  ↓
v1.2.0 vai para produção 🚀
```

---

## 11. Configuração de CI/CD (GitHub Actions — exemplo mínimo)

Arquivo: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: pip install -r requirements.txt
      
      - name: Lint
        run: pylint **/*.py
      
      - name: Run tests
        run: pytest

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run security scan
        run: |
          # Exemplo: verificar secrets expostos
          # ou análise de dependências
```

---

## 12. Permissões e times (GitHub)

### Organizador recomendado (se usar org GitHub)

```
Organização
├── Team "Core" (você)
│   └── Role: Admin (all permissions)
│
├── Team "Developers"
│   └── Role: Maintain (PR, push branches)
│
└── Team "Viewers"
    └── Role: Read (só ler, sem escrever)
```

### Permissões por role
| Role | Merge PR | Push main | Delete branch | Change settings |
|---|---|---|---|---|
| Admin | ✅ | ✅ | ✅ | ✅ |
| Maintain | ✅ | ❌ | ✅ | ❌ |
| Write | ✅ | ❌ | ❌ | ❌ |
| Triage | ✅ | ❌ | ❌ | ❌ |
| Read | ❌ | ❌ | ❌ | ❌ |

---

## 13. Checklist de setup no repo corporativo

- [ ] Criar branch `develop` de `main`
- [ ] Habilitar branch protection em `main` (2 approvals)
- [ ] Habilitar branch protection em `develop` (1 approval)
- [ ] Criar `.github/CODEOWNERS` (você como approver)
- [ ] Criar `.github/pull_request_template.md`
- [ ] Criar `.github/workflows/ci.yml` (se houver testes)
- [ ] Adicionar README com Git Workflow
- [ ] Definir permissões de time (Admin, Maintain, Read)
- [ ] Testar com 1ª PR (você mesmo, de branch teste)

---

## 14. Troubleshooting comum

### "Minha branch está desatualizada com develop"

```bash
git fetch origin
git rebase origin/develop
# ou
git merge origin/develop
```

### "PR tem merge conflicts"

GitHub mostra o conflito. Opções:
1. **Resolve conflicts** (botão no GitHub UI)
2. Ou local:
```bash
git pull origin develop
git merge --no-ff origin/develop  # resolve conflitos
git push origin feature/...
```

### "Quero atualizar meu PR antes que seja aprovado"

Simplesmente faça novo commit e push na mesma branch:
```bash
git add .
git commit -m "fix: address review comments"
git push origin feature/...
```

### "Acidentalmente mergei sem approval"

Se foi recente, GitHub permite "Revert" no UI — cria PR reverso automaticamente.

---

## 15. Exemplo real (seu repo corporativo)

**Cenário:** Você e João vão refatorar as queries Oracle para Opção D.

```bash
# João cria branch
git checkout develop
git pull origin develop
git checkout -b feature/refactor-queries-opton-d

# João faz 3 commits
git commit -m "refactor: reescreve Query 1 contra tabelas-base"
git commit -m "test: adiciona testes de paridade contra Oracle"
git commit -m "docs: atualiza schema_saida.md"

git push origin feature/refactor-queries-opton-d

# GitHub: abre PR, CI passa, João pede seu review
# Você revisa código → aprova → João faz squash merge

# 2 semanas depois, pronto para produção
# Você cria release/v2.0.0 de develop → 2 approvals → merge em main
# Deploy automático (via Actions ou manual)

# Tudo rastreado:
# git log --oneline main  # vê cada release
# git tag                 # vê todas as versões
```

---

## Resumo dos comandos principais

```bash
# Setup inicial
git clone <repo>
git checkout develop

# Iniciar feature
git checkout -b feature/meu-nome
git add .
git commit -m "tipo: mensagem"
git push origin feature/meu-nome

# Atualizar com develop
git fetch origin
git rebase origin/develop

# Preparar para merge (squash commits menores)
git rebase -i origin/develop  # rebase interativo

# Push final
git push origin feature/meu-nome

# [Abrir PR no GitHub]

# Merge em develop (do GitHub UI, não local)
# [Deletar branch local após merge]
git branch -D feature/meu-nome
```

---

**Documento concluído.** Agora vá para a pasta `guias/github_templates/` para ver os arquivos prontos para copiar.
