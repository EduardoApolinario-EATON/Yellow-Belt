# Indicadores

> **Revisão documental: 2026-10-14.** Os indicadores abaixo foram propostos para melhoria; disponibilidade no relatório atual deve ser distinguida de meta ou medição futura.

## Indicadores comprovados no modelo

Total do Ciclo conta linhas no contexto filtrado; Qtd Prontos/Oleo/Paga Guia usam PASTA_DESTINO; Qtd Excecoes usa APTA Nao. Guia e exceções podem sobrepor: não somar os cartões para obter total. ChavesParaCopiar/QtdChaves usam aptas de comprimento 44, sem deduplicação ou exclusão do histórico por si só.

Tempo de ciclo, produtividade, erros físicos, SLA e ganhos não são medidas implementadas comprovadas nesta cópia. Usar [coleta](03_Coleta_de_Dados.md) e [dashboard de gestão](../05_Control/02_Dashboard_Gestao.md); limiares e metas precisam de aprovação.

> KPIs do projeto Yellow Belt. Define o que medir antes, durante e depois da implementação.
> Última atualização: 2026-05-28

## 1. KPIs principais (do charter)

| # | Indicador | Unidade | Baseline AS-IS | Meta TO-BE | Frequência | Fonte |
|---|---|---|---|---|---|---|
| K1 | Lead Time do ciclo de expedição | min | ~240 | ≤ 75 | Por ciclo | Cronômetro / Power BI |
| K2 | Tempo de separação por prisma (Bloco 5) | min | ~132 | 0 | Por ciclo | Cronômetro |
| K3 | % NFs classificadas automaticamente | % | 0 | ≥ 99 | Por ciclo | EXP_CICLOS_LOG |
| K4 | Taxa de falha de classificação | % | n/a | < 1 | Por ciclo | EXP_FALHAS_LOG |
| K5 | Volume diário de NFs | NFs | ~350 (média) | — (controle) | Diário | Query |

## 2. KPIs secundários (operacionais)

| # | Indicador | Unidade | Por que importa | Fonte |
|---|---|---|---|---|
| S1 | Tempo de validação fiscal (Bloco 2) | min | Mede ganho do dashboard sobre Pt.1 manual | Power BI |
| S2 | Minutos aguardando SEFAZ (mediana das NFs APTA) | min | Identifica gargalo upstream | Dataset |
| S3 | Nº de exceções fiscais por ciclo | qtd | Variabilidade do processo | EXP_CICLOS_LOG |
| S4 | Nº de prismas por ciclo | qtd | Capacidade física da expedição | Dataset |
| S5 | % NFs com SUB_LOC nulo | % | Saúde da chave de pasta | Dataset |

## 3. KPIs de risco / compliance

| # | Indicador | Estado AS-IS | Meta TO-BE |
|---|---|---|---|
| R1 | NFs reais enviadas para serviço externo (`api.pdfconverted.com`) | 100% das NFs do ciclo | 0 |
| R2 | Trilha de auditoria de ciclos | Inexistente | EXP_CICLOS_LOG com 100% dos ciclos |
| R3 | Trilha de auditoria de falhas | Inexistente | EXP_FALHAS_LOG com 100% das falhas |

## 4. Status atual de cada KPI

| KPI | Medido hoje? | Como será medido na Fase Improve |
|---|---|---|
| K1 (Lead time) | ⚠️ Estimado | Power BI agrega timestamps por ciclo |
| K2 (Separação) | ⚠️ Estimado | Cronômetro nas 2 primeiras semanas pós-implantação |
| K3 (% classificada) | ❌ Não existe | Calculado pelo fluxo Power Automate |
| K4 (Taxa falha) | ❌ Não existe | EXP_FALHAS_LOG |
| K5 (Volume) | ✅ Disponível na query | Power BI aba Gestão |
| S1–S5 | ❌ Não existem | Power BI |
| R1–R3 | ❌ Inexistentes | Auditoria pós-implantação |

## 5. Cadência de revisão

| Cadência | Quem | O que olha |
|---|---|---|
| Por ciclo | Operador / Eduardo | EXP_CICLOS_LOG, EXP_FALHAS_LOG, notificação |
| Semanal | Eduardo + supervisor | K1, K2, K3, K4 |
| Mensal | Eduardo + patrocinador | Dashboard de gestão (Power BI) |

Detalhe operacional do controle pós-implantação em `05_Control/01_Plano_de_Controle.md` e `05_Control/02_Dashboard_Gestao.md`.
