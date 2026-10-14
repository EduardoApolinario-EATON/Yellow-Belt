# Restrição Power BI × Views EBS — Avaliação de Opções

> **Revisão documental: 2026-10-14.** Estudo histórico de acesso ao Oracle. A opção observada na cópia usa tabelas-base em dataflows Bronze; não conecta o modelo diretamente às views.

Conexões, gateway, limitações do tenant e permissões upstream precisam ser confirmados com o dono das origens. As opções A/B de obtenção de PDFs são outro eixo, não estas opções de acesso a dados. Ver [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md).

> Por que o Power BI não consome diretamente as views `_BR_V` do Oracle EBS, e como resolver dentro do escopo da Fase 1.
> Última atualização: 2026-05-28

## 1. A restrição

**O Power BI não acessa as views da camada APPS do Oracle EBS** (`XXRA_CUSTOMER_TRX_BR_V`, `JL_BR_AR_*`, etc.). Causa provável: as views exigem contexto de sessão `mo_global.set_policy_context('S', 1344)` aplicado por logon trigger no SQL Developer dos usuários EBS, e têm row-level security amarrada ao ORG_ID.

Quando o Power BI abre uma sessão Oracle via ODAC, **não** aplica o `set_policy_context`. A view `_BR_V` retorna sem dados ou erro silencioso — não há exceção visível, apenas linhas faltando.

## 2. Implicações práticas

- Direct Query nas views é **inviável**: divergência silenciosa.
- Tentar reproduzir a lógica em DAX ou M também não resolve — a query nem entrega as linhas para começo de processamento.
- A refatoração precisa **levar a lógica para uma camada que o Power BI consiga consumir**.

## 3. Cenários ao testar Power BI ↔ Oracle

| Cenário | Sintoma | Causa | Ação |
|---|---|---|---|
| 1 | Resultados batem 100% | Logon trigger seta contexto automaticamente | Seguir com a query como está |
| 2 | Power BI traz menos linhas / zero | Views `_BR_V` sem policy context | Reescrever contra tabelas-base (Opção D) |
| 3 | Power BI dá erro `ORA-00942` | Tabela/view não existe | Pedir GRANT à TI ou reescrever (Opção D) |

## 4. Opções avaliadas

> **Decisão da Fase 1 (2026-05-25):** Opção D é a escolhida. As demais ficam registradas como alternativas para uma eventual Fase 2 caso a D se mostre inviável.

### Restrições firmes que filtram as opções

- Sem dependência de DBA / criação de objetos no Oracle → descarta A e C.
- Sem dependência de conectores Premium / APIs externas → descarta B.
- Stack permitido: Power BI Pro + Power Automate Free + M365.

### Opção D — Reescrever contra tabelas-base (sem views) ✅ ESCOLHIDA

Substituir views `_BR_V` por ingestão direta das tabelas-base (`RA_CUSTOMER_TRX_ALL`, `JL_BR_AR_*`, `HZ_PARTIES`, `WSH.*`, etc.) num **dataflow dedicado**. Filtros que o policy context fazia (ex.: `ORG_ID`) viram filtros explícitos em Power Query (M). O **dataset** é construído a partir do dataflow (modo Import); a lógica das queries vive em M/DAX.

- **Prós:** dispensa DBA; mantém autonomia do projeto; lógica versionada no repo.
- **Contras:** replicar a lógica das 3 queries em M/DAX; risco de divergência se a replicação interna das views for imprecisa; performance média.
- **Pré-requisitos:**
  - Permissão `SELECT` nas tabelas-base (pergunta 7.10 do `07_Open_Questions.md`).
  - Conhecimento da definição interna das views (consulta a `ALL_VIEWS`).
  - Validação row-by-row contra o AS-IS (ver §5).

Detalhamento técnico em `04_Improve/04_Arquitetura/01_Opcao_D_Refatoracao.md`; plano de paridade na §5 acima.

### Opção A — Tabela materializada no Oracle (job agendado) — descartada na Fase 1

DBA cria tabela física + job que executa a query refatorada com contexto correto. **Inviável**: exige acesso DBA que o projeto não tem.

### Opção B — Power Automate como ETL — descartada

Conector Oracle exige Power Automate Premium, que não está disponível. Também depende de API/HTTP, igualmente fora do escopo.

### Opção C — Stored Procedure — descartada

Mesma restrição da A (precisa de DBA). Power BI consome procedures mal — geralmente força voltar para A ou B.

### Comparativo rápido

| Critério | A (materialização) | B (Power Automate ETL) | D (tabelas-base) |
|---|---|---|---|
| Trabalho TI/DBA | Alto | Baixo | Baixo |
| Trabalho do projeto | Médio | Médio-alto | Alto |
| Risco fiscal | Baixo | Baixo | Médio |
| Performance Power BI | Alta | Alta | Média |
| Custo licença | — | Power Automate Premium | — |
| Autonomia do projeto | Baixa | Alta | Alta |
| **Viável na Fase 1** | ❌ (precisa DBA) | ❌ (precisa Premium) | ✅ |

## 5. Plano de validação de paridade

Após reescrever a query no formato Opção D, validar contra a query AS-IS rodada no SQL Developer:

| Verificação | Comparação |
|---|---|
| Quantidade de linhas | `COUNT(*)` Oracle = Power BI |
| Soma de coluna numérica | `SUM(ICMS_ST)` idêntico |
| Lista de NFs | Top 50 NFs idêntica (ordenadas) |
| NFs distintas | `COUNT(DISTINCT TRX_NUMBER)` igual |
| Datas extremas | `MIN/MAX(TRX_DATE)` igual |
| Cobertura de SUB_LOC | Distribuição de prismas idêntica |

Detalhamento em `04_Improve/04_Arquitetura/01_Opcao_D_Refatoracao.md`.

## 6. Perguntas que destravam a Opção D

| # | Pergunta | Status |
|---|---|---|
| 7.9 | Qual é exatamente o bloqueio do Power BI nas views? Erro de policy context, permissão revogada, ou outro? | ⬜ |
| 7.10 | O usuário Power BI tem permissão de `SELECT` nas tabelas-base? | ⬜ |
| 7.11 | Existe documentação interna do mapeamento view EBS → tabelas-base? | ⬜ |

Detalhe completo em `07_Open_Questions.md` §7.
