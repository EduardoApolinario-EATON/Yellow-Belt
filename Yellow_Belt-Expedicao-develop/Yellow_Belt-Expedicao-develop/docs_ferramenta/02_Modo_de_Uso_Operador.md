# Guia Rápido - Operador da Expedição

Revisão: 2026-10-14. Referência de treinamento; liberação da rotina depende de confirmar acessos, pastas e responsáveis no [manual completo](../05_Control/05_Manual_Operador.md). Os PDFs antigos desta pasta não foram atualizados.

## Antes de começar

Tenha acesso ao relatório, à biblioteca SharePoint autorizada, ao SYNCHRO e à impressora. Não use o botão `PAGA GUIA [TESTE]`. Não misture PDFs de rodadas diferentes.

## Sequência do ciclo

| Etapa | Ação | Conferência |
|---|---|---|
| 1 | Abrir Lista de Impressão e conferir o período de faturamento e os filtros | A lista deve corresponder à rodada pretendida |
| 2 | Se necessário, usar ATUALIZAR DATASET uma vez | Aguardar conclusão do refresh e recarregar os visuais; se não houver confirmação, acionar suporte |
| 3 | Obter os PDFs pelo procedimento SYNCHRO aprovado e colocá-los na pasta de origem autorizada | Caminho e procedimento de download: a confirmar. Conferir presença dos arquivos no SharePoint, não só no computador |
| 4 | Comparar os PDFs e a lista por chave de acesso | Contagem igual não prova correspondência; verificar chaves, aptidão e notas já processadas |
| 5 | Acionar PROCESSAR PDFs uma vez, somente após a conferência e autorização do universo processado | Não presumir que filtros da tela restringem o fluxo; esse vínculo deve ser homologado |
| 6 | Aguardar conclusão e conferir as pastas resultantes | Arquivos sem destino, erros e movimentos parciais precisam de análise antes de novo disparo |
| 7 | Imprimir apenas o lote autorizado e conferir a sequência física | Ordenar por nome; validar ordem no leitor PDF/impressora e registrar o lote concluído |

## Como tratar os destinos

| Classificação no modelo | Conduta |
|---|---|
| PRONTO | Conferir aptidão, prisma e ausência de pendências antes de imprimir |
| AGUARDANDO GUIA | Segregar e aguardar orientação/liberação do Fiscal. Pode conter nota não apta; não liberar só pelo nome da pasta |
| OLEO | Seguir rotina de óleo validada pelo supervisor |
| EXCECAO/* | Não imprimir junto do lote normal; tratar motivo com Fiscal, Armazém ou TI |

Os nomes acima são valores do modelo. Caminhos físicos e subpastas do fluxo precisam ser confirmados. O botão `Paga Guia` é funcional, mas seu procedimento e resultado ainda precisam ser detalhados pelo responsável; não presumir pagamento automático.

## Pare e peça apoio quando

- A nota não aparecer, a chave não corresponder, o prisma estiver ausente ou a lista parecer desatualizada.
- Houver `JA PROCESSADA`: é presença no histórico importado, não prova de impressão física. Conferir antes de reimprimir.
- O botão der erro ou mover só parte dos arquivos: registrar horário, filtros e evidências; não clicar repetidamente.
- A impressora interromper: identificar exatamente o lote afetado e obter autorização para reimpressão. Não apagar histórico nem reprocessar todo o ciclo.

`PENDENTE` significa chave ausente do histórico importado; não é liberação fiscal. `SEM CHAVE` exige análise da chave. Um ícone de nuvem não significa, por si só, falha: o arquivo pode estar disponível online; a conferência decisiva é na biblioteca SharePoint.

Contatos e caminhos: a confirmar no [Manual do Operador](../05_Control/05_Manual_Operador.md).
