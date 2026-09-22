# HANDOFF — Projeto Expedição AFT (Modelo_Expedicao)

> Documento de contexto para continuar o trabalho em qualquer sessão do Copilot
> (inclusive ao migrar do Codespace para o VS Code local). Leia isto primeiro.
> Última atualização: 2026-07-27.

## Objetivo do projeto

Substituir a macro VBA manual (`IMPRESSAO.xlsb`, ~2h12 por ciclo) da Expedição AFT
(Eaton Valinhos Aftermarket) por um modelo Power BI que **classifica as NFs** (1 linha
por NF) para ordenar impressão e definir destino físico (prisma). ORG_ID=1344, warehouse
1627.

## FONTE DE VERDADE

`reports/EXPEDICAO_AFT/reference/QUERY_AFTK_original.sql` — a query PL/SQL oficial que a
expedição roda (gera o `QUERY_AFTK.xlsx`). A macro NÃO calcula nada: consome essa query.
**Todo o dataset `NotasFiscais` replica essa query** (usando tabelas base do Bronze).

## DECISÕES FIRMES (do chefe / usuário)

- **NUNCA** mexer na branch `main` nem no workspace de PRODUÇÃO do Power BI ("VG Data Management", GUID 5f0e4cee-9281-4b9e-88fb-7af2b207ce9f). Trabalhar em `develop` + DEV.
- DEV = workspace "VG Data Management [Development]" (GUID ee6c85f4-c90f-440e-8433-bb036d02ade7).
- **NÃO usar views `_BR_V`** no Power BI (o PBI não acessa as tabelas por trás das views).
  → Reconstruir tudo com **tabelas base do Bronze** (Caminho A). Decisão de 2026-07-27.

## ESTADO ATUAL — Modelo `NotasFiscais` (reports/EXPEDICAO_AFT/)

VALIDADO e funcionando (em DEV):
- 1 linha por NF, STATUS_FISCAL, CASE_RILA, PAGA_GUIA, APTA, UF, CFOP/CFOP_COMPLETO,
  PARTY_NAME, ORDEM_CLASSIFICACAO.
- CNPJ = HZ_PARTIES.JGZZ_FISCAL_CODE (só 8 díg = raiz; usuário aceitou provisório).
  O correto (14 díg) seria RA_ADDRESSES_ALL.GA3||GA4||GA5 substr(2,14) via RA_SITE_USES_ALL.
- **SUB_LOC**: lógica implementada e a parte do prisma validada (ver abaixo).

### SUB_LOC — lógica (fiel à query)
```
SUB_LOC = BASE + " " + PRIORIDADE + " " + FLAG_EMBREAGEM
BASE:
  CFOP óleo (6.655/5.655) -> "OLEO_" + MTL_SYSTEM_ITEMS_B.SEGMENT1 (item)
  header RA_CUSTOMER_TRX_ALL.GLOBAL_ATTRIBUTE19 preenchido -> usa ele (= o PRISMA, digitado manual)
  senão -> locator MTL_ITEM_LOCATIONS.SEG1.SEG2.SEG3 (via WSH_DELIVERY_DETAILS.LOCATOR_ID)
PRIORIDADE = OE_ORDER_LINES.SHIPMENT_PRIORITY_CODE (ONT) — ex "DIRECT SHIPMENT", "UNIDADE PARADA DSH"
FLAG = "EMBREAGEM_DSH" se item categoria BRA MFG='A' E prioridade='DIRECT SHIPMENT' (INV+ONT)
```
- ✅ Ramo do GA19 (prisma) VALIDADO: PRISMA_GA19 == SUB_LOC (ex `SJ2129-26`).
- Prisma tem formatos variados por armazém: `SJ####-##`, `STG.XXXX.###`, `STGD.UPAR.###`.

### SUB_LOC — 2 PONTOS QUE FALTAM
1. **Locator vem `FGI` (origem), deveria ser `STG` (staging).** Quando o GA19 do header é
   NULL, usa-se o locator do WSH; meu join está pegando o subinventário FGI, não o STG.
   Diagnóstico em andamento: colunas temporárias `LOC_ALL`/`SUBINV_ALL` (todos locators/subinv
   por NF) para ver se o STG existe nos dados do WSH ou se é problema de estágio/timing.
