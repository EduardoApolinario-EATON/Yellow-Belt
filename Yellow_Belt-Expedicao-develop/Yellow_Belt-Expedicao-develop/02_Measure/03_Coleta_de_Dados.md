# Coleta de Dados

> Plano de coleta de 5 ciclos para validar a linha de base do AS-IS.
> Última atualização: 2026-05-28

## Objetivo

Quantificar o tempo real e a variabilidade de cada bloco do processo de expedição, em condições normais de operação, para confirmar o `01_Baseline_AS_IS.md`.

## Critérios de amostragem

- Coletar **5 ciclos** em dias distintos, da forma mais aleatória possível (não escolher só dias "bons").
- Cobrir pelo menos um dia com volume **abaixo da média** (< 300 NFs) e um **acima** (> 400 NFs).
- Cobrir pelo menos um ciclo com **exceção fiscal** (delivery com erro / NF parada na RILA).

## O que medir por ciclo

| Métrica | Como medir | Unidade |
|---|---|---|
| Volume de NFs | Contagem na query Pt.2 | NFs |
| Horário de início do ciclo | Início do Bloco 1 (bipagem) | hh:mm |
| Horário de término do ciclo | NFs prontas para embarque | hh:mm |
| Tempo Bloco 1 (Bipagem) | Cronômetro | min |
| Tempo Bloco 2 (Pt.1) | Cronômetro | min |
| Tempo Bloco 3 (Pt.2 + macro) | Cronômetro | min |
| Tempo Bloco 4 (Impressão) | Cronômetro | min |
| Tempo Bloco 5 (Separação manual) | Cronômetro | min |
| Houve exceção fiscal? | Observação | sim/não |
| Quantidade de prismas no ciclo | Contagem física | prismas |

---

## Ciclo 1

| Campo | Valor |
|---|---|
| Data | |
| Volume (NFs) | |
| Horário início | |
| Horário término | |
| Tempo Bloco 1 | |
| Tempo Bloco 2 | |
| Tempo Bloco 3 | |
| Tempo Bloco 4 | |
| Tempo Bloco 5 | |
| Exceção fiscal? | |
| Qtd prismas | |
| Observações | |

## Ciclo 2

| Campo | Valor |
|---|---|
| Data | |
| Volume (NFs) | |
| Horário início | |
| Horário término | |
| Tempo Bloco 1 | |
| Tempo Bloco 2 | |
| Tempo Bloco 3 | |
| Tempo Bloco 4 | |
| Tempo Bloco 5 | |
| Exceção fiscal? | |
| Qtd prismas | |
| Observações | |

## Ciclo 3

| Campo | Valor |
|---|---|
| Data | |
| Volume (NFs) | |
| Horário início | |
| Horário término | |
| Tempo Bloco 1 | |
| Tempo Bloco 2 | |
| Tempo Bloco 3 | |
| Tempo Bloco 4 | |
| Tempo Bloco 5 | |
| Exceção fiscal? | |
| Qtd prismas | |
| Observações | |

## Ciclo 4

| Campo | Valor |
|---|---|
| Data | |
| Volume (NFs) | |
| Horário início | |
| Horário término | |
| Tempo Bloco 1 | |
| Tempo Bloco 2 | |
| Tempo Bloco 3 | |
| Tempo Bloco 4 | |
| Tempo Bloco 5 | |
| Exceção fiscal? | |
| Qtd prismas | |
| Observações | |

## Ciclo 5

| Campo | Valor |
|---|---|
| Data | |
| Volume (NFs) | |
| Horário início | |
| Horário término | |
| Tempo Bloco 1 | |
| Tempo Bloco 2 | |
| Tempo Bloco 3 | |
| Tempo Bloco 4 | |
| Tempo Bloco 5 | |
| Exceção fiscal? | |
| Qtd prismas | |
| Observações | |

---

## Auditorias paralelas (uma vez, não por ciclo)

Estas medições não precisam ser repetidas por ciclo, mas precisam ser feitas em algum momento da Fase Measure.

| Auditoria | Pergunta a responder | Método |
|---|---|---|
| Nome do PDF na origem | Existe a chave de acesso (44 dígitos) no nome do arquivo? Em quantos %? | Inspeção de 100 PDFs |
| SUB_LOC populado | % de NFs com `SUB_LOC` não nulo no ciclo real | Query sobre 1 ciclo completo |
| Nota mãe vs vide nota | Há um campo Oracle que distingue? | Análise de 50 NFs com `CT_REFERENCE` ≠ NF |
| Frequência de ciclos | Quantos ciclos por dia em média? | Log de faturamento (1 semana) |
| Volume mínimo e máximo | Qual a faixa real? | Log de 1 mês de queries |

---

## Análise dos dados coletados

Após os 5 ciclos, preencher:

| Estatística | Tempo total | Bloco 5 (separação) |
|---|---|---|
| Mínimo | | |
| Máximo | | |
| Média | | |
| Desvio padrão | | |

E responder:

- O Bloco 5 representa mesmo ~55% do ciclo?
- A variabilidade entre dias é alta? Por quê?
- Há correlação linear entre volume e tempo do Bloco 5?
- A "exceção fiscal de 5 dias" apareceu? Com qual frequência?

Resultados consolidados alimentam o `01_Baseline_AS_IS.md` e o `04_Improve/09_Ganho_Esperado.md`.
