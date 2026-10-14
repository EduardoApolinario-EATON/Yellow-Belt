# Baseline AS-IS — Linha de base quantitativa

> **Revisão documental: 2026-10-14.** Os valores abaixo são baseline qualitativo/reportado de maio/2026 e projeções, não série medida nem resultados da versão atual. A própria coleta de cinco dias estava pendente. Preservados sem validação numérica nesta revisão.

Não misturar 2h12 de organização manual deste BPI com a estimativa de 1h30 usada em outros documentos. Volume, cadência e ganho devem ser reconfirmados com amostra, período e aprovador. Cinco dias de exceção fiscal não são SLA nem média comprovada.

Ver [plano de coleta](03_Coleta_de_Dados.md), [indicadores](04_Indicadores.md) e [P17/P19](../03_Analyze/07_Open_Questions.md).

> Tempos, volume e distribuição do processo atual de expedição.
> Última atualização: 2026-05-28 (dados qualitativos do BPI; coleta dos 5 dias pendente)

## 1. Sumário

| Métrica | Valor atual |
|---|---|
| Tempo total do ciclo | ~4h |
| Volume médio | 350 NFs/ciclo |
| Tempo de retrabalho puro | ~2h12 (~55% do ciclo) |
| Frequência de ciclos | A confirmar (Coleta_de_Dados) — provavelmente 1–4/dia |

## 2. Distribuição por bloco

| # | Bloco | Tempo | % do ciclo | Classificação BPI |
|---|---|---|---|---|
| 1 | Faturamento e bipagem | 6 min | 2,5% | 🟢🔵 Agrega valor + necessário |
| 2 | Validação fiscal (Query Pt.1 manual) | 30 min (até **5 dias** em exceções) | 12,5% | 🔵 Necessário |
| 3 | Geração do pacote (Query Pt.2 + macro quebrada) | 6 min | 2,5% | 🔵🔴 Necessário + retrabalho |
| 4 | Impressão física (NFs + etiquetas) | ~1h05 | 27% | 🟢🔴 Agrega valor + parcial retrabalho |
| 5 | **Organização manual por prisma** | **~2h12** | **55%** | 🔴 Retrabalho puro |
| | **Total** | **~4h** | **100%** | |

## 3. Gargalo identificado

**Bloco 5 — Organização manual por prisma.** Representa 55% do tempo total e é 100% retrabalho. Causa raiz upstream: macro do Bloco 3 quebrada após update do SYNCHRO. Sem PDFs classificados, o time imprime tudo fora de ordem e separa manualmente.

## 4. Variabilidade conhecida (qualitativa)

| Bloco | Fonte de variabilidade | Impacto |
|---|---|---|
| 2 | Exceções fiscais (delivery com erro) | Pode estender o ciclo de 30 min para até **5 dias** |
| 5 | Volume diário (de ~150 a ~500 NFs) | Tempo escala quase linearmente |
| 5 | Mistura nota mãe + vide notas + óleo + embreagem | Maior complexidade → mais erro |

A confirmação numérica desses extremos depende da Coleta de Dados (5 dias).

## 5. Premissas da linha de base

- **350 NFs/ciclo** é a média histórica reportada pelo time. Não há série histórica medida.
- **2h12 do Bloco 5** vem do BPI consolidado pela operação. Pode estar subestimado em dias de pico.
- **5 dias do Bloco 2** é o **pior caso** quando há erro fiscal — não a média.
- Etiquetas (1h dentro do Bloco 4) podem entrar em outro fluxo paralelo; precisa confirmar.

## 6. O que ainda falta medir (lacunas)

| Lacuna | Por que importa | Como será coberta |
|---|---|---|
| Tempo real médio do Bloco 5 (mín/máx/desvio) | Define o ganho real do projeto | 03_Coleta_de_Dados.md (5 dias) |
| Frequência diária de ciclos | Define carga do Power Automate (actions/dia) | 03_Coleta_de_Dados.md |
| Taxa de PDFs sem chave de acesso parseável no nome | Define necessidade de OCR no Caminho A | Auditoria de amostra real |
| % de NFs com SUB_LOC nulo | Define se a chave de pasta é viável | Auditoria de amostra real |

## 7. Comparativo TO-BE projetado

| Bloco | AS-IS | TO-BE Fase 1 | Δ |
|---|---|---|---|
| 1 | 6 min | 6 min | 0 |
| 2 | 30 min | ~5 min (dashboard) | -25 min |
| 3 | 6 min + risco compliance | 1–2 min (refresh + drop PDFs) | -4 min + remove risco |
| 4 | 1h05 | 1h05 | 0 |
| 5 | **2h12** | **0** | **-2h12** |
| **Total** | **~4h** | **~1h15** | **~-2h45 (-70%)** |

O ganho real depende da resolução das premissas técnicas (origem dos PDFs, SUB_LOC, chave de acesso no nome).
