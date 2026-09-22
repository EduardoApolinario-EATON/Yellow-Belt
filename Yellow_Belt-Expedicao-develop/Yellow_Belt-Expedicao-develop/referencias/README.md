# referencias/ — Materiais de referência

> Documentos e artefatos do estado AS-IS preservados para consulta.
> Última atualização: 2026-05-28

## Conteúdo

| Item | Descrição |
|---|---|
| `Manual_AS_IS.pdf` | Manual de instrução do operador no fluxo atual (antes do TO-BE) |
| `macro_antiga/` | Engenharia reversa da macro VBA legada (chave do Caminho A — Power Automate Desktop) |
| `exemplos/Exemplo_Notas_Fiscais.xlsb` | Planilha de exemplo do output atual da macro |
| `exemplos/ciclo_exemplo_2025-06-06.zip` | ZIP com ~350 PDFs (DANFEs) de um ciclo real para teste do classificador |

## Como usar

| Quando você precisar | Olhe em |
|---|---|
| Entender o fluxo manual atual | `Manual_AS_IS.pdf` |
| Entender o que a macro fazia | `macro_antiga/README.md` + `codigo/` |
| Testar o classificador com dados reais | `exemplos/ciclo_exemplo_2025-06-06.zip` |
| Validar schema do dataset | `exemplos/Exemplo_Notas_Fiscais.xlsb` |

## Compliance

O `Manual_AS_IS.pdf` cita uso de `api.pdfconverted.com`; o risco deve ser tratado antes de qualquer publicação externa. A pasta `macro_antiga/` deve permanecer apenas no repositório interno; **não publicar externamente**.

## Pendentes

- `orquestrador_PowerBI/` — clone read-only do repo do gestor (segunda rodada).
