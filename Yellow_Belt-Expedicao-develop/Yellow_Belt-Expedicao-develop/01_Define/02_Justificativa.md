# Justificativa do Projeto

> Motivação curta para o Project Charter.
> Última atualização: 2026-05-28

O processo de expedição da planta Eaton Valinhos depende da impressão correta e ordenada das Notas Fiscais para que a separação física por prisma ocorra sem retrabalho. Uma macro que automatizava essa organização parou de funcionar após uma atualização do SYNCHRO e não pode ser corrigida — o Excel é gerado, mas os PDFs classificados não.

Hoje, o time imprime fora de ordem e separa manualmente. São cerca de **2 horas de retrabalho por ciclo de faturamento**, sobre um volume médio de 350 NFs, totalizando ~4h por ciclo completo. Esse esforço manual não agrega valor, aumenta o risco de erro físico na separação e atrasa o embarque.

Além do tempo perdido, o fluxo atual envia PDFs de NFs reais para um serviço externo gratuito (`api.pdfconverted.com`) na etapa de merge — um risco de compliance que precisa ser eliminado.

Este projeto propõe substituir a macro quebrada por uma solução baseada em ferramentas já licenciadas (Power BI Pro + Power Automate + SharePoint), eliminando a separação manual, restaurando a previsibilidade do ciclo e removendo o uso de serviço externo para arquivos fiscais. O ganho estimado é de **~2h45min por ciclo (-70%)** e a remoção integral do risco de compliance hoje existente.
