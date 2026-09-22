# Git Workflow para Power BI / Análise de Dados

> Fluxo colaborativo simples e rápido para dataflows, modelos semânticos e reports.
> Para aplicar no repositório corporativo de BI/Analytics.
> Última atualização: 2026-05-28

---

## 1. Visão geral do modelo

```
┌──────────────────────────────────────┐
│ main (protegida — produção)          │ ← POWER BI SERVICE
│ └─ 1 approval: você valida           │
└──────────────────────────────────────┘
        ↑ PR + 1 review visual
        │ (você abre Power BI, confere)
┌──────────────────────────────────────┐
│ develop (sandbox — sem proteção)     │ ← DEV / STAGING
│ └─ merges rápidas de features        │
└──────────────────────────────────────┘
        ↑ PR (rápido, sem approval obrigatório)
        │
┌──────────────────────────────────────┐
│ feature/* (seu trabalho local)       │ ← POWER BI DESKTOP
│ └─ você trabalha no Desktop          │
└──────────────────────────────────────┘
```

**Fluxo:** Você abre Power BI Desktop → trabalha em `feature/...` → commit `.pbip` → PR em develop → merge rápido → depois PR em main → você aprova → merge para produção.

---

## 2. Estrutura de branches

| Branch | Propósito | Criado de | Merge em | Proteção |
|---|---|---|---|---|
| `main` | Produção, Power BI Service | — | — | ✅ Requer 1 approval (você) |
| `develop` | Integração, sandbox | main | main | ❌ Sem proteção (movimento rápido) |
| `feature/*` | Nova dashboard / dataflow | develop | develop | ❌ Sem proteção |
| `fix/*` | Correção de bug | develop | develop | ❌ Sem proteção |

### Convenção de nomes
```
feature/dashboard-vendas           # novo dashboard
feature/refactor-medidas-icms      # otimizar DAX
fix/data-errada-abril              # corrigir valores
fix/performance-query              # melhorar velocidade
```

---

## 3. Setup simples no GitHub

### 3.1 Branch Protection em `main`

No GitHub: **Settings → Branches → Branch protection rules** → criar regra para `main`

```
✅ Require a pull request before merging
   ✅ Dismiss stale pull request approvals when new commits are pushed
   
✅ Require code reviews before merging
   ✅ Number of approvals: 1
   ✅ Require review from Code Owners
   
❌ Require status checks to pass (não há testes em BI)

✅ Include administrators (aplicar a si mesmo)
```

### 3.2 Nenhuma proteção em `develop`

Deixar aberta — permite movimento rápido. O gatekeeping é só em main.

---

## 4. CODEOWNERS — Simples

Arquivo: `.github/CODEOWNERS`

```
# Tudo requer sua aprovação antes de entrar em main
* @seu-usuario-github
```

**Efeito:** GitHub automaticamente convida você para revisar todo PR que chegar em main.

---

## 5. Workflow prático (passo a passo)

### 5.1 Começar nova feature

```bash
# 1. Sincronizar develop local
git checkout develop
git pull origin develop

# 2. Criar branch de feature
git checkout -b feature/meu-dashboard

# 3. Abrir Power BI Desktop — conectar ao repo local
#    (File → Open from git)
```

### 5.2 Fazer mudanças no Power BI Desktop

- Adicionar nova medida DAX
- Criar relatório novo
- Atualizar dataflow
- Tudo é salvo em `.pbip` (JSON estruturado)

### 5.3 Commitar mudanças

```bash
# Git detecta mudanças em .pbip
git status

# Commitar (message clara)
git add .
git commit -m "feat: dashboard de vendas com drill-down por região"

# Push
git push origin feature/meu-dashboard
```

### 5.4 Abrir PR em develop

No GitHub:
- Botão "New Pull Request"
- **Base:** develop
- **Compare:** feature/meu-dashboard
- **Título:** `Dashboard: vendas por região`
- **Descrição:** preencher template (seção 6)
- **Reviewer:** ninguém obrigatório (development é rápido)

### 5.5 Mergear em develop

Você ou colega:
- Revisa rapidamente (visualmente — pode abrir Power BI Desktop)
- Se OK: clica "Merge pull request"
- Branch deletada automaticamente

### 5.6 Colocar em produção (main)

Quando pronto (após testes em develop/sandbox):

```bash
# Opção A: Abrir PR develop → main no GitHub
# (GitHub UI)

# Opção B: Linha de comando
git checkout main
git pull origin develop
git merge develop
git push origin main
```

