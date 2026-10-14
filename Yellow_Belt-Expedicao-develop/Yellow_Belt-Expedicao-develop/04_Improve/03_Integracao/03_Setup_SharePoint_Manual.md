# 🛠️ Manual Guiado — Criar a Estrutura SharePoint (Manual, sem script)

> **Revisão: 2026-10-14.** Roteiro de criação histórico, não runbook para recriar a estrutura atual. Não criar/apagar listas ou bibliotecas sem comparar a configuração funcional e obter autorização de TI.

Preservar lista NFS_IMPRESSAS, ID, nomes/tipos e conexões; o modelo Import depende dela. Biblioteca e pastas de PDFs, donos, permissões, retenção e migração: a confirmar. Fazer inventário/backup e teste em DEV antes de qualquer provisionamento. Ver [Handoff](../05_Implementacao/HANDOFF.md) e [P02/P12/P15/P16](../../03_Analyze/07_Open_Questions.md).

> Passo-a-passo clique-a-clique para criar a biblioteca de pastas e as duas
> SharePoint Lists do projeto Expedição, **sem instalar nada**.
> Tempo estimado: ~15 min.
>
> Especificação de origem:
> - Pastas → [02_Armazenamento_PDFs.md](02_Armazenamento_PDFs.md)
> - Listas → [../../05_Control/04_Auditoria_Lite.md](../../05_Control/04_Auditoria_Lite.md)

---

## 0. Pré-requisito: o site

Você precisa de um **site SharePoint** (Team site). Se ainda não tem:

1. Acesse https://eaton.sharepoint.com (ou o portal SharePoint da Eaton).
2. **+ Criar site** → **Site de Equipe (Team site)**.
3. Nome sugerido: `Expedicao` ou `Expedicao-Valinhos`.
4. Privacidade: **Privado** (só membros).
5. Anote a URL final, algo como:
   `https://eaton.sharepoint.com/sites/Expedicao`

> Guarde essa URL — ela é o `-SiteUrl` caso um dia use o script, e é onde você
> fará todos os passos abaixo.

---

## 1. Criar a estrutura de PASTAS

As pastas ficam dentro da biblioteca **Documentos** (Documents) do site.

### 1.1 Abrir a biblioteca
1. No site, menu lateral esquerdo → **Documentos** (ou "Documents").

### 1.2 Criar a pasta raiz
1. Botão **+ Novo** → **Pasta**.
2. Nome: `EXPEDICAO` → **Criar**.
3. Clique duas vezes em `EXPEDICAO` para entrar nela.

### 1.3 Criar as subpastas
Dentro de `EXPEDICAO`, repita **+ Novo → Pasta** para cada uma:

| Pasta | Onde criar |
|---|---|
| `INPUT` | dentro de `EXPEDICAO` |
| `PROCESSADO` | dentro de `EXPEDICAO` |
| `FAILED` | dentro de `EXPEDICAO` |
| `LOGS` | dentro de `EXPEDICAO` |

Depois entre em `FAILED` e crie **3 subpastas** dentro dela:

| Pasta | Onde criar |
|---|---|
| `ocr` | dentro de `EXPEDICAO/FAILED` |
| `chave_nao_encontrada` | dentro de `EXPEDICAO/FAILED` |
| `chave_nao_existe_dataset` | dentro de `EXPEDICAO/FAILED` |

### 1.4 Resultado esperado

```
Documentos/EXPEDICAO/
├─ INPUT/
├─ PROCESSADO/        (o fluxo cria subpastas prisma_STG.A12.xxx aqui)
├─ FAILED/
│   ├─ ocr/
│   ├─ chave_nao_encontrada/
│   └─ chave_nao_existe_dataset/
└─ LOGS/
```

> Não precisa criar as pastas `prisma_STG.A12.xxx` — o Power Automate cria sozinho.

---

## 2. Criar a Lista `EXP_CICLOS_LOG`

Uma linha por ciclo do classificador.

### 2.1 Criar a lista
1. No site → **+ Novo** (no topo da Home) → **Lista**
   - Ou: ⚙️ **Configurações** → **Conteúdo do site** → **+ Novo → Lista**.
2. **Lista em branco**.
3. Nome: `EXP_CICLOS_LOG`.
4. **Mostrar na navegação do site**: marcado (opcional).
5. **Criar**.

