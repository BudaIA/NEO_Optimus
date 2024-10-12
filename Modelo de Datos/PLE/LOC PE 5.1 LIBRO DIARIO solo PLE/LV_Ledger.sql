select gll.name, gll.ledger_id
from   gl_ledgers gll
where gll.ledger_id = (SELECT MAX(GLEV.LEDGER_ID)
					   FROM GL_LEDGER_LE_V GLEV 
					   WHERE 1 = 1 AND GLEV.LEGAL_ENTITY_ID = :p_legal_entity
					   AND GLEV.LEDGER_CATEGORY_CODE = 'PRIMARY'
					   )