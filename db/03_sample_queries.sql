-- 机车 PHM 故障规则工作台 · 典型读写查询示例（PostgreSQL / 金仓 PG 模式通用写法）
-- 1) 诊断加载：按 cx + ly + gzdm 取规则 + 应继承的前置规则（扣除单条豁免）
--    :cx / :ly / :gzdm 为绑定变量，示例取 FXN5C / TCMS / 3816
SELECT f.id, f.cx, f.ly, f.gzdm, f.rule_mode, f.czdj, f.fault_rule
FROM t_phm_fault_rule f
WHERE f.cx = 'FXN5C' AND f.ly = 'TCMS' AND f.gzdm = '3816' AND f.del_flag = 0 AND f.is_enabled = 1;

SELECT p.filter_code, p.exec_timing, p.priority, p.filter_expr
FROM t_phm_pre_filter_rule p, t_phm_fault_rule f
WHERE f.cx = 'FXN5C' AND f.ly = 'TCMS' AND f.gzdm = '3816'
  AND p.is_enabled = 1 AND p.del_flag = 0
  AND (p.scope_cx = 'ALL' OR ',' || p.scope_cx || ',' LIKE '%,' || f.cx || ',%')
  AND (p.scope_ly = 'ALL' OR p.scope_ly = f.ly)
  AND NOT EXISTS (SELECT 1 FROM t_phm_fault_pre_skip k WHERE k.fault_rule_id = f.id AND k.filter_id = p.id AND k.del_flag = 0)
ORDER BY p.exec_timing DESC, p.priority;

-- 2) 编辑页：故障的 A1…An 引入清单（原子 / 命名组）
SELECT r.seq_no, 'A' || r.seq_no AS alias, r.ref_type, COALESCE(a.atom_code, g.group_code) AS code,
       COALESCE(a.atom_name, g.group_name) AS name, COALESCE(a.atom_expr, g.expand_expr) AS expr
FROM t_phm_fault_rule f
JOIN t_phm_fault_rule_ref r ON r.fault_rule_id = f.id AND r.del_flag = 0
LEFT JOIN t_phm_rule_atom a ON a.id = r.atom_id
LEFT JOIN t_phm_rule_group g ON g.id = r.group_id
WHERE f.cx = 'HXD1C' AND f.ly = 'TCMS' AND f.gzdm = '1873'
ORDER BY r.seq_no;

-- 3) 原子“被 N 个故障引用”（直接引用 + 经命名组间接引用），删除前检查
SELECT a.atom_code,
       (SELECT COUNT(DISTINCT r.fault_rule_id) FROM t_phm_fault_rule_ref r WHERE r.atom_id = a.id AND r.del_flag = 0) AS direct_faults,
       (SELECT COUNT(*) FROM t_phm_rule_group_item gi WHERE gi.atom_id = a.id AND gi.del_flag = 0) AS in_groups,
       (SELECT COUNT(*) FROM t_phm_dispose_branch b WHERE b.cond_atom_id = a.id AND b.del_flag = 0) AS in_branches
FROM t_phm_rule_atom a ORDER BY a.atom_code;

-- 4) 运行时：故障报出后取生效的处置流程版本与起点步骤
SELECT fl.flow_code, fl.is_template, v.ver_no, v.win_pre_sec, v.win_post_sec, s.step_code AS start_step, s.step_title
FROM t_phm_fault_rule f
JOIN t_phm_dispose_flow_bind b ON b.fault_rule_id = f.id AND b.del_flag = 0
JOIN t_phm_dispose_flow fl ON fl.id = b.flow_id AND fl.del_flag = 0
JOIN t_phm_dispose_flow_ver v ON v.flow_id = fl.id AND v.ver_status = 'PUBLISHED'
JOIN t_phm_dispose_step s ON s.flow_ver_id = v.id AND s.seq_no = 1
WHERE f.cx = 'HXD1C' AND f.ly = 'TCMS' AND f.gzdm = '1914' AND f.czdj IN ('CHECK', 'WATCH');

-- 5) 流程图：某版本的全部边（步骤 → 分支 → 去向）
SELECT s.seq_no, s.step_code, s.step_type, s.step_title, b.branch_label, b.cond_src, n.step_code AS next_step
FROM t_phm_dispose_flow fl
JOIN t_phm_dispose_flow_ver v ON v.flow_id = fl.id
JOIN t_phm_dispose_step s ON s.flow_ver_id = v.id
LEFT JOIN t_phm_dispose_branch b ON b.step_id = s.id
LEFT JOIN t_phm_dispose_step n ON n.id = b.next_step_id
WHERE fl.flow_code = 'FL1914' AND v.ver_status = 'PUBLISHED'
ORDER BY s.seq_no, b.seq_no;

-- 6) 发布前一致性校验示例：分支未配置出口 / 跨版本指向 / 数据卡引用跨步骤
SELECT 'branch_no_target' AS issue, COUNT(*) FROM t_phm_dispose_branch b JOIN t_phm_dispose_step s ON s.id = b.step_id
  WHERE b.next_step_id IS NULL AND s.step_type <> 'END'
UNION ALL
SELECT 'branch_cross_version', COUNT(*) FROM t_phm_dispose_branch b JOIN t_phm_dispose_step s ON s.id = b.step_id JOIN t_phm_dispose_step n ON n.id = b.next_step_id
  WHERE n.flow_ver_id <> s.flow_ver_id
UNION ALL
SELECT 'card_cross_step', COUNT(*) FROM t_phm_dispose_branch b JOIN t_phm_dispose_card c ON c.id = b.cond_card_id
  WHERE c.step_id <> b.step_id
UNION ALL
SELECT 'none_level_with_flow', COUNT(*) FROM t_phm_dispose_flow_bind b JOIN t_phm_fault_rule f ON f.id = b.fault_rule_id
  WHERE f.czdj = 'NONE';