### 2.2 Renomear a coluna "Título" para `Ciclo_ID`
A lista já vem com uma coluna **Título** (Title). Vamos reaproveitá-la:
1. Clique no cabeçalho da coluna **Título** → **Configurações da coluna** → **Renomear**.
2. Novo nome: `Ciclo_ID` → **Salvar**.

### 2.3 Adicionar as demais colunas
Para cada linha da tabela: clique em **+ Adicionar coluna** → escolha o **tipo** → preencha o **nome** → ajuste conforme a coluna "Configuração" → **Salvar**.

| Nome da coluna | Tipo | Configuração |
|---|---|---|
| `Inicio` | **Data e hora** | Incluir hora = **Sim** |
| `Fim` | **Data e hora** | Incluir hora = **Sim** |
| `Total_NFs` | **Número** | — |
| `Total_Classificadas` | **Número** | — |
| `Total_Falhas` | **Número** | — |
| `Status` | **Opção (Choice)** | Opções: `OK`, `OK_COM_FALHAS`, `ERRO` |
| `Link_Pasta` | **Hiperlink** | — |
| `Operador` | **Linha única de texto** | — |
| `Origem_PDFs` | **Opção (Choice)** | Opções: `Caminho_A`, `Caminho_B` |

> Em **Opção (Choice)**: apague as opções de exemplo ("Escolha 1, 2, 3") e
> digite exatamente os valores acima, um por linha.

### 2.4 Conferência
A lista deve ter **10 colunas**: Ciclo_ID, Inicio, Fim, Total_NFs,
Total_Classificadas, Total_Falhas, Status, Link_Pasta, Operador, Origem_PDFs.

---

## 3. Criar a Lista `EXP_FALHAS_LOG`

Uma linha por PDF que falhou na classificação.

### 3.1 Criar a lista
1. **+ Novo → Lista** → **Lista em branco**.
2. Nome: `EXP_FALHAS_LOG` → **Criar**.

### 3.2 Renomear "Título" → `Ciclo_ID`
Mesmo procedimento do passo 2.2 (é a chave que liga a falha ao ciclo).

### 3.3 Adicionar as colunas

| Nome da coluna | Tipo | Configuração |
|---|---|---|
| `Arquivo_PDF` | **Linha única de texto** | — |
| `Motivo` | **Opção (Choice)** | Opções: `NF_NAO_ENCONTRADA`, `ERRO_MOVER`, `SUB_LOC_NULO`, `OUTRO` |
| `Data` | **Data e hora** | Incluir hora = **Sim** |
| `Detalhe` | **Várias linhas de texto** | Texto simples |

### 3.4 Conferência
A lista deve ter **5 colunas**: Ciclo_ID, Arquivo_PDF, Motivo, Data, Detalhe.

---

## 4. Permissões (depois de criar tudo)

| Quem | O quê | Onde |
|---|---|---|
| **Operador** | Contribuir (upload/editar) | pasta `EXPEDICAO/INPUT` |
| **Operador** | Ler | pasta `EXPEDICAO/PROCESSADO` |
| **Conta/serviço do Power Automate** | Editar | todo `EXPEDICAO/` + as 2 listas |
| **Você / Eduardo** | Controle total | site inteiro |

> Configurar em: na pasta/lista → **⚙️ → Configurações → Permissões** →
> *Parar de herdar permissões* (se precisar de granularidade) → adicionar pessoas.
> Para o piloto, pode deixar tudo herdando do site e só garantir que o operador é membro.

---

## 5. Checklist final

- [ ] Site criado e URL anotada
- [ ] Pasta `EXPEDICAO` + INPUT / PROCESSADO / LOGS
- [ ] `FAILED` + ocr / chave_nao_encontrada / chave_nao_existe_dataset
- [ ] Lista `EXP_CICLOS_LOG` com 10 colunas
- [ ] Lista `EXP_FALHAS_LOG` com 5 colunas
- [ ] Choices digitados exatamente (sem espaços/acentos diferentes)
- [ ] Operador é membro do site
- [ ] URL do site registrada para o Power Automate

---

## 6. Próximo passo

Com a estrutura pronta, o próximo item é o **Fluxo Classificador** no Power Automate
(trigger em `INPUT/`, grava nas duas listas). Ver
[../02_PowerAutomate/01_Fluxo_Classificador.md](../02_PowerAutomate/01_Fluxo_Classificador.md).

> Observação: se um dia quiser recriar isso de forma automatizada, o mesmo está
> no script [setup_sharepoint.ps1](setup_sharepoint.ps1) (requer PowerShell 7 + app Entra ID).
