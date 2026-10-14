# Manual de Operação - Expedição AFT (Eaton Valinhos)

> **Versão vigente: 2026-10-14.** O procedimento abaixo substitui as instruções do anexo histórico. Acessos, caminhos e autorizações ainda precisam de validação local antes da entrega como rotina liberada.

## 1. Objetivo e limites

Orientar a conferência de notas fiscais, a classificação dos PDFs no SharePoint e a preparação da impressão. Power BI apresenta os dados e calcula classificação/ordem; Power Automate organiza arquivos; a equipe confere documentos e impressão física. A ferramenta não substitui liberação fiscal nem confirmação de entrega.

O responsável confirmou o funcionamento de Power BI, atualização do modelo, processamento de PDFs e paga guias. Ambiente de produção, homologação e detalhes dos fluxos: a confirmar. Não executar instruções de teste como rotina.

## 2. Cadastro operacional obrigatório

| Informação | Valor | Quem valida |
|---|---|---|
| Link do relatório e ambiente autorizado | A confirmar | BI/TI |
| Biblioteca e pasta de origem dos PDFs | A confirmar | Automação + supervisor |
| Pastas de resultado, exceções e identificação de rodada | A confirmar | Automação + supervisor |
| Procedimento SYNCHRO de download | A confirmar | Expedição |
| Impressora, leitor PDF e sequência de lote homologada | A confirmar | Expedição + TI |
| Contato do supervisor e substituto | A confirmar | Expedição |
| Contato Fiscal/Faturamento | A confirmar | Fiscal |
| Contato TI/BI/Automação e canal de chamado | A confirmar | TI |
| Tempo esperado de atualização e de processamento | A confirmar | Dados + Automação |
| Liberação e retorno de guia | A confirmar | Fiscal + Automação |

O site configurado para o histórico é uma referência técnica; não deve ser tratado como caminho comprovado de entrada/saída de PDFs.

## 3. Conhecendo as telas

| Página | Uso pela expedição |
|---|---|
| Visão Geral | Observar totais, destinos e motivos para o período selecionado |
| Lista de Impressão | Conferir ordem, guia, nota, delivery, mãe, prisma, volume, cliente, UF, transportadora, aptidão, chave, impostos e status de ciclo |
| Monitor | Investigar notas não aptas com Fiscal/Armazém |
| Óleo | Conferir documentação do fluxo de óleo; validar os filtros da página |
| Chaves para Download | Consultar chaves aptas no contexto de filtros; procedimento de cópia/download a confirmar |
| DL Etiquetas | Consultar chaves e comando *DN; rotina de etiquetas a confirmar antes de usar |
| Mesma NF em Outro Locator | Conferir LOC_ALL e necessidade de separação em mais de um local com o Armazém |

O filtro de data usa o horário de faturamento do modelo, não necessariamente o momento do processamento. Verificar também aptidão, paga guia e demais filtros ativos. Uma tela filtrada não prova que o fluxo receberá apenas as notas visíveis.

## 4. Botões da Lista de Impressão

| Rótulo exibido | Uso confirmado | Cuidado |
|---|---|---|
| ATUALIZAR DATASET | Solicitar atualização do modelo | Clique uma vez, aguarde conclusão e recarregue os visuais. Não garante atualização das origens |
| PROCESSAR PDFs | Classificar arquivos no SharePoint conforme a ordem da Lista de Impressão | Conferir universo, origem e execução; não repetir em falha parcial |
| Paga Guia | Fluxo de paga guias funcional | Procedimento, resultados e retorno: a confirmar com Fiscal/responsável |
| PAGA GUIA [TESTE] | Visual de teste | Não usar na rotina liberada |

Neste manual, “processar ciclo” é o nome da atividade; o botão da cópia atual se chama `PROCESSAR PDFs`.

## 5. Procedimento por rodada