Quando chegar a main:
- GitHub avisa você (CODEOWNERS)
- Você revisa visualmente
- Aprova ("Approve")
- Você mesmo faz merge (ou alguém do time)
- Deploy automático OU manual (publish em Power BI Service)

---

## 6. PR Template — Simples

Arquivo: `.github/pull_request_template.md`

```markdown
## O que foi adicionado / modificado?

Descreva brevemente o que mudou:
- [ ] Novo dashboard
- [ ] Dataflow atualizado
- [ ] Medida DAX refatorada
- [ ] Relatório revisado
- [ ] Outra: _________

## Validações manuais

Antes de mergear, validei:
- [ ] Abri localmente em Power BI Desktop
- [ ] Dados aparecem corretamente (sample rows)
- [ ] Performance OK (queries não travaram)
- [ ] Visuais estão legíveis (cores, labels)
- [ ] Sem erros de DAX (sem warnings vermelhos)

## Notas para reviewer

Algo específico que você deva validar?

(Opcional — ex: "atentar para a medida ICMS que mudou",
"teste com dados de 2024 antes de aprovar")

## Pronto para produção?

- [ ] Sim, mergear em main após PR
- [ ] Não, ainda em desenvolvimento em develop
```

---

## 7. Fluxo visual completo

```
Você abre Power BI Desktop
    ↓
Edita em develop local / feature branch
    ↓
Commita (.pbip muda)
    ↓
git push origin feature/dashboard-x
    ↓
Abre PR develop (sem approval obrigatório)
    ↓
Você ou colega revisa (30 segundos — visual)
    ↓
Mergea em develop
    ↓
[Sandbox testing — alguns dias]
    ↓
Cria PR develop → main
    ↓
Você aprova (review visual ~ 5 min)
    ↓
Mergea em main
    ↓
Publica em Power BI Service (manual ou automático)
    ↓
Pronto em produção 🚀
```

---

## 8. Boas práticas para Power BI

### Commits claros
```
✅ Bom:
feat: dashboard de vendas com drill-down regional
fix: corrigir medida de ICMS que estava zerando
refactor: simplificar DAX da medida de frete

❌ Ruim:
ajustes
fix
updated dashboard
```

### Mensagens de PR
```
✅ Bom:
"Novo dashboard consolidado de vendas.
Incluí drill-down por região e período.
Testei com dados de 2024, tudo OK."

❌ Ruim:
"novo dashboard"
"pronto"
```

### Merge conflicts (raros em BI, mas acontecem)

Se 2 pessoas editam mesma medida DAX:
```bash
# Git vai mostrar conflito no .pbip
# Opção 1: Abrir Power BI Desktop, Power BI resolve visualmente
# Opção 2: Reescrever DAX manualmente, testar, commitar

git add .
git commit -m "resolve: merge conflict em medida de vendas"
git push
```

### Performance

Ao fazer PR, validar:
- Query não demora mais de 30s
- Dataflow não bufa dados desnecessários
- DAX eficiente (usar CALCULATE com cuidado)

---

## 9. Proteção de dados (importante em BI)

Se tiver dados sensíveis:

```
# Arquivo: .gitignore

# Não commitar credenciais
.pbist  # Power BI settings com conexões
*.pbix  # Backups comprimidos (opcional)

# Não commitar dados brutos
data/raw/
*.xlsx
*.csv
```

**Melhor prática:** dados vêm do banco de dados (Oracle, SQL Server), não do repo. Repo só tem metadados (DAX, fluxos, estrutura).

---

## 10. Fluxo em equipe (2+ pessoas)

### Cenário: Você + João trabalham em vendas

```
João começa: feature/dashboard-detalhado
  ↓
João edita em Desktop, commita
  ↓
João abre PR develop
  ↓
Você revisa (2 min): "aprova, vejo que testou com dados 2024"
  ↓
João mergea em develop
  ↓
Você começa: feature/otimizar-dax
  ↓
Você trabalha em paralelo (branches diferentes = sem conflito)
  ↓
Alguns dias depois, ambos PRs em main
  ↓
Você valida ambas (5 min cada)
  ↓
Ambas mergeadas em main
  ↓
Publicadas em Power BI Service
```

**Vantagem:** cada pessoa em sua branch, zero conflitos, movimento rápido.

---

## 11. Comparação de fluxos

