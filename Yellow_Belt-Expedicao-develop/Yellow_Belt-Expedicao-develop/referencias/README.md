# referencias/ — Materiais de referência

> **Revisão documental: 2026-10-14.** Referências do legado e evidências locais, não contrato atual nem homologação da cópia PBIP. Não presumir que materiais ausentes ou relatos antigos comprovem paridade atual.

Contrato vigente: [Mapa de Regras](../04_Improve/07_Mapa_de_Regras.md), [Dicionário](../04_Improve/01_PowerBI/01_Dataset_Schema.md) e [Manual Técnico](../docs_ferramenta/01_Documentacao_Tecnica.md). Dados fiscais, planilhas e PDFs reais devem permanecer em canal autorizado; não extrair/publicar conteúdo sensível. Evidências de homologação precisam identificar ambiente, versão, amostra e aprovador.

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
