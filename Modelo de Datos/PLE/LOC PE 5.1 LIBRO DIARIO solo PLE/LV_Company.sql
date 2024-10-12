SELECT gls.segment_value
  FROM xle_entity_profiles le
         , gl_ledgers lg
         , gl_ledger_norm_seg_vals gls
WHERE 1=1
AND le.legal_entity_id = gls.legal_entity_id
AND gls.legal_entity_id = :p_legal_entity
AND gls.ledger_id = lg.ledger_id
AND lg.ledger_category_code = 'PRIMARY'
 AND NVL(lg.complete_flag, 'Y') = 'Y'
UNION 
SELECT gls.segment_value
  FROM xle_entity_profiles le
     ,  GL_LEDGER_CONFIG_DETAILS cfgDet
     , gl_ledger_configurations cfg
     , gl_ledger_config_details primdet
     , gl_ledger_relationships rs
     , gl_ledgers lg
     , gl_ledger_norm_seg_vals gls
 WHERE     1 = 1
       AND le.legal_entity_id(+) = cfgdet.object_id
      AND  cfgdet.object_id = :p_legal_entity
       AND cfgdet.configuration_id(+) = cfg.configuration_id
       AND cfgdet.object_type_code(+) = 'LEGAL_ENTITY'
       AND cfgdet.setup_step_code(+) = 'NONE'
       AND cfg.configuration_id = primdet.configuration_id
       AND primdet.object_id = rs.primary_ledger_id
       AND primdet.object_type_code = 'PRIMARY'
       AND primdet.setup_step_code = 'NONE'
       AND lg.ledger_id = rs.target_ledger_id
       AND lg.ledger_category_code = rs.target_ledger_category_code
       AND gls.legal_entity_id IS NULL
       AND gls.ledger_id = lg.ledger_id
       AND lg.ledger_category_code = 'PRIMARY'
       AND NVL(lg.complete_flag, 'Y') = 'Y'