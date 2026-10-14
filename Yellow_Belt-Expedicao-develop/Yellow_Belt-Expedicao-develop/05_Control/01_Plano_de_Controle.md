# Plano de Controle

> **Referência atual: 2026-10-14.** Controles de aceitação propostos para a ferramenta funcional; execução, frequência aprovada, nomes e SLAs ainda precisam de confirmação. O plano original permanece histórico.

## Matriz para o supervisor

| Controle | Quando proposto | Evidência | Papel | Desvio |
|---|---|---|---|---|
| Universo da rodada | Antes do disparo | Período/filtros e chaves esperadas versus PDFs | Expedição + BI | Suspender se não corresponder |
| Frescor | Antes do processamento | Refresh concluído de origens/modelo e visuais atualizados | Dados/BI | Não presumir timestamp como confirmação das origens |
| Aptidão/guia/local | Antes de impressão | APTA, MOTIVO, liberação Fiscal e conferência de prisma | Fiscal + Armazém | Segregar nota com pendência |
| Resultado do fluxo | Após cada execução | Chave -> arquivo/destino/histórico/erro | Automação + Expedição | Reconciliar falha parcial antes de retry |
| Impressão física | Ao fechar lote | Sequência e lote conferidos pelo operador | Expedição | Reimpressão somente autorizada |
| Acesso/continuidade | Após mudança e periodicidade a definir | Donos/substitutos, conexões, backup e recuperação | TI | Não operar sem responsável ou acesso necessário |
| Métrica/ganho | Período de coleta aprovado | Tempos reais, volume/mix, baseline comparável | Yellow Belt + supervisor | Não divulgar projeção como resultado |

Não somar cartões de guia/exceção; conciliar conjuntos por chave. Não apagar histórico para limpar desvio. Formalizar frequência, limites e contatos nas [P01-P19](../03_Analyze/07_Open_Questions.md); usar [Manual do Operador](05_Manual_Operador.md) e [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md).

## Plano histórico

> KPIs monitorados, meta, frequência, fonte e responsável.
> Última atualização: 2026-05-28

## 1. Tabela de controle

| # | KPI | Meta | Frequência | Fonte | Responsável | Ação se desviar |
|---|---|---|---|---|---|---|
| C1 | Lead Time do ciclo de expedição | ≤ 75 min | Por ciclo | EXP_CICLOS_LOG (Inicio→Fim) + cronômetro Bloco 4 | Operador | Investigar bloco mais lento; comunicar Eduardo |
| C2 | Tempo de separação manual | 0 | Por ciclo | Observação | Operador | Se > 0: classificação falhou — investigar `_falhas/` |
| C3 | % NFs classificadas automaticamente | ≥ 99% | Por ciclo | EXP_CICLOS_LOG | Operador | Se < 99%: revisar SUB_LOC nulos e PDFs sem chave |
| C4 | Taxa de falha de classificação | < 1% | Por ciclo | EXP_FALHAS_LOG / Total | Operador | Se > 1%: análise dos motivos no log |
| C5 | Tempo de validação fiscal (Bloco 2) | ≤ 5 min | Por ciclo | Dashboard Power BI | Operador | Se > 5 min: dashboard com lag de refresh — verificar gateway |
| C6 | NFs com SUB_LOC nulo | < 1% | Diário | Dashboard | Supervisor | Se > 1%: alinhar com PCP/Logística |
| C7 | NFs enviadas para serviço externo (compliance) | 0 | Sempre | Auditoria de processo | Eduardo / Patrocinador | Se > 0: parar processo, escalar Compliance |
| C8 | Volume diário de NFs | Dentro do P10-P90 histórico | Diário | Dashboard | Supervisor | Pico fora da faixa → planejar capacidade |
| C9 | Actions Power Automate (consumo Free) | < 5.000/dia | Diário | Power Automate Analytics | Eduardo | Se > 5.000: separar fluxos por horário |

## 2. Gestão dos desvios

| Severidade | Critério | Quem aciona | Em quanto tempo |
|---|---|---|---|
| **Crítica** | C7 (compliance) qualquer ocorrência | Eduardo + Patrocinador | Imediato |
| **Crítica** | C2 > 0 (separação manual ressurgiu) | Operador → Eduardo | No mesmo ciclo |
| **Alta** | C4 > 5% | Operador → Eduardo | No mesmo dia |
| **Alta** | Fluxo Power Automate falhou (qualquer) | Sistema (notificação) → Eduardo | Imediato |
| **Média** | C1 > 75 min | Operador → Eduardo | No fim do dia |
| **Média** | C3 < 99% | Supervisor → Eduardo | Semanal |
| **Baixa** | C6 / C8 / C9 fora da meta | Supervisor → Eduardo | Semanal |

## 3. Cadência de revisão

| Cadência | Quem | O que olha |
|---|---|---|
| Por ciclo | Operador | Notificação Teams/Outlook; abre `_falhas/` se houver |
| Diário | Supervisor | Dashboard de Gestão (Power BI aba Gestão) |
| Semanal | Eduardo + Supervisor | KPIs C1–C4 da semana; tendência |
| Mensal | Eduardo + Patrocinador | Consolidado do mês; ajustes |

## 4. Critério de sucesso para encerrar o YB

- 4 semanas consecutivas com:
  - C1 ≤ 75 min em ≥ 90% dos ciclos
  - C2 = 0 em 100% dos ciclos
  - C3 ≥ 99% em todos os ciclos
  - C7 = 0 (sem nenhuma exceção)
- Manual do operador validado por 2 operadores diferentes.
- Power BI aba Gestão funcionando e revisada semanalmente pelo supervisor.

Detalhes operacionais em `02_Dashboard_Gestao.md`, `03_SLAs_e_Alertas.md` e `05_Manual_Operador.md`.