2. **Sufixo de prioridade + `_EMBREAGEM_DSH`.** Precisa do módulo **ONT** (`OE_ORDER_LINES`/
   `OE_ORDER_HEADERS`) no DEV — ainda NÃO está. (INV_MST já está no DEV, com MTL_*.)

## MUDANÇAS DE BRONZE já feitas no DEV (via editar query no dataflow, versões espelhadas do PROD)
- `BRZ_ORACLE_AR_MST`: `RA_CUST_TRX_TYPES_ALL.GLOBAL_ATTRIBUTE3` (CFOP) + `HZ_LOCATIONS.GA3/4/5`.
- `BRZ_ORACLE_AR_DOC_CUR`: `RA_CUSTOMER_TRX_LINES_ALL.GLOBAL_ATTRIBUTE19` + `RA_CUSTOMER_TRX_ALL` (header) `.GLOBAL_ATTRIBUTE19`.
- Artefatos de deploy em `prod_exports/fixed/DEPLOY_*.m` (gitignored).
- Modelo consome dataflows por `PowerBI.Dataflows(null)` + `workspaceId` (GUID). NÃO usar PowerPlatform.Dataflows.

## DADOS / VALIDAÇÃO — armadilha importante
- `AR_DOC_CUR` tem parâmetro **`DaysText`** (default `"0"` = só hoje). Com "0" o DEV mostra
  pouquíssimas NFs (frescas, sem prisma). Para validar, aumentar `DaysText` p/ "15" no dataflow
  (Editar tabelas → parâmetro DaysText → valor 15) → Atualizar dataflow → atualizar modelo.
- Snapshot intraday muda muito; dataflows podem estar dessincronizados (refresh AR/CLL/WSH/INV juntos).

## FLUXO DE DEPLOY (atual)
1. Copilot edita `.tmdl` em `reports/EXPEDICAO_AFT/` + commita em `develop` + regenera
   `reports/EXPEDICAO_AFT/Modelo_Expedicao.zip` (gitignored).
2. Usuário: baixa/pull → abre `Modelo_Expedicao.pbip` no Power BI Desktop (Windows) →
   Publicar no DEV (Substituir) → Atualizar no Service.
- Git Integration do Fabric = DESABILITADA no tenant. Sem Service Principal. Sem git no Windows (até agora).
- Objetivo: local via GitHub Desktop/VS Code Desktop (pull em vez de zip), OU Git Integration, OU Service Principal.

## PENDÊNCIAS / PRÓXIMOS PASSOS
1. Fechar SUB_LOC: (a) resolver locator STG (ver diagnóstico LOC_ALL/SUBINV_ALL), (b) trazer ONT p/ o sufixo.
2. Remover colunas de diagnóstico (`LOC_ALL`, `SUBINV_ALL`) depois de resolver.
3. CNPJ full-14 (opcional).
4. Relatório: páginas + medidas DAX (Fila de Impressão, Exceções, Paga-Guia).
5. Camada de execução: SharePoint (3 listas) + Power Automate (Sync via "Run a query against a dataset" + Classifier de PDFs `DFE<44>.pdf`).
6. Caminho PROD (Deployment Pipeline não operacional → paste manual) — alinhar com chefe.

## REGRAS DE DERIVAÇÃO (definitivas, da query/macro)
- STATUS = DECODE(CLL_F031.STATUS): 2=FINALIZADO; 4,6=CANCELADO; 1,3,5,7,8=ERRO.
- CASE_RILA = OK se SUM(QUANTITY_ORDERED por CT_REFERENCE=INTERFACE_LINE_ATTRIBUTE3) = SUM(SHIPPED_QUANTITY por DELIVERY_ID, SOURCE_CODE='OE'); senão VERF_RILA.
- PAGA_GUIA = SIM se UF in {AC,AM,AP,RO,RR} OU (UF in {AL,DF,GO,MS,TO} e ICMS_ST<>0).
- CFOP = C.GLOBAL_ATTRIBUTE3; CFOP_ST = S_ST se soma ICMS-ST=0 senão C_ST.
- CHAVE_ACESSO = CLL_F031.ATTRIBUTE2 (44 díg, sem prefixo DFE). NOTA_MAE = Text.Middle(chave,27,7).
- ORDEM = index após sort PAGA_GUIA desc, SUB_LOC asc, DELIVERY asc, NF asc.
- APTA = "Sim" se STATUS=FINALIZADO e CASE_RILA=OK e CHAVE_LEN=44.