1. Identificar a rodada com o supervisor. Abrir o relatório autorizado e conferir período e filtros na Lista de Impressão.
2. Quando necessário, solicitar atualização pelo botão ATUALIZAR DATASET. Aguardar confirmação do término do refresh, recarregar visuais e conferir se as notas esperadas estão presentes. Sem confirmação, parar e acionar suporte.
3. Obter os PDFs pelo procedimento SYNCHRO aprovado e colocá-los na pasta autorizada. Se usar sincronização local, confirmar a presença dos arquivos na biblioteca SharePoint pelo navegador. Ícones locais não substituem essa conferência.
4. Conciliar por chave, não apenas por quantidade: notas esperadas, PDFs disponíveis, aptidão, guia, prisma e histórico. Uma mesma quantidade pode esconder notas diferentes.
5. Separar pendências: notas não aptas, guia sem liberação, chave inválida, prisma desconhecido e histórico já processado. Confirmar com o responsável que o universo do fluxo corresponde à rodada, independentemente dos filtros visuais.
6. Clicar PROCESSAR PDFs uma vez. Aguardar conclusão pelo mecanismo homologado. Não há tempo máximo comprovado nesta revisão; acionar suporte conforme o SLA a definir.
7. Conferir resultado por chave: arquivos classificados, rejeitados, ainda na origem e registros de processamento. Movimento parcial exige reconciliação antes de repetir.
8. Imprimir apenas notas autorizadas e conferir separação física/ordem. Registrar conclusão e pendências da rodada no controle definido pelo supervisor.

## 6. Classificações e impedimentos

| Valor no modelo | Significado | Ação |
|---|---|---|
| PRONTO | Apta, sem paga guia e sem CFOP de óleo | Conferir prisma e pendências operacionais antes da impressão |
| AGUARDANDO GUIA | Paga guia SIM, com ou sem aptidão | Segregar; conferir APTA/MOTIVO e aguardar Fiscal. Não é autorização de expedição |
| OLEO | Apta, sem paga guia e CFOP 6.655/5.655 | Seguir rotina de óleo aprovada |
| EXCECAO/ERRO_NF | Fiscal não finalizado, RILA OK e chave de comprimento 44 | Fiscal/Faturamento |
| EXCECAO/VERIFICAR_DELIVERY | Divergência de quantidade com fiscal finalizado e chave de comprimento 44 | Armazém |
| EXCECAO/ERRO_DELIVERY_NF | Divergência de quantidade e fiscal | Armazém + Fiscal |
| EXCECAO/CHAVE_INVALIDA | Comprimento da chave do modelo diferente de 44 | Conferir origem com BI/Fiscal; não presumir PDF ilegível |
| EXCECAO/OUTROS | Fallback da classificação | Responsável técnico |

Esses são destinos calculados pelo modelo. O mapeamento das pastas físicas deve ser confirmado no fluxo. SUB_LOC pode representar prisma digitado, locator ou óleo/prioridade; não exigir um único formato STG para todos os casos.

## 7. Histórico e reimpressão

| STATUS_CICLO | Interpretação |
|---|---|
| PENDENTE | Chave normalizada de comprimento 44 não encontrada no histórico importado; ainda verificar aptidão e documentos |
| JA PROCESSADA | Chave encontrada no histórico importado; conferir evidência antes de novo processamento/impressão |
| SEM CHAVE | Chave normalizada não tem comprimento 44; encaminhar para análise |

O histórico só chega ao relatório no refresh. Não há comprovação nesta cópia de que o fluxo bloqueie todos os disparos duplicados nem de que DataImpressao corresponda à impressão física. Não apagar registros ou pastas para “liberar” uma nota. Reimpressão requer supervisor, identificação do lote afetado e justificativa auditável.

## 8. Impressão e fechamento

Os nomes calculados são `EXPEDICAO <letra><posição> - NF <nota>.pdf`, `PAGA GUIA <letra><posição> - NF <nota>.pdf` ou `DFE<chave>.pdf`. Ordenar por nome ajuda a preparar o lote, mas não garante a sequência do spooler. Usar leitor e método homologados; conferir primeira/última nota e sequência física. Não recomendar seleção indiscriminada de todos os PDFs antes de validar elegibilidade.

