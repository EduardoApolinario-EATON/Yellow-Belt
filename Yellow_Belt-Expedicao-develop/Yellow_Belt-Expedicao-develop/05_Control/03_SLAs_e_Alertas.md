# SLAs e Alertas

> Limites operacionais e triggers de notificação do TO-BE.
> Última atualização: 2026-05-28

## 1. SLAs por bloco

| Bloco | SLA | Medido em | Fonte |
|---|---|---|---|
| Bloco 1 — Download SYNCHRO | ≤ 10 min | Início → ZIP em `/INPUT/PDFs/` | Manual / Power Automate Desktop |
| Bloco 2 — Validação fiscal | ≤ 5 min | Refresh dataset → consulta no Power BI | Power Automate Analytics (Fluxo #1) |
| Bloco 3 — Classificação por prisma | ≤ 5 min | Trigger → notificação Teams | Power Automate Analytics (Fluxo #2) |
| Bloco 4 — Impressão | ≤ 45 min | Início impressão → última folha | Cronômetro operador |
| Bloco 6 — Auditoria | ≤ 5 min | Após Bloco 4 | EXP_CICLOS_LOG |
| **Ciclo total** | **≤ 75 min** | Início Bloco 1 → fim Bloco 6 | EXP_CICLOS_LOG (`Fim - Inicio`) |

## 2. Alertas automáticos

| ID | Trigger | Canal | Destinatário | Severidade |
|---|---|---|---|---|
| AL1 | Fluxo Power Automate falhou (Cloud ou Desktop) | E-mail + Teams | Eduardo | Alta |
| AL2 | `EXP_CICLOS_LOG.Status = ERRO` | Teams | Operador + Eduardo | Alta |
| AL3 | `EXP_CICLOS_LOG.Status = OK_COM_FALHAS` | Teams (notificação simples) | Operador | Média |
| AL4 | Ciclo passou de 75 min | Teams | Operador + Eduardo | Média |
| AL5 | `Total_Falhas > 5%` num ciclo | Teams | Operador + Eduardo | Alta |
| AL6 | Power Automate Analytics: > 5.000 actions/dia | E-mail (semanal) | Eduardo | Baixa |
| AL7 | Refresh do dataset Power BI falhou | E-mail (nativo Power BI) | Eduardo | Alta |
| AL8 | NF com `MINUTOS_AGUARDANDO > 60` ainda pendente | Card vermelho no dashboard | Operador | Visual |

## 3. Implementação dos alertas

| Alerta | Como é implementado |
|---|---|
| AL1 | Power Automate `Configure run after` → ramo de erro → "Send an email" + "Post message in Teams" |
| AL2, AL3 | Lógica no fim do Fluxo #2: condição sobre `Status` calculado |
| AL4 | Comparação `sub(ticks(utcNow()), ticks(variables('Inicio')))` no fim do fluxo |
| AL5 | Cálculo `Total_Falhas / Total_NFs` antes de gravar EXP_CICLOS_LOG |
| AL6 | Fluxo agendado semanal lê Power Automate Analytics via export manual ou via UI |
| AL7 | Nativo: Power BI Service → Settings → Dataset → "Send refresh failure notifications" |
| AL8 | Medida DAX no Power BI: `COUNTROWS(FILTER(EXP_NF_DATASET, [MINUTOS_AGUARDANDO] > 60))` com formatação condicional |

## 4. Escalonamento

| Severidade | Resposta esperada | Quem |
|---|---|---|
| **Alta** | Investigar no mesmo turno | Operador notifica Eduardo |
| **Média** | Investigar no fim do dia | Operador anota; Eduardo revisa |
| **Baixa** | Revisar na reunião semanal | Eduardo |
| **Visual** | Ação direta do operador | Operador |

## 5. Mensagens-padrão (Teams)

### Sucesso
```
✅ Ciclo {Ciclo_ID} concluído
NFs: {Total_NFs} | Classificadas: {Total_Classificadas} | Falhas: 0
Lead time: {minutos} min
Pasta: {Link_Pasta}
```

### Com falhas parciais
```
⚠️ Ciclo {Ciclo_ID} concluído com falhas
NFs: {Total_NFs} | Classificadas: {Total_Classificadas} | Falhas: {Total_Falhas}
Verificar: {Link_Pasta}/_falhas/
```

### Erro
```
❌ Ciclo {Ciclo_ID} falhou
Status: ERRO | Detalhe: {mensagem do erro}
Eduardo, favor verificar.
```

## 6. O que NÃO deve gerar alerta

Para evitar ruído:

- NFs com `STATUS_FISCAL ≠ FINALIZADO` esperadas (parte do processo) — vão pro dashboard, não geram push.
- Volumes acima da média mas dentro do P90 histórico.
- Refresh do dataset rodando com menos de 5 min de atraso.

## 7. Revisão dos SLAs

A cada 4 semanas, durante a fase Control, Eduardo + Supervisor revisam:

- SLAs ainda fazem sentido?
- Algum alerta gerou muito ruído? (false positive)
- Algum alerta deixou passar problema real? (false negative)

Ajustes documentados aqui mesmo (versionado por commit).
