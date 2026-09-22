/* 
alter session set nls_language='AMERICAN';
ALTER SESSION SET CURRENT_SCHEMA=APPS;
BEGIN APPS.mo_global.set_policy_context('S',1344); END;
Begin DBMS_APPLICATION_INFO.SET_CLIENT_INFO('1344'); End;

*/

SELECT DISTINCT A.TRX_NUMBER NF,
                A.CT_REFERENCE DELIVERY,
                CASE
                   WHEN C.GLOBAL_ATTRIBUTE3 IN ('6.655', '5.655') THEN
                    'OLEO_' ||
                   -------ITEM OLEO-------
                    (SELECT MSI.SEGMENT1
                       FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V RCTLA,
                            APPS.XXRA_CUSTOMER_TRX_BR_V       RCTA,
                            APPS.XXMTL_SYSTEM_ITEMS_BR_V      MSI
                      WHERE RCTLA.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                        AND MSI.INVENTORY_ITEM_ID = RCTLA.INVENTORY_ITEM_ID
                        AND RCTLA.WAREHOUSE_ID = MSI.ORGANIZATION_ID
                        AND RCTLA.LINE_TYPE = 'LINE'
                        AND RCTLA.LINE_NUMBER = '1'
                        AND RCTA.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID)
                 ----------------SUBINVENTARIO------------------------------------
                   WHEN A.GLOBAL_ATTRIBUTE19 IS NULL THEN
                    MIL.SEGMENT1 || '.' || MIL.SEGMENT2 || '.' ||
                    MIL.SEGMENT3
                   ELSE
                    A.GLOBAL_ATTRIBUTE19
                 END || ' ' ||
                ------------------OLL.SHIPMENT_PRIORITY_CODE ----------------
                 (SELECT OLL.SHIPMENT_PRIORITY_CODE
                    FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V RCTLA,
                         APPS.XXRA_CUSTOMER_TRX_BR_V       RCTA,
                         APPS.XXMTL_SYSTEM_ITEMS_BR_V      MSI,
                         APPS.XXOE_ORDER_HEADERS_BR_V      OHL,
                         APPS.XXOE_ORDER_LINES_BR_V        OLL
                   WHERE RCTLA.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                     AND MSI.INVENTORY_ITEM_ID = RCTLA.INVENTORY_ITEM_ID
                     AND RCTLA.WAREHOUSE_ID = MSI.ORGANIZATION_ID
                     AND RCTLA.LINE_TYPE = 'LINE'
                     AND RCTLA.LINE_NUMBER = '1'
                     AND OHL.HEADER_ID = OLL.HEADER_ID
                     and RCTLA.INTERFACE_LINE_ATTRIBUTE1 = OHL.ORDER_NUMBER
                     AND RCTA.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                     AND OLL.ORG_ID = 1344
                     AND RCTLA.INVENTORY_ITEM_ID = OLL.INVENTORY_ITEM_ID
                     AND RCTLA.WAREHOUSE_ID = OLL.SHIP_FROM_ORG_ID
                     AND OLL.LINE_ID = RCTLA.INTERFACE_LINE_ATTRIBUTE6
                     AND OLL.SHIPMENT_PRIORITY_CODE IN
                         ('UNIDADE PARADA DSH',
                          'EMBREAGENS',
                          'DIRECT SHIPMENT')) || ' ' ||
                --------------EMBBREAGEM DSH------------------
                 CASE
                   WHEN (SELECT MC.SEGMENT1 --, MSI.SEGMENT1
                           FROM APPS.XXMTL_ITEM_CATEGORIES_BR_V MIC,
                                APPS.MTL_CATEGORY_SETS_TL       MCST,
                                APPS.MTL_CATEGORY_SETS_B        MCS,
                                APPS.MFG_LOOKUPS                ML,
                                APPS.MTL_CATEGORIES_B_KFV       MC,
                                APPS.XXMTL_SYSTEM_ITEMS_BR_V    MSI
                          WHERE MIC.CATEGORY_SET_ID = MCS.CATEGORY_SET_ID
                            AND MCS.CATEGORY_SET_ID = MCST.CATEGORY_SET_ID
                            AND MCST.LANGUAGE = userenv('LANG')
                            AND MIC.CATEGORY_ID = MC.CATEGORY_ID
                            AND MCS.CONTROL_LEVEL = ML.LOOKUP_CODE
                            AND ML.LOOKUP_TYPE = 'ITEM_CONTROL_LEVEL_GUI'
                            AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                            AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                            AND MCST.CATEGORY_SET_NAME = 'BRA MFG'
                            AND MC.SEGMENT1 = 'A'
                            AND MSI.SEGMENT1 = A.INTERFACE_HEADER_ATTRIBUTE14
                            AND MSI.ORGANIZATION_ID =
                                A.INTERFACE_HEADER_ATTRIBUTE10) = 'A' AND
                        (SELECT OLL.SHIPMENT_PRIORITY_CODE
                           FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V RCTLA,
                                APPS.XXRA_CUSTOMER_TRX_BR_V       RCTA,
                                APPS.XXMTL_SYSTEM_ITEMS_BR_V      MSI,
                                APPS.XXOE_ORDER_HEADERS_BR_V      OHL,
                                APPS.XXOE_ORDER_LINES_BR_V        OLL
                          WHERE RCTLA.CUSTOMER_TRX_ID = RCTA.CUSTOMER_TRX_ID
                            AND MSI.INVENTORY_ITEM_ID =
                                RCTLA.INVENTORY_ITEM_ID
                            AND RCTLA.WAREHOUSE_ID = MSI.ORGANIZATION_ID
                            AND RCTLA.LINE_TYPE = 'LINE'
                            AND RCTLA.LINE_NUMBER = '1'
                            AND OHL.HEADER_ID = OLL.HEADER_ID
                            and RCTLA.INTERFACE_LINE_ATTRIBUTE1 =
                                OHL.ORDER_NUMBER
                            AND RCTA.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                            AND OLL.ORG_ID = 1344
                            AND RCTLA.INVENTORY_ITEM_ID =
                                OLL.INVENTORY_ITEM_ID
                            AND RCTLA.WAREHOUSE_ID = OLL.SHIP_FROM_ORG_ID
                            AND OLL.LINE_ID = RCTLA.INTERFACE_LINE_ATTRIBUTE6
                            AND OLL.SHIPMENT_PRIORITY_CODE = 'DIRECT SHIPMENT') =
                        'DIRECT SHIPMENT' THEN
                    'EMBREAGEM_DSH'
                   ELSE
                    NULL
                 END SUB_LOC,
                WND.GLOBAL_ATTRIBUTE3 VOL,
                ---------- CNPJ ---------
                SUBSTR((SELECT RAA.GLOBAL_ATTRIBUTE3 ||
                              RAA.GLOBAL_ATTRIBUTE4 ||
                              RAA.GLOBAL_ATTRIBUTE5
                         FROM APPS.XXETN_RA_SITE_USES_BR_V     RSUA2,
                              APPS.XXETN_RA_SITE_USES_BR_V     RSUA,
                              APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA
                        WHERE RSUA2.ADDRESS_ID = RSUA.ADDRESS_ID
                          AND RAA.ADDRESS_ID = RSUA.ADDRESS_ID
                          AND RSUA.SITE_USE_ID = A.SHIP_TO_SITE_USE_ID
                          AND RSUA2.SITE_USE_CODE = 'BILL_TO' and rownum=1),
                       2,
                       14) CNPJ,
                -----------------CLIENTE-----------------
                SUBSTR(E.CUSTOMER_NAME, 1, 20) CLIENTE,
                ----------------- Unidade Federativa -----------------
                (SELECT RAA.STATE
                   FROM APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA,
                        APPS.XXETN_RA_SITE_USES_BR_V     RSUA
                  WHERE RAA.ADDRESS_ID = RSUA.ADDRESS_ID
                    AND RSUA.SITE_USE_ID = A.SHIP_TO_SITE_USE_ID) UF,
                'DFE' || B.ATTRIBUTE2 CHAVE_DE_ACESSO,
                A.SHIP_VIA TRANSP,
                ------------------- CFOP ---------------------
                C.GLOBAL_ATTRIBUTE3 || ' ' || CASE
                  WHEN NVL((SELECT SUM(GLOBAL_ATTRIBUTE19)
                             FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V
                            WHERE A.CUSTOMER_TRX_ID = CUSTOMER_TRX_ID
                              AND LINE_TYPE = 'TAX'
                              AND VAT_TAX_ID IN ('11057',
                                                 '11059',
                                                 '11623',
                                                 '11624',
                                                 '11744',
                                                 '11745',
                                                 '11746',
                                                 '11747',
                                                 '11882',
                                                 '11956',
                                                 '11957',
                                                 '11958',
                                                 '12602',
                                                 '12922',
                                                 '13422',
                                                 '13642',
                                                 '13662',
                                                 '13663',
                                                 '13762',
                                                 '14046',
                                                 '14047',
                                                 '14048',
                                                 '14049',
                                                 '14362',
                                                 '14363',
                                                 '14364',
                                                 '14365',
                                                 '14482',
                                                 '14483',
                                                 '14484',
                                                 '14485',
                                                 '14486',
                                                 '14583',
                                                 '14602',
                                                 '14642',
                                                 '14702',
                                                 '14722',
                                                 '14842',
                                                 '15162',
                                                 '15222',
                                                 '15224',
                                                 '15226',
                                                 '15232',
                                                 '15463',
                                                 '16343')),
                           0) = '0' THEN
                   'S_ST'
                  ELSE
                   'C_ST'
                END CFOP,
                ---------------------------ICMS ST-----------------------------
                --  CASE WHEN (SELECT DISTINCT INTERFACE_LINE_ATTRIBUTE3 FROM APPS.XXRA_INTERFACE_LINES_BR_V WHERE INTERFACE_LINE_ATTRIBUTE3 = A.CT_REFERENCE) IS NULL THEN 'OK'ELSE 'VERF_RILA' END CASE_RILA_ANTIGO,
                ----
                CASE
                  WHEN (select SUM(CTLA2.QUANTITY_ORDERED)
                          from APPS.XXRA_CUSTOMER_TRX_LINES_BR_V CTLA2
                         where CTLA2.INTERFACE_LINE_ATTRIBUTE3 =
                               A.CT_REFERENCE) =
                       (select SUM(DD.SHIPPED_QUANTITY)
                          from apps.XXWSH_DELIVERY_DETAILS_BR_V DD,
                               WSH.WSH_DELIVERY_ASSIGNMENTS     DA
                         where DD.DELIVERY_DETAIL_ID = DA.DELIVERY_DETAIL_ID
                           AND DA.DELIVERY_ID = A.CT_REFERENCE
                           AND SOURCE_CODE = 'OE') THEN
                   'OK'
                  ELSE
                   'VERF_RILA'
                END CASE_RILA,
                ----
                       
                DECODE(B.STATUS,
                       '3',
                       'ERRO',
                       '8',
                       'ERRO',
                       '7',
                       'ERRO',
                       '1',
                       'ERRO',
                       '5',
                       'ERRO', ---ERRO, CONTIGENCIA E ENVIADO
                       '4',
                       'CANCELADO',
                       '6',
                       'CANCELADO', -- CANCELADO E INITILIZADO
                       '2',
                       'FINALIZADO') STATUS, --AUTORIZADO
                (select MAX(TO_CHAR(ERA.OCCURRENCE_DATE,
                                    'DD/MM/YYYY HH24:MI'))
                   from APPS.XXCLL_F031_ELECTRONIC_RET_ALL_BR_V ERA
                  where ERA.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID) DATA_HORA,
                TRUNC(A.TRX_DATE) DATA_GL,
                NVL((SELECT SUM(EXTENDED_AMOUNT)
                      FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V
                     WHERE A.CUSTOMER_TRX_ID = CUSTOMER_TRX_ID
                       AND LINE_TYPE = 'TAX'
                       AND VAT_TAX_ID IN
                           (SELECT VAT.VAT_TAX_ID
                              FROM APPS.FND_LOOKUP_VALUES_VL LV,
                                   APPS.XXAR_VAT_TAX_VL_BR_V VAT
                             WHERE LV.LOOKUP_TYPE =
                                   'XXBR8282_GFSS_TAX_ICMS_ST'
                               AND VAT.TAX_CODE = LV.LOOKUP_CODE)),
                    0) ICMS_ST,
                --------------------------FCP-----------------------------------------
                NVL((SELECT SUM(EXTENDED_AMOUNT)
                      FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V
                     WHERE A.CUSTOMER_TRX_ID = CUSTOMER_TRX_ID
                       AND LINE_TYPE = 'TAX'
                       AND VAT_TAX_ID IN ('16423',
                                          '16424',
                                          '16429',
                                          '16430',
                                          '16435',
                                          '16436',
                                          '16444',
                                          '16445',
                                          '16483',
                                          '16484')),
                    0) FCP_ST,
                DECODE((SELECT RAA.STATE
                         FROM APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA,
                              APPS.XXETN_RA_SITE_USES_BR_V     RSUA
                        WHERE RAA.ADDRESS_ID = RSUA.ADDRESS_ID
                          AND RSUA.SITE_USE_ID = A.SHIP_TO_SITE_USE_ID),
                       'AM',
                       '49007912',
                       'AP',
                       '30197490',
                       'BA',
                       '143610924',
                       'CE',
                       '64998339',
                       'ES',
                       '47414',
                       'MA',
                       '124923461',
                       'MG',
                       '5628807330194',
                       'MT',
                       '137395302',
                       'PA',
                       '151951810',
                       'PB',
                       '169002535',
                       'PE',
                       '0253748-69',
                       'PI',
                       '195789512',
                       'PR',
                       '990444706',
                       'RJ',
                       '92029409',
                       'RN',
                       '203009894',
                       'RS',
                       '9000027999',
                       'SC',
                       '253591376',
                       'SE',
                       '270956123') INSCRICAO_UF,
                (SELECT raa.GLOBAL_ATTRIBUTE6
                   FROM APPS.XXETN_RA_SITE_USES_BR_V     RSUA2,
                        APPS.XXETN_RA_SITE_USES_BR_V     RSUA,
                        APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA
                  WHERE RSUA2.ADDRESS_ID = RSUA.ADDRESS_ID
                    AND RAA.ADDRESS_ID = RSUA.ADDRESS_ID
                    AND RSUA.SITE_USE_ID = A.SHIP_TO_SITE_USE_ID
                    AND RSUA2.SITE_USE_CODE = 'BILL_TO' and rownum=1) INSCRICAO_CLIENTE
  FROM APPS.XXRA_CUSTOMER_TRX_BR_V             A,
       APPS.XXCLL_F031_ELECTRONIC_TRX_ALL_BR_V B,
       APPS.XXRA_CUST_TRX_TYPES_BR_V           C,
       APPS.XXRA_BATCH_SOURCES_BR_V            D,
       APPS.XXETN_RA_CUSTOMERS                 E,
       APPS.FND_USER                           F,
       APPS.XXRA_CUSTOMER_TRX_LINES_BR_V       CTLA,
       APPS.XXWSH_DELIVERY_DETAILS_BR_V        WDD,
       APPS.WSH_DELIVERY_ASSIGNMENTS           WDA,
       APPS.XXMTL_ITEM_LOCATIONS_BR_V          MIL,
       APPS.XXWSH_NEW_DELIVERIES_BR_V          WND
 WHERE A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
   AND A.CUSTOMER_TRX_ID = CTLA.CUSTOMER_TRX_ID
   AND WDD.SOURCE_CODE = 'OE'
   AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
   AND WDD.SOURCE_LINE_ID = CTLA.INTERFACE_LINE_ATTRIBUTE6
   AND WDA.DELIVERY_ID = WND.DELIVERY_ID
   AND MIL.ORGANIZATION_ID = CTLA.WAREHOUSE_ID
   AND MIL.INVENTORY_LOCATION_ID = WDD.LOCATOR_ID
   AND A.SOLD_TO_CUSTOMER_ID = E.CUSTOMER_ID
   AND A.CREATED_BY = F.USER_ID
   AND A.CUST_TRX_TYPE_ID = C.CUST_TRX_TYPE_ID
   AND A.BATCH_SOURCE_ID = D.BATCH_SOURCE_ID
      --AND CTLA.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID
      --AND CTLA.WAREHOUSE_ID = WDD.ORGANIZATION_ID
   AND CTLA.LINE_TYPE = 'LINE'
      --AND WDA.DELIVERY_ID = CTLA.INTERFACE_LINE_ATTRIBUTE3
      --AND WDD.SOURCE_LINE_ID = CTLA.INTERFACE_LINE_ATTRIBUTE6
   AND C.NAME NOT IN ('SI COMPL PRECO C/AR')
   AND B.STATUS NOT IN ('4', '6')
   and (SELECT RAA.STATE
          FROM APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA,
               APPS.XXETN_RA_SITE_USES_BR_V     RSUA
         WHERE RAA.ADDRESS_ID = RSUA.ADDRESS_ID
           AND RSUA.SITE_USE_ID = A.SHIP_TO_SITE_USE_ID) not in ('EX')
   AND A.ORG_ID = '1344'
   AND D.NAME IN ('VALI AFT VENDA AUTOMATICA', 'VALI AFT VENDA AUTOMATICA OLD')
      and C.GLOBAL_ATTRIBUTE3 in ('6.655', '5.655')
      --and A.TRX_NUMBER='1042399'
   AND B.LAST_UPDATE_DATE >=
       TO_DATE('&DATA_INICIO 00:00', 'DD/MM/YY HH24:MI') --'01/01/20 00:00'
   AND B.LAST_UPDATE_DATE <= TO_DATE('&DATA_FIM 23:59', 'DD/MM/YY HH24:MI') --'31/12/20 23:59'
   -- AND A.CT_REFERENCE = '98510565'

