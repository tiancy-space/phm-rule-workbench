-- =====================================================================================
-- 机车 PHM 故障规则管理工作台 · 示例数据（人大金仓 V8R6，database_mode=oracle）
-- 由 db/02_seed.sql 改写，业务行不变。PostgreSQL / Supabase 继续用 02_seed.sql。
--
-- 连接时由用户指定 currentSchema=phm_main。本文件不 CREATE SCHEMA，也不 SET search_path。
--
-- 可重复执行：业务唯一键已存在则跳过，不覆盖后来改过的行。
-- 金仓 Oracle 模式没有 PostgreSQL 的 ON CONFLICT，改成 INSERT ... SELECT ... WHERE NOT EXISTS。
-- 试跑测点不再用 VALUES (...) AS v(列名)，改成带列别名的 UNION ALL。
-- 每一支常量 SELECT 都 FROM 字典里的 HXD1C 一行（脚本更前面已经插入，且只有一行）。
-- 这样金仓 Oracle 模式不必写 FROM dual，PostgreSQL 也能执行。
--
-- 不向任何列写空串。可选列用 NULL。表达式里的 ''-'' 是转义后的减号，不是空串。
-- 主键仍由 BIGSERIAL 生成，不在 INSERT 里写死 id。
-- 末尾用 setval 把每张表的序列推到 max(id)：表里有行时下一次 nextval 为 max+1，
-- 空表则下一次仍从 1 开始。pg_get_serial_sequence 按列找真实序列名，避免大小写折算对不上。
-- =====================================================================================

BEGIN;

-- 0. 字典

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'HXD1C',
       'HXD1C',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'HXD1C'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'HXD1D',
       'HXD1D',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'HXD1D'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'HXD2',
       'HXD2',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'HXD2'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'HXD3C',
       'HXD3C',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'HXD3C'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'HXD3D',
       'HXD3D',
       NULL,
       NULL,
       5,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'HXD3D'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'FXN5C',
       'FXN5C',
       NULL,
       NULL,
       6,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'FXN5C'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CX',
       'HXN5',
       'HXN5',
       NULL,
       NULL,
       7,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CX'
      AND item_code = 'HXN5'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'LY',
       'TCMS',
       'TCMS',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'LY'
      AND item_code = 'TCMS'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'LY',
       '6A',
       '6A',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'LY'
      AND item_code = '6A'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RULE_MODE',
       'CONDITIONAL',
       '条件组合判定',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RULE_MODE'
      AND item_code = 'CONDITIONAL'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RULE_MODE',
       'DIRECT',
       '直接报出',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RULE_MODE'
      AND item_code = 'DIRECT'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RULE_MODE',
       'DISABLED',
       '停用过滤',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RULE_MODE'
      AND item_code = 'DISABLED'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RULE_MODE',
       'PENDING',
       '待配置规则',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RULE_MODE'
      AND item_code = 'PENDING'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CZDJ',
       'CHECK',
       '排查',
       '需按处置流程处置',
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CZDJ'
      AND item_code = 'CHECK'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CZDJ',
       'WATCH',
       '关注',
       '司机留意、地面关注',
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CZDJ'
      AND item_code = 'WATCH'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CZDJ',
       'NONE',
       '无需干预',
       '仅记录，不配处置流程',
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CZDJ'
      AND item_code = 'NONE'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'JKDJ',
       'A',
       'A',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'JKDJ'
      AND item_code = 'A'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'JKDJ',
       'B',
       'B',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'JKDJ'
      AND item_code = 'B'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'JKDJ',
       'C',
       'C',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'JKDJ'
      AND item_code = 'C'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'JKDJ',
       'D',
       'D',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'JKDJ'
      AND item_code = 'D'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '==',
       '==',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '=='
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '!=',
       '!=',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '!='
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '>',
       '>',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '>'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '>=',
       '>=',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '>='
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '<',
       '<',
       NULL,
       NULL,
       5,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '<'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '<=',
       '<=',
       NULL,
       NULL,
       6,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '<='
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       'IN',
       'IN',
       NULL,
       NULL,
       7,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = 'IN'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       'NOT IN',
       'NOT IN',
       NULL,
       NULL,
       8,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = 'NOT IN'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CMP_OP',
       '=~',
       '=~ 正则匹配',
       NULL,
       NULL,
       9,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CMP_OP'
      AND item_code = '=~'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'WIN_FN',
       'allNotExists',
       '窗口内均未出现',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'WIN_FN'
      AND item_code = 'allNotExists'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'WIN_FN',
       'anyExists',
       '窗口内任一出现',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'WIN_FN'
      AND item_code = 'anyExists'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'WIN_FN',
       'allExists',
       '窗口内全部出现',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'WIN_FN'
      AND item_code = 'allExists'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'WIN_FN',
       'anyNotExists',
       '窗口内不全出现',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'WIN_FN'
      AND item_code = 'anyNotExists'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STEP_TYPE',
       'VIEW',
       '查看',
       '查看数据与现场状态，单一下一步',
       'roles=EXPERT;branches=下一步',
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STEP_TYPE'
      AND item_code = 'VIEW'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STEP_TYPE',
       'JUDGE',
       '判断',
       '多分支；系统预判，专家确认或改判',
       'roles=SYSTEM,EXPERT;branches=是,否',
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STEP_TYPE'
      AND item_code = 'JUDGE'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STEP_TYPE',
       'OP',
       '操作',
       '司机执行，专家记录 / 复核；成功 / 未成功两个出口',
       'roles=DRIVER,EXPERT;branches=成功,未成功',
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STEP_TYPE'
      AND item_code = 'OP'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STEP_TYPE',
       'CONTACT',
       '联络上报',
       '联络调度 / 检修 / 上级，单一下一步',
       'roles=EXPERT;branches=已联络',
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STEP_TYPE'
      AND item_code = 'CONTACT'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STEP_TYPE',
       'END',
       '结束',
       '给出处置结论，无出口',
       'roles=EXPERT;branches=',
       5,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STEP_TYPE'
      AND item_code = 'END'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'ROLE',
       'DRIVER',
       '司机',
       '执行',
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'ROLE'
      AND item_code = 'DRIVER'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'ROLE',
       'EXPERT',
       '专家',
       '确认 / 记录 / 改判',
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'ROLE'
      AND item_code = 'EXPERT'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'ROLE',
       'SYSTEM',
       '系统',
       '预答',
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'ROLE'
      AND item_code = 'SYSTEM'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CONCLUSION',
       'MAINTAIN',
       '维持运行',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CONCLUSION'
      AND item_code = 'MAINTAIN'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CONCLUSION',
       'SPEED_LIMIT',
       '限速运行',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CONCLUSION'
      AND item_code = 'SPEED_LIMIT'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CONCLUSION',
       'RESCUE',
       '请求救援',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CONCLUSION'
      AND item_code = 'RESCUE'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CONCLUSION',
       'RETURN_DEPOT',
       '回库处理',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CONCLUSION'
      AND item_code = 'RETURN_DEPOT'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CARD_KIND',
       'NUM',
       '数值窗口统计',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CARD_KIND'
      AND item_code = 'NUM'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CARD_KIND',
       'STATE',
       '状态量取值',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CARD_KIND'
      AND item_code = 'STATE'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'CARD_KIND',
       'FAULT',
       '关联故障',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'CARD_KIND'
      AND item_code = 'FAULT'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:T0值',
       'T0值',
       NULL,
       'card_kind=NUM',
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:T0值'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:最大',
       '最大',
       NULL,
       'card_kind=NUM',
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:最大'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:最小',
       '最小',
       NULL,
       'card_kind=NUM',
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:最小'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:平均',
       '平均',
       NULL,
       'card_kind=NUM',
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:平均'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:首值',
       '首值',
       NULL,
       'card_kind=NUM',
       5,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:首值'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:末值',
       '末值',
       NULL,
       'card_kind=NUM',
       6,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:末值'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:变化量',
       '变化量',
       NULL,
       'card_kind=NUM',
       7,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:变化量'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'NUM:越限时长',
       '越限时长',
       NULL,
       'card_kind=NUM',
       8,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'NUM:越限时长'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'STATE:T0值',
       'T0值',
       NULL,
       'card_kind=STATE',
       9,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'STATE:T0值'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'STATE:变位次数',
       '变位次数',
       NULL,
       'card_kind=STATE',
       10,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'STATE:变位次数'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'STATE:占用时长',
       '占用时长',
       NULL,
       'card_kind=STATE',
       11,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'STATE:占用时长'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'STATE:是否出现过',
       '是否出现过',
       NULL,
       'card_kind=STATE',
       12,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'STATE:是否出现过'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'FAULT:出现次数',
       '出现次数',
       NULL,
       'card_kind=FAULT',
       13,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'FAULT:出现次数'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'STAT_ITEM',
       'FAULT:T0后再次出现',
       'T0后再次出现',
       NULL,
       'card_kind=FAULT',
       14,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'STAT_ITEM'
      AND item_code = 'FAULT:T0后再次出现'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RUN_INFO',
       'CC',
       '车次',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RUN_INFO'
      AND item_code = 'CC'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RUN_INFO',
       'SD',
       '速度',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RUN_INFO'
      AND item_code = 'SD'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RUN_INFO',
       'WZ',
       '位置',
       NULL,
       NULL,
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RUN_INFO'
      AND item_code = 'WZ'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RUN_INFO',
       'JL',
       '交路',
       NULL,
       NULL,
       4,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RUN_INFO'
      AND item_code = 'JL'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RUN_INFO',
       'SJ',
       '司机',
       NULL,
       NULL,
       5,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RUN_INFO'
      AND item_code = 'SJ'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'RUN_INFO',
       'FSSJ',
       '发生时间',
       NULL,
       NULL,
       6,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'RUN_INFO'
      AND item_code = 'FSSJ'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'EXEC_TIMING',
       'BEFORE_HBASE',
       '查 HBase 前短路拦截',
       NULL,
       NULL,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'EXEC_TIMING'
      AND item_code = 'BEFORE_HBASE'
);

INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by)
SELECT 'EXEC_TIMING',
       'AFTER_HBASE',
       '查 HBase 后拦截',
       NULL,
       NULL,
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dict_item
    WHERE dict_type = 'EXEC_TIMING'
      AND item_code = 'AFTER_HBASE'
);

-- 1. 参数元数据

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'CC',
       '车次',
       'STRING',
       NULL,
       NULL,
       'KAFKA',
       'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ',
       'ALL',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'CC'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'SJSD',
       'LKJ实际速度',
       'NUMBER',
       'km/h',
       NULL,
       'KAFKA',
       'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ',
       'ALL',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'SJSD'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'ZZZT_0',
       'LKJ装置降级状态',
       'ENUM',
       NULL,
       '0:监控;1:降级',
       'HBASE_LKJ',
       'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ',
       'ALL',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'ZZZT_0'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_ST5_0',
       'I端司机室占用',
       'ENUM',
       NULL,
       '0:未激活;1:激活',
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_ST5_0'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_ST6_3',
       '受电弓1(I端)升弓状态',
       'ENUM',
       NULL,
       '0:未升起;1:升起',
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_ST6_3'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_ST7_0',
       'II端司机室占用',
       'ENUM',
       NULL,
       '0:未激活;1:激活',
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_ST7_0'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_ST8_3',
       '受电弓2(II端)升弓状态',
       'ENUM',
       NULL,
       '0:未升起;1:升起',
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_ST8_3'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_ST11_0',
       '主断闭合状态',
       'ENUM',
       NULL,
       '0:断开;1:闭合',
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_ST11_0'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_SD_SJ',
       'TCMS实际速度',
       'NUMBER',
       'km/h',
       NULL,
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_SD_SJ'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_YBDY',
       '原边电压',
       'NUMBER',
       'V',
       NULL,
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_YBDY'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_ZFGYL',
       '总风缸压力',
       'NUMBER',
       'kPa',
       NULL,
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_ZFGYL'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_XDCYL',
       '蓄电池\控制电源电压',
       'NUMBER',
       'V',
       NULL,
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_XDCYL'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'QY_QYBYQYW1',
       '牵引变压器油温1(ST)',
       'NUMBER',
       '℃',
       NULL,
       'HBASE_PHM',
       'LOCOMOTIVE_ADS:T_PHM_PARAM',
       'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'QY_QYBYQYW1'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'TRAIN_STATUS',
       '机车运用状态',
       'ENUM',
       NULL,
       '0:运用;1:非运用',
       'KAFKA',
       '事件 / 机车维表',
       'ALL',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'TRAIN_STATUS'
      AND hbase_table = '事件 / 机车维表'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'IS_ZDX',
       '是否中大修',
       'ENUM',
       NULL,
       '0:否;1:是',
       'DIM',
       '事件 / 机车维表',
       'ALL',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'IS_ZDX'
      AND hbase_table = '事件 / 机车维表'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'CYJ_CYJJYJKWD',
       '柴油机机油进口温度',
       'NUMBER',
       '℃',
       NULL,
       'HBASE',
       'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10',
       'FXN5C',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'CYJ_CYJJYJKWD'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'CYJ_GWSJKWD',
       '高温水进口温度',
       'NUMBER',
       '℃',
       NULL,
       'HBASE',
       'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10',
       'FXN5C',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'CYJ_GWSJKWD'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'
);

INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by)
SELECT 'YX_JCYXSD',
       '机车运行速度',
       'NUMBER',
       'km/h',
       NULL,
       'HBASE',
       'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10',
       'FXN5C',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_param_meta
    WHERE param_col = 'YX_JCYXSD'
      AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'
);

-- 2. 共享原子规则

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R001',
       'TCMS实际速度 > 0 km/h',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_SD_SJ',
       '>',
       '0',
       NULL,
       NULL,
       NULL,
       'YX_SD_SJ > 0',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R001'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R002',
       'LKJ实际速度 > 0 km/h',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'SJSD',
       '>',
       '0',
       NULL,
       NULL,
       NULL,
       'SJSD > 0',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R002'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R003',
       'TCMS实际速度 未取到（缺失）',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_SD_SJ',
       '==',
       '-',
       NULL,
       NULL,
       NULL,
       'YX_SD_SJ == ''-''',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R003'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R004',
       '原边电压 ≥ 15000 V',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_YBDY',
       '>=',
       '15000',
       NULL,
       NULL,
       NULL,
       'YX_YBDY >= 15000',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R004'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R005',
       '受电弓1(I端)升弓状态 为 升起',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST6_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST6_3',
       '==',
       '1',
       NULL,
       NULL,
       NULL,
       'YX_ST6_3 == 1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R005'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R006',
       '受电弓2(II端)升弓状态 为 升起',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST8_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST8_3',
       '==',
       '1',
       NULL,
       NULL,
       NULL,
       'YX_ST8_3 == 1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R006'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R007',
       '前后 10 秒内未出现 1874、1875 中任一故障',
       'WINDOW',
       'HXD1C',
       NULL,
       NULL,
       NULL,
       NULL,
       'allNotExists',
       10,
       '1874,1875',
       'allNotExists(10, 1874, 1875)',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R007'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R008',
       'TCMS实际速度 > 3 km/h',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_SD_SJ',
       '>',
       '3',
       NULL,
       NULL,
       NULL,
       'YX_SD_SJ > 3',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R008'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R009',
       'LKJ实际速度 > 3 km/h',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'SJSD',
       '>',
       '3',
       NULL,
       NULL,
       NULL,
       'SJSD > 3',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R009'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R010',
       '主断闭合状态 为 闭合',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST11_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST11_0',
       '==',
       '1',
       NULL,
       NULL,
       NULL,
       'YX_ST11_0 == 1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R010'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R011',
       '前后 10 秒内未出现 1809、1887、1888、1889、1902 中任一故障',
       'WINDOW',
       'HXD1C',
       NULL,
       NULL,
       NULL,
       NULL,
       'allNotExists',
       10,
       '1809,1887,1888,1889,1902',
       'allNotExists(10, 1809, 1887, 1888, 1889, 1902)',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R011'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R012',
       '前后 60 秒内未出现 1031、1742、1790、1836 中任一故障',
       'WINDOW',
       'HXD1D',
       NULL,
       NULL,
       NULL,
       NULL,
       'allNotExists',
       60,
       '1031,1742,1790,1836',
       'allNotExists(60, 1031, 1742, 1790, 1836)',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R012'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R013',
       '柴油机机油进口温度 ≥ 60 ℃',
       'PARAM',
       'FXN5C',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CYJ_CYJJYJKWD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'),
       'CYJ_CYJJYJKWD',
       '>=',
       '60',
       NULL,
       NULL,
       NULL,
       'CYJ_CYJJYJKWD >= 60',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R013'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R014',
       '高温水进口温度 ≥ 60 ℃',
       'PARAM',
       'FXN5C',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CYJ_GWSJKWD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'),
       'CYJ_GWSJKWD',
       '>=',
       '60',
       NULL,
       NULL,
       NULL,
       'CYJ_GWSJKWD >= 60',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R014'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R015',
       '机车运行速度 > 0 km/h',
       'PARAM',
       'FXN5C',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_JCYXSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'),
       'YX_JCYXSD',
       '>',
       '0',
       NULL,
       NULL,
       NULL,
       'YX_JCYXSD > 0',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R015'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R016',
       '机车运行速度 未取到（缺失）',
       'PARAM',
       'FXN5C',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_JCYXSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'),
       'YX_JCYXSD',
       '==',
       '-',
       NULL,
       NULL,
       NULL,
       'YX_JCYXSD == ''-''',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R016'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R017',
       '正线车次以英文字母开头',
       'PARAM',
       'HXD3D',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CC' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'CC',
       '=~',
       '^[A-Za-z]',
       NULL,
       NULL,
       NULL,
       'CC =~ ''^[A-Za-z]''',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R017'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R018',
       '原边电压 ≥ 2000 V',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_YBDY',
       '>=',
       '2000',
       NULL,
       NULL,
       NULL,
       'YX_YBDY >= 2000',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R018'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R019',
       'I端司机室占用 为 激活',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST5_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST5_0',
       '==',
       '1',
       NULL,
       NULL,
       NULL,
       'YX_ST5_0 == 1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R019'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R020',
       'II端司机室占用 为 激活',
       'PARAM',
       'ALL',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST7_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST7_0',
       '==',
       '1',
       NULL,
       NULL,
       NULL,
       'YX_ST7_0 == 1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R020'
);

INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by)
SELECT 'R021',
       '前后 10 秒内未出现故障 1070',
       'WINDOW',
       'HXD1C',
       NULL,
       NULL,
       NULL,
       NULL,
       'allNotExists',
       10,
       '1070',
       'allNotExists(10, 1070)',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_atom
    WHERE atom_code = 'R021'
);

-- 3. 命名条件组与成员

INSERT INTO t_phm_rule_group (group_code, group_name, scope_cx, group_expr, expand_expr, group_desc, create_by, update_by)
SELECT 'G001',
       '机车在运行',
       'ALL',
       '(R001 & R002) | (R003 & R002)',
       '(YX_SD_SJ > 0 & SJSD > 0) | (YX_SD_SJ == ''-'' & SJSD > 0)',
       'TCMS实际速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group
    WHERE group_code = 'G001'
);

