SELECT s.schemaname||'.'||s.relname AS "TABLENAME",
       s.indexrelname AS "INDEXNAME",
       pg_relation_size(s.indexrelid)/1024/1024/1024 AS "INDEX_SIZE_IN_GB",
	   i_s.indexdef||';' as "INDEX_DDL",
	   'DROP INDEX '|| s.schemaname||'.'||s.indexrelname ||';' as "DROP_STATEMENT"
FROM pg_catalog.pg_stat_user_indexes s
   JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
   JOIN pg_catalog.pg_indexes i_s on s.indexrelname = i_s.indexname
WHERE s.idx_scan = 0      -- has never been scanned
  AND 0 <>ALL (i.indkey)  -- no index column is an expression
  AND s.schemaname not like '%pg_temp%'
  AND NOT i.indisunique   -- is not a UNIQUE index
  AND NOT EXISTS          -- does not enforce a constraint
         (SELECT 1 FROM pg_catalog.pg_constraint c
          WHERE c.conindid = s.indexrelid)
ORDER BY pg_relation_size(s.indexrelid) DESC;

