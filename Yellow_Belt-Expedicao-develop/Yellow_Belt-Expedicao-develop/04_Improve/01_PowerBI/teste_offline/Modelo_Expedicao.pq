// =====================================================================
// MODELO EXPEDICAO - TESTE OFFLINE (Power Query / M)
// ---------------------------------------------------------------------
// Como usar:
//   1. No Power BI Desktop: Pagina Inicial > Transformar dados
//   2. Nova Fonte > Consulta em Branco
//   3. Exibir > Editor Avancado > apague tudo e cole ESTE codigo
//   4. Edite a variavel  Pasta  abaixo com o caminho da pasta dados_mock
//   5. Concluir. A consulta "Modelo_Expedicao" traz as colunas do dataset.
//
// Lista ICMS-ST (VAT_TAX_ID) mockada = {"101"}. Na producao, trocar pela
// lista real de ~46 codigos das queries (ver Mapa_de_Regras D.7/D.10).
// =====================================================================
let
    // >>> EDITE AQUI: caminho da pasta com os CSVs (termine com \) <<<
    Pasta = "C:\Expedicao\dados_mock\",

    // Lista de VAT_TAX_ID considerados ICMS-ST (mock)
    ICMS_ST_IDS = {"101"},

    // Funcao para ler cada CSV com cabecalho
    Ler = (nome as text) as table =>
        Table.PromoteHeaders(
            Csv.Document(
                File.Contents(Pasta & nome),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
            ),
            [PromoteAllScalars = true]
        ),

    // ---------- 1. Fontes ----------
    RCT  = Ler("RA_CUSTOMER_TRX_ALL.csv"),
    ELT  = Ler("CLL_F031_ELECTRONIC_TRX_ALL.csv"),
    CTL0 = Ler("RA_CUSTOMER_TRX_LINES_ALL.csv"),
    TYP  = Ler("RA_CUST_TRX_TYPES_ALL.csv"),
    RILA = Ler("RA_INTERFACE_LINES_ALL.csv"),
    PAR  = Ler("HZ_PARTIES.csv"),
    ACC  = Ler("HZ_CUST_ACCOUNTS.csv"),
    SIT  = Ler("HZ_CUST_ACCT_SITES.csv"),
    LOC  = Ler("HZ_LOCATIONS.csv"),
    WDA  = Ler("WSH_DELIVERY_ASSIGNMENTS.csv"),
    WDD  = Ler("WSH_DELIVERY_DETAILS.csv"),

    // ---------- 2. Agregacoes de linhas (CTL) ----------
    CTL = Table.TransformColumnTypes(CTL0, {
        {"QUANTITY_INVOICED", type number},
        {"EXTENDED_AMOUNT", type number}
    }),
    // Somas da LINHA de produto (LINE_TYPE = LINE)
    LinhasProduto = Table.SelectRows(CTL, each [LINE_TYPE] = "LINE"),
    AggLinha = Table.Group(LinhasProduto, {"CUSTOMER_TRX_ID"}, {
        {"QUANTITY", each List.Sum([QUANTITY_INVOICED]), type number},
        {"EXTENDED_AMOUNT", each List.Sum([EXTENDED_AMOUNT]), type number},
        {"GLOBAL_ATTRIBUTE19", each List.First([GLOBAL_ATTRIBUTE19]), type text}
    }),
    // Soma das linhas de imposto ICMS-ST (LINE_TYPE = TAX e VAT_TAX_ID na lista)
    LinhasST = Table.SelectRows(CTL, each [LINE_TYPE] = "TAX" and List.Contains(ICMS_ST_IDS, [VAT_TAX_ID])),
    AggST = Table.Group(LinhasST, {"CUSTOMER_TRX_ID"}, {
        {"ICMS_ST", each List.Sum([EXTENDED_AMOUNT]), type number}
    }),

    // ---------- 3. RILA (quantidade pedida) ----------
    RILAt = Table.TransformColumnTypes(RILA, {{"QUANTITY_ORDERED", type number}}),
    AggRILA = Table.Group(RILAt, {"CUSTOMER_TRX_ID"}, {
        {"QUANTITY_ORDERED", each List.Sum([QUANTITY_ORDERED]), type number},
        {"BATCH_SOURCE_NAME", each List.First([BATCH_SOURCE_NAME]), type text}
    }),

    // ---------- 4. Entrega (WDA -> WDD) por delivery ----------
    WDDt = Table.TransformColumnTypes(WDD, {{"SHIPPED_QUANTITY", type number}}),
    Entrega = Table.NestedJoin(WDA, {"DELIVERY_DETAIL_ID"}, WDDt, {"DELIVERY_DETAIL_ID"}, "d", JoinKind.LeftOuter),
    EntregaExp = Table.ExpandTableColumn(Entrega, "d",
        {"SUBINVENTORY", "SHIPPED_QUANTITY", "SHIPMENT_PRIORITY_CODE"},
        {"SUBINVENTORY", "SHIPPED_QUANTITY", "SHIPMENT_PRIORITY_CODE"}),
    AggEntrega = Table.Group(EntregaExp, {"DELIVERY_ID"}, {
        {"SUBINVENTORY", each List.First([SUBINVENTORY]), type text},
        {"SHIPPED_QUANTITY", each List.Sum([SHIPPED_QUANTITY]), type number},
        {"SHIPMENT_PRIORITY_CODE", each List.First([SHIPMENT_PRIORITY_CODE]), type text}
    }),

    // ---------- 5. Base = RA_CUSTOMER_TRX_ALL + merges ----------
    B0 = Table.SelectRows(RCT, each [ORG_ID] = "1344"),

    // Tipo de transacao -> INVOICE_TYPE e CFOP
    B1 = Table.ExpandTableColumn(
        Table.NestedJoin(B0, {"CUST_TRX_TYPE_ID"}, TYP, {"CUST_TRX_TYPE_ID"}, "t", JoinKind.LeftOuter),
        "t", {"NAME", "GLOBAL_ATTRIBUTE3"}, {"INVOICE_TYPE", "CFOP"}),

    // Nota eletronica -> CHAVE_ACESSO, STATUS
    B2 = Table.ExpandTableColumn(
        Table.NestedJoin(B1, {"CUSTOMER_TRX_ID"}, ELT, {"CUSTOMER_TRX_ID"}, "e", JoinKind.LeftOuter),
        "e", {"ATTRIBUTE2", "STATUS"}, {"CHAVE_ACESSO", "STATUS_COD"}),

    // Linhas -> QUANTITY, EXTENDED_AMOUNT, GA19
    B3 = Table.ExpandTableColumn(
        Table.NestedJoin(B2, {"CUSTOMER_TRX_ID"}, AggLinha, {"CUSTOMER_TRX_ID"}, "l", JoinKind.LeftOuter),
        "l", {"QUANTITY", "EXTENDED_AMOUNT", "GLOBAL_ATTRIBUTE19"}, {"QUANTITY", "EXTENDED_AMOUNT", "GA19"}),

    // Imposto ICMS-ST
    B4 = Table.ExpandTableColumn(
        Table.NestedJoin(B3, {"CUSTOMER_TRX_ID"}, AggST, {"CUSTOMER_TRX_ID"}, "s", JoinKind.LeftOuter),
        "s", {"ICMS_ST"}, {"ICMS_ST"}),

    // RILA -> pedido + batch source
    B5 = Table.ExpandTableColumn(
        Table.NestedJoin(B4, {"CUSTOMER_TRX_ID"}, AggRILA, {"CUSTOMER_TRX_ID"}, "r", JoinKind.LeftOuter),
        "r", {"QUANTITY_ORDERED", "BATCH_SOURCE_NAME"}, {"QUANTITY_ORDERED", "BATCH_SOURCE_NAME"}),

    // Entrega -> SUB_LOC bruto + embarcado + prioridade (CT_REFERENCE = DELIVERY_ID)
    B6 = Table.ExpandTableColumn(
        Table.NestedJoin(B5, {"CT_REFERENCE"}, AggEntrega, {"DELIVERY_ID"}, "w", JoinKind.LeftOuter),
        "w", {"SUBINVENTORY", "SHIPPED_QUANTITY", "SHIPMENT_PRIORITY_CODE"},
             {"SUBINVENTORY", "SHIPPED_QUANTITY", "SHIPMENT_PRIORITY_CODE"}),

    // Cliente -> PARTY_ID -> PARTY_NAME
    B7 = Table.ExpandTableColumn(
        Table.NestedJoin(B6, {"SOLD_TO_CUSTOMER_ID"}, ACC, {"CUST_ACCOUNT_ID"}, "a", JoinKind.LeftOuter),
        "a", {"PARTY_ID"}, {"PARTY_ID"}),
    B8 = Table.ExpandTableColumn(
        Table.NestedJoin(B7, {"PARTY_ID"}, PAR, {"PARTY_ID"}, "p", JoinKind.LeftOuter),
        "p", {"PARTY_NAME"}, {"PARTY_NAME"}),

    // Endereco -> LOCATION_ID -> STATE + CNPJ
    B9 = Table.ExpandTableColumn(
        Table.NestedJoin(B8, {"SHIP_TO_SITE_USE_ID"}, SIT, {"CUST_ACCT_SITE_ID"}, "cs", JoinKind.LeftOuter),
        "cs", {"LOCATION_ID"}, {"LOCATION_ID"}),
    B10 = Table.ExpandTableColumn(
        Table.NestedJoin(B9, {"LOCATION_ID"}, LOC, {"LOCATION_ID"}, "lo", JoinKind.LeftOuter),
        "lo", {"STATE", "GLOBAL_ATTRIBUTE3", "GLOBAL_ATTRIBUTE4", "GLOBAL_ATTRIBUTE5"},
              {"STATE", "L_GA3", "L_GA4", "L_GA5"}),

    // ---------- 6. Colunas derivadas ----------
    // CNPJ = SUBSTR(GA3||GA4||GA5, 2, 14)  -> Text.Middle indice 1, tamanho 14
    C_CNPJ = Table.AddColumn(B10, "CNPJ", each
        Text.Middle(Text.Combine({[L_GA3], [L_GA4], [L_GA5]}), 1, 14), type text),

    // CFOP + ST  (S_ST se soma ICMS-ST = 0/nulo; senao C_ST)
    C_CFOP = Table.AddColumn(C_CNPJ, "CFOP_ST", each
        [CFOP] & (if ([ICMS_ST] = null or [ICMS_ST] = 0) then " S_ST" else " C_ST"), type text),

    // CASE_RILA = OK se pedido = embarcado
    C_RILA = Table.AddColumn(C_CFOP, "CASE_RILA", each
        if [QUANTITY_ORDERED] = [SHIPPED_QUANTITY] then "OK" else "VERF_RILA", type text),

    // STATUS_FISCAL (DECODE)
    C_STATUS = Table.AddColumn(C_RILA, "STATUS_FISCAL", each
        if [STATUS_COD] = "2" then "FINALIZADO"
        else if [STATUS_COD] = "4" or [STATUS_COD] = "6" then "CANCELADO"
        else "ERRO", type text),

    // SUB_LOC: oleo -> OLEO_<item>; senao GA19 se preenchido; senao locator (SUBINVENTORY)
    //          + sufixo EMBREAGEM_DSH quando prioridade = DIRECT SHIPMENT
    C_SUBLOC = Table.AddColumn(C_STATUS, "SUB_LOC", each
        let
            base =
                if [CFOP] = "6.655" or [CFOP] = "5.655" then "OLEO_" & (if [GA19] = null then "" else [GA19])
                else if [GA19] <> null and [GA19] <> "" then [GA19]
                else [SUBINVENTORY],
            sufixo = if [SHIPMENT_PRIORITY_CODE] = "DIRECT SHIPMENT" then "_EMBREAGEM_DSH" else ""
        in base & sufixo, type text),

    // PAGA_GUIA por UF (5 incondicionais + 5 condicionais)
    C_GUIA = Table.AddColumn(C_SUBLOC, "PAGA_GUIA", each
        let
            inc = List.Contains({"AC","AM","AP","RO","RR"}, [STATE]),
            cond = List.Contains({"AL","DF","GO","MS","TO"}, [STATE]) and [EXTENDED_AMOUNT] <> 0
        in if inc or cond then "SIM" else "NAO", type text),

    // NOTA_MAE: sem delivery -> mae
    C_MAE = Table.AddColumn(C_GUIA, "NOTA_MAE", each
        if [CT_REFERENCE] = null or [CT_REFERENCE] = "" then "SIM" else "NAO", type text),

    // ---------- 7. Ordenacao final + ORDEM_CLASSIFICACAO (A/B/C/D) ----------
    Ordenado = Table.Sort(C_MAE, {
        {"PAGA_GUIA", Order.Descending},
        {"SUB_LOC", Order.Ascending},
        {"CT_REFERENCE", Order.Ascending},
        {"TRX_NUMBER", Order.Ascending}
    }),
    ComIndice = Table.AddIndexColumn(Ordenado, "INDICE", 1, 1, Int64.Type),
    ComOrdem = Table.AddColumn(ComIndice, "ORDEM_CLASSIFICACAO", each
        (if [INDICE] < 10 then "A" else if [INDICE] < 100 then "B" else if [INDICE] < 1000 then "C" else "D")
        & Text.From([INDICE]), type text),

    // ---------- 8. Selecao final das colunas do dataset ----------
    Final = Table.SelectColumns(ComOrdem, {
        "TRX_NUMBER", "TRX_DATE", "CNPJ", "PARTY_NAME", "INVOICE_TYPE",
        "BATCH_SOURCE_NAME", "QUANTITY", "EXTENDED_AMOUNT", "SUB_LOC",
        "CT_REFERENCE", "NOTA_MAE", "CHAVE_ACESSO", "STATUS_FISCAL",
        "CASE_RILA", "CFOP_ST", "STATE", "PAGA_GUIA", "ORDEM_CLASSIFICACAO"
    }),
    Renomeado = Table.RenameColumns(Final, {
        {"TRX_NUMBER", "NF"},
        {"CT_REFERENCE", "DELIVERY"}
    })
in
    Renomeado