INSERT INTO t_phm_rule_group (group_code, group_name, scope_cx, group_expr, expand_expr, group_desc, create_by, update_by)
SELECT 'G002',
       '机车速度大于3',
       'ALL',
       '(R008 & R009) | (R003 & R009)',
       '(YX_SD_SJ > 3 & SJSD > 3) | (YX_SD_SJ == ''-'' & SJSD > 3)',
       'TCMS实际速度 > 3 km/h 且 LKJ实际速度 > 3 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 3 km/h',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group
    WHERE group_code = 'G002'
);

INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by)
SELECT (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'),
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001'),
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group_item
    WHERE group_id = (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001')
      AND atom_id = (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001')
);

INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by)
SELECT (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'),
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'),
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group_item
    WHERE group_id = (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001')
      AND atom_id = (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002')
);

INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by)
SELECT (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'),
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R003'),
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group_item
    WHERE group_id = (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001')
      AND atom_id = (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R003')
);

INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by)
SELECT (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'),
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R008'),
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group_item
    WHERE group_id = (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002')
      AND atom_id = (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R008')
);

INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by)
SELECT (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'),
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R009'),
       2,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group_item
    WHERE group_id = (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002')
      AND atom_id = (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R009')
);

INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by)
SELECT (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'),
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R003'),
       3,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_rule_group_item
    WHERE group_id = (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002')
      AND atom_id = (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R003')
);

-- 4. 通用前置规则

INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by)
SELECT 'PF_TRAIN_STATUS',
       '仅保留运用状态机车',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'TRAIN_STATUS' AND hbase_table = '事件 / 机车维表'),
       'TRAIN_STATUS',
       '==',
       '0',
       'ALL',
       'ALL',
       'BEFORE_HBASE',
       'TRAIN_STATUS == 0',
       10,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_pre_filter_rule
    WHERE filter_code = 'PF_TRAIN_STATUS'
);

INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by)
SELECT 'PF_LKJ_ZZZT',
       '排除 LKJ 整备状态',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'ZZZT_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'ZZZT_0',
       '!=',
       '1',
       'ALL',
       'ALL',
       'AFTER_HBASE',
       'ZZZT_0 != 1',
       20,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_pre_filter_rule
    WHERE filter_code = 'PF_LKJ_ZZZT'
);

INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by)
SELECT 'PF_OVERHAUL',
       '排除中大修机车',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'IS_ZDX' AND hbase_table = '事件 / 机车维表'),
       'IS_ZDX',
       '==',
       '0',
       'ALL',
       'ALL',
       'BEFORE_HBASE',
       'IS_ZDX == 0',
       30,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_pre_filter_rule
    WHERE filter_code = 'PF_OVERHAUL'
);

INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by)
SELECT 'PF_CC_TEST',
       '排除测试车次黑名单',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CC' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'CC',
       'NOT IN',
       '8100,8200,8300,8400,8500,8600,8700,8800,8900,11111,22222,77777,8028,8128,8010,8020,8030,8040,8050,8060,8070,8080,8090,8012,8016,8018',
       'HXD1C',
       'TCMS',
       'BEFORE_HBASE',
       'CC NOT IN (''8100'', ''8200'', ''8300'', ''8400'', ''8500'', ''8600'', ''8700'', ''8800'', ''8900'', ''11111'', ''22222'', ''77777'', ''8028'', ''8128'', ''8010'', ''8020'', ''8030'', ''8040'', ''8050'', ''8060'', ''8070'', ''8080'', ''8090'', ''8012'', ''8016'', ''8018'')',
       40,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_pre_filter_rule
    WHERE filter_code = 'PF_CC_TEST'
);

INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by)
SELECT 'PF_CC6',
       '排除 6 项特殊车次',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CC' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'CC',
       'NOT IN',
       '11111,22222,33333,66666,88888,65432',
       'HXD1D',
       'TCMS',
       'BEFORE_HBASE',
       'CC NOT IN (''11111'', ''22222'', ''33333'', ''66666'', ''88888'', ''65432'')',
       50,
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_pre_filter_rule
    WHERE filter_code = 'PF_CC6'
);

-- 5. 故障规则主表 / 引入清单 / 前置豁免

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1C',
       'TCMS',
       '1873',
       'ATP电源MCB断开',
       'ATP电源MCB断开',
       'D',
       'CHECK',
       'CONDITIONAL',
       'A1 & A2 & (A3 | A4) & A5',
       '((YX_SD_SJ > 0 & SJSD > 0) | (YX_SD_SJ == ''-'' & SJSD > 0)) & YX_YBDY >= 15000 & (YX_ST6_3 == 1 | YX_ST8_3 == 1) & allNotExists(10, 1874, 1875)',
       '报出故障 1873，需同时满足以下 4 项：
① 机车在运行（满足其一）：TCMS实际速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h
② 原边电压 ≥ 15000 V
③ 满足其一：受电弓1(I端)升弓状态 为 升起 ／ 受电弓2(II端)升弓状态 为 升起
④ 前后 10 秒内未出现 1874、1875 中任一故障',
       1,
       NULL,
       '辅助系统',
       NULL,
       NULL,
       '低压电器',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.排除大中修机车;2.TCMS 故障：速度>0;3.TCMS 基本运行信息：机车速度实际值>0（如获取到）;4.原边电压≥15KV;5.受电弓1或受电弓2已升起;6.前后10s未报1874、1875',
       '20260814-最新版本',
       NULL,
       '102468',
       '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & ((YX_SD_SJ>0 && SJSD >0) | (YX_SD_SJ==''-'' & SJSD>0)) & YX_YBDY>=15000 & (YX_ST6_3==1|YX_ST8_3==1) & allNotExists([''1874,1875''],10)',
       '广州局株洲机务段_v8.0_吴东昊_20260814',
       'seed',
       '2026-08-14 09:23:48.514898',
       'seed',
       '2026-08-14 09:23:48.514898'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1C'
      AND ly = 'TCMS'
      AND gzdm = '1873'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1C',
       'TCMS',
       '1914',
       '停放制动隔离塞门关闭',
       '停放制动隔离塞门关闭',
       'D',
       'CHECK',
       'CONDITIONAL',
       'A1 & A2 & A3',
       '((YX_SD_SJ > 3 & SJSD > 3) | (YX_SD_SJ == ''-'' & SJSD > 3)) & YX_ST11_0 == 1 & allNotExists(10, 1809, 1887, 1888, 1889, 1902)',
       '报出故障 1914，需同时满足以下 3 项：
① 机车速度大于3（满足其一）：TCMS实际速度 > 3 km/h 且 LKJ实际速度 > 3 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 3 km/h
② 主断闭合状态 为 闭合
③ 前后 10 秒内未出现 1809、1887、1888、1889、1902 中任一故障',
       1,
       NULL,
       '制动系统',
       NULL,
       NULL,
       '风源系统',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.排除大中修机车;2.主断状态闭合;3.TCMS 故障：速度>3;4.TCMS 基本运行信息：机车速度实际值>3;5.前后10秒未出现1809、1887、1888、1889、1902任一故障时报出',
       '20260814-最新版本',
       NULL,
       '102342',
       '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & ((YX_SD_SJ>3 && SJSD >3) | (YX_SD_SJ==''-'' & SJSD>3)) & YX_ST11_0==1 & allNotExists([''1809,1887,1888,1889,1902''],10)',
       '广州局株洲机务段_v8.0_吴东昊_20260814',
       'seed',
       '2026-08-14 09:23:48.514898',
       'seed',
       '2026-08-14 09:23:48.514898'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1C'
      AND ly = 'TCMS'
      AND gzdm = '1914'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1D',
       'TCMS',
       '1835',
       '主断环硬线回路断开',
       NULL,
       'D',
       'CHECK',
       'CONDITIONAL',
       '(A1 | A2) & A3',
       '(YX_ST6_3 == 1 | YX_ST8_3 == 1) & allNotExists(60, 1031, 1742, 1790, 1836)',
       '报出故障 1835，需同时满足以下 2 项：
① 满足其一：受电弓1(I端)升弓状态 为 升起 ／ 受电弓2(II端)升弓状态 为 升起
② 前后 60 秒内未出现 1031、1742、1790、1836 中任一故障',
       1,
       NULL,
       '高压电器装置',
       NULL,
       NULL,
       '主断路器',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.60秒内不报出故障[1031,1742,1790,1836];2.I端受电弓升起状态(YX_ST6_3)=1 OR II端受电弓升起状态(YX_ST8_3)=1;3.非特殊车次:11111,22222,33333,66666,88888,65432;4.装置状态[1-降级,0-监控] != 1;5.上述条件均满足,故障报出;',
       '1',
       NULL,
       '97346',
       'CC!=''11111''&CC!=''22222''&CC!=''33333''&CC!=''66666''&CC!=''88888''&CC!=''65432''&ZZZT_0!=''1''&(YX_ST6_3==''1''|YX_ST8_3==''1'')&allNotExists([''1031'',''1742'',''1790'',''1836''],60)',
       '上海局上海机务段HXD1D_V1.533',
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1D'
      AND ly = 'TCMS'
      AND gzdm = '1835'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'FXN5C',
       'TCMS',
       '3816',
       '柴油机油水温度低，限制8档',
       '柴油机油水温度低，限制8档',
       'D',
       'WATCH',
       'CONDITIONAL',
       '(A1 | A2) & ((A3 & A4) | (A5 & A4))',
       '(CYJ_CYJJYJKWD >= 60 | CYJ_GWSJKWD >= 60) & ((YX_JCYXSD > 0 & SJSD > 0) | (YX_JCYXSD == ''-'' & SJSD > 0))',
       '报出故障 3816，需同时满足以下 2 项：
