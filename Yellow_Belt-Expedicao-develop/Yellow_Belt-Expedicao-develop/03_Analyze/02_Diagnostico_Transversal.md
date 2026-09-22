# Diagnóstico Transversal — Padrões problemáticos das 3 queries

> Problemas que se repetem nas 3 queries e implicações para o TO-BE.
> Última atualização: 2026-05-28

## 1. Matriz de padrões problemáticos

| Problema | Query 1 (Pt.1) | Query 2 (Pt.2 Óleo) | Query 3 (Revisada) |
|---|---|---|---|
| Sintaxe Oracle antiga (vírgula JOIN + `(+)`) | ✅ | ✅ | ✅ |
| `TRUNC` em coluna de data (mata índice) | ✅ | ✅ | ✅ |
| Magic numbers (ORG_ID, WAREHOUSE_ID) | ✅ | ✅ | ✅ |
| Listas hardcoded (VAT_TAX_IDs, inscrições UF) | parcial | ✅ | ✅ |
| JOINs mortos / tabelas não usadas | ✅ | — | — |
| Duplicação entre blocos / queries | ✅ | ✅ (com Q3) | ✅ (com Q2) |
| Subqueries correlacionadas pesadas | — | ✅ | ✅ |
| Mistura de responsabilidades (fiscal + logístico + cálculo) | — | ✅ | ✅ |
| Datas em formatos inconsistentes (`DD/MM/RRRR` vs `DD/MM/YY`) | ✅ | — | — |
| Colunas polissêmicas (`ORDEM` com 4 sentidos) | ✅ | — | — |

## 2. Implicações para o TO-BE

| Implicação | Consequência prática |
|---|---|
| Manutenção atual é frágil | Qualquer mudança fiscal (alíquota, IE, novo VAT_TAX_ID) exige edição em múltiplos pontos do SQL |
| Performance limitada | `TRUNC` em datas + subqueries correlacionadas + JOINs mortos. Direct Query no Power BI sofreria |
| Acoplamento alto | Query 2 e Query 3 são quase clones — refatoração precisa unificar |
| Falta de tipagem | Colunas com semântica variável (como `ORDEM`) impedem modelagem semântica limpa no Power BI |
| Risco de divergência silenciosa | Views `_BR_V` dependem de policy context — Power BI pode trazer subset sem erro visível (ver `06_Restricao_PowerBI_Views.md`) |

## 3. Princípios da refatoração (válidos para qualquer abordagem)

1. **Separação de responsabilidades**:
   - Camada 1: extração crua de NFs (joins fiscais essenciais)
   - Camada 2: classificação (status, prisma, regras de óleo/embreagem)
   - Camada 3: enriquecimento (impostos, inscrições)
2. **Tipagem estável da saída** — schema explícito que Power BI consome (ver `04_Improve/01_PowerBI/01_Dataset_Schema.md`).
3. **Parametrização** — ORG_ID, WAREHOUSE_ID, datas, batch sources viram parâmetros.
4. **Tabelas de configuração** para listas hardcoded (VAT_TAX_IDs, inscrições UF, regras de cliente) — SharePoint Lists ou tabelas Oracle dedicadas.
5. **ANSI JOIN** + range de datas indexável (`TRX_DATE >= ... AND TRX_DATE < ...`).
6. **Lógica das Camadas 1-3 no Power BI** — replicada em **Power Query (M)** no dataflow de ingestão (transformações fiscais e classificação) e em **DAX** no dataset (flags de roteamento como PAGA_GUIA / ORDEM_CLASSIFICACAO). Sem query monolítica no Oracle: o dataflow ingere as tabelas-base e o dataset materializa a saída tipada.

## 4. Consumidores do dataset unificado (TO-BE)

| Consumidor | O que filtra/agrega |
|---|---|
| Power BI — Dashboard operacional | `STATUS_FISCAL ≠ FINALIZADO` agrupado por motivo (substitui Pt.1 manual) |
| Power BI — Relatório de elegibilidade | Lista detalhada por NF (substitui Blocos 2-4 da Pt.1) |
| Power Automate — Pipeline de PDFs | `STATUS_FISCAL = FINALIZADO` agrupado por `SUB_LOC` |
| Time Fiscal | NFs em `CANCELAR` ou `ERRO` para tratamento |

Detalhamento técnico da refatoração em `04_Improve/04_Arquitetura/01_Opcao_D_Refatoracao.md`.
