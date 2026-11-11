# 机车 PHM 故障规则工作台 · 后端数据结构（设计稿 v1，2026-11-10）

| 文件 | 说明 |
|---|---|
| 01_schema.sql | 19 张新表 DDL（可重复执行，先父后子，全部带 COMMENT） |
| 02_seed.sql | 原型 V5.1 SEED/seed5 模拟数据 → INSERT（ON CONFLICT DO NOTHING，可重复执行）。PostgreSQL / Supabase 用这份 |
| 02_seed_kingbase.sql | 同一份数据的金仓 V8R6 Oracle 模式写法（WHERE NOT EXISTS、UNION ALL）。不要改 02_seed.sql |
| 03_sample_queries.sql | 典型读写查询：诊断加载、A1…An 清单、引用检查、取生效流程、流程图边、发布校验 |
| 04_er_diagram.mmd | mermaid erDiagram |
| 05_supabase_only_rls.sql | **仅 Supabase**：19 张表开启 RLS、不建策略（金仓不用执行） |
| _gen/ | 从原型 HTML 抽数与生成 seed 的脚本（node _gen/dump.js && node _gen/dump2.js && node _gen/gen_seed.js） |

本地验证：PostgreSQL 17.11，01 → 02 → 02 → 01 重复执行无报错。

Supabase 落地（2026-11-10）：项目 phm-rule-workbench（ref ctltqbmzjdgjhqnnkcyy，ap-southeast-1，免费档），
迁移 phm_rule_schema → phm_rule_seed → supabase_only_rls；19 表 / 24 外键 / 1,104 行，与本地一致。
https://supabase.com/dashboard/project/ctltqbmzjdgjhqnnkcyy