① 满足其一：柴油机机油进口温度 ≥ 60 ℃ ／ 高温水进口温度 ≥ 60 ℃
② 满足其一：机车运行速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ 机车运行速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h',
       1,
       NULL,
       '柴油机系统',
       NULL,
       NULL,
       '油/水系统',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.机油进口温度(CYJ_CYJJYJKWD)≥60°或高温水进口温度≥60°，则推送，反之则过滤;2.机车速度取值>0:(微机速度和机车速度_LKJ均大于0) 或者 (微机速度未取到 并且 机车速度_LKJ >0 );',
       '20260819-最新版本',
       NULL,
       '101577',
       '(CYJ_CYJJYJKWD>=60 | CYJ_GWSJKWD>=60) & ((YX_JCYXSD>0 && SJSD >0) | (YX_JCYXSD==''-'' & SJSD>0))',
       '上海局上海机务段_v3.0_马晓瑜_20260819',
       'seed',
       '2026-08-19 16:57:25.809100',
       'seed',
       '2026-08-19 16:57:25.809100'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'FXN5C'
      AND ly = 'TCMS'
      AND gzdm = '3816'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD3D',
       'TCMS',
       '440',
       'LG1直流负线接地',
       NULL,
       'D',
       'CHECK',
       'CONDITIONAL',
       'A1',
       'CC =~ ''^[A-Za-z]''',
       '报出故障 440，需同时满足以下 1 项：
① 车次 匹配正则 ^[A-Za-z]',
       1,
       NULL,
       '辅助系统',
       NULL,
       NULL,
       '列车供电柜',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '正线车次报（首字是字母）;',
       '1',
       NULL,
       '94983',
       'CC=~/^[A-Za-z]/',
       NULL,
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD3D'
      AND ly = 'TCMS'
      AND gzdm = '440'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1C',
       'TCMS',
       '1199',
       '受电弓降下保护',
       '受电弓降下保护',
       'D',
       'CHECK',
       'CONDITIONAL',
       'A1 & (A2 | A3)',
       'YX_YBDY >= 2000 & (YX_ST5_0 == 1 | YX_ST7_0 == 1)',
       '报出故障 1199，需同时满足以下 2 项：
① 原边电压 ≥ 2000 V
② 满足其一：I端司机室占用 为 激活 ／ II端司机室占用 为 激活',
       1,
       NULL,
       '网侧高压系统',
       NULL,
       NULL,
       '高压电器装置',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.排除大中修机车;2.原边电压≥2KV;3.I端司机室占用或II端司机室占用',
       '20260814-最新版本',
       NULL,
       '101985',
       '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & YX_YBDY>=2000 & (YX_ST5_0==1|YX_ST7_0==1)',
       '广州局株洲机务段_v8.0_吴东昊_20260814',
       'seed',
       '2026-08-14 09:23:48.514898',
       'seed',
       '2026-08-14 09:23:48.514898'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1C'
      AND ly = 'TCMS'
      AND gzdm = '1199'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1C',
       'TCMS',
       '1019',
       '受电弓1升弓故障',
       '受电弓1升弓故障-未检测到受电弓升起',
       'D',
       'WATCH',
       'CONDITIONAL',
       'A1 & (A2 | A3)',
       'YX_YBDY >= 15000 & (YX_ST5_0 == 1 | YX_ST7_0 == 1)',
       '报出故障 1019，需同时满足以下 2 项：
① 原边电压 ≥ 15000 V
② 满足其一：I端司机室占用 为 激活 ／ II端司机室占用 为 激活',
       1,
       NULL,
       '网侧高压系统',
       NULL,
       NULL,
       '高压电器装置',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.排除大中修机车;2.原边电压≥15KV;3.I端司机室占用或II端司机室占用',
       '20260814-最新版本',
       NULL,
       '101987',
       '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & YX_YBDY>=15000 & (YX_ST5_0==1|YX_ST7_0==1)',
       '广州局株洲机务段_v8.0_吴东昊_20260814',
       'seed',
       '2026-08-14 09:23:48.514898',
       'seed',
       '2026-08-14 09:23:48.514898'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1C'
      AND ly = 'TCMS'
      AND gzdm = '1019'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1C',
       'TCMS',
       '1071',
       '变压器油温2故障',
       '变压器油温2故障',
       'D',
       'WATCH',
       'CONDITIONAL',
       'A1',
       'allNotExists(10, 1070)',
       '报出故障 1071，需同时满足以下 1 项：
① 前后 10 秒内未出现故障 1070',
       1,
       NULL,
       '牵引系统',
       NULL,
       NULL,
       '主变压器',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.排除大中修机车;2.没有报变压器油温1故障时报出',
       '20260814-最新版本',
       NULL,
       '101984',
       '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & allNotExists([''1070''],10)',
       '广州局株洲机务段_v8.0_吴东昊_20260814',
       'seed',
       '2026-08-14 09:23:48.514898',
       'seed',
       '2026-08-14 09:23:48.514898'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1C'
      AND ly = 'TCMS'
      AND gzdm = '1071'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1C',
       'TCMS',
       '1023',
       '原边电压欠压报警',
       '原边电压欠压报警',
       'A',
       'NONE',
       'DISABLED',
       NULL,
       NULL,
       '停用过滤：该故障不报出',
       0,
       NULL,
       '网侧高压系统',
       NULL,
       NULL,
       '高压电器装置',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '不报出',
       '20260814-最新版本',
       NULL,
       '101983',
       NULL,
       '广州局株洲机务段_v8.0_吴东昊_20260814',
       'seed',
       '2026-08-14 09:23:48.514898',
       'seed',
       '2026-08-14 09:23:48.514898'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1C'
      AND ly = 'TCMS'
      AND gzdm = '1023'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD1D',
       'TCMS',
       '1577',
       '变流器2M3元件总故障',
       NULL,
       'D',
       'WATCH',
       'DIRECT',
       NULL,
       NULL,
       '直接报出：收到该故障代码即报出，不做条件判断（仍执行通用前置规则）',
       1,
       NULL,
       '牵引系统',
       NULL,
       NULL,
       '牵引变流器',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '1.无故障规则条件,直接报出;2.非特殊车次:11111,22222,33333,66666,88888,65432;3.装置状态[1-降级,0-监控] != 1;4.上述条件均满足,故障报出;',
       '1',
       NULL,
       '97184',
       'CC!=''11111''&CC!=''22222''&CC!=''33333''&CC!=''66666''&CC!=''88888''&CC!=''65432''&ZZZT_0!=''1''',
       '上海局上海机务段HXD1D_V1.387',
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD1D'
      AND ly = 'TCMS'
      AND gzdm = '1577'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'FXN5C',
       '6A',
       'C29A',
       '2轴4位温升报警',
       '轴报轮轴驱动装置温升报警',
       'C',
       'CHECK',
       'DIRECT',
       NULL,
       NULL,
       '直接报出：收到该故障代码即报出，不做条件判断（仍执行通用前置规则）',
       1,
       NULL,
       '轮轴驱动装置',
       NULL,
       NULL,
       '轮轴驱动装置',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       '直接报;',
       '中车戚墅堰_6A_V1.0',
       NULL,
       '103979',
       '1==1',
       '中车戚墅堰_6A_V1.0',
       'seed',
       '2026-11-02 10:00:00',
       'seed',
       '2026-11-02 10:00:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'FXN5C'
      AND ly = '6A'
      AND gzdm = 'C29A'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD2',
       'TCMS',
       '20 01 06',
       '牵引电机3冷却回路异常',
       NULL,
       'D',
       'WATCH',
       'CONDITIONAL',
       'A1 | A2',
       'YX_SD_SJ > 0 | SJSD > 0',
       '满足以下任一项，即报出故障 20 01 06：
① TCMS实际速度 > 0 km/h
② LKJ实际速度 > 0 km/h',
       1,
       NULL,
       '通风系统',
       '012207',
       'PJ02352',
       '牵引通风系统',
       '01220701',
       'PJ02353',
       '0',
       NULL,
       NULL,
       '速度>0,直接报;',
       '1',
       NULL,
       '97481',
       '(YX_SD_SJ>0 | SJSD>0)',
       NULL,
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD2'
      AND ly = 'TCMS'
      AND gzdm = '20 01 06'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD3C',
       'TCMS',
       '20',
       '车体通风机1故障',
       NULL,
       'D',
       'NONE',
       'PENDING',
       NULL,
       NULL,
       '待配置规则',
       0,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '清洗;',
       '1',
       '为从零配置体验暂置待配置；原始底账与规则保留在溯源中。',
       '103321',
       NULL,
       NULL,
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD3C'
      AND ly = 'TCMS'
      AND gzdm = '20'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXN5',
       'TCMS',
       '19-4013',
       '4位牵引电机锁轴',
       '4位牵引电机锁轴',
       'D',
       'CHECK',
       'PENDING',
       NULL,
       NULL,
       '待配置规则',
       0,
       NULL,
       '牵引系统',
       NULL,
       NULL,
       '牵引电机',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       '直接报;',
       '1',
       '为从零配置体验暂置待配置；原始底账与规则保留在溯源中。',
       '103931',
       '1==1',
       '哈局哈尔滨机务段HXN5_V1.0',
       'seed',
       '2026-10-28 10:00:00',
       'seed',
       '2026-10-28 10:00:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXN5'
      AND ly = 'TCMS'
      AND gzdm = '19-4013'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD3D',
       'TCMS',
       '169',
       'CI5 PG输出异常',
       NULL,
       'D',
       'WATCH',
       'DIRECT',
       NULL,
       NULL,
       '直接报出：收到该故障代码即报出，不做条件判断（仍执行通用前置规则）',
       1,
       NULL,
       '牵引系统',
       NULL,
       NULL,
       '牵引变流器',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '直接报;',
       '1',
       NULL,
       '93520',
       '1==1',
       NULL,
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD3D'
      AND ly = 'TCMS'
      AND gzdm = '169'
);

INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time)
SELECT 'HXD2',
       'TCMS',
       '20 00 24',
       '逆变器3故障',
       NULL,
       'D',
       'WATCH',
       'CONDITIONAL',
       'A1 | A2',
       'YX_SD_SJ > 0 | SJSD > 0',
       '满足以下任一项，即报出故障 20 00 24：
