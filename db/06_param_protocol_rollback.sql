-- 参数协议整理 · 回滚
-- 用备份表 t_phm_rule_param_meta_bak_20261118 恢复 data_source、实表名，并去掉新增列和协议表。
-- 备份表本身保留，便于核对。PostgreSQL 与金仓都能执行（不用 UPDATE FROM，不用 CONCAT）。
BEGIN;

UPDATE t_phm_rule_param_meta p
SET data_source = (SELECT b.data_source FROM t_phm_rule_param_meta_bak_20261118 b WHERE b.id = p.id),
    hbase_table = (SELECT b.hbase_table FROM t_phm_rule_param_meta_bak_20261118 b WHERE b.id = p.id),
    scope_cx    = (SELECT b.scope_cx FROM t_phm_rule_param_meta_bak_20261118 b WHERE b.id = p.id),
    update_by   = 'rollback',
    update_time = CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM t_phm_rule_param_meta_bak_20261118 b WHERE b.id = p.id);

ALTER TABLE t_phm_rule_param_meta DROP CONSTRAINT IF EXISTS fk_phm_param_protocol;
ALTER TABLE t_phm_rule_param_meta DROP CONSTRAINT IF EXISTS ck_phm_param_src;
ALTER TABLE t_phm_rule_param_meta DROP CONSTRAINT IF EXISTS ck_phm_param_hide;
ALTER TABLE t_phm_rule_param_meta DROP CONSTRAINT IF EXISTS ck_phm_param_hreason;

ALTER TABLE t_phm_rule_param_meta DROP COLUMN IF EXISTS protocol_id;
ALTER TABLE t_phm_rule_param_meta DROP COLUMN IF EXISTS subsystem;
ALTER TABLE t_phm_rule_param_meta DROP COLUMN IF EXISTS is_hidden;
ALTER TABLE t_phm_rule_param_meta DROP COLUMN IF EXISTS hide_reason;

ALTER TABLE t_phm_rule_param_meta
    ADD CONSTRAINT ck_phm_param_src CHECK (data_source IN ('KAFKA', 'HBASE', 'HBASE_PHM', 'HBASE_LKJ', 'HBASE_6A', 'DIM'));

DROP TABLE IF EXISTS t_phm_rule_protocol_cx;
DROP TABLE IF EXISTS t_phm_rule_protocol;

COMMIT;