Nota filha referencia a menor NF numérica da mesma delivery; seu volume é zero no modelo para evitar recontagem. Campo NOTA_MAE vazio pode significar mãe ou nota isolada. A ordem pode mudar no refresh; não atualizar/reclassificar no meio de um lote sem reconciliação.

Ao encerrar, registrar rodada, operador, horário, notas/documentos esperados, classificados, bloqueados, impressos e pendentes. Confirmar destino físico com Armazém. Guarda, limpeza e retenção de documentos/histórico dependem de política aprovada, ainda a confirmar.

## 9. Problemas e escalonamento

| Situação | Conduta imediata |
|---|---|
| Botão falhou ou só parte moveu | Não repetir; registrar horário, filtros e evidências; acionar Automação/TI |
| Muitas exceções ou nota ausente | Parar; conferir chaves, período, origem e refresh com BI; não atribuir automaticamente ao ciclo errado |
| Prisma vazio ou só prioridade | Não inferir local físico; acionar Armazém + BI |
| Guia pendente | Segregar e acionar Fiscal; não pressupor pagamento pelo botão |
| Impressora interrompeu | Identificar lote afetado e pedir autorização para reimpressão restrita |
| SYNCHRO/SharePoint indisponível | Suspender etapa; registrar evidência e acionar suporte |

Chamado: horário, rodada, tela, filtros, ação, mensagem e ID de execução quando disponível; dados fiscais apenas em canal corporativo restrito. Nunca enviar credenciais ou notas reais em chamados públicos.

## 10. Glossário e treinamento

NF: nota fiscal. Delivery: referência de entrega. Prisma/SUB_LOC: referência de separação. Chave: identificador fiscal de 44 dígitos esperado pelo processo. APTA: combinação de status fiscal, quantidade e comprimento da chave no modelo. Rodada/ciclo: lote operacional definido pelo supervisor, não uma identificação automática garantida pelo filtro.

Treinamento deve incluir um lote normal, óleo, guia pendente, divergência de delivery, prisma ausente, falha parcial e reimpressão autorizada. Aprovação final: Expedição, Fiscal e TI, com nomes e data a confirmar.

Referências: [guia rápido](../docs_ferramenta/02_Modo_de_Uso_Operador.md), [manual técnico](../docs_ferramenta/01_Documentacao_Tecnica.md), [pendências](../03_Analyze/07_Open_Questions.md).

<details>
<summary>Anexo histórico: instruções de agosto/2026, substituídas; não usar como rotina</summary>

> Documentação de uso e funcionamento para **operadores e equipe da expedição**.
> Descreve o fluxo real: baixar NFs → colocar na pasta do ciclo → clicar **Processar Ciclo** no Power BI → imprimir na ordem certa.
> **Última atualização:** 2026-08-18

> ⚙️ **Antes de publicar, confirme os itens marcados com ⚙️** (caminho do SharePoint, rótulo exato do botão, contatos).

---

## Como funciona (visão geral)

O sistema substitui a macro manual. Você baixa os PDFs das notas, coloca na pasta do ciclo, e o **Power BI + Power Automate** classificam cada NF automaticamente: renomeiam na ordem de impressão e movem para a pasta do destino físico (prisma). Você só confere e imprime.

```
SYNCHRO (baixa PDFs)  →  Pasta ENTRADA do ciclo (você coloca)
        →  Botão "Processar Ciclo" no Power BI (você clica)
        →  Power Automate classifica, renomeia e organiza em SAIDA/<Ciclo>/
        →  Você abre as pastas de destino e imprime na ordem já correta
```

---

# PARTE 1 — Guia Rápido do Operador (imprima e cole na bancada)