① TCMS实际速度 > 0 km/h
② LKJ实际速度 > 0 km/h',
       1,
       NULL,
       '牵引系统',
       '012204',
       'PJ01308',
       '牵引变流器2',
       NULL,
       NULL,
       '0',
       NULL,
       NULL,
       '速度>0,直接报;',
       '1',
       NULL,
       '97351',
       '(YX_SD_SJ>0 | SJSD>0)',
       NULL,
       'seed',
       '2026-03-30 17:11:57.528082',
       'seed',
       '2026-03-30 17:11:57.528082'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule
    WHERE cx = 'HXD2'
      AND ly = 'TCMS'
      AND gzdm = '20 00 24'
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       1,
       'GROUP',
       NULL,
       (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R004'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       3,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R005'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873')
      AND seq_no = 3
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       4,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R006'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873')
      AND seq_no = 4
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       5,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R007'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873')
      AND seq_no = 5
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'),
       1,
       'GROUP',
       NULL,
       (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R010'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'),
       3,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R011'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914')
      AND seq_no = 3
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R005'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R006'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'),
       3,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R012'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835')
      AND seq_no = 3
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R013'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R014'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'),
       3,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R015'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816')
      AND seq_no = 3
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'),
       4,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816')
      AND seq_no = 4
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'),
       5,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R016'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816')
      AND seq_no = 5
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD3D' AND ly = 'TCMS' AND gzdm = '440'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R017'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD3D' AND ly = 'TCMS' AND gzdm = '440')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R018'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R019'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'),
       3,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R020'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199')
      AND seq_no = 3
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R004'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R019'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019'),
       3,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R020'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019')
      AND seq_no = 3
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1071'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R021'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1071')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 01 06'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 01 06')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 01 06'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 01 06')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 00 24'),
       1,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 00 24')
      AND seq_no = 1
);

INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 00 24'),
       2,
       'ATOM',
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_rule_ref
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 00 24')
      AND seq_no = 2
);

INSERT INTO t_phm_fault_pre_skip (fault_rule_id, filter_id, skip_reason, create_by, update_by)
SELECT (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'),
       (SELECT id FROM t_phm_pre_filter_rule WHERE filter_code = 'PF_LKJ_ZZZT'),
       '原规则体无 LKJ 整备状态条件（原型演示的单条豁免）',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_fault_pre_skip
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816')
      AND filter_id = (SELECT id FROM t_phm_pre_filter_rule WHERE filter_code = 'PF_LKJ_ZZZT')
);

-- 6. 处置流程：流程头 / 版本 / 绑定 / 步骤 / 数据卡 / 分支 / 确认项

INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time)
SELECT 'FL1914',
       '停放制动隔离塞门关闭 处置流程',
       0,
       'PUBLISHED',
       1,
       1,
       '示例内容，非正式规程，需按实际司机手册校核',
       'seed',
       '2026-11-08 16:20:00',
       'seed',
       '2026-11-08 16:20:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow
    WHERE flow_code = 'FL1914'
);

INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1914'),
       1,
       'PUBLISHED',
       0,
       '停放制动隔离塞门关闭 处置流程',
       60,
       30,
       'CC,SD,WZ,SJ,FSSJ',
       'seed',
       '2026-11-08 16:20:00',
       'seed',
       '2026-11-08 16:20:00',
       'seed',
       '2026-11-08 16:20:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_ver
    WHERE flow_id = (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1914')
      AND ver_no = 1
);

INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1914'),
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_bind
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914')
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S1',
       1,
       'VIEW',
       '查看运行状态与报警前后数据',
       '以报警时刻 T0 为锚点，查看速度、主断状态及关联制动故障，判断报警时机车是否在运行中。',
       'EXPERT',
       NULL,
       '司机手册 · 制动系统 · 停放制动（条目待校核）',
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S1'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S2',
       2,
       'JUDGE',
       '总风缸风压是否正常？',
       '系统按窗口内总风缸压力最小值预判，专家结合曲线确认或改判。',
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S2'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S3',
       3,
       'OP',
       '停车后检查停放制动隔离塞门并恢复',
       '具备条件时停车，做好防溜后检查塞门位置，将其恢复至开通位并做停放制动试验。',
       'DRIVER,EXPERT',
       '下车作业前须确认机车停稳并做好防溜，按规定联系与防护。',
       '司机手册 · 制动柜塞门（条目待校核）',
       '停车防溜 → 检查制动柜停放制动隔离塞门 → 恢复开通位 → 施加 / 缓解试验，结果电话报告专家',
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S3'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S4',
       4,
       'JUDGE',
       '故障是否消除？',
       '系统检查 T0 后是否再次报 1914，专家确认。',
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S4'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S5',
       5,
       'END',
       '故障消除，维持运行',
       '记录处置过程，回段后复核塞门状态。',
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'MAINTAIN',
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S5'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S6',
       6,
       'CONTACT',
       '联络调度与检修，上报处置情况',
       '专家将数据与处置经过上报调度和检修部门，商定后续运行方式。',
       'EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S6'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S7',
       7,
       'JUDGE',
       '能否限速维持运行至前方站？',
       '人工判断：结合风压、制动表现与调度意见。',
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S7'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S8',
       8,
       'END',
       '限速运行，回库处理',
       '限速运行至前方站后回库，推送检修提示。',
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'SPEED_LIMIT',
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S8'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1),
       'S9',
       9,
       'END',
       '停车请求救援',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'RESCUE',
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1)
      AND step_code = 'S9'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C1',
       1,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_SD_SJ',
       NULL,
       60,
       30,
       'T0值,最大,最小',
       1,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C2',
       2,
       'STATE',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST11_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST11_0',
       NULL,
       60,
       30,
       'T0值,变位次数',
       0,
       NULL,
       NULL,
       '1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C2'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C3',
       3,
       'FAULT',
       NULL,
       NULL,
       '1809,1887,1888,1889,1902',
       60,
       30,
       '出现次数',
       0,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C3'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'C1',
       1,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ZFGYL' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ZFGYL',
       NULL,
       60,
       30,
       'T0值,最小,平均,越限时长',
       1,
       '<',
       '750',
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'),
       'C1',
       1,
       'FAULT',
       NULL,
       NULL,
       '1914',
       0,
       30,
       '出现次数,T0后再次出现',
       0,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'),
       1,
       '下一步',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'),
       1,
       '正常',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'),
       'CARD',
       (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2') AND c.card_code = 'C1'),
       '最小',
       '>=',
       '750',
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'),
       2,
       '异常',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'ELSE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '未成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'),
       1,
       '已消除',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'CARD',
       (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4') AND c.card_code = 'C1'),
       'T0后再次出现',
       '==',
       '0',
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'),
       2,
       '未消除',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'ELSE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'),
       1,
       '已联络',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7'),
       1,
       '能',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S8'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7'),
       2,
       '不能',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S9'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '机车已停稳并做好防溜',
       'DRIVER',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '塞门已恢复开通位，施加 / 缓解试验正常',
       'DRIVER',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'),
       3,
       '专家已记录司机反馈',
       'EXPERT',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 3
);

INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time)
SELECT 'FL1873',
       'ATP 电源 MCB 断开 处置流程',
       0,
       'DRAFT',
       0,
       1,
       '示例内容，非正式规程，需按实际司机手册校核',
       'seed',
       '2026-11-09 10:05:00',
       'seed',
       '2026-11-09 10:05:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow
    WHERE flow_code = 'FL1873'
);

INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1873'),
       1,
       'DRAFT',
       0,
       'ATP 电源 MCB 断开 处置流程',
       60,
       30,
       'CC,SD,WZ,SJ,FSSJ',
       NULL,
       NULL,
       'seed',
       '2026-11-09 10:05:00',
       'seed',
       '2026-11-09 10:05:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_ver
    WHERE flow_id = (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1873')
      AND ver_no = 1
);

INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1873'),
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_bind
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873')
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S1',
       1,
       'VIEW',
       '查看运行状态与网侧供电',
       '查看原边电压、受电弓状态与速度，确认报警时机车处于受电运行。',
       'EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S1'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S2',
       2,
       'JUDGE',
       '网侧供电是否正常？',
       '复用原子规则「原边电压 ≥ 15000 V」做系统预判。',
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S2'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S3',
       3,
       'OP',
       '检查并闭合 ATP 电源 MCB（仅一次）',
       NULL,
       'DRIVER,EXPERT',
       'MCB 再次跳开时不得反复闭合。',
       NULL,
       '在保证行车安全前提下检查低压柜 ATP 电源 MCB，闭合一次并观察 ATP 自检',
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S3'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S4',
       4,
       'JUDGE',
       'ATP 是否恢复？',
       NULL,
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S4'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S5',
       5,
       'END',
       'ATP 恢复，维持运行',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'MAINTAIN',
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S5'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S6',
       6,
       'CONTACT',
       '联络调度，按 ATP 故障行车办理',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S6'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S7',
       7,
       'JUDGE',
       '能否按规定限速运行？',
       NULL,
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S7'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S8',
       8,
       'END',
       '限速运行，回库处理',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'SPEED_LIMIT',
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S8'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1),
       'S9',
       9,
       'END',
       '请求救援',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'RESCUE',
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1)
      AND step_code = 'S9'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C1',
       1,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_YBDY',
       NULL,
       60,
       30,
       'T0值,最小,平均',
       1,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C2',
       2,
       'STATE',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST6_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST6_3',
       NULL,
       60,
       30,
       'T0值,变位次数',
       0,
       NULL,
       NULL,
       '1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C2'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C3',
       3,
       'STATE',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST8_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST8_3',
       NULL,
       60,
       30,
       'T0值',
       0,
       NULL,
       NULL,
       '1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C3'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C4',
       4,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'SJSD',
       NULL,
       60,
       30,
       'T0值,最大',
       1,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C4'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'C1',
       1,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_YBDY',
       NULL,
       60,
       30,
       '最小,越限时长',
       1,
       '<',
       '15000',
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'),
       'C1',
       1,
       'FAULT',
       NULL,
       NULL,
       '1873',
       0,
       30,
       'T0后再次出现',
       0,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'),
       1,
       '下一步',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'),
       1,
       '正常',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'),
       'ATOM',
       NULL,
       NULL,
       NULL,
       NULL,
       (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R004'),
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'),
       2,
       '异常',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'ELSE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '未成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'),
       1,
       '已恢复',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'CARD',
       (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4') AND c.card_code = 'C1'),
       'T0后再次出现',
       '==',
       '0',
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'),
       2,
       '未恢复',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'ELSE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'),
       1,
       '已联络',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7'),
       1,
       '能',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S8'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7'),
       2,
       '不能',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S9'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       'MCB 已闭合一次，未再跳开',
       'DRIVER',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       'ATP 自检通过',
       'DRIVER',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'),
       3,
       '专家已记录',
       'EXPERT',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 3
);

INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time)
SELECT 'FT01',
       '电器类断路 / 跳闸通用处置',
       1,
       'PUBLISHED',
       1,
       1,
       '示例内容，非正式规程，需按实际司机手册校核',
       'seed',
       '2026-11-07 09:12:00',
       'seed',
       '2026-11-07 09:12:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow
    WHERE flow_code = 'FT01'
);

INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01'),
       1,
       'PUBLISHED',
       0,
       '电器类断路 / 跳闸通用处置',
       60,
       30,
       'CC,SD,WZ,SJ,FSSJ',
       'seed',
       '2026-11-07 09:12:00',
       'seed',
       '2026-11-07 09:12:00',
       'seed',
       '2026-11-07 09:12:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_ver
    WHERE flow_id = (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01')
      AND ver_no = 1
);

INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01'),
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_bind
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835')
);

INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01'),
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD3D' AND ly = 'TCMS' AND gzdm = '440'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_bind
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD3D' AND ly = 'TCMS' AND gzdm = '440')
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S1',
       1,
       'VIEW',
       '查看报警前后运行状态',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S1'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S2',
       2,
       'JUDGE',
       '相关设备是否已断开 / 跳闸？',
       '人工判断：专家结合显示屏与司机通话确认。',
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S2'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S3',
       3,
       'OP',
       '按规定复位 / 闭合一次',
       NULL,
       'DRIVER,EXPERT',
       '复位后再次跳开不得反复操作。',
       NULL,
       '按专家指导复位 / 闭合一次，观察是否保持',
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S3'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S4',
       4,
       'JUDGE',
       '故障是否消除？',
       NULL,
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S4'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S5',
       5,
       'CONTACT',
       '联络调度与检修',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S5'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S6',
       6,
       'END',
       '维持运行',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'MAINTAIN',
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S6'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1),
       'S7',
       7,
       'END',
       '回库处理',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'RETURN_DEPOT',
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1)
      AND step_code = 'S7'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C1',
       1,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'),
       'SJSD',
       NULL,
       60,
       30,
       'T0值,最大,最小',
       1,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S1'),
       1,
       '下一步',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2'),
       1,
       '是',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2'),
       2,
       '否',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '未成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4'),
       1,
       '已消除',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S6'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4'),
       2,
       '未消除',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'),
       1,
       '已联络',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S7'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '司机已按指令执行并反馈结果',
       'DRIVER',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '专家已记录 / 复核司机反馈',
       'EXPERT',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time)
SELECT 'FL1199',
       '受电弓降下保护 简版',
       0,
       'DRAFT',
       0,
       1,
       '示例内容，非正式规程，需按实际司机手册校核',
       'seed',
       '2026-11-09 11:30:00',
       'seed',
       '2026-11-09 11:30:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow
    WHERE flow_code = 'FL1199'
);

INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1199'),
       1,
       'DRAFT',
       0,
       '受电弓降下保护 简版',
       60,
       30,
       'CC,SD,WZ,SJ,FSSJ',
       NULL,
       NULL,
       'seed',
       '2026-11-09 11:30:00',
       'seed',
       '2026-11-09 11:30:00'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_ver
    WHERE flow_id = (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1199')
      AND ver_no = 1
);

INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by)
SELECT (SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1199'),
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'),
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_flow_bind
    WHERE fault_rule_id = (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199')
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1),
       'S1',
       1,
       'VIEW',
       '查看受电弓与网压',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1)
      AND step_code = 'S1'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1),
       'S2',
       2,
       'JUDGE',
       '网压是否正常？',
       NULL,
       'SYSTEM,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1)
      AND step_code = 'S2'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1),
       'S3',
       3,
       'OP',
       '按规定重新升弓一次',
       NULL,
       'DRIVER,EXPERT',
       NULL,
       NULL,
       NULL,
       NULL,
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1)
      AND step_code = 'S3'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1),
       'S4',
       4,
       'END',
       '维持运行',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'MAINTAIN',
       0,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1)
      AND step_code = 'S4'
);

INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by)
SELECT (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1),
       'S5',
       5,
       'END',
       '回库处理',
       NULL,
       'EXPERT',
       NULL,
       NULL,
       NULL,
       'RETURN_DEPOT',
       1,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_step
    WHERE flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1)
      AND step_code = 'S5'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C1',
       1,
       'STATE',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST6_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_ST6_3',
       NULL,
       60,
       30,
       'T0值,变位次数',
       0,
       NULL,
       NULL,
       '1',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1'),
       'C2',
       2,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_YBDY',
       NULL,
       60,
       30,
       'T0值,最小',
       1,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND card_code = 'C2'
);

INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'C1',
       1,
       'NUM',
       (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'),
       'YX_YBDY',
       NULL,
       60,
       30,
       '最小',
       1,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_card
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND card_code = 'C1'
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1'),
       1,
       '下一步',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'),
       1,
       '正常',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'),
       'CARD',
       (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2') AND c.card_code = 'C1'),
       '最小',
       '>=',
       '17500',
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'),
       2,
       '异常',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'ELSE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S4'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '未成功',
       (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S5'),
       'NONE',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_branch
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'),
       1,
       '司机已按指令执行并反馈结果',
       'DRIVER',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 1
);

INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by)
SELECT (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'),
       2,
       '专家已记录 / 复核司机反馈',
       'EXPERT',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_dispose_confirm
    WHERE step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3')
      AND seq_no = 2
);

-- 7. 模拟历史事件

INSERT INTO t_phm_sim_event (event_code, fault_rule_id, event_title, expect_outcome, cc, sd, wz, jl, sjxm, fssj, create_by, update_by)
SELECT 'EV1',
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'),
       '2026-10-21 14:32 · 27015 次 · 走向：正常消除',
       '正常消除',
       '27015',
       '46 km/h',
       '某线 K136+420 下行（示意）',
       '甲站—乙站（示意）',
       '张**',
       '2026-10-21 14:32:18',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event
    WHERE event_code = 'EV1'
);

