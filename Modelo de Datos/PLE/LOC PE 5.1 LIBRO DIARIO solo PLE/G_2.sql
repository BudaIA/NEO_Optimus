--NEW
/* ***************************************************************************** 
Reporte:  PLE Libro Diario 5.1
Data model: G_2

Proposito: Permite mostrar información detallada sobre los asientos del libro 
      diario según lo contabilizado en GL

Nombre        Fecha Mod.      Descripción
----------------------------------------------------------------------------
Darwin Haya      15/04/2019      Modificación para permitir lógica de 
                    Informes de Gastos
                    
 **************************************************************************** */

SELECT DISTINCT decode(gir.gl_sl_link_id, NULL, 2, 1) orden --los asientos que no provienen de xla orden 2, los que provienen de xla, orden 1
               ,&acct_field_sec gl_account
               ,gjl.effective_date --- PARA ORDENAR CORRECTAMENTE POR FECHA
               ,concat(to_char(gjl.effective_date, 'YYYYMM'), '00') --periodo
                || '|' || to_char(nvl(nvl(gjh.posting_acct_seq_value, gjh.doc_sequence_value)
                                     ,to_char(gjl.effective_date, 'YYYYMM') || gjl.je_header_id)) --cuo -- campo 2
                || '|' || nvl(vlcc.attribute4, 'M') || lpad(gjl.je_line_num, 9, '0') --correlativo
                || '|' || &acct_field_sec --gl_account
                || '|' --uo -- campo5
                || '|' --ccosto -- campo 6
                || '|' || decode(gjl.currency_code, 'VAC', 'PEN', 'REI', 'PEN', gjl.currency_code) --moneda -- campo 7
                || '|' || nvl(gap.tipo_doc_emisor, gar.tipo_doc_emisor) --tipo_doc_emisor
                || '|' || nvl(gap.numero_doc_emisor, gar.numero_doc_emisor) --numero_doc_emisor
                || '|' || nvl(gap.tipo_doc_trx, nvl(gar.tipo_doc_trx, '00')) --tipo_doc_trx
                || '|' ||
                substr(convert(translate(nvl(REPLACE(REPLACE(nvl(gap.serie, gar.serie), '  ', ''), '_', ''), '')
                                        ,'ñÑÁÉÍÓÚáéíóú|' || chr(10) || chr(13)
                                        ,'nNAEIOUaeiou/  ')
                              ,'US7ASCII')
                      ,1
                      ,20) --serie
                || '|' || substr(convert(translate(nvl(REPLACE(REPLACE(nvl(gap.numero_doc, nvl(gar.numero_doc, '0'))
                                                                      ,'  '
                                                                      ,'')
                                                              ,'_'
                                                              ,'')
                                                      ,'')
                                                  ,'ñÑÁÉÍÓÚáéíóú|' || chr(10) || chr(13)
                                                  ,'nNAEIOUaeiou/  ')
                                        ,'US7ASCII')
                                ,1
                                ,20) --numero_doc
                || '|' || to_char(gjl.effective_date, 'dd/mm/yyyy') --fecha_conta -- campo 13
                || '|' --fecha_venci -- campo 14
                || '|' || nvl(gap.fecha_ap, nvl(gar.fecha_ar, CASE WHEN TRUNC(gjh.creation_date) > TRUNC(per.end_date) THEN to_char(gjl.effective_date, 'dd/mm/yyyy') ELSE to_char(gjh.creation_date, 'dd/mm/yyyy') END)) --fecha_ope
                || '|' || substr(convert(translate(nvl(REPLACE(gjl.description, '  ', ''), '-')
                                                  ,'ñÑÁÉÍÓÚáéíóú|' || chr(10) || chr(13)
                                                  ,'nNAEIOUaeiou/  ')
                                        ,'US7ASCII')
                                ,1
                                ,100) --glosa -- campo 16
                || '|' --glosa_ref -- campo 17
                || '|' || TRIM(to_char(decode(gir.gl_sl_link_id
                                             ,NULL
                                             ,decode(sign(nvl(gjl.accounted_dr, 0) - nvl(gjl.accounted_cr, 0))
                                                    ,1
                                                    ,abs(nvl(gjl.accounted_dr, 0) - nvl(gjl.accounted_cr, 0))
                                                    ,0)
                                             ,decode(sign(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                          round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                                    ,1
                                                    ,abs(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                         round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                                    ,0))
                                      ,'999999999990.99')) --debito_contabilizado_ple
                || '|' || TRIM(to_char(decode(gir.gl_sl_link_id
                                             ,NULL
                                             ,decode(sign(nvl(gjl.accounted_dr, 0) - nvl(gjl.accounted_cr, 0))
                                                    ,-1
                                                    ,abs(nvl(gjl.accounted_dr, 0) - nvl(gjl.accounted_cr, 0))
                                                    ,0)
                                             ,decode(sign(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                          round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                                    ,-1
                                                    ,abs(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                         round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                                    ,0))
                                      ,'999999999990.99')) --credito_contabilizado_ple
                || '|' --datoestructurado
                || '|1|' || gjh.period_name || ',' || gjh.je_source || ',' || gjh.je_category || '|' ||
                gap.categoria_doc || ',' || gap.doc_sequence_value  --estado_ope -- campo 21
|| '|' || gjh.created_by|| ',' ||(to_char(trunc(gjh.creation_date),'ddmmyyyy'))|| '|' linea --Campo 23 
  FROM (SELECT *
          FROM gl_je_headers gjh
        MINUS (SELECT *
                FROM gl_je_headers gjh
               WHERE 1 = 1
                 AND gjh.je_header_id IN (1728086, 1737351, 1725354)
                    -- AND gjh.je_category IN ('PECIERRE_REV', 'PEAPERTURA_REV', '300000469858785')
                 AND (gjh.period_name = 'CIE-21' AND gjh.je_category = 'Revaluation'))) gjh
       
      ,gl_je_lines gjl
      ,gl_code_combinations gcc
      ,gl_import_references gir
      ,xla_ae_lines xal
      ,xla_ae_headers xah
      ,xla_transaction_entities xte
      ,gl_je_categories_vl vlcc
      ,gl_je_sources_vl gso
      ,(SELECT nvl(decode(cust.attribute15, '0', '', cust.attribute15), '') tipo_doc_emisor --no se debe mostrar tipo 0 cuando el cliente no tiene el atributo configurado
              ,REPLACE(org.jgzz_fiscal_code, '-', '') numero_doc_emisor -- numero de documento del cliente
              ,decode(bs.name
                     ,'EXTERNAL_PC'
                     ,substr(cr.trx_number, 3, 1) || substr(cr.trx_number, 5, 3)
                     ,nvl(rcta.attribute14, substr(cr.trx_number, 1, instr(cr.trx_number, '-', 1) - 1))) serie -- 7 serie doc
              ,decode(bs.name
                     ,'EXTERNAL_PC'
                     ,lpad(substr(cr.trx_number, 8, 8), 8, '0')
                     ,lpad(decode(instr(cr.trx_number, '-', 1)
                                 ,0
                                 ,cr.trx_number
                                 ,substr(cr.trx_number, instr(cr.trx_number, '-', 1) + 1, 100))
                          ,8
                          ,'0')) numero_doc -- 8 numero doc
              ,decode(bs.name
                     ,'EXTERNAL_PC'
                     ,decode(substr(cr.trx_number, 1, 2), 'FC', '01', 'BO', '03', 'NC', '07')
                     ,rcta.attribute15) tipo_doc_trx -- 6 tipo doc  
              ,cr.customer_trx_id
              ,'TRANSACTIONS' xtype
              ,222 appl_id
              ,NULL libro_datoestruc
              ,to_char(cr.trx_date, 'DD/MM/YYYY') fecha_ar
              ,NULL datoestructurado
          FROM ra_customer_trx_all      cr
              ,hz_cust_accounts         cust
              ,hz_organization_profiles org
              ,ra_cust_trx_types_all    rcta
              ,ra_batch_sources_all     bs
         WHERE 1 = 1
           AND bs.batch_source_seq_id = cr.batch_source_seq_id
           AND org.party_id = cust.party_id
           AND rcta.cust_trx_type_seq_id = cr.cust_trx_type_seq_id
           AND cust.cust_account_id = cr.bill_to_customer_id
           AND cr.set_of_books_id = :p_ledger
           AND cr.trx_date BETWEEN nvl(:p_start_accounting, cr.trx_date) AND nvl(:p_end_accounting, cr.trx_date)) gar --300000004962428
       -----------------------------------------------------------------------------------------------------------------
      ,(SELECT poz.attribute15 tipo_doc_emisor
              ,REPLACE(nvl(zxp.rep_registration_number, pii.income_tax_id), '-', '') numero_doc_emisor -- también documento_asociado2
               
              ,REPLACE(CASE
                         WHEN nvl(fvv.attribute48, '00') IN ('ADUANA') THEN
                          nvl(ai.attribute9
                             ,lpad(substr(translate(ai.invoice_num, '/ ', '--')
                                         ,1
                                         ,instr(translate(ai.invoice_num, '/ ', '--'), '-', 1) - 1)
                                  ,3
                                  ,'0')) -- codigo aduana
                         WHEN nvl(ai.attribute15, substr(ai.document_sub_type, 13, 2)) = '05' THEN
                          '3'
                         WHEN nvl(ai.attribute15, substr(ai.document_sub_type, 13, 2)) = '10' THEN
                          '1683' --Recibo por arrendamiento
                       
                         WHEN nvl(fvv.attribute48, '00') IN ('ESPECIAL', '00') THEN
                          decode(instr(translate(ai.invoice_num, '/ ', '--'), '-', 1)
                                ,0
                                ,''
                                ,substr(translate(ai.invoice_num, '/ ', '--')
                                       ,1
                                       ,instr(translate(ai.invoice_num, '/ ', '--'), '-', 1) - 1))
                       
                         WHEN nvl(fvv.attribute48, '00') IN ('SERIE4') THEN
                          decode(instr(translate(ai.invoice_num, '/ ', '--'), '-', 1)
                                ,0
                                ,CASE
                                   WHEN cancelled_date IS NULL THEN
                                    'ERROR'
                                   ELSE
                                    ''
                                 END
                                ,lpad(substr(translate(ai.invoice_num, '/ ', '--')
                                            ,1
                                            ,instr(translate(ai.invoice_num, '/ ', '--'), '-', 1) - 1)
                                     ,decode(nvl(ai.attribute15, substr(ai.document_sub_type, 13, 2)), '50', 3, 4)
                                     ,'0'))
                         ELSE
                          NULL
                       END
                      ,'&') serie -- 7 serie de compras 
               
               ---DHAYA/15042019: Actualización para obtener nro doc trx
              ,REPLACE(REPLACE(REPLACE(decode(fvv.attribute50
                                             ,'Y'
                                             ,lpad(TRIM(decode(instr(ai.invoice_num, '-', 1)
                                                              ,0
                                                              ,decode(instr(ai.invoice_num, ' ', 1)
                                                                     ,0
                                                                     ,ai.invoice_num
                                                                     ,substr(ai.invoice_num
                                                                            ,instr(ai.invoice_num, ' ', 1) + 1
                                                                            ,100))
                                                              ,substr(ai.invoice_num
                                                                     ,instr(ai.invoice_num, '-', 1) + 1
                                                                     ,100)))
                                                  ,nvl(fvv.attribute46, 8)
                                                  ,'0')
                                             ,decode(nvl(fvv.attribute48, '00')
                                                    ,'SERIE4'
                                                    ,substr(translate(ai.invoice_num, '/ ', '--'), 5, 25)
                                                    ,substr(translate(ai.invoice_num, '/ ', '--'), 1, 20)))
                                      ,'_'
                                      ,'')
                              ,'-'
                              ,'')
                      ,'&') numero_doc -- 9 nro trx de compras
               
               --- FIN DHAYA/15042019
              ,CASE
                 WHEN ai.attribute_category = 'Leasing' OR cancelled_date IS NOT NULL THEN
                  ''
                 ELSE
                  nvl(ai.attribute15, substr(ai.document_sub_type, 13, 2))
               END tipo_doc_trx
              ,fvv.attribute48
              ,ai.invoice_id
               
              ,'AP_INVOICES' xtype
              ,to_char(ai.invoice_date, 'DD/MM/YYYY') fecha_ap
               
              ,NULL libro_datoestruc
              ,NULL datoestructurado
              ,nvl(ai.document_sub_type, 'N') document_sub_type
              ,dsc.name categoria_doc --DCHUMACERO 190721 categoría de documento
              ,ai.doc_sequence_value --DCHUMACERO 190721 número de comprobante
          FROM ap_invoices_all             ai
              ,poz_suppliers               poz
              ,poz_suppliers_pii           pii
              ,zx_party_tax_profile        zxp
              ,fnd_vs_values_b             fvv
              ,fnd_doc_sequence_categories dsc --DCHUMACERO 190721
         WHERE 1 = 1
           AND ai.doc_category_code = dsc.code --DCHUMACERO 190721 categoría de documento
              --DHAYA/15-04-2019: Para no considerar los IG
           AND ai.invoice_type_lookup_code != 'PAYMENT REQUEST' ---------------------------------------------------
              -------------------
           AND pii.vendor_id(+) = poz.vendor_id
           AND zxp.party_id = poz.party_id
           AND poz.vendor_id = ai.vendor_id
           AND fvv.value(+) = nvl(ai.attribute15, substr(ai.document_sub_type, 13, 2))
           AND fvv.attribute_category(+) = 'LOC_PE_AP_TIPO_DOC'
           AND ai.invoice_num NOT LIKE 'Withho%'
           AND ai.set_of_books_id = :p_ledger
           AND ai.gl_date BETWEEN nvl(:p_start_accounting, ai.gl_date) AND nvl(:p_end_accounting, ai.gl_date)) gap --300000004962428
       --<I> IAMES 09022021      
      ,gl_periods per
      ,gl_ledgers l
--<F>
 WHERE 1 = 1
   AND NOT EXISTS (SELECT 1
          FROM ap_invoices_all          aia2
              ,xla_transaction_entities xte2
         WHERE aia2.invoice_type_lookup_code = 'PAYMENT REQUEST' --------------------------------------------
           AND xte2.entity_code = 'AP_INVOICES'
           AND aia2.invoice_id = xte2.source_id_int_1
           AND xte2.entity_id = xte.entity_id
           AND xte2.application_id = 200)
   AND gap.invoice_id(+) = xte.source_id_int_1
   AND gap.xtype(+) = xte.entity_code
   AND gar.customer_trx_id(+) = xte.source_id_int_1
   AND gar.xtype(+) = xte.entity_code
   AND gar.appl_id(+) = xte.application_id
   AND gso.je_source_name = gjh.je_source
   AND vlcc.je_category_name = gjh.je_category
   AND xte.entity_id(+) = xah.entity_id
   AND xte.application_id(+) = xah.application_id
   AND xah.ae_header_id(+) = xal.ae_header_id
   AND xah.application_id(+) = xal.application_id
   AND xal.gl_sl_link_id(+) = gir.gl_sl_link_id
   AND xal.gl_sl_link_table(+) = gir.gl_sl_link_table
   AND gir.je_header_id(+) = gjl.je_header_id
   AND gir.je_line_num(+) = gjl.je_line_num
   AND gcc.code_combination_id = gjl.code_combination_id
   AND gjl.je_header_id = gjh.je_header_id
   AND gjh.ledger_id = :p_ledger --300000053312741
   AND gjh.actual_flag = 'A'
   AND gjh.status = 'P'
   AND l.ledger_id = gjh.ledger_id
   AND per.period_set_name = l.period_set_name
   AND per.period_name = :p_periodname
   AND gjl.effective_date BETWEEN per.start_date AND per.end_date
      -- Filtro por segmentos
   AND &com_where_sec
   AND &acct_where_sec
   AND gjh.je_header_id NOT IN (1728086, 1737351, 1725354)
      --filtro por fechas
   AND gjl.effective_date BETWEEN nvl(:p_start_accounting, gjl.effective_date) AND
       nvl(:p_end_accounting, gjl.effective_date)
-- DHAYA/17-04-2019: Agregado para considerar IG

UNION ALL
SELECT DISTINCT 1 orden --los asientos que no provienen de xla orden 2, los que provienen de xla, orden 1
               ,&acct_field_sec gl_account
               ,gjl.effective_date --- PARA ORDENAR CORRECTAMENTE POR FECHA
               ,concat(to_char(gjl.effective_date, 'YYYYMM'), '00') --periodo
                || '|' || to_char(nvl(nvl(gjh.posting_acct_seq_value, gjh.doc_sequence_value)
                                     ,to_char(gjl.effective_date, 'YYYYMM') || gjl.je_header_id)) --cuo -- campo 2
                || '|' || nvl(vlcc.attribute4, 'M') || lpad(gjl.je_line_num, 9, '0') --correlativo
                || '|' || &acct_field_sec --gl_account
                || '|' --uo -- campo5
                || '|' --ccosto -- campo 6
                || '|' || decode(gjl.currency_code, 'VAC', 'PEN', 'REI', 'PEN', gjl.currency_code) --moneda -- campo 7
                || '|' || exp_info.tipo_doc_emisor || '|' || exp_info.numero_doc_emisor || '|' ||
                nvl(exp_info.tipo_doc_trx, '00') --tipo_doc_trx
                || '|' || exp_info.serie || '|' || nvl(exp_info.numero_doc, '0') --numero_doc
                || '|' || to_char(gjl.effective_date, 'dd/mm/yyyy') --fecha_conta -- campo 13
                || '|' --fecha_venci -- campo 14
                || '|' || to_char(nvl(exp_info.fecha_ope, gjl.effective_date), 'dd/mm/yyyy') --fecha_ope
                || '|' || substr(convert(translate(nvl(REPLACE(gjl.description, '  ', ''), '-')
                                                  ,'ñÑÁÉÍÓÚáéíóú|' || chr(10) || chr(13)
                                                  ,'nNAEIOUaeiou/  ')
                                        ,'US7ASCII')
                                ,1
                                ,100) --glosa -- campo 16
                || '|' --glosa_ref -- campo 17
                || '|' || TRIM(to_char(decode(sign(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                   round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                             ,1
                                             ,abs(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                  round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                             ,0)
                                      ,'999999999990.99')) --debito_contabilizado_ple
                || '|' || TRIM(to_char(decode(sign(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                   round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                             ,-1
                                             ,abs(round(nvl(xal.unrounded_accounted_dr, 0), 2) -
                                                  round(nvl(xal.unrounded_accounted_cr, 0), 2))
                                             ,0)
                                      ,'999999999990.99')) --credito_contabilizado_ple
                || '|' --datoestructurado
                || '|1|' || gjh.period_name || ',' || gjh.je_source || ',' || gjh.je_category || '|' || dsc.name || ',' ||
                aia.doc_sequence_value  --estado_ope -- campo 21
|| '|' || gjh.created_by || ',' || (to_char(trunc(gjh.creation_date),'ddmmyyyy'))|| '|' linea --Campo 23 Creado usuario
  FROM ap_invoices_all aia
      ,xla_transaction_entities xte
      ,xla_ae_headers xah
      ,xla_ae_lines xal
      ,gl_je_headers gjh
      ,gl_je_lines gjl
      ,gl_code_combinations gcc
      ,gl_import_references gir
      ,gl_je_sources_vl gso
      ,gl_je_categories_vl vlcc
      ,fnd_doc_sequence_categories dsc --DCHUMACERO 190721
      ,(SELECT xdl2.application_id
              ,xdl2.ae_header_id
              ,xdl2.ae_line_num
              ,nvl(prov_inv.tipo_doc, '') tipo_doc_emisor
              ,prov_inv.numero_doc numero_doc_emisor
              ,nvl(ail.attribute2, '00') tipo_doc_trx
              ,CASE
                 WHEN nvl(vstd.orig_serie, '00') IN ('ADUANA') THEN
                 --DHP/12092018: Si es un documento de ADUANA la serie no debe ponerse a 4 dígitos
                  nvl(aia2.attribute9
                     , /*lpad(*/substr(ail.attribute3, 1, instr(ail.attribute3, '-', 1) - 1) /*,4,'0')*/) -- codigo aduana
                 WHEN nvl(vstd.orig_serie, '00') IN ('ESPECIAL', '00') THEN
                  decode(instr(ail.attribute3, '-', 1)
                        ,0
                        ,''
                        ,substr(ail.attribute3, 1, instr(ail.attribute3, '-', 1) - 1))
                 WHEN nvl(vstd.orig_serie, '00') IN ('SERIE4') THEN
                  lpad(decode(instr(ail.attribute3, '-', 1)
                             ,0
                             ,''
                             ,substr(ail.attribute3, 1, instr(ail.attribute3, '-', 1) - 1))
                      ,4
                      ,'0')
                 ELSE
                  'NO DEFINIDO'
               END serie
              ,substr(convert(translate(nvl(REPLACE(REPLACE(lpad(decode(instr(ail.attribute3, '-', 1)
                                                                       ,0
                                                                       ,ail.attribute3
                                                                       ,substr(ail.attribute3
                                                                              ,instr(ail.attribute3, '-', 1) + 1
                                                                              ,100))
                                                                ,vstd.nrolong
                                                                , --7,
                                                                 '0')
                                                           ,'
                                      '
                                                           ,'')
                                                   ,'_'
                                                   ,'')
                                           ,'')
                                       ,'ñÑÁÉÍÓÚáéíóú|' || chr(10) || chr(13)
                                       ,'nNAEIOUaeiou/  ')
                             ,'US7ASCII')
                     ,1
                     ,20) numero_doc
              ,to_date(decode(instr(ail.attribute4, '/')
                             ,3
                             ,NULL
                             ,decode(length(ail.attribute4), 10, ail.attribute4, NULL))
                      ,'yyyy/mm/dd') fecha_ope
          FROM xla_distribution_links xdl2
              ,ap_invoice_distributions_all aid
              ,ap_invoice_lines_all ail
              ,ap_invoices_all aia2
              ,(SELECT vv.flex_value numero_doc
                      ,nvl(vv.attribute1, to_char(vv.attribute_sort_order)) tipo_doc
                      ,REPLACE(vv.description, '#', ' ') denominacion
                  FROM fnd_flex_value_sets vs
                      ,fnd_flex_values_vl  vv
                 WHERE vs.flex_value_set_id = vv.flex_value_set_id
                   AND vs.flex_value_set_name = 'LOC_PE_AP_PROV') prov_inv
              ,(SELECT vv.flex_value codigo
                      ,vv.attribute50 mostrar_rc
                      ,vv.attribute49 f_dua
                      ,vv.attribute48 orig_serie
                      ,nvl(vv.attribute46, 8) nrolong
                  FROM fnd_flex_value_sets vs
                      ,fnd_flex_values_vl  vv
                 WHERE vs.flex_value_set_id = vv.flex_value_set_id
                   AND vs.flex_value_set_name = 'LOC_PE_AP_TIPO_DOC') vstd
         WHERE 1 = 1
              --- Solo se va a mostrar información de aquellos asientos que no agrupan líneas de facturas
           AND (SELECT COUNT(1)
                  FROM xla_distribution_links xdl
                 WHERE xdl.ae_line_num = xdl2.ae_line_num
                   AND xdl.application_id = xdl2.application_id
                   AND xdl.ae_header_id = xdl2.ae_header_id
                   AND xdl.application_id = 200) = 1
              -----
           AND aia2.invoice_id = ail.invoice_id
           AND vstd.codigo(+) = nvl(ail.attribute2, '00')
           AND prov_inv.numero_doc(+) = nvl(ail.attribute1, '999999999')
           AND ail.line_number = aid.invoice_line_number
           AND ail.invoice_id = aid.invoice_id
           AND aid.invoice_distribution_id = xdl2.source_distribution_id_num_1
           AND xdl2.accounting_line_code = 'AP_ITEM_EXPENSE_INV'
           AND aid.accounting_date BETWEEN nvl(:p_start_accounting, aid.accounting_date) AND
               nvl(:p_end_accounting, aid.accounting_date)) exp_info
 WHERE 1 = 1
   AND aia.doc_category_code = dsc.code --DCHUMACERO 190721 categoría de documento
   AND exp_info.ae_header_id(+) = xal.ae_header_id
   AND exp_info.ae_line_num(+) = xal.ae_line_num
   AND exp_info.application_id(+) = xal.application_id
   AND aia.invoice_type_lookup_code = 'PAYMENT REQUEST'
   AND vlcc.je_category_name = gjh.je_category
   AND gso.je_source_name = gjh.je_source
   AND xal.application_id = xah.application_id
   AND xal.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xte.entity_code = 'AP_INVOICES'
   AND xte.source_id_int_1 = aia.invoice_id
      --  AND AIA.INVOICE_NUM = 'INFG-0003657'
   AND xal.gl_sl_link_id = gir.gl_sl_link_id
   AND xal.gl_sl_link_table = gir.gl_sl_link_table
   AND gir.je_header_id = gjl.je_header_id
   AND gir.je_line_num = gjl.je_line_num
   AND gcc.code_combination_id = gjl.code_combination_id
   AND gjl.je_header_id = gjh.je_header_id
   AND gjh.period_name = :p_periodname --'Aug-18'
   AND gjh.ledger_id = :p_ledger --30000005331274
   AND gjh.actual_flag = 'A'
   AND gjh.status = 'P'
   AND gjl.effective_date BETWEEN nvl(:p_start_accounting, gjl.effective_date) AND
       nvl(:p_end_accounting, gjl.effective_date)
 ORDER BY gl_account
         ,orden
         ,effective_date