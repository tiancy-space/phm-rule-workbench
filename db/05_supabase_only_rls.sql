-- =====================================================================================
-- 仅 Supabase 执行（金仓 / 本地 PostgreSQL 不用执行）
-- 原因：Supabase 的 public schema 通过 PostgREST 对外暴露，未开 RLS 的表可被 anon key 任意读写。
-- 做法：19 张表开启 RLS 且不建任何策略 → anon / authenticated 角色读写全部被拒，
--       仅 service_role（后端服务密钥）和数据库直连（postgres 角色）可访问。
-- 前端如需直接读某张表，再按需单独加 SELECT 策略。
-- =====================================================================================
ALTER TABLE t_phm_dict_item ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_branch ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_card ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_confirm ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_flow ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_flow_bind ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_flow_ver ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_dispose_step ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_fault_pre_skip ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_fault_rule ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_fault_rule_ref ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_pre_filter_rule ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_rule_atom ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_rule_group ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_rule_group_item ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_rule_param_meta ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_sim_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_sim_event_answer ENABLE ROW LEVEL SECURITY;
ALTER TABLE t_phm_sim_event_point ENABLE ROW LEVEL SECURITY;