INSERT INTO t_phm_sim_event_point (event_id, point_type, obj_code, offset_sec, num_val, txt_val, create_by, update_by)
SELECT e.id, v.point_type, v.obj_code, v.offset_sec, v.num_val, v.txt_val, 'seed', 'seed'
FROM t_phm_sim_event e
JOIN (
    SELECT 'SERIES' AS point_type, 'YX_SD_SJ' AS obj_code, -120 AS offset_sec,
           CAST(47.6 AS NUMERIC(18, 4)) AS num_val, CAST(NULL AS VARCHAR(64)) AS txt_val
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -118, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -116, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -114, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -112, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -110, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -108, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -106, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -104, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -102, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -100, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -98, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -96, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -94, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -92, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -90, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -88, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -86, CAST(46.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -84, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -82, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -80, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -78, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -76, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -74, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -72, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -70, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -68, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -66, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -64, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -62, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -60, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -58, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -56, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -54, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -52, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -50, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -48, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -46, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -44, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -42, CAST(46.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -40, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -38, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -36, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -34, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -32, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -30, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -28, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -26, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -24, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -22, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -20, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -18, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -16, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -14, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -12, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -10, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -8, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -6, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -4, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -2, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 0, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 2, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 4, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 6, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 8, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 10, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 12, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 14, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 16, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 18, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 20, CAST(46.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 22, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 24, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 26, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 28, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 30, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 32, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 34, CAST(44.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 36, CAST(44.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 38, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 40, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 42, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 44, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 46, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 48, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 50, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 52, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 54, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 56, CAST(47.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 58, CAST(47.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 60, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -120, CAST(45.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -118, CAST(46.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -116, CAST(46.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -114, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -112, CAST(47.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -110, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -108, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -106, CAST(47 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -104, CAST(46.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -102, CAST(46.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -100, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -98, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -96, CAST(45.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -94, CAST(45 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -92, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -90, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -88, CAST(44.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -86, CAST(45.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -84, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -82, CAST(45.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -80, CAST(46.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -78, CAST(46.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -76, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -74, CAST(47.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -72, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -70, CAST(47.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -68, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -66, CAST(46.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -64, CAST(46.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -62, CAST(45.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -60, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -58, CAST(45.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -56, CAST(44.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -54, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -52, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -50, CAST(45 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -48, CAST(45.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -46, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -44, CAST(45.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -42, CAST(46.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -40, CAST(46.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -38, CAST(47 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -36, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -34, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -32, CAST(47.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -30, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -28, CAST(46.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -26, CAST(46.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -24, CAST(45.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -22, CAST(45.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -20, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -18, CAST(44.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -16, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -14, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -12, CAST(45 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -10, CAST(45.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -8, CAST(45.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -6, CAST(46 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -4, CAST(46.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -2, CAST(46.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 0, CAST(47 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 2, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 4, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 6, CAST(47.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 8, CAST(46.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 10, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 12, CAST(46.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 14, CAST(45.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 16, CAST(45.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 18, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 20, CAST(44.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 22, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 24, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 26, CAST(45 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 28, CAST(45.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 30, CAST(45.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 32, CAST(46.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 34, CAST(46.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 36, CAST(46.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 38, CAST(47 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 40, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 42, CAST(47.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 44, CAST(47.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 46, CAST(46.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 48, CAST(46.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 50, CAST(46.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 52, CAST(45.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 54, CAST(45.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 56, CAST(45.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 58, CAST(44.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 60, CAST(44.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -120, CAST(876.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -118, CAST(877 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -116, CAST(876.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -114, CAST(874.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -112, CAST(871.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -110, CAST(868.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -108, CAST(864.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -106, CAST(861.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -104, CAST(859.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -102, CAST(859 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -100, CAST(859.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -98, CAST(861.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -96, CAST(864.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -94, CAST(868.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -92, CAST(871.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -90, CAST(874.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -88, CAST(876.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -86, CAST(877 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -84, CAST(876 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -82, CAST(873.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -80, CAST(870.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -78, CAST(867 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -76, CAST(863.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -74, CAST(860.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -72, CAST(859.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -70, CAST(859.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -68, CAST(860.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -66, CAST(862.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -64, CAST(865.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -62, CAST(869.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -60, CAST(872.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -58, CAST(875.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -56, CAST(876.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -54, CAST(876.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -52, CAST(875.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -50, CAST(872.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -48, CAST(869.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -46, CAST(866 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -44, CAST(862.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -42, CAST(860.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -40, CAST(859.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -38, CAST(859.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -36, CAST(860.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -34, CAST(863.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -32, CAST(867 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -30, CAST(870.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -28, CAST(873.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -26, CAST(876 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -24, CAST(877 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -22, CAST(876.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -20, CAST(874.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -18, CAST(872 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -16, CAST(868.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -14, CAST(865 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -12, CAST(861.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -10, CAST(859.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -8, CAST(859 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -6, CAST(859.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -4, CAST(861.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -2, CAST(864.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 0, CAST(868 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 2, CAST(871.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 4, CAST(874.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 6, CAST(876.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 8, CAST(877 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 10, CAST(876.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 12, CAST(874.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 14, CAST(871 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 16, CAST(867.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 18, CAST(864 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 20, CAST(861.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 22, CAST(859.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 24, CAST(859 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 26, CAST(860 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 28, CAST(862.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 30, CAST(865.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 32, CAST(869 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 34, CAST(872.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 36, CAST(875.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 38, CAST(876.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 40, CAST(876.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 42, CAST(875.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 44, CAST(873.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 46, CAST(870 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 48, CAST(866.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 50, CAST(863.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 52, CAST(860.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 54, CAST(859.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 56, CAST(859.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 58, CAST(860.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 60, CAST(863.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'STATE', 'YX_ST11_0', -120, CAST(NULL AS NUMERIC(18, 4)), CAST('1' AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'FAULT', '1914', 0, CAST(NULL AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
) v ON 1 = 1
WHERE e.event_code = 'EV1'
  AND NOT EXISTS (
      SELECT 1 FROM t_phm_sim_event_point p
      WHERE p.event_id = e.id AND p.point_type = v.point_type
        AND p.obj_code = v.obj_code AND p.offset_sec = v.offset_sec
  );

INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by)
SELECT (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV1'),
       'S3',
       '成功',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event_answer
    WHERE event_id = (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV1')
      AND step_code = 'S3'
);

INSERT INTO t_phm_sim_event (event_code, fault_rule_id, event_title, expect_outcome, cc, sd, wz, jl, sjxm, fssj, create_by, update_by)
SELECT 'EV2',
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'),
       '2026-10-27 09:05 · 10347 次 · 走向：需要升级',
       '需要升级',
       '10347',
       '38 km/h',
       '某线 K88+150 上行（示意）',
       '丙站—丁站（示意）',
       '李**',
       '2026-10-27 09:05:41',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event
    WHERE event_code = 'EV2'
);

INSERT INTO t_phm_sim_event_point (event_id, point_type, obj_code, offset_sec, num_val, txt_val, create_by, update_by)
SELECT e.id, v.point_type, v.obj_code, v.offset_sec, v.num_val, v.txt_val, 'seed', 'seed'
FROM t_phm_sim_event e
JOIN (
    SELECT 'SERIES' AS point_type, 'YX_SD_SJ' AS obj_code, -120 AS offset_sec,
           CAST(41.1 AS NUMERIC(18, 4)) AS num_val, CAST(NULL AS VARCHAR(64)) AS txt_val
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -118, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -116, CAST(41.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -114, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -112, CAST(42.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -110, CAST(42.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -108, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -106, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -104, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -102, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -100, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -98, CAST(42.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -96, CAST(42.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -94, CAST(42 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -92, CAST(41.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -90, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -88, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -86, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -84, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -82, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -80, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -78, CAST(41.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -76, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -74, CAST(42.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -72, CAST(42.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -70, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -68, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -66, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -64, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -62, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -60, CAST(42.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -58, CAST(42.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -56, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -54, CAST(41.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -52, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -50, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -48, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -46, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -44, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -42, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -40, CAST(41.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -38, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -36, CAST(42.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -34, CAST(42.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -32, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -30, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -28, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -26, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -24, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -22, CAST(42.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -20, CAST(42.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -18, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -16, CAST(41.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -14, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -12, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -10, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -8, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -6, CAST(41.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -4, CAST(41.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -2, CAST(41.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 0, CAST(42 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 2, CAST(40.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 4, CAST(39.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 6, CAST(37.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 8, CAST(36.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 10, CAST(35 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 12, CAST(33.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 14, CAST(32.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 16, CAST(30.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 18, CAST(29.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 20, CAST(28 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 22, CAST(26.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 24, CAST(25.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 26, CAST(23.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 28, CAST(22.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 30, CAST(21 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 32, CAST(19.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 34, CAST(18.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 36, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 38, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 40, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 42, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 44, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 46, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 48, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 50, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 52, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 54, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 56, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 58, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 60, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -120, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -118, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -116, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -114, CAST(42.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -112, CAST(42.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -110, CAST(42 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -108, CAST(41.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -106, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -104, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -102, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -100, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -98, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -96, CAST(41.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -94, CAST(42 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -92, CAST(42.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -90, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -88, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -86, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -84, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -82, CAST(42.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -80, CAST(42.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -78, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -76, CAST(41.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -74, CAST(41.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -72, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -70, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -68, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -66, CAST(41.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -64, CAST(41.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -62, CAST(42.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -60, CAST(42.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -58, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -56, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -54, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -52, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -50, CAST(42.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -48, CAST(42.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -46, CAST(41.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -44, CAST(41.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -42, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -40, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -38, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -36, CAST(41.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -34, CAST(41.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -32, CAST(41.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -30, CAST(42.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -28, CAST(42.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -26, CAST(42.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -24, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -22, CAST(43 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -20, CAST(42.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -18, CAST(42.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -16, CAST(42.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -14, CAST(41.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -12, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -10, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -8, CAST(41 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -6, CAST(41.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -4, CAST(41.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -2, CAST(41.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 0, CAST(42 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 2, CAST(40.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 4, CAST(39.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 6, CAST(37.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 8, CAST(36.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 10, CAST(35 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 12, CAST(33.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 14, CAST(32.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 16, CAST(30.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 18, CAST(29.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 20, CAST(28 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 22, CAST(26.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 24, CAST(25.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 26, CAST(23.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 28, CAST(22.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 30, CAST(21 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 32, CAST(19.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 34, CAST(18.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 36, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 38, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 40, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 42, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 44, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 46, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 48, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 50, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 52, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 54, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 56, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 58, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 60, CAST(18 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -120, CAST(870.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -118, CAST(870.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -116, CAST(869 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -114, CAST(866.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -112, CAST(863.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -110, CAST(860.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -108, CAST(859.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -106, CAST(859.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -104, CAST(860.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -102, CAST(862.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -100, CAST(865.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -98, CAST(868.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -96, CAST(870.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -94, CAST(871 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -92, CAST(870.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -90, CAST(867.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -88, CAST(865.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -86, CAST(862.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -84, CAST(860 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -82, CAST(859 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -80, CAST(859.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -78, CAST(861.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -76, CAST(864.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -74, CAST(867.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -72, CAST(869.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -70, CAST(870.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -68, CAST(870.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -66, CAST(869.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -64, CAST(866.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -62, CAST(863.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -60, CAST(861.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -58, CAST(859.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -56, CAST(859.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -54, CAST(860.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -52, CAST(862.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -50, CAST(865.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -48, CAST(868.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -46, CAST(870.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -44, CAST(871 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -42, CAST(870.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -40, CAST(868.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -38, CAST(865.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -36, CAST(862.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -34, CAST(860.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -32, CAST(859.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -30, CAST(859.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -28, CAST(861.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -26, CAST(863.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -24, CAST(858.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -22, CAST(846.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -20, CAST(834 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -18, CAST(821.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -16, CAST(809.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -14, CAST(796.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -12, CAST(784.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -10, CAST(772 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -8, CAST(759.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -6, CAST(747.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -4, CAST(734.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', -2, CAST(722.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 0, CAST(710 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 2, CAST(697.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 4, CAST(685.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 6, CAST(672.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 8, CAST(660.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 10, CAST(648 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 12, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 14, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 16, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 18, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 20, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 22, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 24, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 26, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 28, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 30, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 32, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 34, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 36, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 38, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 40, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 42, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 44, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 46, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 48, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 50, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 52, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 54, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 56, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 58, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_ZFGYL', 60, CAST(640 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'STATE', 'YX_ST11_0', -120, CAST(NULL AS NUMERIC(18, 4)), CAST('1' AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'STATE', 'YX_ST11_0', 8, CAST(NULL AS NUMERIC(18, 4)), CAST('0' AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'FAULT', '1914', 0, CAST(NULL AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'FAULT', '1902', 6, CAST(NULL AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'FAULT', '1914', 22, CAST(NULL AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
) v ON 1 = 1
WHERE e.event_code = 'EV2'
  AND NOT EXISTS (
      SELECT 1 FROM t_phm_sim_event_point p
      WHERE p.event_id = e.id AND p.point_type = v.point_type
        AND p.obj_code = v.obj_code AND p.offset_sec = v.offset_sec
  );

INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by)
SELECT (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV2'),
       'S3',
       '未成功',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event_answer
    WHERE event_id = (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV2')
      AND step_code = 'S3'
);

INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by)
SELECT (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV2'),
       'S7',
       '不能',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event_answer
    WHERE event_id = (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV2')
      AND step_code = 'S7'
);

INSERT INTO t_phm_sim_event (event_code, fault_rule_id, event_title, expect_outcome, cc, sd, wz, jl, sjxm, fssj, create_by, update_by)
SELECT 'EV3',
       (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'),
       '2026-11-02 18:47 · 23061 次 · 走向：需要升级',
       '需要升级',
       '23061',
       '58 km/h',
       '某线 K203+900 下行（示意）',
       '戊站—己站（示意）',
       '王**',
       '2026-11-02 18:47:05',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event
    WHERE event_code = 'EV3'
);

INSERT INTO t_phm_sim_event_point (event_id, point_type, obj_code, offset_sec, num_val, txt_val, create_by, update_by)
SELECT e.id, v.point_type, v.obj_code, v.offset_sec, v.num_val, v.txt_val, 'seed', 'seed'
FROM t_phm_sim_event e
JOIN (
    SELECT 'SERIES' AS point_type, 'YX_YBDY' AS obj_code, -120 AS offset_sec,
           CAST(24861.2 AS NUMERIC(18, 4)) AS num_val, CAST(NULL AS VARCHAR(64)) AS txt_val
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -118, CAST(24896.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -116, CAST(24936.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -114, CAST(24980 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -112, CAST(25024.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -110, CAST(25067.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -108, CAST(25107.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -106, CAST(25141.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -104, CAST(25169.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -102, CAST(25188.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -100, CAST(25198.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -98, CAST(25198.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -96, CAST(25189.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -94, CAST(25170.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -92, CAST(25143.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -90, CAST(25108.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -88, CAST(25069.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -86, CAST(25026.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -84, CAST(24981.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -82, CAST(24938.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -80, CAST(24897.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -78, CAST(24862.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -76, CAST(24833.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -74, CAST(24813.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -72, CAST(24802.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -70, CAST(24800.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -68, CAST(24808.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -66, CAST(24826.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -64, CAST(24852.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -62, CAST(24886.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -60, CAST(24925.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -58, CAST(24967.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -56, CAST(25012.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -54, CAST(25055.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -52, CAST(25096.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -50, CAST(25133 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -48, CAST(25162.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -46, CAST(25184.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -44, CAST(25196.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -42, CAST(25199.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -40, CAST(25192.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -38, CAST(25176.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -36, CAST(25151.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -34, CAST(25118.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -32, CAST(25080.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -30, CAST(25038.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -28, CAST(24993.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -26, CAST(24950 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -24, CAST(24908.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -22, CAST(24871.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -20, CAST(24841 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -18, CAST(24818.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -16, CAST(24804.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -14, CAST(24800 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -12, CAST(24805.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -10, CAST(24820.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -8, CAST(13503.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -6, CAST(13883.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -4, CAST(14027 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', -2, CAST(13527.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 0, CAST(13800 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 2, CAST(14072.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 4, CAST(13573 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 6, CAST(13716.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 8, CAST(14096.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 10, CAST(13636.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 12, CAST(13639 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 14, CAST(14097.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 16, CAST(13713.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 18, CAST(13574.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 20, CAST(25159 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 22, CAST(25128.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 24, CAST(25091.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 26, CAST(25050 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 28, CAST(25006.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 30, CAST(24961.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 32, CAST(24919.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 34, CAST(24881.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 36, CAST(24848.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 38, CAST(24823.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 40, CAST(24807.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 42, CAST(24800.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 44, CAST(24803.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 46, CAST(24815.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 48, CAST(24837.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 50, CAST(24867 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 52, CAST(24903.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 54, CAST(24944.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 56, CAST(24987.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 58, CAST(25032.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_YBDY', 60, CAST(25074.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -120, CAST(57.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -118, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -116, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -114, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -112, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -110, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -108, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -106, CAST(57.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -104, CAST(57.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -102, CAST(57.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -100, CAST(58.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -98, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -96, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -94, CAST(58.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -92, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -90, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -88, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -86, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -84, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -82, CAST(58.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -80, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -78, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -76, CAST(58.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -74, CAST(57.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -72, CAST(57.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -70, CAST(57.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -68, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -66, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -64, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -62, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -60, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -58, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -56, CAST(57.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -54, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -52, CAST(57.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -50, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -48, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -46, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -44, CAST(58.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -42, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -40, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -38, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -36, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -34, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -32, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -30, CAST(58.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -28, CAST(58.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -26, CAST(58.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -24, CAST(57.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -22, CAST(57.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -20, CAST(57.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -18, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -16, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -14, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -12, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -10, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -8, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -6, CAST(57.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -4, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', -2, CAST(57.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 0, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 2, CAST(58.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 4, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 6, CAST(58.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 8, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 10, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 12, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 14, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 16, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 18, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 20, CAST(58.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 22, CAST(58.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 24, CAST(58.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 26, CAST(57.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 28, CAST(57.6 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 30, CAST(57.4 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 32, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 34, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 36, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 38, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 40, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 42, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 44, CAST(57.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 46, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 48, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 50, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 52, CAST(58.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 54, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 56, CAST(58.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 58, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'SJSD', 60, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -120, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -118, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -116, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -114, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -112, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -110, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -108, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -106, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -104, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -102, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -100, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -98, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -96, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -94, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -92, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -90, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -88, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -86, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -84, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -82, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -80, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -78, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -76, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -74, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -72, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -70, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -68, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -66, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -64, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -62, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -60, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -58, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -56, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -54, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -52, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -50, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -48, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -46, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -44, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -42, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -40, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -38, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -36, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -34, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -32, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -30, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -28, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -26, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -24, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -22, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -20, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -18, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -16, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -14, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -12, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -10, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -8, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -6, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -4, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', -2, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 0, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 2, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 4, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 6, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 8, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 10, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 12, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 14, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 16, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 18, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 20, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 22, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 24, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 26, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 28, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 30, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 32, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 34, CAST(57 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 36, CAST(57.1 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 38, CAST(57.2 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 40, CAST(57.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 42, CAST(57.7 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 44, CAST(58 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 46, CAST(58.3 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 48, CAST(58.5 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 50, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 52, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 54, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 56, CAST(59 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 58, CAST(58.9 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'SERIES', 'YX_SD_SJ', 60, CAST(58.8 AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'STATE', 'YX_ST6_3', -120, CAST(NULL AS NUMERIC(18, 4)), CAST('1' AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'STATE', 'YX_ST8_3', -120, CAST(NULL AS NUMERIC(18, 4)), CAST('0' AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
    UNION ALL
    SELECT 'FAULT', '1873', 0, CAST(NULL AS NUMERIC(18, 4)), CAST(NULL AS VARCHAR(64))
    FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C'
) v ON 1 = 1
WHERE e.event_code = 'EV3'
  AND NOT EXISTS (
      SELECT 1 FROM t_phm_sim_event_point p
      WHERE p.event_id = e.id AND p.point_type = v.point_type
        AND p.obj_code = v.obj_code AND p.offset_sec = v.offset_sec
  );

INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by)
SELECT (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV3'),
       'S7',
       '能',
       'seed',
       'seed'
WHERE NOT EXISTS (
    SELECT 1 FROM t_phm_sim_event_answer
    WHERE event_id = (SELECT id FROM t_phm_sim_event WHERE event_code = 'EV3')
      AND step_code = 'S7'
);

COMMIT;


-- 序列对齐到当前最大主键。FROM 用字典里的一行，避免无 FROM 的 SELECT。

SELECT setval(pg_get_serial_sequence('t_phm_dict_item', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dict_item), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dict_item), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_rule_param_meta', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_param_meta), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_param_meta), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_rule_atom', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_atom), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_atom), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_rule_group', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_group), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_group), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_rule_group_item', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_group_item), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_rule_group_item), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_pre_filter_rule', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_pre_filter_rule), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_pre_filter_rule), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_fault_rule', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_fault_rule), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_fault_rule), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_fault_rule_ref', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_fault_rule_ref), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_fault_rule_ref), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_fault_pre_skip', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_fault_pre_skip), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_fault_pre_skip), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_flow', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_flow), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_flow), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_flow_ver', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_flow_ver), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_flow_ver), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_flow_bind', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_flow_bind), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_flow_bind), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_step', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_step), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_step), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_card', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_card), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_card), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_branch', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_branch), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_branch), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_dispose_confirm', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_confirm), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_dispose_confirm), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_sim_event', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_sim_event), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_sim_event), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_sim_event_point', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_sim_event_point), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_sim_event_point), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';

SELECT setval(pg_get_serial_sequence('t_phm_sim_event_answer', 'id'),
              COALESCE((SELECT MAX(id) FROM t_phm_sim_event_answer), 1),
              COALESCE((SELECT MAX(id) FROM t_phm_sim_event_answer), 0) > 0)
FROM t_phm_dict_item WHERE dict_type = 'CX' AND item_code = 'HXD1C';