UNION ALL
select '000000',
       RIL.INTERFACE_LINE_ATTRIBUTE3 DELIVERY,
       MIL.SEGMENT1 || '.' || MIL.SEGMENT2 || '.' || MIL.SEGMENT3 SUB_LOC,
       'VOL',
       (SELECT RAA.GLOBAL_ATTRIBUTE5
          FROM APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA
         WHERE RAA.ADDRESS_ID = RIL.ORIG_SYSTEM_SHIP_ADDRESS_ID) CNPJ,
       (SELECT RA.CUSTOMER_NAME
          FROM APPS.XXETN_RA_CUSTOMERS RA
         WHERE RA.CUSTOMER_ID = RIL.ORIG_SYSTEM_BILL_CUSTOMER_ID) CLIENTE,
       (SELECT RAA.STATE
          FROM APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA
         WHERE RAA.ADDRESS_ID = RIL.ORIG_SYSTEM_SHIP_ADDRESS_ID) UF,
       'DFE'CHAVE_DE_ACESSO,
       RIL.SHIP_VIA TRANSP,
       RIL.LINE_GDF_ATTRIBUTE1 CFOP,
       'CASE_RILA',
       'STATUS',
       'DATA_HORA',
       RIL.TRX_DATE DATA_GL,
       NVL((SELECT SUM(GLOBAL_ATTRIBUTE19)
             FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V
            WHERE RIL.CUSTOMER_TRX_ID = CUSTOMER_TRX_ID
              AND LINE_TYPE = 'TAX'
              AND VAT_TAX_ID IN ('11057',
                                 '11059',
                                 '11623',
                                 '11624',
                                 '11744',
                                 '11745',
                                 '11746',
                                 '11747',
                                 '11882',
                                 '11956',
                                 '11957',
                                 '11958',
                                 '12602',
                                 '12922',
                                 '13422',
                                 '13642',
                                 '13662',
                                 '13663',
                                 '13762',
                                 '14046',
                                 '14047',
                                 '14048',
                                 '14049',
                                 '14362',
                                 '14363',
                                 '14364',
                                 '14365',
                                 '14482',
                                 '14483',
                                 '14484',
                                 '14485',
                                 '14486',
                                 '14583',
                                 '14602',
                                 '14642',
                                 '14702',
                                 '14722',
                                 '14842',
                                 '15162',
                                 '15222',
                                 '15224',
                                 '15226',
                                 '15232',
                                 '15463',
                                 '16343')),
           0) ICMS_ST,
       NVL((SELECT SUM(EXTENDED_AMOUNT)
             FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V
            WHERE RIL.CUSTOMER_TRX_ID = CUSTOMER_TRX_ID
              AND LINE_TYPE = 'TAX'
              AND VAT_TAX_ID IN ('16423',
                                 '16424',
                                 '16429',
                                 '16430',
                                 '16435',
                                 '16436',
                                 '16444',
                                 '16445',
                                 '16483',
                                 '16484')),
           0) FCP_ST,
       DECODE((SELECT RAA.STATE
                FROM APPS.XXETN_RA_ADDRESSES_ALL_BR_V RAA
               WHERE RAA.ADDRESS_ID = RIL.ORIG_SYSTEM_SHIP_ADDRESS_ID),
              'AM',
              '49007912',
              'AP',
              '30197490',
              'BA',
              '143610924',
              'CE',
              '64998339',
              'ES',
              '47414',
              'MA',
              '124923461',
              'MG',
              '5628807330194',
              'MT',
              '137395302',
              'PA',
              '151951810',
              'PB',
              '169002535',
              'PE',
              '0253748-69',
              'PI',
              '195789512',
              'PR',
              '990444706',
              'RJ',
              '92029409',
              'RN',
              '203009894',
              'RS',
              '9000027999',
              'SC',
              '253591376',
              'SE',
              '270956123') INSCRICAO_UF,
       '0000000000'
         from apps.XXWSH_DELIVERY_DETAILS_BR_V DD,
       WSH.WSH_DELIVERY_ASSIGNMENTS     DA,
       APPS.XXRA_INTERFACE_LINES_BR_V   ril,
       APPS.XXMTL_ITEM_LOCATIONS_BR_V   MIL,
       APPS.XXRA_INTERFACE_ERRORS_BR_V  RIE
