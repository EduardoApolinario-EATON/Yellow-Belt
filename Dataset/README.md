# Copia de Referencia - Power BI Expedicao

Revisao documental: 2026-10-14. Esta pasta contem a copia da versao atual fornecida pelo responsavel para revisar a documentacao. A fonte oficial permanece em `mobility-powerbi-architecture`, diretorio `reports/EXPEDICAO_AFT/`. Nao manter duas linhas de desenvolvimento do mesmo modelo.

## Conteudo

- [Modelo_Expedicao.pbip](Modelo_Expedicao.pbip): ponto de abertura do projeto.
- [Modelo_Expedicao_ATUAL.Report/definition.pbir](Modelo_Expedicao_ATUAL.Report/definition.pbir): referencia ao modelo; paginas e visuais em JSON e recursos estaticos.
- [Modelo_Expedicao_ATUAL.SemanticModel/definition.pbism](Modelo_Expedicao_ATUAL.SemanticModel/definition.pbism): definicao do modelo; tabelas, consultas M, medidas/colunas DAX e relacionamentos em TMDL.
- [Modelo_Expedicao_ATUAL.SemanticModel/definition/tables/NotasFiscais.tmdl](Modelo_Expedicao_ATUAL.SemanticModel/definition/tables/NotasFiscais.tmdl): classificacao, ordem e nomes dos PDFs.

## Como consultar

Os arquivos textuais podem ser inspecionados neste ambiente Linux. Abrir/publicar o PBIP exige Power BI Desktop compativel em Windows e acessos corporativos. Atualizacao dos dados depende de dataflows e SharePoint; o projeto textual nao e um snapshot de dados nem um export de Power Automate.

Nao renomear pastas ou editar referencias para adequar somente a documentacao. Nao versionar caches `.pbi`, credenciais, dados fiscais ou configuracoes locais. Antes de adicionar esta copia ao Git, revisar os arquivos locais e as regras de exclusao aplicaveis na raiz; as regras do diretorio documental nao cobrem necessariamente esta pasta irma.

## Documentacao vigente

- [Manual tecnico](../Yellow_Belt-Expedicao-develop/Yellow_Belt-Expedicao-develop/docs_ferramenta/01_Documentacao_Tecnica.md).
- [Dicionario de 39 colunas](../Yellow_Belt-Expedicao-develop/Yellow_Belt-Expedicao-develop/04_Improve/01_PowerBI/01_Dataset_Schema.md).
- [Manual da expedicao](../Yellow_Belt-Expedicao-develop/Yellow_Belt-Expedicao-develop/05_Control/05_Manual_Operador.md).

Licencas, publicacao, homologacao e execucoes reais nao foram validadas pela analise estatica dos arquivos.