### Opção 1: Sem Git (tradicional)
```
Você trabalha em Desktop
Salva em C:\Dashboards\vendas-v1.pbix
Alguém mais trabalha em Desktop
Salva em C:\Dashboards\vendas-v2.pbix
Conflito: qual é a versão certa?
😞
```

### Opção 2: Com Git (recomendado)
```
Você trabalha em feature/dashboard-x
João trabalha em feature/dashboard-y
Ambas em branches diferentes
Sem conflito, ambas testadas
Mergeadas em sequência
Histórico completo
Você sabe quem mudou o quê e quando
😊
```

---

## 12. Checklist de setup no GitHub

- [ ] Repo criado (corporativo, público, mas com proteção)
- [ ] Branch `develop` criada de `main`
- [ ] Branch protection em `main` (1 approval)
- [ ] `.github/CODEOWNERS` criado (você como approver)
- [ ] `.github/pull_request_template.md` criado
- [ ] `.gitignore` criado (credenciais, dados sensíveis)
- [ ] Permissões de time definidas
- [ ] README com instruções de setup Power BI (desktop → git)
- [ ] 1ª pessoa (você) fez teste: clonou, abriu em Desktop, fez mudança, commitou

---

## 13. Troubleshooting

### "Quero voltar uma mudança que foi mergeada"

```bash
# Ver histórico
git log --oneline main

# Revert (cria commit que desfaz)
git revert <commit-hash>
git push origin main
```

### "Minha branch está desatualizada com develop"

```bash
git fetch origin
git rebase origin/develop
# ou merge:
git merge origin/develop
```

### "Acidentalmente commitei credencial"

```bash
# NUNCA fazer push antes de:
git reset HEAD~1          # desfaz commit
# edita arquivo, remove credencial
git add .
git commit -m "fix: remove secret"
git push
```

### "Duas pessoas editaram mesma medida DAX"

Git vai avisar "merge conflict". Opções:

1. **Uma pessoa desfaz mudança:**
   ```bash
   git checkout --ours <arquivo>   # manter sua versão
   # ou
   git checkout --theirs <arquivo> # aceitar deles
   ```

2. **Combinar ambas:** Abrir .pbip em editor de texto, resolver manualmente

---

## 14. Exemplo real

**Cenário:** Novo dashboard de KPIs de expedição

```bash
# Você começa
git checkout develop
git pull origin develop
git checkout -b feature/dashboard-kpis-expedicao

# Abre Power BI Desktop
# File → Open from git → seleciona branch

# Adiciona 3 visuais, 5 medidas DAX, dataflow novo

# Commita
git add .
git commit -m "feat: dashboard KPIs de expedição com lead time e taxa de falha"
git push origin feature/dashboard-kpis-expedicao

# PR em develop (rápido, ninguém precisa revisar agora)
# Você mesmo faz merge → OK, está em develop

# [Próximos 3 dias: testes em sandbox]

# Depois, PR develop → main
# Você revisa: abre Power BI, confere visuais
# Aprova: "Dados corretos, performance OK, visuais legíveis"
# Mergea

# Publica em Power BI Service
git checkout main
git pull  # pega merge de develop
# Power BI Service faz sync automático

# Pronto! Dashboard em produção 🎉
```

---

## 15. Equivalência com backend

Se você vem de backend, entenda as diferenças:

| Backend | Power BI |
|---|---|
| Main deploy = push código | Main deploy = publish Power BI Service |
| Tests automáticos | Testes manuais (visual) |
| Code review rigoroso | Code review rápido (visual) |
| CI/CD pipeline | Sem pipeline |
| Merge conflicts frequentes | Merge conflicts raros |
| Commits por dia = 5-10 | Commits por dia = 1-3 |
| Approval 2 pessoas | Approval 1 pessoa |

---

## Resumo dos comandos principais

```bash
# Iniciar
git clone <repo>
git checkout develop

# Trabalhar
git checkout -b feature/meu-dashboard
# editar em Power BI Desktop
git add .
git commit -m "feat: dashboard novo"
git push origin feature/meu-dashboard

# Mergear
# (no GitHub UI, abrir PR develop)
# você mergea (ou colega)

# Depois produção
# (no GitHub UI, PR develop → main)
# você aprova + mergea

# Atualizar local
git fetch origin
git pull origin main
```

---

**Documento concluído.** Estrutura enxuta, sem CI/CD, focada em movimento rápido. Pronto para Power BI!