where DD.DELIVERY_DETAIL_ID = DA.DELIVERY_DETAIL_ID
   AND DA.DELIVERY_ID = ril.INTERFACE_LINE_ATTRIBUTE3
   AND SOURCE_CODE = 'OE'
   AND DD.LOCATOR_ID = MIL.INVENTORY_LOCATION_ID
   and RIL.INTERFACE_LINE_ID = RIE.INTERFACE_LINE_ID
   and dd.INVENTORY_ITEM_ID = ril.INVENTORY_ITEM_ID
   and dd.ORGANIZATION_ID = ril.WAREHOUSE_ID

/*SELECT *
  FROM APPS.WSH_DELIVERY_DETAILS WDD
WHERE WDD.SOURCE_LINE_ID IN
       (SELECT GLOBAL_ATTRIBUTE19---CTLA.INTERFACE_LINE_ATTRIBUTE6
          FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V CTLA
         WHERE CUSTOMER_TRX_ID IN
               (SELECT CUSTOMER_TRX_ID
                  FROM APPS.XXRA_CUSTOMER_TRX_BR_V A
                 WHERE A.TRX_NUMBER = '1042495')
           AND CTLA.LINE_TYPE = 'LINE')
--SELECT * FROM ALL_TABLES WHERE TABLE_NAME LIKE '%DELIVERY%'*/

/*SELECT *--GLOBAL_ATTRIBUTE19---CTLA.INTERFACE_LINE_ATTRIBUTE6
 FROM APPS.XXRA_CUSTOMER_TRX_LINES_BR_V CTLA
WHERE CUSTOMER_TRX_ID IN
      (SELECT CUSTOMER_TRX_ID
         FROM APPS.XXRA_CUSTOMER_TRX_BR_V A
        WHERE A.TRX_NUMBER = '1042495')*/