| # | O que fazer | Onde |
|---|---|---|
| 1 | Baixar do SYNCHRO os PDFs das NFs autorizadas do ciclo | SYNCHRO |
| 2 | Copiar os PDFs para a pasta **ENTRADA** do ciclo | File Explorer (atalho OneDrive) |
| 3 | **Esperar todos os PDFs ficarem com ✅ verde** (sincronizados na nuvem) | File Explorer |
| 4 | Abrir o relatório no **Power BI** e conferir a **Visão Geral** (totais do ciclo) | Power BI |
| 5 | Clicar no botão **"Processar Ciclo"** ⚙️ | Power BI (relatório) |
| 6 | Aguardar o fluxo terminar (~poucos minutos) | — |
| 7 | Abrir a pasta **SAIDA/\<Ciclo\>** e imprimir cada destino na ordem (ver Parte 2) | File Explorer |
| 8 | Conferir a pasta **EXCECAO** (se houver) e tratar manualmente | File Explorer |

> ⚠️ **Regra de ouro nº 1:** só clique **Processar Ciclo** depois que **todos** os PDFs estiverem com **✅ verde** no Explorer. Ícone de nuvem azul/setas = ainda subindo → o fluxo não acha o arquivo.

> ⚠️ **Regra de ouro nº 2:** **não reimprima** um ciclo já processado. O sistema tem memória anti-reimpressão — NFs já impressas voltam como **JA_IMPRESSO** e não são reprocessadas.

---

# PARTE 2 — Manual Completo de Operação

## 2.1 As pastas

⚙️ Local: SharePoint **"Expedição - Valinhos"** → biblioteca **Documents** (acessível pelo **File Explorer** via atalho do OneDrive).

| Pasta | Para que serve |
|---|---|
| **ENTRADA** | Onde **você** coloca os PDFs baixados do SYNCHRO, antes de processar |
| **SAIDA/\<Ciclo\>** | Onde o sistema **entrega** os PDFs já classificados e renomeados |

> Cada disparo é um **ciclo novo**: os PDFs de um ciclo **não** podem ser misturados com os do ciclo anterior. A pasta **SAIDA/\<Ciclo\>** separa cada rodada.

## 2.2 As 4 classificações (pastas de destino)

Dentro de **SAIDA/\<Ciclo\>**, cada NF cai em uma destas pastas:

