-- =====================================================================================
-- 机车 PHM 故障规则管理工作台 · 示例数据（由原型 V5.1 内嵌 SEED / seed5 自动转换，2026-11-10）
-- 前置：先执行 01_schema.sql。可重复执行：ON CONFLICT (业务唯一键) DO NOTHING，不覆盖人工修改。
-- 外键全部按业务编码子查询取 ID（不写死自增 ID），保留原型业务编码 R001 / G001 / PF_* / FL* / S* / C* / EV*。
-- 注意：ON CONFLICT 为 PG 语法；金仓 Oracle 兼容模式需改 MERGE（见设计 Page 迁移说明）。
-- =====================================================================================
BEGIN;

-- 0. 字典
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'HXD1C', 'HXD1C', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'HXD1D', 'HXD1D', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'HXD2', 'HXD2', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'HXD3C', 'HXD3C', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'HXD3D', 'HXD3D', NULL, NULL, 5, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'FXN5C', 'FXN5C', NULL, NULL, 6, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CX', 'HXN5', 'HXN5', NULL, NULL, 7, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('LY', 'TCMS', 'TCMS', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('LY', '6A', '6A', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RULE_MODE', 'CONDITIONAL', '条件组合判定', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RULE_MODE', 'DIRECT', '直接报出', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RULE_MODE', 'DISABLED', '停用过滤', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RULE_MODE', 'PENDING', '待配置规则', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CZDJ', 'CHECK', '排查', '需按处置流程处置', NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CZDJ', 'WATCH', '关注', '司机留意、地面关注', NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CZDJ', 'NONE', '无需干预', '仅记录，不配处置流程', NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('JKDJ', 'A', 'A', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('JKDJ', 'B', 'B', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('JKDJ', 'C', 'C', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('JKDJ', 'D', 'D', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '==', '==', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '!=', '!=', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '>', '>', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '>=', '>=', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '<', '<', NULL, NULL, 5, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '<=', '<=', NULL, NULL, 6, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', 'IN', 'IN', NULL, NULL, 7, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', 'NOT IN', 'NOT IN', NULL, NULL, 8, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CMP_OP', '=~', '=~ 正则匹配', NULL, NULL, 9, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('WIN_FN', 'allNotExists', '窗口内均未出现', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('WIN_FN', 'anyExists', '窗口内任一出现', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('WIN_FN', 'allExists', '窗口内全部出现', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('WIN_FN', 'anyNotExists', '窗口内不全出现', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STEP_TYPE', 'VIEW', '查看', '查看数据与现场状态，单一下一步', 'roles=EXPERT;branches=下一步', 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STEP_TYPE', 'JUDGE', '判断', '多分支；系统预判，专家确认或改判', 'roles=SYSTEM,EXPERT;branches=是,否', 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STEP_TYPE', 'OP', '操作', '司机执行，专家记录 / 复核；成功 / 未成功两个出口', 'roles=DRIVER,EXPERT;branches=成功,未成功', 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STEP_TYPE', 'CONTACT', '联络上报', '联络调度 / 检修 / 上级，单一下一步', 'roles=EXPERT;branches=已联络', 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STEP_TYPE', 'END', '结束', '给出处置结论，无出口', 'roles=EXPERT;branches=', 5, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('ROLE', 'DRIVER', '司机', '执行', NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('ROLE', 'EXPERT', '专家', '确认 / 记录 / 改判', NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('ROLE', 'SYSTEM', '系统', '预答', NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CONCLUSION', 'MAINTAIN', '维持运行', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CONCLUSION', 'SPEED_LIMIT', '限速运行', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CONCLUSION', 'RESCUE', '请求救援', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CONCLUSION', 'RETURN_DEPOT', '回库处理', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CARD_KIND', 'NUM', '数值窗口统计', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CARD_KIND', 'STATE', '状态量取值', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('CARD_KIND', 'FAULT', '关联故障', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:T0值', 'T0值', NULL, 'card_kind=NUM', 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:最大', '最大', NULL, 'card_kind=NUM', 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:最小', '最小', NULL, 'card_kind=NUM', 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:平均', '平均', NULL, 'card_kind=NUM', 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:首值', '首值', NULL, 'card_kind=NUM', 5, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:末值', '末值', NULL, 'card_kind=NUM', 6, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:变化量', '变化量', NULL, 'card_kind=NUM', 7, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'NUM:越限时长', '越限时长', NULL, 'card_kind=NUM', 8, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'STATE:T0值', 'T0值', NULL, 'card_kind=STATE', 9, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'STATE:变位次数', '变位次数', NULL, 'card_kind=STATE', 10, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'STATE:占用时长', '占用时长', NULL, 'card_kind=STATE', 11, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'STATE:是否出现过', '是否出现过', NULL, 'card_kind=STATE', 12, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'FAULT:出现次数', '出现次数', NULL, 'card_kind=FAULT', 13, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('STAT_ITEM', 'FAULT:T0后再次出现', 'T0后再次出现', NULL, 'card_kind=FAULT', 14, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RUN_INFO', 'CC', '车次', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RUN_INFO', 'SD', '速度', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RUN_INFO', 'WZ', '位置', NULL, NULL, 3, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RUN_INFO', 'JL', '交路', NULL, NULL, 4, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RUN_INFO', 'SJ', '司机', NULL, NULL, 5, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('RUN_INFO', 'FSSJ', '发生时间', NULL, NULL, 6, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('EXEC_TIMING', 'BEFORE_HBASE', '查 HBase 前短路拦截', NULL, NULL, 1, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;
INSERT INTO t_phm_dict_item (dict_type, item_code, item_name, item_desc, ext_val, sort_no, create_by, update_by) VALUES ('EXEC_TIMING', 'AFTER_HBASE', '查 HBase 后拦截', NULL, NULL, 2, 'seed', 'seed') ON CONFLICT (dict_type, item_code) DO NOTHING;

-- 1. 参数元数据
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('CC', '车次', 'STRING', NULL, NULL, 'KAFKA', 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ', 'ALL', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('SJSD', 'LKJ实际速度', 'NUMBER', 'km/h', NULL, 'KAFKA', 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ', 'ALL', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('ZZZT_0', 'LKJ装置降级状态', 'ENUM', NULL, '0:监控;1:降级', 'HBASE_LKJ', 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ', 'ALL', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_ST5_0', 'I端司机室占用', 'ENUM', NULL, '0:未激活;1:激活', 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_ST6_3', '受电弓1(I端)升弓状态', 'ENUM', NULL, '0:未升起;1:升起', 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_ST7_0', 'II端司机室占用', 'ENUM', NULL, '0:未激活;1:激活', 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_ST8_3', '受电弓2(II端)升弓状态', 'ENUM', NULL, '0:未升起;1:升起', 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_ST11_0', '主断闭合状态', 'ENUM', NULL, '0:断开;1:闭合', 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_SD_SJ', 'TCMS实际速度', 'NUMBER', 'km/h', NULL, 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_YBDY', '原边电压', 'NUMBER', 'V', NULL, 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_ZFGYL', '总风缸压力', 'NUMBER', 'kPa', NULL, 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_XDCYL', '蓄电池\控制电源电压', 'NUMBER', 'V', NULL, 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('QY_QYBYQYW1', '牵引变压器油温1(ST)', 'NUMBER', '℃', NULL, 'HBASE_PHM', 'LOCOMOTIVE_ADS:T_PHM_PARAM', 'HXD1,HXD1B,HXD1C,HXD1D,HXD1DJ,HXD2,HXD2B,HXD2C,HXD3,HXD3C,HXD3D,FXD1J,FXD3J', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('TRAIN_STATUS', '机车运用状态', 'ENUM', NULL, '0:运用;1:非运用', 'KAFKA', '事件 / 机车维表', 'ALL', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('IS_ZDX', '是否中大修', 'ENUM', NULL, '0:否;1:是', 'DIM', '事件 / 机车维表', 'ALL', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('CYJ_CYJJYJKWD', '柴油机机油进口温度', 'NUMBER', '℃', NULL, 'HBASE', 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10', 'FXN5C', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('CYJ_GWSJKWD', '高温水进口温度', 'NUMBER', '℃', NULL, 'HBASE', 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10', 'FXN5C', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;
INSERT INTO t_phm_rule_param_meta (param_col, param_name, data_type, unit, enum_dict, data_source, hbase_table, scope_cx, create_by, update_by) VALUES ('YX_JCYXSD', '机车运行速度', 'NUMBER', 'km/h', NULL, 'HBASE', 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10', 'FXN5C', 'seed', 'seed') ON CONFLICT (param_col, hbase_table) DO NOTHING;

-- 2. 共享原子规则
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R001', 'TCMS实际速度 > 0 km/h', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_SD_SJ', '>', '0', NULL, NULL, NULL, 'YX_SD_SJ > 0', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R002', 'LKJ实际速度 > 0 km/h', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'SJSD', '>', '0', NULL, NULL, NULL, 'SJSD > 0', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R003', 'TCMS实际速度 未取到（缺失）', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_SD_SJ', '==', '-', NULL, NULL, NULL, 'YX_SD_SJ == ''-''', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R004', '原边电压 ≥ 15000 V', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_YBDY', '>=', '15000', NULL, NULL, NULL, 'YX_YBDY >= 15000', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R005', '受电弓1(I端)升弓状态 为 升起', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST6_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST6_3', '==', '1', NULL, NULL, NULL, 'YX_ST6_3 == 1', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R006', '受电弓2(II端)升弓状态 为 升起', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST8_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST8_3', '==', '1', NULL, NULL, NULL, 'YX_ST8_3 == 1', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R007', '前后 10 秒内未出现 1874、1875 中任一故障', 'WINDOW', 'HXD1C', NULL, NULL, NULL, NULL, 'allNotExists', 10, '1874,1875', 'allNotExists(10, 1874, 1875)', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R008', 'TCMS实际速度 > 3 km/h', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_SD_SJ', '>', '3', NULL, NULL, NULL, 'YX_SD_SJ > 3', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R009', 'LKJ实际速度 > 3 km/h', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'SJSD', '>', '3', NULL, NULL, NULL, 'SJSD > 3', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R010', '主断闭合状态 为 闭合', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST11_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST11_0', '==', '1', NULL, NULL, NULL, 'YX_ST11_0 == 1', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R011', '前后 10 秒内未出现 1809、1887、1888、1889、1902 中任一故障', 'WINDOW', 'HXD1C', NULL, NULL, NULL, NULL, 'allNotExists', 10, '1809,1887,1888,1889,1902', 'allNotExists(10, 1809, 1887, 1888, 1889, 1902)', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R012', '前后 60 秒内未出现 1031、1742、1790、1836 中任一故障', 'WINDOW', 'HXD1D', NULL, NULL, NULL, NULL, 'allNotExists', 60, '1031,1742,1790,1836', 'allNotExists(60, 1031, 1742, 1790, 1836)', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R013', '柴油机机油进口温度 ≥ 60 ℃', 'PARAM', 'FXN5C', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CYJ_CYJJYJKWD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'), 'CYJ_CYJJYJKWD', '>=', '60', NULL, NULL, NULL, 'CYJ_CYJJYJKWD >= 60', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R014', '高温水进口温度 ≥ 60 ℃', 'PARAM', 'FXN5C', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CYJ_GWSJKWD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'), 'CYJ_GWSJKWD', '>=', '60', NULL, NULL, NULL, 'CYJ_GWSJKWD >= 60', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R015', '机车运行速度 > 0 km/h', 'PARAM', 'FXN5C', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_JCYXSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'), 'YX_JCYXSD', '>', '0', NULL, NULL, NULL, 'YX_JCYXSD > 0', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R016', '机车运行速度 未取到（缺失）', 'PARAM', 'FXN5C', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_JCYXSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_FXN3B_V10'), 'YX_JCYXSD', '==', '-', NULL, NULL, NULL, 'YX_JCYXSD == ''-''', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R017', '正线车次以英文字母开头', 'PARAM', 'HXD3D', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CC' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'CC', '=~', '^[A-Za-z]', NULL, NULL, NULL, 'CC =~ ''^[A-Za-z]''', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R018', '原边电压 ≥ 2000 V', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_YBDY', '>=', '2000', NULL, NULL, NULL, 'YX_YBDY >= 2000', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R019', 'I端司机室占用 为 激活', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST5_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST5_0', '==', '1', NULL, NULL, NULL, 'YX_ST5_0 == 1', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R020', 'II端司机室占用 为 激活', 'PARAM', 'ALL', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST7_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST7_0', '==', '1', NULL, NULL, NULL, 'YX_ST7_0 == 1', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;
INSERT INTO t_phm_rule_atom (atom_code, atom_name, atom_type, scope_cx, param_id, param_col, cmp_op, cmp_val, win_fn, win_sec, rel_gzdm, atom_expr, create_by, update_by) VALUES ('R021', '前后 10 秒内未出现故障 1070', 'WINDOW', 'HXD1C', NULL, NULL, NULL, NULL, 'allNotExists', 10, '1070', 'allNotExists(10, 1070)', 'seed', 'seed') ON CONFLICT (atom_code) DO NOTHING;

-- 3. 命名条件组与成员
INSERT INTO t_phm_rule_group (group_code, group_name, scope_cx, group_expr, expand_expr, group_desc, create_by, update_by) VALUES ('G001', '机车在运行', 'ALL', '(R001 & R002) | (R003 & R002)', '(YX_SD_SJ > 0 & SJSD > 0) | (YX_SD_SJ == ''-'' & SJSD > 0)', 'TCMS实际速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h', 'seed', 'seed') ON CONFLICT (group_code) DO NOTHING;
INSERT INTO t_phm_rule_group (group_code, group_name, scope_cx, group_expr, expand_expr, group_desc, create_by, update_by) VALUES ('G002', '机车速度大于3', 'ALL', '(R008 & R009) | (R003 & R009)', '(YX_SD_SJ > 3 & SJSD > 3) | (YX_SD_SJ == ''-'' & SJSD > 3)', 'TCMS实际速度 > 3 km/h 且 LKJ实际速度 > 3 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 3 km/h', 'seed', 'seed') ON CONFLICT (group_code) DO NOTHING;
INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by) VALUES ((SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'), (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001'), 1, 'seed', 'seed') ON CONFLICT (group_id, atom_id) DO NOTHING;
INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by) VALUES ((SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'), (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'), 2, 'seed', 'seed') ON CONFLICT (group_id, atom_id) DO NOTHING;
INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by) VALUES ((SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'), (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R003'), 3, 'seed', 'seed') ON CONFLICT (group_id, atom_id) DO NOTHING;
INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by) VALUES ((SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'), (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R008'), 1, 'seed', 'seed') ON CONFLICT (group_id, atom_id) DO NOTHING;
INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by) VALUES ((SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'), (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R009'), 2, 'seed', 'seed') ON CONFLICT (group_id, atom_id) DO NOTHING;
INSERT INTO t_phm_rule_group_item (group_id, atom_id, seq_no, create_by, update_by) VALUES ((SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'), (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R003'), 3, 'seed', 'seed') ON CONFLICT (group_id, atom_id) DO NOTHING;

-- 4. 通用前置规则
INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by) VALUES ('PF_TRAIN_STATUS', '仅保留运用状态机车', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'TRAIN_STATUS' AND hbase_table = '事件 / 机车维表'), 'TRAIN_STATUS', '==', '0', 'ALL', 'ALL', 'BEFORE_HBASE', 'TRAIN_STATUS == 0', 10, 0, 'seed', 'seed') ON CONFLICT (filter_code) DO NOTHING;
INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by) VALUES ('PF_LKJ_ZZZT', '排除 LKJ 整备状态', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'ZZZT_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'ZZZT_0', '!=', '1', 'ALL', 'ALL', 'AFTER_HBASE', 'ZZZT_0 != 1', 20, 1, 'seed', 'seed') ON CONFLICT (filter_code) DO NOTHING;
INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by) VALUES ('PF_OVERHAUL', '排除中大修机车', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'IS_ZDX' AND hbase_table = '事件 / 机车维表'), 'IS_ZDX', '==', '0', 'ALL', 'ALL', 'BEFORE_HBASE', 'IS_ZDX == 0', 30, 1, 'seed', 'seed') ON CONFLICT (filter_code) DO NOTHING;
INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by) VALUES ('PF_CC_TEST', '排除测试车次黑名单', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CC' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'CC', 'NOT IN', '8100,8200,8300,8400,8500,8600,8700,8800,8900,11111,22222,77777,8028,8128,8010,8020,8030,8040,8050,8060,8070,8080,8090,8012,8016,8018', 'HXD1C', 'TCMS', 'BEFORE_HBASE', 'CC NOT IN (''8100'', ''8200'', ''8300'', ''8400'', ''8500'', ''8600'', ''8700'', ''8800'', ''8900'', ''11111'', ''22222'', ''77777'', ''8028'', ''8128'', ''8010'', ''8020'', ''8030'', ''8040'', ''8050'', ''8060'', ''8070'', ''8080'', ''8090'', ''8012'', ''8016'', ''8018'')', 40, 1, 'seed', 'seed') ON CONFLICT (filter_code) DO NOTHING;
INSERT INTO t_phm_pre_filter_rule (filter_code, filter_name, param_id, param_col, cmp_op, cmp_val, scope_cx, scope_ly, exec_timing, filter_expr, priority, is_enabled, create_by, update_by) VALUES ('PF_CC6', '排除 6 项特殊车次', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'CC' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'CC', 'NOT IN', '11111,22222,33333,66666,88888,65432', 'HXD1D', 'TCMS', 'BEFORE_HBASE', 'CC NOT IN (''11111'', ''22222'', ''33333'', ''66666'', ''88888'', ''65432'')', 50, 1, 'seed', 'seed') ON CONFLICT (filter_code) DO NOTHING;

-- 5. 故障规则主表 / 引入清单 / 前置豁免
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1C', 'TCMS', '1873', 'ATP电源MCB断开', 'ATP电源MCB断开', 'D', 'CHECK', 'CONDITIONAL', 'A1 & A2 & (A3 | A4) & A5', '((YX_SD_SJ > 0 & SJSD > 0) | (YX_SD_SJ == ''-'' & SJSD > 0)) & YX_YBDY >= 15000 & (YX_ST6_3 == 1 | YX_ST8_3 == 1) & allNotExists(10, 1874, 1875)', '报出故障 1873，需同时满足以下 4 项：
① 机车在运行（满足其一）：TCMS实际速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h
② 原边电压 ≥ 15000 V
③ 满足其一：受电弓1(I端)升弓状态 为 升起 ／ 受电弓2(II端)升弓状态 为 升起
④ 前后 10 秒内未出现 1874、1875 中任一故障', 1, NULL, '辅助系统', NULL, NULL, '低压电器', NULL, NULL, '0', NULL, NULL, '1.排除大中修机车;2.TCMS 故障：速度>0;3.TCMS 基本运行信息：机车速度实际值>0（如获取到）;4.原边电压≥15KV;5.受电弓1或受电弓2已升起;6.前后10s未报1874、1875', '20260814-最新版本', NULL, '102468', '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & ((YX_SD_SJ>0 && SJSD >0) | (YX_SD_SJ==''-'' & SJSD>0)) & YX_YBDY>=15000 & (YX_ST6_3==1|YX_ST8_3==1) & allNotExists([''1874,1875''],10)', '广州局株洲机务段_v8.0_吴东昊_20260814', 'seed', '2026-08-14 09:23:48.514898', 'seed', '2026-08-14 09:23:48.514898') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1C', 'TCMS', '1914', '停放制动隔离塞门关闭', '停放制动隔离塞门关闭', 'D', 'CHECK', 'CONDITIONAL', 'A1 & A2 & A3', '((YX_SD_SJ > 3 & SJSD > 3) | (YX_SD_SJ == ''-'' & SJSD > 3)) & YX_ST11_0 == 1 & allNotExists(10, 1809, 1887, 1888, 1889, 1902)', '报出故障 1914，需同时满足以下 3 项：
① 机车速度大于3（满足其一）：TCMS实际速度 > 3 km/h 且 LKJ实际速度 > 3 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 3 km/h
② 主断闭合状态 为 闭合
③ 前后 10 秒内未出现 1809、1887、1888、1889、1902 中任一故障', 1, NULL, '制动系统', NULL, NULL, '风源系统', NULL, NULL, '0', NULL, NULL, '1.排除大中修机车;2.主断状态闭合;3.TCMS 故障：速度>3;4.TCMS 基本运行信息：机车速度实际值>3;5.前后10秒未出现1809、1887、1888、1889、1902任一故障时报出', '20260814-最新版本', NULL, '102342', '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & ((YX_SD_SJ>3 && SJSD >3) | (YX_SD_SJ==''-'' & SJSD>3)) & YX_ST11_0==1 & allNotExists([''1809,1887,1888,1889,1902''],10)', '广州局株洲机务段_v8.0_吴东昊_20260814', 'seed', '2026-08-14 09:23:48.514898', 'seed', '2026-08-14 09:23:48.514898') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1D', 'TCMS', '1835', '主断环硬线回路断开', NULL, 'D', 'CHECK', 'CONDITIONAL', '(A1 | A2) & A3', '(YX_ST6_3 == 1 | YX_ST8_3 == 1) & allNotExists(60, 1031, 1742, 1790, 1836)', '报出故障 1835，需同时满足以下 2 项：
① 满足其一：受电弓1(I端)升弓状态 为 升起 ／ 受电弓2(II端)升弓状态 为 升起
② 前后 60 秒内未出现 1031、1742、1790、1836 中任一故障', 1, NULL, '高压电器装置', NULL, NULL, '主断路器', NULL, NULL, '0', NULL, NULL, '1.60秒内不报出故障[1031,1742,1790,1836];2.I端受电弓升起状态(YX_ST6_3)=1 OR II端受电弓升起状态(YX_ST8_3)=1;3.非特殊车次:11111,22222,33333,66666,88888,65432;4.装置状态[1-降级,0-监控] != 1;5.上述条件均满足,故障报出;', '1', NULL, '97346', 'CC!=''11111''&CC!=''22222''&CC!=''33333''&CC!=''66666''&CC!=''88888''&CC!=''65432''&ZZZT_0!=''1''&(YX_ST6_3==''1''|YX_ST8_3==''1'')&allNotExists([''1031'',''1742'',''1790'',''1836''],60)', '上海局上海机务段HXD1D_V1.533', 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('FXN5C', 'TCMS', '3816', '柴油机油水温度低，限制8档', '柴油机油水温度低，限制8档', 'D', 'WATCH', 'CONDITIONAL', '(A1 | A2) & ((A3 & A4) | (A5 & A4))', '(CYJ_CYJJYJKWD >= 60 | CYJ_GWSJKWD >= 60) & ((YX_JCYXSD > 0 & SJSD > 0) | (YX_JCYXSD == ''-'' & SJSD > 0))', '报出故障 3816，需同时满足以下 2 项：
① 满足其一：柴油机机油进口温度 ≥ 60 ℃ ／ 高温水进口温度 ≥ 60 ℃
② 满足其一：机车运行速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ 机车运行速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h', 1, NULL, '柴油机系统', NULL, NULL, '油/水系统', NULL, NULL, '0', NULL, NULL, '1.机油进口温度(CYJ_CYJJYJKWD)≥60°或高温水进口温度≥60°，则推送，反之则过滤;2.机车速度取值>0:(微机速度和机车速度_LKJ均大于0) 或者 (微机速度未取到 并且 机车速度_LKJ >0 );', '20260819-最新版本', NULL, '101577', '(CYJ_CYJJYJKWD>=60 | CYJ_GWSJKWD>=60) & ((YX_JCYXSD>0 && SJSD >0) | (YX_JCYXSD==''-'' & SJSD>0))', '上海局上海机务段_v3.0_马晓瑜_20260819', 'seed', '2026-08-19 16:57:25.809100', 'seed', '2026-08-19 16:57:25.809100') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD3D', 'TCMS', '440', 'LG1直流负线接地', NULL, 'D', 'CHECK', 'CONDITIONAL', 'A1', 'CC =~ ''^[A-Za-z]''', '报出故障 440，需同时满足以下 1 项：
① 车次 匹配正则 ^[A-Za-z]', 1, NULL, '辅助系统', NULL, NULL, '列车供电柜', NULL, NULL, '0', NULL, NULL, '正线车次报（首字是字母）;', '1', NULL, '94983', 'CC=~/^[A-Za-z]/', NULL, 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1C', 'TCMS', '1199', '受电弓降下保护', '受电弓降下保护', 'D', 'CHECK', 'CONDITIONAL', 'A1 & (A2 | A3)', 'YX_YBDY >= 2000 & (YX_ST5_0 == 1 | YX_ST7_0 == 1)', '报出故障 1199，需同时满足以下 2 项：
① 原边电压 ≥ 2000 V
② 满足其一：I端司机室占用 为 激活 ／ II端司机室占用 为 激活', 1, NULL, '网侧高压系统', NULL, NULL, '高压电器装置', NULL, NULL, '0', NULL, NULL, '1.排除大中修机车;2.原边电压≥2KV;3.I端司机室占用或II端司机室占用', '20260814-最新版本', NULL, '101985', '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & YX_YBDY>=2000 & (YX_ST5_0==1|YX_ST7_0==1)', '广州局株洲机务段_v8.0_吴东昊_20260814', 'seed', '2026-08-14 09:23:48.514898', 'seed', '2026-08-14 09:23:48.514898') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1C', 'TCMS', '1019', '受电弓1升弓故障', '受电弓1升弓故障-未检测到受电弓升起', 'D', 'WATCH', 'CONDITIONAL', 'A1 & (A2 | A3)', 'YX_YBDY >= 15000 & (YX_ST5_0 == 1 | YX_ST7_0 == 1)', '报出故障 1019，需同时满足以下 2 项：
① 原边电压 ≥ 15000 V
② 满足其一：I端司机室占用 为 激活 ／ II端司机室占用 为 激活', 1, NULL, '网侧高压系统', NULL, NULL, '高压电器装置', NULL, NULL, '0', NULL, NULL, '1.排除大中修机车;2.原边电压≥15KV;3.I端司机室占用或II端司机室占用', '20260814-最新版本', NULL, '101987', '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & YX_YBDY>=15000 & (YX_ST5_0==1|YX_ST7_0==1)', '广州局株洲机务段_v8.0_吴东昊_20260814', 'seed', '2026-08-14 09:23:48.514898', 'seed', '2026-08-14 09:23:48.514898') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1C', 'TCMS', '1071', '变压器油温2故障', '变压器油温2故障', 'D', 'WATCH', 'CONDITIONAL', 'A1', 'allNotExists(10, 1070)', '报出故障 1071，需同时满足以下 1 项：
① 前后 10 秒内未出现故障 1070', 1, NULL, '牵引系统', NULL, NULL, '主变压器', NULL, NULL, '0', NULL, NULL, '1.排除大中修机车;2.没有报变压器油温1故障时报出', '20260814-最新版本', NULL, '101984', '(CC!=8100 & CC!=8200 & CC!=8300 & CC!=8400 & CC!=8500 & CC!=8600 & CC!=8700 & CC!=8800 & CC!=8900 & CC!=11111 & CC!=22222 & CC!=77777 & CC!=8028 & CC!=8128 & CC!=8010 & CC!=8020 & CC!=8030 & CC!=8040 & CC!=8050 & CC!=8060 & CC!=8070 & CC!=8080 & CC!=8090 & CC!=8012 & CC!=8016 & CC!=8018) & allNotExists([''1070''],10)', '广州局株洲机务段_v8.0_吴东昊_20260814', 'seed', '2026-08-14 09:23:48.514898', 'seed', '2026-08-14 09:23:48.514898') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1C', 'TCMS', '1023', '原边电压欠压报警', '原边电压欠压报警', 'A', 'NONE', 'DISABLED', NULL, NULL, '停用过滤：该故障不报出', 0, NULL, '网侧高压系统', NULL, NULL, '高压电器装置', NULL, NULL, '0', NULL, NULL, '不报出', '20260814-最新版本', NULL, '101983', NULL, '广州局株洲机务段_v8.0_吴东昊_20260814', 'seed', '2026-08-14 09:23:48.514898', 'seed', '2026-08-14 09:23:48.514898') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD1D', 'TCMS', '1577', '变流器2M3元件总故障', NULL, 'D', 'WATCH', 'DIRECT', NULL, NULL, '直接报出：收到该故障代码即报出，不做条件判断（仍执行通用前置规则）', 1, NULL, '牵引系统', NULL, NULL, '牵引变流器', NULL, NULL, '0', NULL, NULL, '1.无故障规则条件,直接报出;2.非特殊车次:11111,22222,33333,66666,88888,65432;3.装置状态[1-降级,0-监控] != 1;4.上述条件均满足,故障报出;', '1', NULL, '97184', 'CC!=''11111''&CC!=''22222''&CC!=''33333''&CC!=''66666''&CC!=''88888''&CC!=''65432''&ZZZT_0!=''1''', '上海局上海机务段HXD1D_V1.387', 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('FXN5C', '6A', 'C29A', '2轴4位温升报警', '轴报轮轴驱动装置温升报警', 'C', 'CHECK', 'DIRECT', NULL, NULL, '直接报出：收到该故障代码即报出，不做条件判断（仍执行通用前置规则）', 1, NULL, '轮轴驱动装置', NULL, NULL, '轮轴驱动装置', NULL, NULL, NULL, NULL, NULL, '直接报;', '中车戚墅堰_6A_V1.0', NULL, '103979', '1==1', '中车戚墅堰_6A_V1.0', 'seed', '2026-11-02 10:00:00', 'seed', '2026-11-02 10:00:00') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD2', 'TCMS', '20 01 06', '牵引电机3冷却回路异常', NULL, 'D', 'WATCH', 'CONDITIONAL', 'A1 | A2', 'YX_SD_SJ > 0 | SJSD > 0', '满足以下任一项，即报出故障 20 01 06：
① TCMS实际速度 > 0 km/h
② LKJ实际速度 > 0 km/h', 1, NULL, '通风系统', '012207', 'PJ02352', '牵引通风系统', '01220701', 'PJ02353', '0', NULL, NULL, '速度>0,直接报;', '1', NULL, '97481', '(YX_SD_SJ>0 | SJSD>0)', NULL, 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD3C', 'TCMS', '20', '车体通风机1故障', NULL, 'D', 'NONE', 'PENDING', NULL, NULL, '待配置规则', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, '清洗;', '1', '为从零配置体验暂置待配置；原始底账与规则保留在溯源中。', '103321', NULL, NULL, 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXN5', 'TCMS', '19-4013', '4位牵引电机锁轴', '4位牵引电机锁轴', 'D', 'CHECK', 'PENDING', NULL, NULL, '待配置规则', 0, NULL, '牵引系统', NULL, NULL, '牵引电机', NULL, NULL, NULL, NULL, NULL, '直接报;', '1', '为从零配置体验暂置待配置；原始底账与规则保留在溯源中。', '103931', '1==1', '哈局哈尔滨机务段HXN5_V1.0', 'seed', '2026-10-28 10:00:00', 'seed', '2026-10-28 10:00:00') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD3D', 'TCMS', '169', 'CI5 PG输出异常', NULL, 'D', 'WATCH', 'DIRECT', NULL, NULL, '直接报出：收到该故障代码即报出，不做条件判断（仍执行通用前置规则）', 1, NULL, '牵引系统', NULL, NULL, '牵引变流器', NULL, NULL, '0', NULL, NULL, '直接报;', '1', NULL, '93520', '1==1', NULL, 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule (cx, ly, gzdm, gzmc, mxmc, jkdj, czdj, rule_mode, rule_expr, fault_rule, rule_desc, is_enabled, ljdm, ssxt, xtbm, xtpjm, ssbj, bjbm, bjpjm, sjlx, gzms, mxgzzs, description, version, config_note, src_rule_ids, legacy_logic_expr, remark, create_by, create_time, update_by, update_time) VALUES ('HXD2', 'TCMS', '20 00 24', '逆变器3故障', NULL, 'D', 'WATCH', 'CONDITIONAL', 'A1 | A2', 'YX_SD_SJ > 0 | SJSD > 0', '满足以下任一项，即报出故障 20 00 24：
① TCMS实际速度 > 0 km/h
② LKJ实际速度 > 0 km/h', 1, NULL, '牵引系统', '012204', 'PJ01308', '牵引变流器2', NULL, NULL, '0', NULL, NULL, '速度>0,直接报;', '1', NULL, '97351', '(YX_SD_SJ>0 | SJSD>0)', NULL, 'seed', '2026-03-30 17:11:57.528082', 'seed', '2026-03-30 17:11:57.528082') ON CONFLICT (cx, ly, gzdm) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), 1, 'GROUP', NULL, (SELECT id FROM t_phm_rule_group WHERE group_code = 'G001'), 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R004'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), 3, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R005'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), 4, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R006'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), 5, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R007'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'), 1, 'GROUP', NULL, (SELECT id FROM t_phm_rule_group WHERE group_code = 'G002'), 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R010'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'), 3, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R011'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R005'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R006'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'), 3, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R012'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R013'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R014'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'), 3, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R015'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'), 4, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'), 5, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R016'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD3D' AND ly = 'TCMS' AND gzdm = '440'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R017'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R018'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R019'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'), 3, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R020'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R004'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R019'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1019'), 3, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R020'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1071'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R021'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 01 06'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 01 06'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 00 24'), 1, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R001'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_rule_ref (fault_rule_id, seq_no, ref_type, atom_id, group_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD2' AND ly = 'TCMS' AND gzdm = '20 00 24'), 2, 'ATOM', (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R002'), NULL, 'seed', 'seed') ON CONFLICT (fault_rule_id, seq_no) DO NOTHING;
INSERT INTO t_phm_fault_pre_skip (fault_rule_id, filter_id, skip_reason, create_by, update_by) VALUES ((SELECT id FROM t_phm_fault_rule WHERE cx = 'FXN5C' AND ly = 'TCMS' AND gzdm = '3816'), (SELECT id FROM t_phm_pre_filter_rule WHERE filter_code = 'PF_LKJ_ZZZT'), '原规则体无 LKJ 整备状态条件（原型演示的单条豁免）', 'seed', 'seed') ON CONFLICT (fault_rule_id, filter_id) DO NOTHING;

-- 6. 处置流程：流程头 / 版本 / 绑定 / 步骤 / 数据卡 / 分支 / 确认项
INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time) VALUES ('FL1914', '停放制动隔离塞门关闭 处置流程', 0, 'PUBLISHED', 1, 1, '示例内容，非正式规程，需按实际司机手册校核', 'seed', '2026-11-08 16:20:00', 'seed', '2026-11-08 16:20:00') ON CONFLICT (flow_code) DO NOTHING;
INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1914'), 1, 'PUBLISHED', 0, '停放制动隔离塞门关闭 处置流程', 60, 30, 'CC,SD,WZ,SJ,FSSJ', 'seed', '2026-11-08 16:20:00', 'seed', '2026-11-08 16:20:00', 'seed', '2026-11-08 16:20:00') ON CONFLICT (flow_id, ver_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1914'), (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'), 'seed', 'seed') ON CONFLICT (fault_rule_id) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S1', 1, 'VIEW', '查看运行状态与报警前后数据', '以报警时刻 T0 为锚点，查看速度、主断状态及关联制动故障，判断报警时机车是否在运行中。', 'EXPERT', NULL, '司机手册 · 制动系统 · 停放制动（条目待校核）', NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S2', 2, 'JUDGE', '总风缸风压是否正常？', '系统按窗口内总风缸压力最小值预判，专家结合曲线确认或改判。', 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S3', 3, 'OP', '停车后检查停放制动隔离塞门并恢复', '具备条件时停车，做好防溜后检查塞门位置，将其恢复至开通位并做停放制动试验。', 'DRIVER,EXPERT', '下车作业前须确认机车停稳并做好防溜，按规定联系与防护。', '司机手册 · 制动柜塞门（条目待校核）', '停车防溜 → 检查制动柜停放制动隔离塞门 → 恢复开通位 → 施加 / 缓解试验，结果电话报告专家', NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S4', 4, 'JUDGE', '故障是否消除？', '系统检查 T0 后是否再次报 1914，专家确认。', 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S5', 5, 'END', '故障消除，维持运行', '记录处置过程，回段后复核塞门状态。', 'EXPERT', NULL, NULL, NULL, 'MAINTAIN', 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S6', 6, 'CONTACT', '联络调度与检修，上报处置情况', '专家将数据与处置经过上报调度和检修部门，商定后续运行方式。', 'EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S7', 7, 'JUDGE', '能否限速维持运行至前方站？', '人工判断：结合风压、制动表现与调度意见。', 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S8', 8, 'END', '限速运行，回库处理', '限速运行至前方站后回库，推送检修提示。', 'EXPERT', NULL, NULL, NULL, 'SPEED_LIMIT', 1, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1), 'S9', 9, 'END', '停车请求救援', NULL, 'EXPERT', NULL, NULL, NULL, 'RESCUE', 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C1', 1, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_SD_SJ' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_SD_SJ', NULL, 60, 30, 'T0值,最大,最小', 1, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C2', 2, 'STATE', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST11_0' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST11_0', NULL, 60, 30, 'T0值,变位次数', 0, NULL, NULL, '1', 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C3', 3, 'FAULT', NULL, NULL, '1809,1887,1888,1889,1902', 60, 30, '出现次数', 0, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'), 'C1', 1, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ZFGYL' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ZFGYL', NULL, 60, 30, 'T0值,最小,平均,越限时长', 1, '<', '750', NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'), 'C1', 1, 'FAULT', NULL, NULL, '1914', 0, 30, '出现次数,T0后再次出现', 0, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S1'), 1, '下一步', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'), 1, '正常', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'), 'CARD', (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2') AND c.card_code = 'C1'), '最小', '>=', '750', NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S2'), 2, '异常', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'), 'ELSE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '未成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'), 1, '已消除', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S5'), 'CARD', (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4') AND c.card_code = 'C1'), 'T0后再次出现', '==', '0', NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S4'), 2, '未消除', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'), 'ELSE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S6'), 1, '已联络', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7'), 1, '能', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S8'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S7'), 2, '不能', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S9'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '机车已停稳并做好防溜', 'DRIVER', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '塞门已恢复开通位，施加 / 缓解试验正常', 'DRIVER', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1914' AND v.ver_no = 1) AND s.step_code = 'S3'), 3, '专家已记录司机反馈', 'EXPERT', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time) VALUES ('FL1873', 'ATP 电源 MCB 断开 处置流程', 0, 'DRAFT', 0, 1, '示例内容，非正式规程，需按实际司机手册校核', 'seed', '2026-11-09 10:05:00', 'seed', '2026-11-09 10:05:00') ON CONFLICT (flow_code) DO NOTHING;
INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1873'), 1, 'DRAFT', 0, 'ATP 电源 MCB 断开 处置流程', 60, 30, 'CC,SD,WZ,SJ,FSSJ', NULL, NULL, 'seed', '2026-11-09 10:05:00', 'seed', '2026-11-09 10:05:00') ON CONFLICT (flow_id, ver_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1873'), (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), 'seed', 'seed') ON CONFLICT (fault_rule_id) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S1', 1, 'VIEW', '查看运行状态与网侧供电', '查看原边电压、受电弓状态与速度，确认报警时机车处于受电运行。', 'EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S2', 2, 'JUDGE', '网侧供电是否正常？', '复用原子规则「原边电压 ≥ 15000 V」做系统预判。', 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S3', 3, 'OP', '检查并闭合 ATP 电源 MCB（仅一次）', NULL, 'DRIVER,EXPERT', 'MCB 再次跳开时不得反复闭合。', NULL, '在保证行车安全前提下检查低压柜 ATP 电源 MCB，闭合一次并观察 ATP 自检', NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S4', 4, 'JUDGE', 'ATP 是否恢复？', NULL, 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S5', 5, 'END', 'ATP 恢复，维持运行', NULL, 'EXPERT', NULL, NULL, NULL, 'MAINTAIN', 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S6', 6, 'CONTACT', '联络调度，按 ATP 故障行车办理', NULL, 'EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S7', 7, 'JUDGE', '能否按规定限速运行？', NULL, 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S8', 8, 'END', '限速运行，回库处理', NULL, 'EXPERT', NULL, NULL, NULL, 'SPEED_LIMIT', 1, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1), 'S9', 9, 'END', '请求救援', NULL, 'EXPERT', NULL, NULL, NULL, 'RESCUE', 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C1', 1, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_YBDY', NULL, 60, 30, 'T0值,最小,平均', 1, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C2', 2, 'STATE', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST6_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST6_3', NULL, 60, 30, 'T0值,变位次数', 0, NULL, NULL, '1', 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C3', 3, 'STATE', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST8_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST8_3', NULL, 60, 30, 'T0值', 0, NULL, NULL, '1', 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C4', 4, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'SJSD', NULL, 60, 30, 'T0值,最大', 1, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'), 'C1', 1, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_YBDY', NULL, 60, 30, '最小,越限时长', 1, '<', '15000', NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'), 'C1', 1, 'FAULT', NULL, NULL, '1873', 0, 30, 'T0后再次出现', 0, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S1'), 1, '下一步', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'), 1, '正常', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'), 'ATOM', NULL, NULL, NULL, NULL, (SELECT id FROM t_phm_rule_atom WHERE atom_code = 'R004'), NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S2'), 2, '异常', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'), 'ELSE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '未成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'), 1, '已恢复', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S5'), 'CARD', (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4') AND c.card_code = 'C1'), 'T0后再次出现', '==', '0', NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S4'), 2, '未恢复', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'), 'ELSE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S6'), 1, '已联络', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7'), 1, '能', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S8'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S7'), 2, '不能', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S9'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, 'MCB 已闭合一次，未再跳开', 'DRIVER', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, 'ATP 自检通过', 'DRIVER', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1873' AND v.ver_no = 1) AND s.step_code = 'S3'), 3, '专家已记录', 'EXPERT', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time) VALUES ('FT01', '电器类断路 / 跳闸通用处置', 1, 'PUBLISHED', 1, 1, '示例内容，非正式规程，需按实际司机手册校核', 'seed', '2026-11-07 09:12:00', 'seed', '2026-11-07 09:12:00') ON CONFLICT (flow_code) DO NOTHING;
INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01'), 1, 'PUBLISHED', 0, '电器类断路 / 跳闸通用处置', 60, 30, 'CC,SD,WZ,SJ,FSSJ', 'seed', '2026-11-07 09:12:00', 'seed', '2026-11-07 09:12:00', 'seed', '2026-11-07 09:12:00') ON CONFLICT (flow_id, ver_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01'), (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1D' AND ly = 'TCMS' AND gzdm = '1835'), 'seed', 'seed') ON CONFLICT (fault_rule_id) DO NOTHING;
INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FT01'), (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD3D' AND ly = 'TCMS' AND gzdm = '440'), 'seed', 'seed') ON CONFLICT (fault_rule_id) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S1', 1, 'VIEW', '查看报警前后运行状态', NULL, 'EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S2', 2, 'JUDGE', '相关设备是否已断开 / 跳闸？', '人工判断：专家结合显示屏与司机通话确认。', 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S3', 3, 'OP', '按规定复位 / 闭合一次', NULL, 'DRIVER,EXPERT', '复位后再次跳开不得反复操作。', NULL, '按专家指导复位 / 闭合一次，观察是否保持', NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S4', 4, 'JUDGE', '故障是否消除？', NULL, 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S5', 5, 'CONTACT', '联络调度与检修', NULL, 'EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S6', 6, 'END', '维持运行', NULL, 'EXPERT', NULL, NULL, NULL, 'MAINTAIN', 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1), 'S7', 7, 'END', '回库处理', NULL, 'EXPERT', NULL, NULL, NULL, 'RETURN_DEPOT', 1, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C1', 1, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'SJSD' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAMS_LKJ'), 'SJSD', NULL, 60, 30, 'T0值,最大,最小', 1, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S1'), 1, '下一步', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2'), 1, '是', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S2'), 2, '否', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '未成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4'), 1, '已消除', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S6'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S4'), 2, '未消除', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S5'), 1, '已联络', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S7'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '司机已按指令执行并反馈结果', 'DRIVER', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FT01' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '专家已记录 / 复核司机反馈', 'EXPERT', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow (flow_code, flow_name, is_template, flow_status, pub_ver_no, is_sample, sample_note, create_by, create_time, update_by, update_time) VALUES ('FL1199', '受电弓降下保护 简版', 0, 'DRAFT', 0, 1, '示例内容，非正式规程，需按实际司机手册校核', 'seed', '2026-11-09 11:30:00', 'seed', '2026-11-09 11:30:00') ON CONFLICT (flow_code) DO NOTHING;
INSERT INTO t_phm_dispose_flow_ver (flow_id, ver_no, ver_status, base_ver_no, flow_name, win_pre_sec, win_post_sec, run_info_cols, publish_by, publish_time, create_by, create_time, update_by, update_time) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1199'), 1, 'DRAFT', 0, '受电弓降下保护 简版', 60, 30, 'CC,SD,WZ,SJ,FSSJ', NULL, NULL, 'seed', '2026-11-09 11:30:00', 'seed', '2026-11-09 11:30:00') ON CONFLICT (flow_id, ver_no) DO NOTHING;
INSERT INTO t_phm_dispose_flow_bind (flow_id, fault_rule_id, create_by, update_by) VALUES ((SELECT id FROM t_phm_dispose_flow WHERE flow_code = 'FL1199'), (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1199'), 'seed', 'seed') ON CONFLICT (fault_rule_id) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1), 'S1', 1, 'VIEW', '查看受电弓与网压', NULL, 'EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1), 'S2', 2, 'JUDGE', '网压是否正常？', NULL, 'SYSTEM,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1), 'S3', 3, 'OP', '按规定重新升弓一次', NULL, 'DRIVER,EXPERT', NULL, NULL, NULL, NULL, 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1), 'S4', 4, 'END', '维持运行', NULL, 'EXPERT', NULL, NULL, NULL, 'MAINTAIN', 0, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_step (flow_ver_id, step_code, seq_no, step_type, step_title, step_desc, role_codes, safety_tip, manual_ref, driver_action, conclusion, push_repair, create_by, update_by) VALUES ((SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1), 'S5', 5, 'END', '回库处理', NULL, 'EXPERT', NULL, NULL, NULL, 'RETURN_DEPOT', 1, 'seed', 'seed') ON CONFLICT (flow_ver_id, step_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C1', 1, 'STATE', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_ST6_3' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_ST6_3', NULL, 60, 30, 'T0值,变位次数', 0, NULL, NULL, '1', 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1'), 'C2', 2, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_YBDY', NULL, 60, 30, 'T0值,最小', 1, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_card (step_id, card_code, seq_no, card_kind, param_id, param_col, rel_gzdm, win_pre_sec, win_post_sec, stat_items, show_curve, limit_op, limit_val, target_val, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'), 'C1', 1, 'NUM', (SELECT id FROM t_phm_rule_param_meta WHERE param_col = 'YX_YBDY' AND hbase_table = 'LOCOMOTIVE_ADS:T_PHM_PARAM'), 'YX_YBDY', NULL, 60, 30, '最小', 1, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, card_code) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S1'), 1, '下一步', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'), 1, '正常', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'), 'CARD', (SELECT c.id FROM t_phm_dispose_card c WHERE c.step_id = (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2') AND c.card_code = 'C1'), '最小', '>=', '17500', NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S2'), 2, '异常', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S5'), 'ELSE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S4'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_branch (step_id, seq_no, branch_label, next_step_id, cond_src, cond_card_id, cond_stat, cond_op, cond_val, cond_atom_id, cond_group_id, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '未成功', (SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S5'), 'NONE', NULL, NULL, NULL, NULL, NULL, NULL, 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'), 1, '司机已按指令执行并反馈结果', 'DRIVER', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;
INSERT INTO t_phm_dispose_confirm (step_id, seq_no, confirm_text, role_code, create_by, update_by) VALUES ((SELECT s.id FROM t_phm_dispose_step s WHERE s.flow_ver_id = (SELECT v.id FROM t_phm_dispose_flow_ver v JOIN t_phm_dispose_flow f ON f.id = v.flow_id WHERE f.flow_code = 'FL1199' AND v.ver_no = 1) AND s.step_code = 'S3'), 2, '专家已记录 / 复核司机反馈', 'EXPERT', 'seed', 'seed') ON CONFLICT (step_id, seq_no) DO NOTHING;

-- 7. 模拟历史事件
INSERT INTO t_phm_sim_event (event_code, fault_rule_id, event_title, expect_outcome, cc, sd, wz, jl, sjxm, fssj, create_by, update_by) VALUES ('EV1', (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'), '2026-10-21 14:32 · 27015 次 · 走向：正常消除', '正常消除', '27015', '46 km/h', '某线 K136+420 下行（示意）', '甲站—乙站（示意）', '张**', '2026-10-21 14:32:18', 'seed', 'seed') ON CONFLICT (event_code) DO NOTHING;
INSERT INTO t_phm_sim_event_point (event_id, point_type, obj_code, offset_sec, num_val, txt_val, create_by, update_by)
SELECT e.id, v.point_type, v.obj_code, v.offset_sec, CAST(v.num_val AS NUMERIC(18, 4)), CAST(v.txt_val AS VARCHAR(64)), 'seed', 'seed'
FROM t_phm_sim_event e, (VALUES
  ('SERIES', 'YX_SD_SJ', -120, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', -118, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', -116, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', -114, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', -112, 46.5, NULL),
  ('SERIES', 'YX_SD_SJ', -110, 46, NULL),
  ('SERIES', 'YX_SD_SJ', -108, 45.6, NULL),
  ('SERIES', 'YX_SD_SJ', -106, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', -104, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', -102, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', -100, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', -98, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', -96, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', -94, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', -92, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', -90, 45.5, NULL),
  ('SERIES', 'YX_SD_SJ', -88, 46, NULL),
  ('SERIES', 'YX_SD_SJ', -86, 46.4, NULL),
  ('SERIES', 'YX_SD_SJ', -84, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', -82, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', -80, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', -78, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', -76, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', -74, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', -72, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', -70, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', -68, 46.5, NULL),
  ('SERIES', 'YX_SD_SJ', -66, 46, NULL),
  ('SERIES', 'YX_SD_SJ', -64, 45.6, NULL),
  ('SERIES', 'YX_SD_SJ', -62, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', -60, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', -58, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', -56, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', -54, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', -52, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', -50, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', -48, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', -46, 45.5, NULL),
  ('SERIES', 'YX_SD_SJ', -44, 46, NULL),
  ('SERIES', 'YX_SD_SJ', -42, 46.4, NULL),
  ('SERIES', 'YX_SD_SJ', -40, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', -38, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', -36, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', -34, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', -32, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', -30, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', -28, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', -26, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', -24, 46.5, NULL),
  ('SERIES', 'YX_SD_SJ', -22, 46, NULL),
  ('SERIES', 'YX_SD_SJ', -20, 45.6, NULL),
  ('SERIES', 'YX_SD_SJ', -18, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', -16, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', -14, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', -12, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', -10, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', -8, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', -6, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', -4, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', -2, 45.5, NULL),
  ('SERIES', 'YX_SD_SJ', 0, 46, NULL),
  ('SERIES', 'YX_SD_SJ', 2, 46.5, NULL),
  ('SERIES', 'YX_SD_SJ', 4, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', 6, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', 8, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', 10, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', 12, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', 14, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', 16, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', 18, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', 20, 46.4, NULL),
  ('SERIES', 'YX_SD_SJ', 22, 46, NULL),
  ('SERIES', 'YX_SD_SJ', 24, 45.5, NULL),
  ('SERIES', 'YX_SD_SJ', 26, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', 28, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', 30, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', 32, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', 34, 44.4, NULL),
  ('SERIES', 'YX_SD_SJ', 36, 44.5, NULL),
  ('SERIES', 'YX_SD_SJ', 38, 44.8, NULL),
  ('SERIES', 'YX_SD_SJ', 40, 45.1, NULL),
  ('SERIES', 'YX_SD_SJ', 42, 45.6, NULL),
  ('SERIES', 'YX_SD_SJ', 44, 46, NULL),
  ('SERIES', 'YX_SD_SJ', 46, 46.5, NULL),
  ('SERIES', 'YX_SD_SJ', 48, 46.9, NULL),
  ('SERIES', 'YX_SD_SJ', 50, 47.2, NULL),
  ('SERIES', 'YX_SD_SJ', 52, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', 54, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', 56, 47.6, NULL),
  ('SERIES', 'YX_SD_SJ', 58, 47.5, NULL),
  ('SERIES', 'YX_SD_SJ', 60, 47.2, NULL),
  ('SERIES', 'SJSD', -120, 45.8, NULL),
  ('SERIES', 'SJSD', -118, 46.2, NULL),
  ('SERIES', 'SJSD', -116, 46.6, NULL),
  ('SERIES', 'SJSD', -114, 46.9, NULL),
  ('SERIES', 'SJSD', -112, 47.1, NULL),
  ('SERIES', 'SJSD', -110, 47.2, NULL),
  ('SERIES', 'SJSD', -108, 47.2, NULL),
  ('SERIES', 'SJSD', -106, 47, NULL),
  ('SERIES', 'SJSD', -104, 46.7, NULL),
  ('SERIES', 'SJSD', -102, 46.3, NULL),
  ('SERIES', 'SJSD', -100, 46, NULL),
  ('SERIES', 'SJSD', -98, 45.6, NULL),
  ('SERIES', 'SJSD', -96, 45.2, NULL),
  ('SERIES', 'SJSD', -94, 45, NULL),
  ('SERIES', 'SJSD', -92, 44.8, NULL),
  ('SERIES', 'SJSD', -90, 44.8, NULL),
  ('SERIES', 'SJSD', -88, 44.9, NULL),
  ('SERIES', 'SJSD', -86, 45.2, NULL),
  ('SERIES', 'SJSD', -84, 45.5, NULL),
  ('SERIES', 'SJSD', -82, 45.9, NULL),
  ('SERIES', 'SJSD', -80, 46.3, NULL),
  ('SERIES', 'SJSD', -78, 46.6, NULL),
  ('SERIES', 'SJSD', -76, 46.9, NULL),
  ('SERIES', 'SJSD', -74, 47.1, NULL),
  ('SERIES', 'SJSD', -72, 47.2, NULL),
  ('SERIES', 'SJSD', -70, 47.1, NULL),
  ('SERIES', 'SJSD', -68, 46.9, NULL),
  ('SERIES', 'SJSD', -66, 46.7, NULL),
  ('SERIES', 'SJSD', -64, 46.3, NULL),
  ('SERIES', 'SJSD', -62, 45.9, NULL),
  ('SERIES', 'SJSD', -60, 45.5, NULL),
  ('SERIES', 'SJSD', -58, 45.2, NULL),
  ('SERIES', 'SJSD', -56, 44.9, NULL),
  ('SERIES', 'SJSD', -54, 44.8, NULL),
  ('SERIES', 'SJSD', -52, 44.8, NULL),
  ('SERIES', 'SJSD', -50, 45, NULL),
  ('SERIES', 'SJSD', -48, 45.2, NULL),
  ('SERIES', 'SJSD', -46, 45.6, NULL),
  ('SERIES', 'SJSD', -44, 45.9, NULL),
  ('SERIES', 'SJSD', -42, 46.3, NULL),
  ('SERIES', 'SJSD', -40, 46.7, NULL),
  ('SERIES', 'SJSD', -38, 47, NULL),
  ('SERIES', 'SJSD', -36, 47.2, NULL),
  ('SERIES', 'SJSD', -34, 47.2, NULL),
  ('SERIES', 'SJSD', -32, 47.1, NULL),
  ('SERIES', 'SJSD', -30, 46.9, NULL),
  ('SERIES', 'SJSD', -28, 46.6, NULL),
  ('SERIES', 'SJSD', -26, 46.2, NULL),
  ('SERIES', 'SJSD', -24, 45.8, NULL),
  ('SERIES', 'SJSD', -22, 45.5, NULL),
  ('SERIES', 'SJSD', -20, 45.1, NULL),
  ('SERIES', 'SJSD', -18, 44.9, NULL),
  ('SERIES', 'SJSD', -16, 44.8, NULL),
  ('SERIES', 'SJSD', -14, 44.8, NULL),
  ('SERIES', 'SJSD', -12, 45, NULL),
  ('SERIES', 'SJSD', -10, 45.3, NULL),
  ('SERIES', 'SJSD', -8, 45.6, NULL),
  ('SERIES', 'SJSD', -6, 46, NULL),
  ('SERIES', 'SJSD', -4, 46.4, NULL),
  ('SERIES', 'SJSD', -2, 46.7, NULL),
  ('SERIES', 'SJSD', 0, 47, NULL),
  ('SERIES', 'SJSD', 2, 47.2, NULL),
  ('SERIES', 'SJSD', 4, 47.2, NULL),
  ('SERIES', 'SJSD', 6, 47.1, NULL),
  ('SERIES', 'SJSD', 8, 46.9, NULL),
  ('SERIES', 'SJSD', 10, 46.5, NULL),
  ('SERIES', 'SJSD', 12, 46.2, NULL),
  ('SERIES', 'SJSD', 14, 45.8, NULL),
  ('SERIES', 'SJSD', 16, 45.4, NULL),
  ('SERIES', 'SJSD', 18, 45.1, NULL),
  ('SERIES', 'SJSD', 20, 44.9, NULL),
  ('SERIES', 'SJSD', 22, 44.8, NULL),
  ('SERIES', 'SJSD', 24, 44.8, NULL),
  ('SERIES', 'SJSD', 26, 45, NULL),
  ('SERIES', 'SJSD', 28, 45.3, NULL),
  ('SERIES', 'SJSD', 30, 45.7, NULL),
  ('SERIES', 'SJSD', 32, 46.1, NULL),
  ('SERIES', 'SJSD', 34, 46.4, NULL),
  ('SERIES', 'SJSD', 36, 46.8, NULL),
  ('SERIES', 'SJSD', 38, 47, NULL),
  ('SERIES', 'SJSD', 40, 47.2, NULL),
  ('SERIES', 'SJSD', 42, 47.2, NULL),
  ('SERIES', 'SJSD', 44, 47.1, NULL),
  ('SERIES', 'SJSD', 46, 46.8, NULL),
  ('SERIES', 'SJSD', 48, 46.5, NULL),
  ('SERIES', 'SJSD', 50, 46.1, NULL),
  ('SERIES', 'SJSD', 52, 45.7, NULL),
  ('SERIES', 'SJSD', 54, 45.3, NULL),
  ('SERIES', 'SJSD', 56, 45.1, NULL),
  ('SERIES', 'SJSD', 58, 44.9, NULL),
  ('SERIES', 'SJSD', 60, 44.8, NULL),
  ('SERIES', 'YX_ZFGYL', -120, 876.2, NULL),
  ('SERIES', 'YX_ZFGYL', -118, 877, NULL),
  ('SERIES', 'YX_ZFGYL', -116, 876.4, NULL),
  ('SERIES', 'YX_ZFGYL', -114, 874.5, NULL),
  ('SERIES', 'YX_ZFGYL', -112, 871.6, NULL),
  ('SERIES', 'YX_ZFGYL', -110, 868.1, NULL),
  ('SERIES', 'YX_ZFGYL', -108, 864.6, NULL),
  ('SERIES', 'YX_ZFGYL', -106, 861.6, NULL),
  ('SERIES', 'YX_ZFGYL', -104, 859.6, NULL),
  ('SERIES', 'YX_ZFGYL', -102, 859, NULL),
  ('SERIES', 'YX_ZFGYL', -100, 859.8, NULL),
  ('SERIES', 'YX_ZFGYL', -98, 861.9, NULL),
  ('SERIES', 'YX_ZFGYL', -96, 864.9, NULL),
  ('SERIES', 'YX_ZFGYL', -94, 868.4, NULL),
  ('SERIES', 'YX_ZFGYL', -92, 871.9, NULL),
  ('SERIES', 'YX_ZFGYL', -90, 874.8, NULL),
  ('SERIES', 'YX_ZFGYL', -88, 876.5, NULL),
  ('SERIES', 'YX_ZFGYL', -86, 877, NULL),
  ('SERIES', 'YX_ZFGYL', -84, 876, NULL),
  ('SERIES', 'YX_ZFGYL', -82, 873.7, NULL),
  ('SERIES', 'YX_ZFGYL', -80, 870.6, NULL),
  ('SERIES', 'YX_ZFGYL', -78, 867, NULL),
  ('SERIES', 'YX_ZFGYL', -76, 863.6, NULL),
  ('SERIES', 'YX_ZFGYL', -74, 860.9, NULL),
  ('SERIES', 'YX_ZFGYL', -72, 859.3, NULL),
  ('SERIES', 'YX_ZFGYL', -70, 859.1, NULL),
  ('SERIES', 'YX_ZFGYL', -68, 860.3, NULL),
  ('SERIES', 'YX_ZFGYL', -66, 862.7, NULL),
  ('SERIES', 'YX_ZFGYL', -64, 865.9, NULL),
  ('SERIES', 'YX_ZFGYL', -62, 869.5, NULL),
  ('SERIES', 'YX_ZFGYL', -60, 872.8, NULL),
  ('SERIES', 'YX_ZFGYL', -58, 875.4, NULL),
  ('SERIES', 'YX_ZFGYL', -56, 876.8, NULL),
  ('SERIES', 'YX_ZFGYL', -54, 876.8, NULL),
  ('SERIES', 'YX_ZFGYL', -52, 875.5, NULL),
  ('SERIES', 'YX_ZFGYL', -50, 872.9, NULL),
  ('SERIES', 'YX_ZFGYL', -48, 869.6, NULL),
  ('SERIES', 'YX_ZFGYL', -46, 866, NULL),
  ('SERIES', 'YX_ZFGYL', -44, 862.7, NULL),
  ('SERIES', 'YX_ZFGYL', -42, 860.3, NULL),
  ('SERIES', 'YX_ZFGYL', -40, 859.1, NULL),
  ('SERIES', 'YX_ZFGYL', -38, 859.3, NULL),
  ('SERIES', 'YX_ZFGYL', -36, 860.9, NULL),
  ('SERIES', 'YX_ZFGYL', -34, 863.6, NULL),
  ('SERIES', 'YX_ZFGYL', -32, 867, NULL),
  ('SERIES', 'YX_ZFGYL', -30, 870.5, NULL),
  ('SERIES', 'YX_ZFGYL', -28, 873.7, NULL),
  ('SERIES', 'YX_ZFGYL', -26, 876, NULL),
  ('SERIES', 'YX_ZFGYL', -24, 877, NULL),
  ('SERIES', 'YX_ZFGYL', -22, 876.6, NULL),
  ('SERIES', 'YX_ZFGYL', -20, 874.8, NULL),
  ('SERIES', 'YX_ZFGYL', -18, 872, NULL),
  ('SERIES', 'YX_ZFGYL', -16, 868.5, NULL),
  ('SERIES', 'YX_ZFGYL', -14, 865, NULL),
  ('SERIES', 'YX_ZFGYL', -12, 861.9, NULL),
  ('SERIES', 'YX_ZFGYL', -10, 859.8, NULL),
  ('SERIES', 'YX_ZFGYL', -8, 859, NULL),
  ('SERIES', 'YX_ZFGYL', -6, 859.6, NULL),
  ('SERIES', 'YX_ZFGYL', -4, 861.5, NULL),
  ('SERIES', 'YX_ZFGYL', -2, 864.5, NULL),
  ('SERIES', 'YX_ZFGYL', 0, 868, NULL),
  ('SERIES', 'YX_ZFGYL', 2, 871.5, NULL),
  ('SERIES', 'YX_ZFGYL', 4, 874.5, NULL),
  ('SERIES', 'YX_ZFGYL', 6, 876.4, NULL),
  ('SERIES', 'YX_ZFGYL', 8, 877, NULL),
  ('SERIES', 'YX_ZFGYL', 10, 876.2, NULL),
  ('SERIES', 'YX_ZFGYL', 12, 874.1, NULL),
  ('SERIES', 'YX_ZFGYL', 14, 871, NULL),
  ('SERIES', 'YX_ZFGYL', 16, 867.5, NULL),
  ('SERIES', 'YX_ZFGYL', 18, 864, NULL),
  ('SERIES', 'YX_ZFGYL', 20, 861.2, NULL),
  ('SERIES', 'YX_ZFGYL', 22, 859.4, NULL),
  ('SERIES', 'YX_ZFGYL', 24, 859, NULL),
  ('SERIES', 'YX_ZFGYL', 26, 860, NULL),
  ('SERIES', 'YX_ZFGYL', 28, 862.3, NULL),
  ('SERIES', 'YX_ZFGYL', 30, 865.5, NULL),
  ('SERIES', 'YX_ZFGYL', 32, 869, NULL),
  ('SERIES', 'YX_ZFGYL', 34, 872.4, NULL),
  ('SERIES', 'YX_ZFGYL', 36, 875.1, NULL),
  ('SERIES', 'YX_ZFGYL', 38, 876.7, NULL),
  ('SERIES', 'YX_ZFGYL', 40, 876.9, NULL),
  ('SERIES', 'YX_ZFGYL', 42, 875.7, NULL),
  ('SERIES', 'YX_ZFGYL', 44, 873.3, NULL),
  ('SERIES', 'YX_ZFGYL', 46, 870, NULL),
  ('SERIES', 'YX_ZFGYL', 48, 866.4, NULL),
  ('SERIES', 'YX_ZFGYL', 50, 863.1, NULL),
  ('SERIES', 'YX_ZFGYL', 52, 860.5, NULL),
  ('SERIES', 'YX_ZFGYL', 54, 859.2, NULL),
  ('SERIES', 'YX_ZFGYL', 56, 859.2, NULL),
  ('SERIES', 'YX_ZFGYL', 58, 860.6, NULL),
  ('SERIES', 'YX_ZFGYL', 60, 863.2, NULL),
  ('STATE', 'YX_ST11_0', -120, NULL, '1'),
  ('FAULT', '1914', 0, NULL, NULL)
) AS v (point_type, obj_code, offset_sec, num_val, txt_val)
WHERE e.event_code = 'EV1'
ON CONFLICT (event_id, point_type, obj_code, offset_sec) DO NOTHING;
INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by) VALUES ((SELECT id FROM t_phm_sim_event WHERE event_code = 'EV1'), 'S3', '成功', 'seed', 'seed') ON CONFLICT (event_id, step_code) DO NOTHING;
INSERT INTO t_phm_sim_event (event_code, fault_rule_id, event_title, expect_outcome, cc, sd, wz, jl, sjxm, fssj, create_by, update_by) VALUES ('EV2', (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1914'), '2026-10-27 09:05 · 10347 次 · 走向：需要升级', '需要升级', '10347', '38 km/h', '某线 K88+150 上行（示意）', '丙站—丁站（示意）', '李**', '2026-10-27 09:05:41', 'seed', 'seed') ON CONFLICT (event_code) DO NOTHING;
INSERT INTO t_phm_sim_event_point (event_id, point_type, obj_code, offset_sec, num_val, txt_val, create_by, update_by)
SELECT e.id, v.point_type, v.obj_code, v.offset_sec, CAST(v.num_val AS NUMERIC(18, 4)), CAST(v.txt_val AS VARCHAR(64)), 'seed', 'seed'
FROM t_phm_sim_event e, (VALUES
  ('SERIES', 'YX_SD_SJ', -120, 41.1, NULL),
  ('SERIES', 'YX_SD_SJ', -118, 41.3, NULL),
  ('SERIES', 'YX_SD_SJ', -116, 41.5, NULL),
  ('SERIES', 'YX_SD_SJ', -114, 41.9, NULL),
  ('SERIES', 'YX_SD_SJ', -112, 42.2, NULL),
  ('SERIES', 'YX_SD_SJ', -110, 42.5, NULL),
  ('SERIES', 'YX_SD_SJ', -108, 42.8, NULL),
  ('SERIES', 'YX_SD_SJ', -106, 42.9, NULL),
  ('SERIES', 'YX_SD_SJ', -104, 43, NULL),
  ('SERIES', 'YX_SD_SJ', -102, 43, NULL),
  ('SERIES', 'YX_SD_SJ', -100, 42.8, NULL),
  ('SERIES', 'YX_SD_SJ', -98, 42.6, NULL),
  ('SERIES', 'YX_SD_SJ', -96, 42.3, NULL),
  ('SERIES', 'YX_SD_SJ', -94, 42, NULL),
  ('SERIES', 'YX_SD_SJ', -92, 41.6, NULL),
  ('SERIES', 'YX_SD_SJ', -90, 41.3, NULL),
  ('SERIES', 'YX_SD_SJ', -88, 41.1, NULL),
  ('SERIES', 'YX_SD_SJ', -86, 41, NULL),
  ('SERIES', 'YX_SD_SJ', -84, 41, NULL),
  ('SERIES', 'YX_SD_SJ', -82, 41.1, NULL),
  ('SERIES', 'YX_SD_SJ', -80, 41.3, NULL),
  ('SERIES', 'YX_SD_SJ', -78, 41.6, NULL),
  ('SERIES', 'YX_SD_SJ', -76, 41.9, NULL),
  ('SERIES', 'YX_SD_SJ', -74, 42.2, NULL),
  ('SERIES', 'YX_SD_SJ', -72, 42.5, NULL),
  ('SERIES', 'YX_SD_SJ', -70, 42.8, NULL),
  ('SERIES', 'YX_SD_SJ', -68, 42.9, NULL),
  ('SERIES', 'YX_SD_SJ', -66, 43, NULL),
  ('SERIES', 'YX_SD_SJ', -64, 42.9, NULL),
  ('SERIES', 'YX_SD_SJ', -62, 42.8, NULL),
  ('SERIES', 'YX_SD_SJ', -60, 42.5, NULL),
  ('SERIES', 'YX_SD_SJ', -58, 42.2, NULL),
  ('SERIES', 'YX_SD_SJ', -56, 41.9, NULL),
  ('SERIES', 'YX_SD_SJ', -54, 41.6, NULL),
  ('SERIES', 'YX_SD_SJ', -52, 41.3, NULL),
  ('SERIES', 'YX_SD_SJ', -50, 41.1, NULL),
  ('SERIES', 'YX_SD_SJ', -48, 41, NULL),
  ('SERIES', 'YX_SD_SJ', -46, 41, NULL),
  ('SERIES', 'YX_SD_SJ', -44, 41.1, NULL),
  ('SERIES', 'YX_SD_SJ', -42, 41.3, NULL),
  ('SERIES', 'YX_SD_SJ', -40, 41.6, NULL),
  ('SERIES', 'YX_SD_SJ', -38, 41.9, NULL),
  ('SERIES', 'YX_SD_SJ', -36, 42.3, NULL),
  ('SERIES', 'YX_SD_SJ', -34, 42.6, NULL),
  ('SERIES', 'YX_SD_SJ', -32, 42.8, NULL),
  ('SERIES', 'YX_SD_SJ', -30, 43, NULL),
  ('SERIES', 'YX_SD_SJ', -28, 43, NULL),
  ('SERIES', 'YX_SD_SJ', -26, 42.9, NULL),
  ('SERIES', 'YX_SD_SJ', -24, 42.8, NULL),
  ('SERIES', 'YX_SD_SJ', -22, 42.5, NULL),
  ('SERIES', 'YX_SD_SJ', -20, 42.2, NULL),
  ('SERIES', 'YX_SD_SJ', -18, 41.9, NULL),
  ('SERIES', 'YX_SD_SJ', -16, 41.5, NULL),
  ('SERIES', 'YX_SD_SJ', -14, 41.3, NULL),
  ('SERIES', 'YX_SD_SJ', -12, 41.1, NULL),
  ('SERIES', 'YX_SD_SJ', -10, 41, NULL),
  ('SERIES', 'YX_SD_SJ', -8, 41, NULL),
  ('SERIES', 'YX_SD_SJ', -6, 41.2, NULL),
  ('SERIES', 'YX_SD_SJ', -4, 41.4, NULL),
  ('SERIES', 'YX_SD_SJ', -2, 41.7, NULL),
  ('SERIES', 'YX_SD_SJ', 0, 42, NULL),
  ('SERIES', 'YX_SD_SJ', 2, 40.6, NULL),
  ('SERIES', 'YX_SD_SJ', 4, 39.2, NULL),
  ('SERIES', 'YX_SD_SJ', 6, 37.8, NULL),
  ('SERIES', 'YX_SD_SJ', 8, 36.4, NULL),
  ('SERIES', 'YX_SD_SJ', 10, 35, NULL),
  ('SERIES', 'YX_SD_SJ', 12, 33.6, NULL),
  ('SERIES', 'YX_SD_SJ', 14, 32.2, NULL),
  ('SERIES', 'YX_SD_SJ', 16, 30.8, NULL),
  ('SERIES', 'YX_SD_SJ', 18, 29.4, NULL),
  ('SERIES', 'YX_SD_SJ', 20, 28, NULL),
  ('SERIES', 'YX_SD_SJ', 22, 26.6, NULL),
  ('SERIES', 'YX_SD_SJ', 24, 25.2, NULL),
  ('SERIES', 'YX_SD_SJ', 26, 23.8, NULL),
  ('SERIES', 'YX_SD_SJ', 28, 22.4, NULL),
  ('SERIES', 'YX_SD_SJ', 30, 21, NULL),
  ('SERIES', 'YX_SD_SJ', 32, 19.6, NULL),
  ('SERIES', 'YX_SD_SJ', 34, 18.2, NULL),
  ('SERIES', 'YX_SD_SJ', 36, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 38, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 40, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 42, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 44, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 46, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 48, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 50, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 52, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 54, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 56, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 58, 18, NULL),
  ('SERIES', 'YX_SD_SJ', 60, 18, NULL),
  ('SERIES', 'SJSD', -120, 42.9, NULL),
  ('SERIES', 'SJSD', -118, 43, NULL),
  ('SERIES', 'SJSD', -116, 42.9, NULL),
  ('SERIES', 'SJSD', -114, 42.7, NULL),
  ('SERIES', 'SJSD', -112, 42.4, NULL),
  ('SERIES', 'SJSD', -110, 42, NULL),
  ('SERIES', 'SJSD', -108, 41.6, NULL),
  ('SERIES', 'SJSD', -106, 41.3, NULL),
  ('SERIES', 'SJSD', -104, 41.1, NULL),
  ('SERIES', 'SJSD', -102, 41, NULL),
  ('SERIES', 'SJSD', -100, 41.1, NULL),
  ('SERIES', 'SJSD', -98, 41.3, NULL),
  ('SERIES', 'SJSD', -96, 41.7, NULL),
  ('SERIES', 'SJSD', -94, 42, NULL),
  ('SERIES', 'SJSD', -92, 42.4, NULL),
  ('SERIES', 'SJSD', -90, 42.8, NULL),
  ('SERIES', 'SJSD', -88, 42.9, NULL),
  ('SERIES', 'SJSD', -86, 43, NULL),
  ('SERIES', 'SJSD', -84, 42.9, NULL),
  ('SERIES', 'SJSD', -82, 42.6, NULL),
  ('SERIES', 'SJSD', -80, 42.3, NULL),
  ('SERIES', 'SJSD', -78, 41.9, NULL),
  ('SERIES', 'SJSD', -76, 41.5, NULL),
  ('SERIES', 'SJSD', -74, 41.2, NULL),
  ('SERIES', 'SJSD', -72, 41, NULL),
  ('SERIES', 'SJSD', -70, 41, NULL),
  ('SERIES', 'SJSD', -68, 41.1, NULL),
  ('SERIES', 'SJSD', -66, 41.4, NULL),
  ('SERIES', 'SJSD', -64, 41.8, NULL),
  ('SERIES', 'SJSD', -62, 42.2, NULL),
  ('SERIES', 'SJSD', -60, 42.5, NULL),
  ('SERIES', 'SJSD', -58, 42.8, NULL),
  ('SERIES', 'SJSD', -56, 43, NULL),
  ('SERIES', 'SJSD', -54, 43, NULL),
  ('SERIES', 'SJSD', -52, 42.8, NULL),
  ('SERIES', 'SJSD', -50, 42.5, NULL),
  ('SERIES', 'SJSD', -48, 42.2, NULL),
  ('SERIES', 'SJSD', -46, 41.8, NULL),
  ('SERIES', 'SJSD', -44, 41.4, NULL),
  ('SERIES', 'SJSD', -42, 41.1, NULL),
  ('SERIES', 'SJSD', -40, 41, NULL),
  ('SERIES', 'SJSD', -38, 41, NULL),
  ('SERIES', 'SJSD', -36, 41.2, NULL),
  ('SERIES', 'SJSD', -34, 41.5, NULL),
  ('SERIES', 'SJSD', -32, 41.9, NULL),
  ('SERIES', 'SJSD', -30, 42.3, NULL),
  ('SERIES', 'SJSD', -28, 42.6, NULL),
  ('SERIES', 'SJSD', -26, 42.9, NULL),
  ('SERIES', 'SJSD', -24, 43, NULL),
  ('SERIES', 'SJSD', -22, 43, NULL),
  ('SERIES', 'SJSD', -20, 42.8, NULL),
  ('SERIES', 'SJSD', -18, 42.4, NULL),
  ('SERIES', 'SJSD', -16, 42.1, NULL),
  ('SERIES', 'SJSD', -14, 41.7, NULL),
  ('SERIES', 'SJSD', -12, 41.3, NULL),
  ('SERIES', 'SJSD', -10, 41.1, NULL),
  ('SERIES', 'SJSD', -8, 41, NULL),
  ('SERIES', 'SJSD', -6, 41.1, NULL),
  ('SERIES', 'SJSD', -4, 41.3, NULL),
  ('SERIES', 'SJSD', -2, 41.6, NULL),
  ('SERIES', 'SJSD', 0, 42, NULL),
  ('SERIES', 'SJSD', 2, 40.6, NULL),
  ('SERIES', 'SJSD', 4, 39.2, NULL),
  ('SERIES', 'SJSD', 6, 37.8, NULL),
  ('SERIES', 'SJSD', 8, 36.4, NULL),
  ('SERIES', 'SJSD', 10, 35, NULL),
  ('SERIES', 'SJSD', 12, 33.6, NULL),
  ('SERIES', 'SJSD', 14, 32.2, NULL),
  ('SERIES', 'SJSD', 16, 30.8, NULL),
  ('SERIES', 'SJSD', 18, 29.4, NULL),
  ('SERIES', 'SJSD', 20, 28, NULL),
  ('SERIES', 'SJSD', 22, 26.6, NULL),
  ('SERIES', 'SJSD', 24, 25.2, NULL),
  ('SERIES', 'SJSD', 26, 23.8, NULL),
  ('SERIES', 'SJSD', 28, 22.4, NULL),
  ('SERIES', 'SJSD', 30, 21, NULL),
  ('SERIES', 'SJSD', 32, 19.6, NULL),
  ('SERIES', 'SJSD', 34, 18.2, NULL),
  ('SERIES', 'SJSD', 36, 18, NULL),
  ('SERIES', 'SJSD', 38, 18, NULL),
  ('SERIES', 'SJSD', 40, 18, NULL),
  ('SERIES', 'SJSD', 42, 18, NULL),
  ('SERIES', 'SJSD', 44, 18, NULL),
  ('SERIES', 'SJSD', 46, 18, NULL),
  ('SERIES', 'SJSD', 48, 18, NULL),
  ('SERIES', 'SJSD', 50, 18, NULL),
  ('SERIES', 'SJSD', 52, 18, NULL),
  ('SERIES', 'SJSD', 54, 18, NULL),
  ('SERIES', 'SJSD', 56, 18, NULL),
  ('SERIES', 'SJSD', 58, 18, NULL),
  ('SERIES', 'SJSD', 60, 18, NULL),
  ('SERIES', 'YX_ZFGYL', -120, 870.9, NULL),
  ('SERIES', 'YX_ZFGYL', -118, 870.6, NULL),
  ('SERIES', 'YX_ZFGYL', -116, 869, NULL),
  ('SERIES', 'YX_ZFGYL', -114, 866.3, NULL),
  ('SERIES', 'YX_ZFGYL', -112, 863.4, NULL),
  ('SERIES', 'YX_ZFGYL', -110, 860.8, NULL),
  ('SERIES', 'YX_ZFGYL', -108, 859.3, NULL),
  ('SERIES', 'YX_ZFGYL', -106, 859.1, NULL),
  ('SERIES', 'YX_ZFGYL', -104, 860.4, NULL),
  ('SERIES', 'YX_ZFGYL', -102, 862.8, NULL),
  ('SERIES', 'YX_ZFGYL', -100, 865.8, NULL),
  ('SERIES', 'YX_ZFGYL', -98, 868.5, NULL),
  ('SERIES', 'YX_ZFGYL', -96, 870.4, NULL),
  ('SERIES', 'YX_ZFGYL', -94, 871, NULL),
  ('SERIES', 'YX_ZFGYL', -92, 870.1, NULL),
  ('SERIES', 'YX_ZFGYL', -90, 867.9, NULL),
  ('SERIES', 'YX_ZFGYL', -88, 865.1, NULL),
  ('SERIES', 'YX_ZFGYL', -86, 862.2, NULL),
  ('SERIES', 'YX_ZFGYL', -84, 860, NULL),
  ('SERIES', 'YX_ZFGYL', -82, 859, NULL),
  ('SERIES', 'YX_ZFGYL', -80, 859.5, NULL),
  ('SERIES', 'YX_ZFGYL', -78, 861.4, NULL),
  ('SERIES', 'YX_ZFGYL', -76, 864.1, NULL),
  ('SERIES', 'YX_ZFGYL', -74, 867.1, NULL),
  ('SERIES', 'YX_ZFGYL', -72, 869.5, NULL),
  ('SERIES', 'YX_ZFGYL', -70, 870.9, NULL),
  ('SERIES', 'YX_ZFGYL', -68, 870.8, NULL),
  ('SERIES', 'YX_ZFGYL', -66, 869.3, NULL),
  ('SERIES', 'YX_ZFGYL', -64, 866.7, NULL),
  ('SERIES', 'YX_ZFGYL', -62, 863.8, NULL),
  ('SERIES', 'YX_ZFGYL', -60, 861.1, NULL),
  ('SERIES', 'YX_ZFGYL', -58, 859.4, NULL),
  ('SERIES', 'YX_ZFGYL', -56, 859.1, NULL),
  ('SERIES', 'YX_ZFGYL', -54, 860.2, NULL),
  ('SERIES', 'YX_ZFGYL', -52, 862.5, NULL),
  ('SERIES', 'YX_ZFGYL', -50, 865.4, NULL),
  ('SERIES', 'YX_ZFGYL', -48, 868.2, NULL),
  ('SERIES', 'YX_ZFGYL', -46, 870.3, NULL),
  ('SERIES', 'YX_ZFGYL', -44, 871, NULL),
  ('SERIES', 'YX_ZFGYL', -42, 870.3, NULL),
  ('SERIES', 'YX_ZFGYL', -40, 868.3, NULL),
  ('SERIES', 'YX_ZFGYL', -38, 865.5, NULL),
  ('SERIES', 'YX_ZFGYL', -36, 862.5, NULL),
  ('SERIES', 'YX_ZFGYL', -34, 860.2, NULL),
  ('SERIES', 'YX_ZFGYL', -32, 859.1, NULL),
  ('SERIES', 'YX_ZFGYL', -30, 859.4, NULL),
  ('SERIES', 'YX_ZFGYL', -28, 861.1, NULL),
  ('SERIES', 'YX_ZFGYL', -26, 863.7, NULL),
  ('SERIES', 'YX_ZFGYL', -24, 858.8, NULL),
  ('SERIES', 'YX_ZFGYL', -22, 846.4, NULL),
  ('SERIES', 'YX_ZFGYL', -20, 834, NULL),
  ('SERIES', 'YX_ZFGYL', -18, 821.6, NULL),
  ('SERIES', 'YX_ZFGYL', -16, 809.2, NULL),
  ('SERIES', 'YX_ZFGYL', -14, 796.8, NULL),
  ('SERIES', 'YX_ZFGYL', -12, 784.4, NULL),
  ('SERIES', 'YX_ZFGYL', -10, 772, NULL),
  ('SERIES', 'YX_ZFGYL', -8, 759.6, NULL),
  ('SERIES', 'YX_ZFGYL', -6, 747.2, NULL),
  ('SERIES', 'YX_ZFGYL', -4, 734.8, NULL),
  ('SERIES', 'YX_ZFGYL', -2, 722.4, NULL),
  ('SERIES', 'YX_ZFGYL', 0, 710, NULL),
  ('SERIES', 'YX_ZFGYL', 2, 697.6, NULL),
  ('SERIES', 'YX_ZFGYL', 4, 685.2, NULL),
  ('SERIES', 'YX_ZFGYL', 6, 672.8, NULL),
  ('SERIES', 'YX_ZFGYL', 8, 660.4, NULL),
  ('SERIES', 'YX_ZFGYL', 10, 648, NULL),
  ('SERIES', 'YX_ZFGYL', 12, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 14, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 16, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 18, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 20, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 22, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 24, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 26, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 28, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 30, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 32, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 34, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 36, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 38, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 40, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 42, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 44, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 46, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 48, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 50, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 52, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 54, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 56, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 58, 640, NULL),
  ('SERIES', 'YX_ZFGYL', 60, 640, NULL),
  ('STATE', 'YX_ST11_0', -120, NULL, '1'),
  ('STATE', 'YX_ST11_0', 8, NULL, '0'),
  ('FAULT', '1914', 0, NULL, NULL),
  ('FAULT', '1902', 6, NULL, NULL),
  ('FAULT', '1914', 22, NULL, NULL)
) AS v (point_type, obj_code, offset_sec, num_val, txt_val)
WHERE e.event_code = 'EV2'
ON CONFLICT (event_id, point_type, obj_code, offset_sec) DO NOTHING;
INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by) VALUES ((SELECT id FROM t_phm_sim_event WHERE event_code = 'EV2'), 'S3', '未成功', 'seed', 'seed') ON CONFLICT (event_id, step_code) DO NOTHING;
INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by) VALUES ((SELECT id FROM t_phm_sim_event WHERE event_code = 'EV2'), 'S7', '不能', 'seed', 'seed') ON CONFLICT (event_id, step_code) DO NOTHING;
INSERT INTO t_phm_sim_event (event_code, fault_rule_id, event_title, expect_outcome, cc, sd, wz, jl, sjxm, fssj, create_by, update_by) VALUES ('EV3', (SELECT id FROM t_phm_fault_rule WHERE cx = 'HXD1C' AND ly = 'TCMS' AND gzdm = '1873'), '2026-11-02 18:47 · 23061 次 · 走向：需要升级', '需要升级', '23061', '58 km/h', '某线 K203+900 下行（示意）', '戊站—己站（示意）', '王**', '2026-11-02 18:47:05', 'seed', 'seed') ON CONFLICT (event_code) DO NOTHING;
INSERT INTO t_phm_sim_event_point (event_id, point_type, obj_code, offset_sec, num_val, txt_val, create_by, update_by)
SELECT e.id, v.point_type, v.obj_code, v.offset_sec, CAST(v.num_val AS NUMERIC(18, 4)), CAST(v.txt_val AS VARCHAR(64)), 'seed', 'seed'
FROM t_phm_sim_event e, (VALUES
  ('SERIES', 'YX_YBDY', -120, 24861.2, NULL),
  ('SERIES', 'YX_YBDY', -118, 24896.4, NULL),
  ('SERIES', 'YX_YBDY', -116, 24936.6, NULL),
  ('SERIES', 'YX_YBDY', -114, 24980, NULL),
  ('SERIES', 'YX_YBDY', -112, 25024.3, NULL),
  ('SERIES', 'YX_YBDY', -110, 25067.5, NULL),
  ('SERIES', 'YX_YBDY', -108, 25107.3, NULL),
  ('SERIES', 'YX_YBDY', -106, 25141.9, NULL),
  ('SERIES', 'YX_YBDY', -104, 25169.5, NULL),
  ('SERIES', 'YX_YBDY', -102, 25188.7, NULL),
  ('SERIES', 'YX_YBDY', -100, 25198.7, NULL),
  ('SERIES', 'YX_YBDY', -98, 25198.9, NULL),
  ('SERIES', 'YX_YBDY', -96, 25189.3, NULL),
  ('SERIES', 'YX_YBDY', -94, 25170.4, NULL),
  ('SERIES', 'YX_YBDY', -92, 25143.1, NULL),
  ('SERIES', 'YX_YBDY', -90, 25108.8, NULL),
  ('SERIES', 'YX_YBDY', -88, 25069.1, NULL),
  ('SERIES', 'YX_YBDY', -86, 25026.1, NULL),
  ('SERIES', 'YX_YBDY', -84, 24981.7, NULL),
  ('SERIES', 'YX_YBDY', -82, 24938.3, NULL),
  ('SERIES', 'YX_YBDY', -80, 24897.9, NULL),
  ('SERIES', 'YX_YBDY', -78, 24862.5, NULL),
  ('SERIES', 'YX_YBDY', -76, 24833.9, NULL),
  ('SERIES', 'YX_YBDY', -74, 24813.4, NULL),
  ('SERIES', 'YX_YBDY', -72, 24802.1, NULL),
  ('SERIES', 'YX_YBDY', -70, 24800.6, NULL),
  ('SERIES', 'YX_YBDY', -68, 24808.8, NULL),
  ('SERIES', 'YX_YBDY', -66, 24826.5, NULL),
  ('SERIES', 'YX_YBDY', -64, 24852.7, NULL),
  ('SERIES', 'YX_YBDY', -62, 24886.1, NULL),
  ('SERIES', 'YX_YBDY', -60, 24925.2, NULL),
  ('SERIES', 'YX_YBDY', -58, 24967.9, NULL),
  ('SERIES', 'YX_YBDY', -56, 25012.2, NULL),
  ('SERIES', 'YX_YBDY', -54, 25055.9, NULL),
  ('SERIES', 'YX_YBDY', -52, 25096.8, NULL),
  ('SERIES', 'YX_YBDY', -50, 25133, NULL),
  ('SERIES', 'YX_YBDY', -48, 25162.7, NULL),
  ('SERIES', 'YX_YBDY', -46, 25184.3, NULL),
  ('SERIES', 'YX_YBDY', -44, 25196.9, NULL),
  ('SERIES', 'YX_YBDY', -42, 25199.8, NULL),
  ('SERIES', 'YX_YBDY', -40, 25192.9, NULL),
  ('SERIES', 'YX_YBDY', -38, 25176.5, NULL),
  ('SERIES', 'YX_YBDY', -36, 25151.4, NULL),
  ('SERIES', 'YX_YBDY', -34, 25118.8, NULL),
  ('SERIES', 'YX_YBDY', -32, 25080.4, NULL),
  ('SERIES', 'YX_YBDY', -30, 25038.1, NULL),
  ('SERIES', 'YX_YBDY', -28, 24993.9, NULL),
  ('SERIES', 'YX_YBDY', -26, 24950, NULL),
  ('SERIES', 'YX_YBDY', -24, 24908.5, NULL),
  ('SERIES', 'YX_YBDY', -22, 24871.6, NULL),
  ('SERIES', 'YX_YBDY', -20, 24841, NULL),
  ('SERIES', 'YX_YBDY', -18, 24818.1, NULL),
  ('SERIES', 'YX_YBDY', -16, 24804.3, NULL),
  ('SERIES', 'YX_YBDY', -14, 24800, NULL),
  ('SERIES', 'YX_YBDY', -12, 24805.6, NULL),
  ('SERIES', 'YX_YBDY', -10, 24820.8, NULL),
  ('SERIES', 'YX_YBDY', -8, 13503.2, NULL),
  ('SERIES', 'YX_YBDY', -6, 13883.8, NULL),
  ('SERIES', 'YX_YBDY', -4, 14027, NULL),
  ('SERIES', 'YX_YBDY', -2, 13527.2, NULL),
  ('SERIES', 'YX_YBDY', 0, 13800, NULL),
  ('SERIES', 'YX_YBDY', 2, 14072.8, NULL),
  ('SERIES', 'YX_YBDY', 4, 13573, NULL),
  ('SERIES', 'YX_YBDY', 6, 13716.2, NULL),
  ('SERIES', 'YX_YBDY', 8, 14096.8, NULL),
  ('SERIES', 'YX_YBDY', 10, 13636.8, NULL),
  ('SERIES', 'YX_YBDY', 12, 13639, NULL),
  ('SERIES', 'YX_YBDY', 14, 14097.2, NULL),
  ('SERIES', 'YX_YBDY', 16, 13713.6, NULL),
  ('SERIES', 'YX_YBDY', 18, 13574.7, NULL),
  ('SERIES', 'YX_YBDY', 20, 25159, NULL),
  ('SERIES', 'YX_YBDY', 22, 25128.4, NULL),
  ('SERIES', 'YX_YBDY', 24, 25091.5, NULL),
  ('SERIES', 'YX_YBDY', 26, 25050, NULL),
  ('SERIES', 'YX_YBDY', 28, 25006.1, NULL),
  ('SERIES', 'YX_YBDY', 30, 24961.9, NULL),
  ('SERIES', 'YX_YBDY', 32, 24919.6, NULL),
  ('SERIES', 'YX_YBDY', 34, 24881.2, NULL),
  ('SERIES', 'YX_YBDY', 36, 24848.6, NULL),
  ('SERIES', 'YX_YBDY', 38, 24823.5, NULL),
  ('SERIES', 'YX_YBDY', 40, 24807.1, NULL),
  ('SERIES', 'YX_YBDY', 42, 24800.2, NULL),
  ('SERIES', 'YX_YBDY', 44, 24803.1, NULL),
  ('SERIES', 'YX_YBDY', 46, 24815.7, NULL),
  ('SERIES', 'YX_YBDY', 48, 24837.3, NULL),
  ('SERIES', 'YX_YBDY', 50, 24867, NULL),
  ('SERIES', 'YX_YBDY', 52, 24903.2, NULL),
  ('SERIES', 'YX_YBDY', 54, 24944.1, NULL),
  ('SERIES', 'YX_YBDY', 56, 24987.8, NULL),
  ('SERIES', 'YX_YBDY', 58, 25032.1, NULL),
  ('SERIES', 'YX_YBDY', 60, 25074.8, NULL),
  ('SERIES', 'SJSD', -120, 57.3, NULL),
  ('SERIES', 'SJSD', -118, 57.2, NULL),
  ('SERIES', 'SJSD', -116, 57.1, NULL),
  ('SERIES', 'SJSD', -114, 57, NULL),
  ('SERIES', 'SJSD', -112, 57, NULL),
  ('SERIES', 'SJSD', -110, 57.1, NULL),
  ('SERIES', 'SJSD', -108, 57.2, NULL),
  ('SERIES', 'SJSD', -106, 57.4, NULL),
  ('SERIES', 'SJSD', -104, 57.6, NULL),
  ('SERIES', 'SJSD', -102, 57.8, NULL),
  ('SERIES', 'SJSD', -100, 58.1, NULL),
  ('SERIES', 'SJSD', -98, 58.3, NULL),
  ('SERIES', 'SJSD', -96, 58.5, NULL),
  ('SERIES', 'SJSD', -94, 58.7, NULL),
  ('SERIES', 'SJSD', -92, 58.9, NULL),
  ('SERIES', 'SJSD', -90, 59, NULL),
  ('SERIES', 'SJSD', -88, 59, NULL),
  ('SERIES', 'SJSD', -86, 59, NULL),
  ('SERIES', 'SJSD', -84, 58.9, NULL),
  ('SERIES', 'SJSD', -82, 58.7, NULL),
  ('SERIES', 'SJSD', -80, 58.5, NULL),
  ('SERIES', 'SJSD', -78, 58.3, NULL),
  ('SERIES', 'SJSD', -76, 58.1, NULL),
  ('SERIES', 'SJSD', -74, 57.8, NULL),
  ('SERIES', 'SJSD', -72, 57.6, NULL),
  ('SERIES', 'SJSD', -70, 57.4, NULL),
  ('SERIES', 'SJSD', -68, 57.2, NULL),
  ('SERIES', 'SJSD', -66, 57.1, NULL),
  ('SERIES', 'SJSD', -64, 57, NULL),
  ('SERIES', 'SJSD', -62, 57, NULL),
  ('SERIES', 'SJSD', -60, 57.1, NULL),
  ('SERIES', 'SJSD', -58, 57.2, NULL),
  ('SERIES', 'SJSD', -56, 57.3, NULL),
  ('SERIES', 'SJSD', -54, 57.5, NULL),
  ('SERIES', 'SJSD', -52, 57.8, NULL),
  ('SERIES', 'SJSD', -50, 58, NULL),
  ('SERIES', 'SJSD', -48, 58.3, NULL),
  ('SERIES', 'SJSD', -46, 58.5, NULL),
  ('SERIES', 'SJSD', -44, 58.7, NULL),
  ('SERIES', 'SJSD', -42, 58.9, NULL),
  ('SERIES', 'SJSD', -40, 59, NULL),
  ('SERIES', 'SJSD', -38, 59, NULL),
  ('SERIES', 'SJSD', -36, 59, NULL),
  ('SERIES', 'SJSD', -34, 58.9, NULL),
  ('SERIES', 'SJSD', -32, 58.8, NULL),
  ('SERIES', 'SJSD', -30, 58.6, NULL),
  ('SERIES', 'SJSD', -28, 58.4, NULL),
  ('SERIES', 'SJSD', -26, 58.1, NULL),
  ('SERIES', 'SJSD', -24, 57.9, NULL),
  ('SERIES', 'SJSD', -22, 57.6, NULL),
  ('SERIES', 'SJSD', -20, 57.4, NULL),
  ('SERIES', 'SJSD', -18, 57.2, NULL),
  ('SERIES', 'SJSD', -16, 57.1, NULL),
  ('SERIES', 'SJSD', -14, 57, NULL),
  ('SERIES', 'SJSD', -12, 57, NULL),
  ('SERIES', 'SJSD', -10, 57.1, NULL),
  ('SERIES', 'SJSD', -8, 57.2, NULL),
  ('SERIES', 'SJSD', -6, 57.3, NULL),
  ('SERIES', 'SJSD', -4, 57.5, NULL),
  ('SERIES', 'SJSD', -2, 57.8, NULL),
  ('SERIES', 'SJSD', 0, 58, NULL),
  ('SERIES', 'SJSD', 2, 58.2, NULL),
  ('SERIES', 'SJSD', 4, 58.5, NULL),
  ('SERIES', 'SJSD', 6, 58.7, NULL),
  ('SERIES', 'SJSD', 8, 58.8, NULL),
  ('SERIES', 'SJSD', 10, 58.9, NULL),
  ('SERIES', 'SJSD', 12, 59, NULL),
  ('SERIES', 'SJSD', 14, 59, NULL),
  ('SERIES', 'SJSD', 16, 58.9, NULL),
  ('SERIES', 'SJSD', 18, 58.8, NULL),
  ('SERIES', 'SJSD', 20, 58.6, NULL),
  ('SERIES', 'SJSD', 22, 58.4, NULL),
  ('SERIES', 'SJSD', 24, 58.1, NULL),
  ('SERIES', 'SJSD', 26, 57.9, NULL),
  ('SERIES', 'SJSD', 28, 57.6, NULL),
  ('SERIES', 'SJSD', 30, 57.4, NULL),
  ('SERIES', 'SJSD', 32, 57.2, NULL),
  ('SERIES', 'SJSD', 34, 57.1, NULL),
  ('SERIES', 'SJSD', 36, 57, NULL),
  ('SERIES', 'SJSD', 38, 57, NULL),
  ('SERIES', 'SJSD', 40, 57, NULL),
  ('SERIES', 'SJSD', 42, 57.1, NULL),
  ('SERIES', 'SJSD', 44, 57.3, NULL),
  ('SERIES', 'SJSD', 46, 57.5, NULL),
  ('SERIES', 'SJSD', 48, 57.7, NULL),
  ('SERIES', 'SJSD', 50, 58, NULL),
  ('SERIES', 'SJSD', 52, 58.2, NULL),
  ('SERIES', 'SJSD', 54, 58.5, NULL),
  ('SERIES', 'SJSD', 56, 58.7, NULL),
  ('SERIES', 'SJSD', 58, 58.8, NULL),
  ('SERIES', 'SJSD', 60, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', -120, 59, NULL),
  ('SERIES', 'YX_SD_SJ', -118, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', -116, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', -114, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', -112, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', -110, 58, NULL),
  ('SERIES', 'YX_SD_SJ', -108, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', -106, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', -104, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', -102, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', -100, 57, NULL),
  ('SERIES', 'YX_SD_SJ', -98, 57, NULL),
  ('SERIES', 'YX_SD_SJ', -96, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', -94, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', -92, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', -90, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', -88, 58, NULL),
  ('SERIES', 'YX_SD_SJ', -86, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', -84, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', -82, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', -80, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', -78, 59, NULL),
  ('SERIES', 'YX_SD_SJ', -76, 59, NULL),
  ('SERIES', 'YX_SD_SJ', -74, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', -72, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', -70, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', -68, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', -66, 58, NULL),
  ('SERIES', 'YX_SD_SJ', -64, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', -62, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', -60, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', -58, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', -56, 57, NULL),
  ('SERIES', 'YX_SD_SJ', -54, 57, NULL),
  ('SERIES', 'YX_SD_SJ', -52, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', -50, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', -48, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', -46, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', -44, 58, NULL),
  ('SERIES', 'YX_SD_SJ', -42, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', -40, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', -38, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', -36, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', -34, 59, NULL),
  ('SERIES', 'YX_SD_SJ', -32, 59, NULL),
  ('SERIES', 'YX_SD_SJ', -30, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', -28, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', -26, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', -24, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', -22, 58, NULL),
  ('SERIES', 'YX_SD_SJ', -20, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', -18, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', -16, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', -14, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', -12, 57, NULL),
  ('SERIES', 'YX_SD_SJ', -10, 57, NULL),
  ('SERIES', 'YX_SD_SJ', -8, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', -6, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', -4, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', -2, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', 0, 58, NULL),
  ('SERIES', 'YX_SD_SJ', 2, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', 4, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', 6, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', 8, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', 10, 59, NULL),
  ('SERIES', 'YX_SD_SJ', 12, 59, NULL),
  ('SERIES', 'YX_SD_SJ', 14, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', 16, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', 18, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', 20, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', 22, 58, NULL),
  ('SERIES', 'YX_SD_SJ', 24, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', 26, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', 28, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', 30, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', 32, 57, NULL),
  ('SERIES', 'YX_SD_SJ', 34, 57, NULL),
  ('SERIES', 'YX_SD_SJ', 36, 57.1, NULL),
  ('SERIES', 'YX_SD_SJ', 38, 57.2, NULL),
  ('SERIES', 'YX_SD_SJ', 40, 57.5, NULL),
  ('SERIES', 'YX_SD_SJ', 42, 57.7, NULL),
  ('SERIES', 'YX_SD_SJ', 44, 58, NULL),
  ('SERIES', 'YX_SD_SJ', 46, 58.3, NULL),
  ('SERIES', 'YX_SD_SJ', 48, 58.5, NULL),
  ('SERIES', 'YX_SD_SJ', 50, 58.8, NULL),
  ('SERIES', 'YX_SD_SJ', 52, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', 54, 59, NULL),
  ('SERIES', 'YX_SD_SJ', 56, 59, NULL),
  ('SERIES', 'YX_SD_SJ', 58, 58.9, NULL),
  ('SERIES', 'YX_SD_SJ', 60, 58.8, NULL),
  ('STATE', 'YX_ST6_3', -120, NULL, '1'),
  ('STATE', 'YX_ST8_3', -120, NULL, '0'),
  ('FAULT', '1873', 0, NULL, NULL)
) AS v (point_type, obj_code, offset_sec, num_val, txt_val)
WHERE e.event_code = 'EV3'
ON CONFLICT (event_id, point_type, obj_code, offset_sec) DO NOTHING;
INSERT INTO t_phm_sim_event_answer (event_id, step_code, answer_label, create_by, update_by) VALUES ((SELECT id FROM t_phm_sim_event WHERE event_code = 'EV3'), 'S7', '能', 'seed', 'seed') ON CONFLICT (event_id, step_code) DO NOTHING;

COMMIT;
