SELECT DISTINCT 'LE'||xreg.registration_number||ps.period_year||lpad(ps.period_num-1,2,'0')||'00'||'050100'||'00'||'1'||'1'||'1'||'1' AS TITULO1, 
'PERIODO|CUO|CORRELATIVO|COD CUENTA|COD UO|COD CECO|TIPO MON|TIPO DOC IDEN EMISOR|NUM DOC IDENT DEL EMIS|TIPO COMPR PAGO|NUM SERIE|NUM COMPR PAGO|FECHA CONTABLE|FECHA VENC|FECHA OPE|GLOSA|GLOSA REF|MOV DEBE|MOV HABER|DATO ESTRUCTURADO|ESTADO OPERACION|COLUMNA 1|COLUMNA 2|USUARIO DE CREACION|' as TITULO2 
FROM 
     xle_registrations              xreg 
     ,xle_entity_profiles            xep
     ,GL_period_statuses      ps
WHERE 1=1 
and xreg.source_id = xep.legal_entity_id
and xep.legal_entity_id = :p_legal_entity
and ps.period_name = :p_periodname
AND NVL(:P_CABECERA,'N') = 'Y'