| Pasta | Significa | O que o operador faz |
|---|---|---|
| **PRONTO** | NF apta, sem pendência — pode imprimir e expedir | Imprimir na ordem dos nomes |
| **AGUARDANDO GUIA** | NF com ICMS-ST / paga guia — depende da guia antes de expedir | Imprimir e encaminhar conforme regra fiscal |
| **OLEO** | NF de óleo (CFOP 6.655 / 5.655) — separação específica | Imprimir e separar no fluxo do óleo |
| **EXCECAO/** | NF que **não** pôde ser classificada (erro/pendência) | **Tratar manualmente** (ver Parte 3) |

## 2.3 Nomes de arquivo e ordem de impressão

O sistema renomeia cada PDF para garantir a ordem certa na impressão do Windows:

| Tipo | Padrão do nome |
|---|---|
| NF apta | `EXPEDICAO <L><pos> - NF <nf>.pdf` |
| Paga guia | `PAGA GUIA <L><pos> - NF <nf>.pdf` |
| Sem classificação | `DFE<chave>.pdf` |

- **`<L>` é a letra da ordem** (A, B, C, D) conforme o número de dígitos da posição — garante que o Windows ordene A→B→C→D corretamente.
- **Imprima assim:** abra a pasta do destino, ordene por **Nome**, selecione tudo (Ctrl+A) e imprima. A ordem alfabética já é a ordem física de separação (nota mãe antes das filhas, no mesmo prisma).

## 2.4 Ordem recomendada de impressão dos destinos
1. **PRONTO** (o grosso do ciclo)
2. **AGUARDANDO GUIA** (encaminhar conforme fiscal)
3. **OLEO** (fluxo específico)
4. **EXCECAO** (tratar antes de imprimir — ver Parte 3)

---

# PARTE 3 — Exceções (pasta EXCECAO)

Quando uma NF não pode ser classificada, ela vai para uma subpasta de **EXCECAO** indicando o motivo:

| Subpasta | O que aconteceu | Ação sugerida |
|---|---|---|
| **ERRO_NF** | Problema nos dados da NF | Conferir a NF no sistema / avisar Fiscal |
| **VERIFICAR_DELIVERY** | Delivery inconsistente | Conferir a delivery no Oracle/WMS |
| **ERRO_DELIVERY_NF** | Divergência NF × delivery | Conferir vínculo NF/delivery |
| **CHAVE_INVALIDA** | Chave de acesso do PDF não tem 44 dígitos / ilegível | Rebaixar o PDF do SYNCHRO novamente |
| **OUTROS** | Caso não previsto | Escalar ao responsável |

> Uma NF em EXCECAO **não** foi impressa nem marcada como concluída. Depois de resolver, ela entra no próximo ciclo normalmente.

---

# PARTE 4 — Solução de Problemas

| Sintoma | O que fazer |
|---|---|
| Cliquei **Processar Ciclo** e nada moveu | Confirme que os PDFs estavam com **✅ verde** na ENTRADA antes de clicar. Se estavam subindo (nuvem azul), aguarde e clique de novo. |
| Um PDF ficou em **CHAVE_INVALIDA** | O PDF veio ilegível/incompleto. Baixe de novo do SYNCHRO e reprocesse (só ele, no próximo ciclo). |
| NF que eu esperava **não apareceu** em nenhuma pasta | Pode já ter sido impressa antes (**JA_IMPRESSO** — memória anti-reimpressão). Confira com o supervisor antes de forçar. |
| O Power BI mostra números **desatualizados** | O dado vem do refresh dos dataflows (pode levar até ~30 min). Avise ⚙️ [responsável] se persistir. |
| O botão **Processar Ciclo** dá erro | Não reprocesse repetidamente. Anote o horário e avise ⚙️ [responsável]. |
| Impressora travou / sem papel | Resolver no prédio. Reimprimir **só** o lote afetado (a ordem dos nomes garante a sequência). |
| SYNCHRO fora do ar | Acionar TI. |

---

# PARTE 5 — Papéis e contatos

| Assunto | Quem |
|---|---|
| Fluxo Power Automate / Power BI | ⚙️ Eduardo Apolinario |
| NF bloqueada / dúvida fiscal | Time Fiscal |
| Acesso SharePoint / Power BI / OneDrive | TI |
| Impressora | TI / Prédio |
| Política de processo | Supervisor da Expedição |

---

# PARTE 6 — Glossário

| Termo | Significado |
|---|---|
| **Ciclo** | Uma rodada de faturamento/expedição (~350 NFs). 4–6 por dia. |
| **Prisma / SUB_LOC** | Localização física de separação para onde a NF vai. |
| **Chave de acesso** | Código de 44 dígitos que identifica a NF-e; usado para casar o PDF com o dado. |
| **NOTA MÃE / filha** | Notas agrupadas no mesmo prisma; a mãe imprime antes das filhas. |
| **PAGA GUIA** | NF com ICMS-ST que exige guia antes da expedição. |
| **PRONTO / OLEO / AGUARDANDO GUIA / EXCECAO** | As 4 classificações de destino do PDF. |
| **JA_IMPRESSO** | NF que já foi processada/impressa antes — bloqueada para não reimprimir. |
| **✅ verde (OneDrive)** | Arquivo já sincronizado na nuvem; pronto para o fluxo ler. |

---

## ⚙️ Itens a confirmar antes de publicar
- Caminho exato do SharePoint / atalho OneDrive das pastas **ENTRADA** e **SAIDA**.
- Rótulo exato do botão no relatório (ex.: "Processar Ciclo").
- Nome/contato do responsável técnico para escalonamento.
- Decisão pendente do `DaysText` (janela de refresh) — não afeta o operador, mas afeta a atualização dos dados.

---

*Versão imprimível: a **Parte 1** cabe em 1 página — imprima e cole na bancada.*

</details>
