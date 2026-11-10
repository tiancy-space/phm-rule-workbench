-- =====================================================================================
-- 机车 PHM 故障规则管理工作台 · 后端数据结构 DDL（设计稿 v1，2026-11-10）
-- 来源：前端原型 机车PHM故障规则管理工作台_原型V5.1.html + V5 用户操作手册 + 处置流程方案 + 规则维护方案
-- 目标库：PostgreSQL 17（Supabase）先落地 → 迁移 KingbaseES V8R6（PG 兼容模式）
--
-- 【红线】只 CREATE 本文件中的新表；不 ALTER / UPDATE / DELETE / DROP 生产旧表 t_phm_fault_code_rule_v2。
-- 【可重复执行】CREATE TABLE IF NOT EXISTS / CREATE INDEX IF NOT EXISTS；COMMENT 可重复执行。
-- 【通用写法】只用 BIGSERIAL / BIGINT / INTEGER / SMALLINT / VARCHAR / TEXT / NUMERIC / TIMESTAMP；
--   不用 IDENTITY、JSON/JSONB、数组、扩展、RLS、触发器。多值字段统一用英文逗号 ',' 分隔。
-- 【审计字段】每张表都有 create_by / create_time / update_by / update_time / del_flag（0 正常 1 逻辑删除）；
--   可编辑的主对象另有 rev（修订号，乐观锁：UPDATE ... SET rev = rev + 1 WHERE id = ? AND rev = ?）。
-- 【执行顺序】先父表后子表：字典 → 参数 → 原子 → 命名组 → 前置 → 故障规则 → 处置流程 → 模拟事件。
-- 如需放到指定 schema（例如金仓生产的 phm_main），执行前先：SET search_path TO phm_main;
-- =====================================================================================

-- =====================================================================================
-- 0. 字典
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_dict_item (
    id              BIGSERIAL       PRIMARY KEY,
    dict_type       VARCHAR(32)     NOT NULL,
    item_code       VARCHAR(64)     NOT NULL,
    item_name       VARCHAR(128)    NOT NULL,
    item_desc       VARCHAR(512),
    ext_val         VARCHAR(256),
    sort_no         INTEGER         NOT NULL DEFAULT 0,
    is_enabled      SMALLINT        NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_dict_item UNIQUE (dict_type, item_code),
    CONSTRAINT ck_phm_dict_item_en  CHECK (is_enabled IN (0, 1)),
    CONSTRAINT ck_phm_dict_item_del CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dict_item              IS '通用字典项：车型、来源、判定模式、处置等级、时间窗函数、步骤类型、角色、结束结论、数据卡类型、统计项、运行信息字段等枚举的显示名与排序';
COMMENT ON COLUMN t_phm_dict_item.id           IS '主键';
COMMENT ON COLUMN t_phm_dict_item.dict_type    IS '字典类型：CX 车型 / LY 来源 / RULE_MODE 判定模式 / CZDJ 处置等级 / JKDJ 健康等级 / CMP_OP 比较符 / WIN_FN 时间窗函数 / STEP_TYPE 步骤类型 / ROLE 角色 / CONCLUSION 结束结论 / CARD_KIND 数据卡类型 / STAT_ITEM 统计项 / RUN_INFO 运行信息字段 / EXEC_TIMING 前置执行时机';
COMMENT ON COLUMN t_phm_dict_item.item_code    IS '字典编码（入库值）';
COMMENT ON COLUMN t_phm_dict_item.item_name    IS '显示名称（中文）';
COMMENT ON COLUMN t_phm_dict_item.item_desc    IS '说明';
COMMENT ON COLUMN t_phm_dict_item.ext_val      IS '扩展值：如步骤类型的默认角色与默认出口、统计项所属数据卡类型';
COMMENT ON COLUMN t_phm_dict_item.sort_no      IS '排序号';
COMMENT ON COLUMN t_phm_dict_item.is_enabled   IS '是否启用：1 启用 0 停用';
COMMENT ON COLUMN t_phm_dict_item.create_by    IS '创建人';
COMMENT ON COLUMN t_phm_dict_item.create_time  IS '创建时间';
COMMENT ON COLUMN t_phm_dict_item.update_by    IS '最后修改人';
COMMENT ON COLUMN t_phm_dict_item.update_time  IS '最后修改时间';
COMMENT ON COLUMN t_phm_dict_item.del_flag     IS '逻辑删除：0 正常 1 已删除';

-- =====================================================================================
-- 1. 参数元数据（V3 协议参数字典；原型 SEED.params）
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_rule_param_meta (
    id              BIGSERIAL       PRIMARY KEY,
    param_col       VARCHAR(64)     NOT NULL,
    param_name      VARCHAR(128)    NOT NULL,
    data_type       VARCHAR(16)     NOT NULL DEFAULT 'STRING',
    unit            VARCHAR(32),
    enum_dict       VARCHAR(2048),
    data_source     VARCHAR(16)     NOT NULL,
    hbase_table     VARCHAR(128)    NOT NULL DEFAULT '-',
    scope_cx        VARCHAR(512)    NOT NULL DEFAULT 'ALL',
    is_selectable   SMALLINT        NOT NULL DEFAULT 1,
    is_enabled      SMALLINT        NOT NULL DEFAULT 1,
    remark          VARCHAR(512),
    rev             INTEGER         NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_rule_param_meta UNIQUE (param_col, hbase_table),
    CONSTRAINT ck_phm_param_type CHECK (data_type IN ('NUMBER', 'ENUM', 'STRING')),
    CONSTRAINT ck_phm_param_src  CHECK (data_source IN ('KAFKA', 'HBASE', 'HBASE_PHM', 'HBASE_LKJ', 'HBASE_6A', 'DIM')),
    CONSTRAINT ck_phm_param_col  CHECK (param_col = UPPER(param_col)),
    CONSTRAINT ck_phm_param_sel  CHECK (is_selectable IN (0, 1)),
    CONSTRAINT ck_phm_param_en   CHECK (is_enabled IN (0, 1)),
    CONSTRAINT ck_phm_param_del  CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_rule_param_meta               IS '规则测点参数元数据：原子规则、前置规则、数据卡都从这里选参数（中文名、单位、码表、数据源、实表、适用车型）';
COMMENT ON COLUMN t_phm_rule_param_meta.id            IS '主键';
COMMENT ON COLUMN t_phm_rule_param_meta.param_col     IS '参数编码（零 JSON 表达式中直接书写的测点名，如 YX_YBDY），大写';
COMMENT ON COLUMN t_phm_rule_param_meta.param_name    IS '参数中文名，如 原边电压';
COMMENT ON COLUMN t_phm_rule_param_meta.data_type     IS '数据类型：NUMBER 数值 / ENUM 枚举状态 / STRING 文本';
COMMENT ON COLUMN t_phm_rule_param_meta.unit          IS '单位，如 V、kPa、km/h、℃';
COMMENT ON COLUMN t_phm_rule_param_meta.enum_dict     IS '枚举码表，格式 编码:名称;编码:名称，如 0:断开;1:闭合';
COMMENT ON COLUMN t_phm_rule_param_meta.data_source   IS '数据源：KAFKA 实时消息 / HBASE_PHM TCMS 参数表 / HBASE_LKJ LKJ 参数表 / HBASE_6A / HBASE 车型专属表 / DIM 维表';
COMMENT ON COLUMN t_phm_rule_param_meta.hbase_table   IS '实表名（HBase 表或维表），未知写 -';
COMMENT ON COLUMN t_phm_rule_param_meta.scope_cx      IS '适用车型，ALL 或逗号分隔车型列表';
COMMENT ON COLUMN t_phm_rule_param_meta.is_selectable IS '页面是否可选：1 可选 0 隐藏';
COMMENT ON COLUMN t_phm_rule_param_meta.is_enabled    IS '是否启用：1 启用 0 停用';
COMMENT ON COLUMN t_phm_rule_param_meta.remark        IS '备注';
COMMENT ON COLUMN t_phm_rule_param_meta.rev           IS '修订号（乐观锁）';
COMMENT ON COLUMN t_phm_rule_param_meta.create_by     IS '创建人';
COMMENT ON COLUMN t_phm_rule_param_meta.create_time   IS '创建时间';
COMMENT ON COLUMN t_phm_rule_param_meta.update_by     IS '最后修改人';
COMMENT ON COLUMN t_phm_rule_param_meta.update_time   IS '最后修改时间';
COMMENT ON COLUMN t_phm_rule_param_meta.del_flag      IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_param_col ON t_phm_rule_param_meta (param_col);

-- =====================================================================================
-- 2. 共享原子规则（原型 atoms，编号 R001…）
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_rule_atom (
    id              BIGSERIAL       PRIMARY KEY,
    atom_code       VARCHAR(16)     NOT NULL,
    atom_name       VARCHAR(256)    NOT NULL,
    atom_type       VARCHAR(16)     NOT NULL,
    scope_cx        VARCHAR(512)    NOT NULL DEFAULT 'ALL',
    param_id        BIGINT,
    param_col       VARCHAR(64),
    cmp_op          VARCHAR(8),
    cmp_val         VARCHAR(2048),
    win_fn          VARCHAR(16),
    win_sec         INTEGER,
    rel_gzdm        VARCHAR(1024),
    atom_expr       TEXT            NOT NULL,
    is_enabled      SMALLINT        NOT NULL DEFAULT 1,
    remark          VARCHAR(512),
    rev             INTEGER         NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_rule_atom_code UNIQUE (atom_code),
    CONSTRAINT fk_phm_atom_param FOREIGN KEY (param_id) REFERENCES t_phm_rule_param_meta (id),
    CONSTRAINT ck_phm_atom_type  CHECK (atom_type IN ('PARAM', 'WINDOW')),
    CONSTRAINT ck_phm_atom_op    CHECK (cmp_op IS NULL OR cmp_op IN ('==', '!=', '>', '>=', '<', '<=', 'IN', 'NOT IN', '=~')),
    CONSTRAINT ck_phm_atom_fn    CHECK (win_fn IS NULL OR win_fn IN ('allNotExists', 'anyExists', 'allExists', 'anyNotExists')),
    CONSTRAINT ck_phm_atom_param CHECK (atom_type <> 'PARAM'  OR (param_id IS NOT NULL AND param_col IS NOT NULL AND cmp_op IS NOT NULL AND cmp_val IS NOT NULL)),
    CONSTRAINT ck_phm_atom_win   CHECK (atom_type <> 'WINDOW' OR (win_fn IS NOT NULL AND win_sec > 0 AND rel_gzdm IS NOT NULL)),
    CONSTRAINT ck_phm_atom_en    CHECK (is_enabled IN (0, 1)),
    CONSTRAINT ck_phm_atom_del   CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_rule_atom             IS '共享原子规则（积木）：最小判定条件，分参数测点比较 PARAM 与关联故障时间窗 WINDOW；被故障规则、命名条件组、处置流程分支共享引用，修改同步所有引用方';
COMMENT ON COLUMN t_phm_rule_atom.id          IS '主键';
COMMENT ON COLUMN t_phm_rule_atom.atom_code   IS '原子编号，如 R001（业务唯一）';
COMMENT ON COLUMN t_phm_rule_atom.atom_name   IS '原子名称（现场说法），留空时由系统按参数中文名自动生成';
COMMENT ON COLUMN t_phm_rule_atom.atom_type   IS '原子类型：PARAM 参数测点比较 / WINDOW 关联故障时间窗';
COMMENT ON COLUMN t_phm_rule_atom.scope_cx    IS '适用车型：ALL 通用或具体车型（逗号分隔）';
COMMENT ON COLUMN t_phm_rule_atom.param_id    IS 'PARAM 类：参数元数据 ID（FK t_phm_rule_param_meta.id）';
COMMENT ON COLUMN t_phm_rule_atom.param_col   IS 'PARAM 类：参数编码冗余，便于直接拼表达式';
COMMENT ON COLUMN t_phm_rule_atom.cmp_op      IS 'PARAM 类：比较符 == != > >= < <= IN, NOT IN, =~（正则）';
COMMENT ON COLUMN t_phm_rule_atom.cmp_val     IS 'PARAM 类：目标值；缺失值写 -（配合 ==）；IN 列表用逗号分隔；枚举写编码值';
COMMENT ON COLUMN t_phm_rule_atom.win_fn      IS 'WINDOW 类：时间窗函数 allNotExists 均未出现 / anyExists 任一出现 / allExists 全部出现 / anyNotExists 不全出现';
COMMENT ON COLUMN t_phm_rule_atom.win_sec     IS 'WINDOW 类：同车事件窗口秒数（前后 N 秒）';
COMMENT ON COLUMN t_phm_rule_atom.rel_gzdm    IS 'WINDOW 类：关联故障代码，逗号分隔';
COMMENT ON COLUMN t_phm_rule_atom.atom_expr   IS '零 JSON 表达式片段（保存时生成），如 YX_YBDY >= 15000、allNotExists(10, 1874, 1875)';
COMMENT ON COLUMN t_phm_rule_atom.is_enabled  IS '是否启用：1 启用 0 停用';
COMMENT ON COLUMN t_phm_rule_atom.remark      IS '备注';
COMMENT ON COLUMN t_phm_rule_atom.rev         IS '修订号（乐观锁）';
COMMENT ON COLUMN t_phm_rule_atom.create_by   IS '创建人';
COMMENT ON COLUMN t_phm_rule_atom.create_time IS '创建时间';
COMMENT ON COLUMN t_phm_rule_atom.update_by   IS '最后修改人';
COMMENT ON COLUMN t_phm_rule_atom.update_time IS '最后修改时间';
COMMENT ON COLUMN t_phm_rule_atom.del_flag    IS '逻辑删除：0 正常 1 已删除（被引用时禁止删除）';
CREATE INDEX IF NOT EXISTS idx_phm_atom_param ON t_phm_rule_atom (param_id);
CREATE INDEX IF NOT EXISTS idx_phm_atom_scope ON t_phm_rule_atom (scope_cx, atom_type);

-- =====================================================================================
-- 3. 命名条件组（原型 groups，编号 G001…）及其成员
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_rule_group (
    id              BIGSERIAL       PRIMARY KEY,
    group_code      VARCHAR(16)     NOT NULL,
    group_name      VARCHAR(128)    NOT NULL,
    scope_cx        VARCHAR(512)    NOT NULL DEFAULT 'ALL',
    group_expr      VARCHAR(2048)   NOT NULL,
    expand_expr     TEXT            NOT NULL,
    group_desc      TEXT,
    is_enabled      SMALLINT        NOT NULL DEFAULT 1,
    remark          VARCHAR(512),
    rev             INTEGER         NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_rule_group_code UNIQUE (group_code),
    CONSTRAINT uk_phm_rule_group_name UNIQUE (group_name),
    CONSTRAINT ck_phm_group_en  CHECK (is_enabled IN (0, 1)),
    CONSTRAINT ck_phm_group_del CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_rule_group             IS '命名条件组：给常用原子组合起业务名称（如“机车在运行”），组内只能引用原子、不能嵌套组';
COMMENT ON COLUMN t_phm_rule_group.id          IS '主键';
COMMENT ON COLUMN t_phm_rule_group.group_code  IS '组编号，如 G001（业务唯一）';
COMMENT ON COLUMN t_phm_rule_group.group_name  IS '组名称（业务说法，全局唯一，不能含 & | ( )）';
COMMENT ON COLUMN t_phm_rule_group.scope_cx    IS '适用车型：ALL 或逗号分隔车型';
COMMENT ON COLUMN t_phm_rule_group.group_expr  IS '组合式（以原子编号书写的规范写法），如 (R001 & R002) | (R003 & R002)';
COMMENT ON COLUMN t_phm_rule_group.expand_expr IS '展开后的零 JSON 表达式（入库内容，原子修改后需重算）';
COMMENT ON COLUMN t_phm_rule_group.group_desc  IS '现场说法（中文释义）';
COMMENT ON COLUMN t_phm_rule_group.is_enabled  IS '是否启用：1 启用 0 停用';
COMMENT ON COLUMN t_phm_rule_group.remark      IS '备注';
COMMENT ON COLUMN t_phm_rule_group.rev         IS '修订号（乐观锁）';
COMMENT ON COLUMN t_phm_rule_group.create_by   IS '创建人';
COMMENT ON COLUMN t_phm_rule_group.create_time IS '创建时间';
COMMENT ON COLUMN t_phm_rule_group.update_by   IS '最后修改人';
COMMENT ON COLUMN t_phm_rule_group.update_time IS '最后修改时间';
COMMENT ON COLUMN t_phm_rule_group.del_flag    IS '逻辑删除：0 正常 1 已删除（被引用时禁止删除）';

CREATE TABLE IF NOT EXISTS t_phm_rule_group_item (
    id              BIGSERIAL       PRIMARY KEY,
    group_id        BIGINT          NOT NULL,
    atom_id         BIGINT          NOT NULL,
    seq_no          INTEGER         NOT NULL,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_group_item UNIQUE (group_id, atom_id),
    CONSTRAINT fk_phm_group_item_group FOREIGN KEY (group_id) REFERENCES t_phm_rule_group (id),
    CONSTRAINT fk_phm_group_item_atom  FOREIGN KEY (atom_id)  REFERENCES t_phm_rule_atom (id),
    CONSTRAINT ck_phm_group_item_del CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_rule_group_item             IS '命名条件组成员：组合式里出现的原子（去重），保存组时由后端按 group_expr 解析重建；用于引用检查与反查';
COMMENT ON COLUMN t_phm_rule_group_item.id          IS '主键';
COMMENT ON COLUMN t_phm_rule_group_item.group_id    IS '命名组 ID（FK t_phm_rule_group.id）';
COMMENT ON COLUMN t_phm_rule_group_item.atom_id     IS '原子 ID（FK t_phm_rule_atom.id）';
COMMENT ON COLUMN t_phm_rule_group_item.seq_no      IS '在组合式中首次出现的顺序';
COMMENT ON COLUMN t_phm_rule_group_item.create_by   IS '创建人';
COMMENT ON COLUMN t_phm_rule_group_item.create_time IS '创建时间';
COMMENT ON COLUMN t_phm_rule_group_item.update_by   IS '最后修改人';
COMMENT ON COLUMN t_phm_rule_group_item.update_time IS '最后修改时间';
COMMENT ON COLUMN t_phm_rule_group_item.del_flag    IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_group_item_atom ON t_phm_rule_group_item (atom_id);

-- =====================================================================================
-- 4. 通用前置规则（原型 pre）
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_pre_filter_rule (
    id              BIGSERIAL       PRIMARY KEY,
    filter_code     VARCHAR(64)     NOT NULL,
    filter_name     VARCHAR(128)    NOT NULL,
    param_id        BIGINT          NOT NULL,
    param_col       VARCHAR(64)     NOT NULL,
    cmp_op          VARCHAR(8)      NOT NULL,
    cmp_val         VARCHAR(2048)   NOT NULL,
    scope_cx        VARCHAR(512)    NOT NULL DEFAULT 'ALL',
    scope_ly        VARCHAR(16)     NOT NULL DEFAULT 'ALL',
    exec_timing     VARCHAR(16)     NOT NULL DEFAULT 'BEFORE_HBASE',
    filter_expr     TEXT            NOT NULL,
    priority        INTEGER         NOT NULL DEFAULT 100,
    is_enabled      SMALLINT        NOT NULL DEFAULT 1,
    remark          VARCHAR(512),
    rev             INTEGER         NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_pre_filter_code UNIQUE (filter_code),
    CONSTRAINT fk_phm_pre_filter_param FOREIGN KEY (param_id) REFERENCES t_phm_rule_param_meta (id),
    CONSTRAINT ck_phm_pre_op     CHECK (cmp_op IN ('==', '!=', '>', '>=', '<', '<=', 'IN', 'NOT IN', '=~')),
    CONSTRAINT ck_phm_pre_ly     CHECK (scope_ly IN ('ALL', 'TCMS', '6A')),
    CONSTRAINT ck_phm_pre_timing CHECK (exec_timing IN ('BEFORE_HBASE', 'AFTER_HBASE')),
    CONSTRAINT ck_phm_pre_en     CHECK (is_enabled IN (0, 1)),
    CONSTRAINT ck_phm_pre_del    CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_pre_filter_rule             IS '通用前置故障规则：先于组合规则执行，任一不通过即拦截；全局维护，各故障按车型/来源自动继承，可单条豁免；启停即时生效';
COMMENT ON COLUMN t_phm_pre_filter_rule.id          IS '主键';
COMMENT ON COLUMN t_phm_pre_filter_rule.filter_code IS '前置规则编码，如 PF_LKJ_ZZZT（业务唯一）';
COMMENT ON COLUMN t_phm_pre_filter_rule.filter_name IS '前置规则名称，如 排除 LKJ 整备状态';
COMMENT ON COLUMN t_phm_pre_filter_rule.param_id    IS '协议指标 ID（FK t_phm_rule_param_meta.id）';
COMMENT ON COLUMN t_phm_pre_filter_rule.param_col   IS '协议指标编码冗余';
COMMENT ON COLUMN t_phm_pre_filter_rule.cmp_op      IS '比较符（与原子规则同一套）';
COMMENT ON COLUMN t_phm_pre_filter_rule.cmp_val     IS '目标值；IN/NOT IN 列表用逗号分隔';
COMMENT ON COLUMN t_phm_pre_filter_rule.scope_cx    IS '适用车型：ALL 与具体车型互斥；多个车型逗号分隔';
COMMENT ON COLUMN t_phm_pre_filter_rule.scope_ly    IS '适用来源：ALL / TCMS / 6A';
COMMENT ON COLUMN t_phm_pre_filter_rule.exec_timing IS '执行时机：BEFORE_HBASE 查 HBase 前短路拦截（只能用 KAFKA/DIM 参数）/ AFTER_HBASE 查 HBase 后拦截';
COMMENT ON COLUMN t_phm_pre_filter_rule.filter_expr IS '零 JSON 表达式（通过条件），如 ZZZT_0 != 1';
COMMENT ON COLUMN t_phm_pre_filter_rule.priority    IS '执行优先级，越小越先执行';
COMMENT ON COLUMN t_phm_pre_filter_rule.is_enabled  IS '启停开关：1 生效 0 停用';
COMMENT ON COLUMN t_phm_pre_filter_rule.remark      IS '备注';
COMMENT ON COLUMN t_phm_pre_filter_rule.rev         IS '修订号（乐观锁）';
COMMENT ON COLUMN t_phm_pre_filter_rule.create_by   IS '创建人';
COMMENT ON COLUMN t_phm_pre_filter_rule.create_time IS '创建时间';
COMMENT ON COLUMN t_phm_pre_filter_rule.update_by   IS '最后修改人';
COMMENT ON COLUMN t_phm_pre_filter_rule.update_time IS '最后修改时间';
COMMENT ON COLUMN t_phm_pre_filter_rule.del_flag    IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_pre_filter_en ON t_phm_pre_filter_rule (is_enabled, priority);

-- =====================================================================================
-- 5. 故障规则主表（故障底账 + 判定规则 + 处置等级；粒度 cx + ly + gzdm）
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_fault_rule (
    id                  BIGSERIAL       PRIMARY KEY,
    cx                  VARCHAR(32)     NOT NULL,
    ly                  VARCHAR(16)     NOT NULL,
    gzdm                VARCHAR(64)     NOT NULL,
    gzmc                VARCHAR(256)    NOT NULL,
    mxmc                VARCHAR(256),
    jkdj                VARCHAR(8)      NOT NULL DEFAULT 'D',
    czdj                VARCHAR(16)     NOT NULL DEFAULT 'WATCH',
    rule_mode           VARCHAR(16)     NOT NULL DEFAULT 'PENDING',
    rule_expr           VARCHAR(1024),
    fault_rule          TEXT,
    rule_desc           TEXT,
    is_enabled          SMALLINT        NOT NULL DEFAULT 0,
    ljdm                VARCHAR(32),
    ssxt                VARCHAR(255),
    xtbm                VARCHAR(64),
    xtpjm               VARCHAR(64),
    ssbj                VARCHAR(255),
    bjbm                VARCHAR(64),
    bjpjm               VARCHAR(64),
    sjlx                VARCHAR(16),
    gzms                TEXT,
    mxgzzs              TEXT,
    description         TEXT,
    version             VARCHAR(64),
    config_note         VARCHAR(512),
    src_rule_ids        VARCHAR(256),
    legacy_logic_expr   TEXT,
    remark              VARCHAR(512),
    rev                 INTEGER         NOT NULL DEFAULT 1,
    create_by           VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by           VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag            SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_fault_rule_key UNIQUE (cx, ly, gzdm),
    CONSTRAINT ck_phm_fault_ly      CHECK (ly IN ('TCMS', '6A')),
    CONSTRAINT ck_phm_fault_jkdj    CHECK (jkdj IN ('A', 'B', 'C', 'D')),
    CONSTRAINT ck_phm_fault_czdj    CHECK (czdj IN ('CHECK', 'WATCH', 'NONE')),
    CONSTRAINT ck_phm_fault_mode    CHECK (rule_mode IN ('CONDITIONAL', 'DIRECT', 'DISABLED', 'PENDING')),
    CONSTRAINT ck_phm_fault_enabled CHECK ((rule_mode IN ('CONDITIONAL', 'DIRECT') AND is_enabled = 1) OR (rule_mode IN ('DISABLED', 'PENDING') AND is_enabled = 0)),
    CONSTRAINT ck_phm_fault_cond    CHECK (rule_mode <> 'CONDITIONAL' OR (rule_expr IS NOT NULL AND fault_rule IS NOT NULL AND LENGTH(TRIM(fault_rule)) > 0)),
    CONSTRAINT ck_phm_fault_nojson  CHECK (fault_rule IS NULL OR POSITION('":' IN fault_rule) = 0),
    CONSTRAINT ck_phm_fault_del     CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_fault_rule                    IS '故障规则主表：故障底账（车型+来源+故障代码唯一）+ 判定模式 + 组合规则（A1…An 局部式与展开后的零 JSON 表达式）+ 处置等级；与生产旧表 t_phm_fault_code_rule_v2 隔离，只沿用其字段口径';
COMMENT ON COLUMN t_phm_fault_rule.id                 IS '主键';
COMMENT ON COLUMN t_phm_fault_rule.cx                 IS '车型，如 HXD1C（同旧表 cx）';
COMMENT ON COLUMN t_phm_fault_rule.ly                 IS '来源：TCMS / 6A';
COMMENT ON COLUMN t_phm_fault_rule.gzdm               IS '故障代码，保留原始写法（可含空格，如 20 01 06）';
COMMENT ON COLUMN t_phm_fault_rule.gzmc               IS '故障名称';
COMMENT ON COLUMN t_phm_fault_rule.mxmc               IS '所属模型名称';
COMMENT ON COLUMN t_phm_fault_rule.jkdj               IS '健康等级：A / B / C / D';
COMMENT ON COLUMN t_phm_fault_rule.czdj               IS '故障处置等级：CHECK 排查（需按处置流程处置）/ WATCH 关注（司机留意、地面关注）/ NONE 无需干预（仅记录，不配流程）';
COMMENT ON COLUMN t_phm_fault_rule.rule_mode          IS '判定模式：CONDITIONAL 条件组合判定 / DIRECT 直接报出 / DISABLED 停用过滤 / PENDING 待配置规则';
COMMENT ON COLUMN t_phm_fault_rule.rule_expr          IS '组合式（局部代号写法），如 A1 & A2 & (A3 | A4) & A5；An 对应 t_phm_fault_rule_ref.seq_no = n';
COMMENT ON COLUMN t_phm_fault_rule.fault_rule         IS '展开后的零 JSON 故障规则（引擎执行内容，不含前置规则），如 YX_YBDY >= 15000 & allNotExists(10, 1874, 1875)；原子/命名组修改后由后端重算';
COMMENT ON COLUMN t_phm_fault_rule.rule_desc          IS '中文释义（现场说法）';
COMMENT ON COLUMN t_phm_fault_rule.is_enabled         IS '是否参与诊断：CONDITIONAL/DIRECT=1，DISABLED/PENDING=0（由判定模式决定）';
COMMENT ON COLUMN t_phm_fault_rule.ljdm               IS '路局代码（沿用旧表口径，信息字段）';
COMMENT ON COLUMN t_phm_fault_rule.ssxt               IS '所属系统（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.xtbm               IS '系统编码（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.xtpjm              IS '系统配件码（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.ssbj               IS '所属部件（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.bjbm               IS '部件编码（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.bjpjm              IS '部件配件码（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.sjlx               IS '数据类型（沿用旧表 sjlx）';
COMMENT ON COLUMN t_phm_fault_rule.gzms               IS '故障描述（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.mxgzzs             IS '模型故障注释（沿用旧表）';
COMMENT ON COLUMN t_phm_fault_rule.description        IS '规则文字描述（沿用旧表 description）';
COMMENT ON COLUMN t_phm_fault_rule.version            IS '底账版本说明（沿用旧表 version）';
COMMENT ON COLUMN t_phm_fault_rule.config_note        IS '配置备注（原型 annotation，如“为从零配置体验暂置待配置”）';
COMMENT ON COLUMN t_phm_fault_rule.src_rule_ids       IS '迁移留痕：对应旧表 t_phm_fault_code_rule_v2.id（逗号分隔），只读参考';
COMMENT ON COLUMN t_phm_fault_rule.legacy_logic_expr  IS '迁移留痕：旧表 rule_json.logic_expr 原文，只读参考，运行时不用';
COMMENT ON COLUMN t_phm_fault_rule.remark             IS '备注（沿用旧表 remark）';
COMMENT ON COLUMN t_phm_fault_rule.rev                IS '修订号（乐观锁；每次保存 +1）';
COMMENT ON COLUMN t_phm_fault_rule.create_by          IS '创建人';
COMMENT ON COLUMN t_phm_fault_rule.create_time        IS '创建时间';
COMMENT ON COLUMN t_phm_fault_rule.update_by          IS '最后修改人';
COMMENT ON COLUMN t_phm_fault_rule.update_time        IS '最后修改时间';
COMMENT ON COLUMN t_phm_fault_rule.del_flag           IS '逻辑删除：0 正常 1 已删除（同 cx+ly+gzdm 再次新增时恢复该行，不另插）';
CREATE INDEX IF NOT EXISTS idx_phm_fault_load ON t_phm_fault_rule (cx, ly, is_enabled);
CREATE INDEX IF NOT EXISTS idx_phm_fault_mode ON t_phm_fault_rule (rule_mode, czdj);
CREATE INDEX IF NOT EXISTS idx_phm_fault_gzmc ON t_phm_fault_rule (gzmc);

CREATE TABLE IF NOT EXISTS t_phm_fault_rule_ref (
    id              BIGSERIAL       PRIMARY KEY,
    fault_rule_id   BIGINT          NOT NULL,
    seq_no          INTEGER         NOT NULL,
    ref_type        VARCHAR(8)      NOT NULL,
    atom_id         BIGINT,
    group_id        BIGINT,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_fault_ref UNIQUE (fault_rule_id, seq_no),
    CONSTRAINT fk_phm_fault_ref_fault FOREIGN KEY (fault_rule_id) REFERENCES t_phm_fault_rule (id),
    CONSTRAINT fk_phm_fault_ref_atom  FOREIGN KEY (atom_id)  REFERENCES t_phm_rule_atom (id),
    CONSTRAINT fk_phm_fault_ref_group FOREIGN KEY (group_id) REFERENCES t_phm_rule_group (id),
    CONSTRAINT ck_phm_fault_ref_type  CHECK ((ref_type = 'ATOM' AND atom_id IS NOT NULL AND group_id IS NULL) OR (ref_type = 'GROUP' AND group_id IS NOT NULL AND atom_id IS NULL)),
    CONSTRAINT ck_phm_fault_ref_seq   CHECK (seq_no >= 1),
    CONSTRAINT ck_phm_fault_ref_del   CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_fault_rule_ref               IS '故障规则引入的原子 / 命名组清单：seq_no=n 即组合式里的局部代号 An；用于“被 N 个故障引用”和禁止删除检查';
COMMENT ON COLUMN t_phm_fault_rule_ref.id            IS '主键';
COMMENT ON COLUMN t_phm_fault_rule_ref.fault_rule_id IS '故障规则 ID（FK t_phm_fault_rule.id）';
COMMENT ON COLUMN t_phm_fault_rule_ref.seq_no        IS '局部代号序号：1 → A1，2 → A2 …';
COMMENT ON COLUMN t_phm_fault_rule_ref.ref_type      IS '引用类型：ATOM 原子 / GROUP 命名组';
COMMENT ON COLUMN t_phm_fault_rule_ref.atom_id       IS 'ref_type=ATOM 时的原子 ID（FK t_phm_rule_atom.id）';
COMMENT ON COLUMN t_phm_fault_rule_ref.group_id      IS 'ref_type=GROUP 时的命名组 ID（FK t_phm_rule_group.id）';
COMMENT ON COLUMN t_phm_fault_rule_ref.create_by     IS '创建人';
COMMENT ON COLUMN t_phm_fault_rule_ref.create_time   IS '创建时间';
COMMENT ON COLUMN t_phm_fault_rule_ref.update_by     IS '最后修改人';
COMMENT ON COLUMN t_phm_fault_rule_ref.update_time   IS '最后修改时间';
COMMENT ON COLUMN t_phm_fault_rule_ref.del_flag      IS '逻辑删除：0 正常 1 已删除（保存故障规则时按草稿整体重建，建议物理删除后重插）';
CREATE INDEX IF NOT EXISTS idx_phm_fault_ref_atom  ON t_phm_fault_rule_ref (atom_id);
CREATE INDEX IF NOT EXISTS idx_phm_fault_ref_group ON t_phm_fault_rule_ref (group_id);

CREATE TABLE IF NOT EXISTS t_phm_fault_pre_skip (
    id              BIGSERIAL       PRIMARY KEY,
    fault_rule_id   BIGINT          NOT NULL,
    filter_id       BIGINT          NOT NULL,
    skip_reason     VARCHAR(512),
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_fault_pre_skip UNIQUE (fault_rule_id, filter_id),
    CONSTRAINT fk_phm_pre_skip_fault  FOREIGN KEY (fault_rule_id) REFERENCES t_phm_fault_rule (id),
    CONSTRAINT fk_phm_pre_skip_filter FOREIGN KEY (filter_id)     REFERENCES t_phm_pre_filter_rule (id),
    CONSTRAINT ck_phm_pre_skip_del CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_fault_pre_skip               IS '单条故障豁免通用前置规则：有记录即该前置规则对该故障不生效';
COMMENT ON COLUMN t_phm_fault_pre_skip.id            IS '主键';
COMMENT ON COLUMN t_phm_fault_pre_skip.fault_rule_id IS '故障规则 ID（FK t_phm_fault_rule.id）';
COMMENT ON COLUMN t_phm_fault_pre_skip.filter_id     IS '被豁免的前置规则 ID（FK t_phm_pre_filter_rule.id）';
COMMENT ON COLUMN t_phm_fault_pre_skip.skip_reason   IS '豁免原因';
COMMENT ON COLUMN t_phm_fault_pre_skip.create_by     IS '创建人';
COMMENT ON COLUMN t_phm_fault_pre_skip.create_time   IS '创建时间';
COMMENT ON COLUMN t_phm_fault_pre_skip.update_by     IS '最后修改人';
COMMENT ON COLUMN t_phm_fault_pre_skip.update_time   IS '最后修改时间';
COMMENT ON COLUMN t_phm_fault_pre_skip.del_flag      IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_pre_skip_filter ON t_phm_fault_pre_skip (filter_id);

-- =====================================================================================
-- 6. 处置流程：流程头 → 版本 → 步骤 → 数据卡 / 分支 / 确认项；流程 ↔ 故障绑定
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_dispose_flow (
    id              BIGSERIAL       PRIMARY KEY,
    flow_code       VARCHAR(32)     NOT NULL,
    flow_name       VARCHAR(256)    NOT NULL,
    is_template     SMALLINT        NOT NULL DEFAULT 0,
    flow_status     VARCHAR(16)     NOT NULL DEFAULT 'DRAFT',
    pub_ver_no      INTEGER         NOT NULL DEFAULT 0,
    is_sample       SMALLINT        NOT NULL DEFAULT 0,
    sample_note     VARCHAR(256),
    remark          VARCHAR(512),
    rev             INTEGER         NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_dispose_flow_code UNIQUE (flow_code),
    CONSTRAINT ck_phm_flow_tpl    CHECK (is_template IN (0, 1)),
    CONSTRAINT ck_phm_flow_status CHECK (flow_status IN ('DRAFT', 'PUBLISHED', 'DISABLED')),
    CONSTRAINT ck_phm_flow_pubver CHECK (pub_ver_no >= 0),
    CONSTRAINT ck_phm_flow_sample CHECK (is_sample IN (0, 1)),
    CONSTRAINT ck_phm_flow_del    CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_flow             IS '处置流程（流程头）：专属流程或通用模板；一期草稿可直接发布、不审核；具体内容挂在版本表下';
COMMENT ON COLUMN t_phm_dispose_flow.id          IS '主键';
COMMENT ON COLUMN t_phm_dispose_flow.flow_code   IS '流程编码，如 FL1914、FT01（业务唯一）';
COMMENT ON COLUMN t_phm_dispose_flow.flow_name   IS '流程名称（当前工作名称）';
COMMENT ON COLUMN t_phm_dispose_flow.is_template IS '是否通用模板：1 模板（可绑多个故障共用）0 专属流程';
COMMENT ON COLUMN t_phm_dispose_flow.flow_status IS '当前状态：DRAFT 草稿（未发布，或已发布后又修改 = 草稿·基于 vN）/ PUBLISHED 已发布且无未发布修改 / DISABLED 停用';
COMMENT ON COLUMN t_phm_dispose_flow.pub_ver_no  IS '当前生效的已发布版本号，0 表示从未发布';
COMMENT ON COLUMN t_phm_dispose_flow.is_sample   IS '是否示例内容：1 示例（非正式规程）0 正式';
COMMENT ON COLUMN t_phm_dispose_flow.sample_note IS '示例提示语';
COMMENT ON COLUMN t_phm_dispose_flow.remark      IS '备注';
COMMENT ON COLUMN t_phm_dispose_flow.rev         IS '修订号（乐观锁）';
COMMENT ON COLUMN t_phm_dispose_flow.create_by   IS '创建人';
COMMENT ON COLUMN t_phm_dispose_flow.create_time IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_flow.update_by   IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_flow.update_time IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_flow.del_flag    IS '逻辑删除：0 正常 1 已删除（删除后绑定的故障变为未配置）';

CREATE TABLE IF NOT EXISTS t_phm_dispose_flow_ver (
    id              BIGSERIAL       PRIMARY KEY,
    flow_id         BIGINT          NOT NULL,
    ver_no          INTEGER         NOT NULL,
    ver_status      VARCHAR(16)     NOT NULL DEFAULT 'DRAFT',
    base_ver_no     INTEGER         NOT NULL DEFAULT 0,
    flow_name       VARCHAR(256)    NOT NULL,
    win_pre_sec     INTEGER         NOT NULL DEFAULT 60,
    win_post_sec    INTEGER         NOT NULL DEFAULT 30,
    run_info_cols   VARCHAR(256)    NOT NULL DEFAULT 'CC,SD,WZ,SJ,FSSJ',
    publish_by      VARCHAR(64),
    publish_time    TIMESTAMP,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_flow_ver UNIQUE (flow_id, ver_no),
    CONSTRAINT fk_phm_flow_ver_flow FOREIGN KEY (flow_id) REFERENCES t_phm_dispose_flow (id),
    CONSTRAINT ck_phm_flow_ver_status CHECK (ver_status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    CONSTRAINT ck_phm_flow_ver_no     CHECK (ver_no >= 1 AND base_ver_no >= 0),
    CONSTRAINT ck_phm_flow_ver_win    CHECK (win_pre_sec BETWEEN 0 AND 3600 AND win_post_sec BETWEEN 0 AND 3600),
    CONSTRAINT ck_phm_flow_ver_pub    CHECK (ver_status = 'DRAFT' OR publish_time IS NOT NULL),
    CONSTRAINT ck_phm_flow_ver_del    CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_flow_ver              IS '处置流程版本：每个流程最多一个 DRAFT（编辑中）和一个 PUBLISHED（生效）版本，旧的已发布版本转 ARCHIVED；步骤等内容挂在版本上，发布即把草稿版本置为 PUBLISHED，编辑已发布流程时复制出新草稿';
COMMENT ON COLUMN t_phm_dispose_flow_ver.id           IS '主键';
COMMENT ON COLUMN t_phm_dispose_flow_ver.flow_id      IS '流程 ID（FK t_phm_dispose_flow.id）';
COMMENT ON COLUMN t_phm_dispose_flow_ver.ver_no       IS '版本号：已发布为 v1、v2…；草稿占用下一个号（pub_ver_no + 1）';
COMMENT ON COLUMN t_phm_dispose_flow_ver.ver_status   IS '版本状态：DRAFT 草稿 / PUBLISHED 当前生效 / ARCHIVED 历史版本';
COMMENT ON COLUMN t_phm_dispose_flow_ver.base_ver_no  IS '草稿基于的已发布版本号（草稿 · 基于 vN），0 表示全新草稿';
COMMENT ON COLUMN t_phm_dispose_flow_ver.flow_name    IS '该版本的流程名称快照';
COMMENT ON COLUMN t_phm_dispose_flow_ver.win_pre_sec  IS '默认取数窗口：T0 前 x 秒';
COMMENT ON COLUMN t_phm_dispose_flow_ver.win_post_sec IS '默认取数窗口：T0 后 y 秒';
COMMENT ON COLUMN t_phm_dispose_flow_ver.run_info_cols IS '处置单顶部常驻运行信息字段，逗号分隔：CC 车次 / SD 速度 / WZ 位置 / JL 交路 / SJ 司机 / FSSJ 发生时间';
COMMENT ON COLUMN t_phm_dispose_flow_ver.publish_by   IS '发布人';
COMMENT ON COLUMN t_phm_dispose_flow_ver.publish_time IS '发布时间';
COMMENT ON COLUMN t_phm_dispose_flow_ver.create_by    IS '创建人';
COMMENT ON COLUMN t_phm_dispose_flow_ver.create_time  IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_flow_ver.update_by    IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_flow_ver.update_time  IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_flow_ver.del_flag     IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_flow_ver_status ON t_phm_dispose_flow_ver (flow_id, ver_status);

CREATE TABLE IF NOT EXISTS t_phm_dispose_flow_bind (
    id              BIGSERIAL       PRIMARY KEY,
    flow_id         BIGINT          NOT NULL,
    fault_rule_id   BIGINT          NOT NULL,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_flow_bind_fault UNIQUE (fault_rule_id),
    CONSTRAINT fk_phm_flow_bind_flow  FOREIGN KEY (flow_id)       REFERENCES t_phm_dispose_flow (id),
    CONSTRAINT fk_phm_flow_bind_fault FOREIGN KEY (fault_rule_id) REFERENCES t_phm_fault_rule (id),
    CONSTRAINT ck_phm_flow_bind_del CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_flow_bind               IS '流程绑定故障：一个故障只能用一套流程（fault_rule_id 唯一）；专属流程绑 1 个，通用模板可绑多个；绑定/解绑不改变发布状态，即时生效';
COMMENT ON COLUMN t_phm_dispose_flow_bind.id            IS '主键';
COMMENT ON COLUMN t_phm_dispose_flow_bind.flow_id       IS '流程 ID（FK t_phm_dispose_flow.id）';
COMMENT ON COLUMN t_phm_dispose_flow_bind.fault_rule_id IS '故障规则 ID（FK t_phm_fault_rule.id），处置等级须为 CHECK 或 WATCH';
COMMENT ON COLUMN t_phm_dispose_flow_bind.create_by     IS '创建人';
COMMENT ON COLUMN t_phm_dispose_flow_bind.create_time   IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_flow_bind.update_by     IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_flow_bind.update_time   IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_flow_bind.del_flag      IS '逻辑删除：0 正常 1 已删除（解绑建议物理删除，以便重新绑定）';
CREATE INDEX IF NOT EXISTS idx_phm_flow_bind_flow ON t_phm_dispose_flow_bind (flow_id);

CREATE TABLE IF NOT EXISTS t_phm_dispose_step (
    id              BIGSERIAL       PRIMARY KEY,
    flow_ver_id     BIGINT          NOT NULL,
    step_code       VARCHAR(16)     NOT NULL,
    seq_no          INTEGER         NOT NULL,
    step_type       VARCHAR(16)     NOT NULL,
    step_title      VARCHAR(256)    NOT NULL,
    step_desc       TEXT,
    role_codes      VARCHAR(64)     NOT NULL,
    safety_tip      VARCHAR(1024),
    manual_ref      VARCHAR(256),
    driver_action   VARCHAR(2048),
    conclusion      VARCHAR(16),
    push_repair     SMALLINT        NOT NULL DEFAULT 0,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_step_code UNIQUE (flow_ver_id, step_code),
    CONSTRAINT uk_phm_step_seq  UNIQUE (flow_ver_id, seq_no),
    CONSTRAINT fk_phm_step_ver FOREIGN KEY (flow_ver_id) REFERENCES t_phm_dispose_flow_ver (id),
    CONSTRAINT ck_phm_step_type   CHECK (step_type IN ('VIEW', 'JUDGE', 'OP', 'CONTACT', 'END')),
    CONSTRAINT ck_phm_step_concl  CHECK (conclusion IS NULL OR conclusion IN ('MAINTAIN', 'SPEED_LIMIT', 'RESCUE', 'RETURN_DEPOT')),
    CONSTRAINT ck_phm_step_end    CHECK (step_type <> 'END' OR conclusion IS NOT NULL),
    CONSTRAINT ck_phm_step_repair CHECK (push_repair IN (0, 1)),
    CONSTRAINT ck_phm_step_del    CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_step               IS '处置步骤：五类（查看/判断/操作/联络上报/结束）；seq_no=1 的步骤为起点';
COMMENT ON COLUMN t_phm_dispose_step.id            IS '主键';
COMMENT ON COLUMN t_phm_dispose_step.flow_ver_id   IS '流程版本 ID（FK t_phm_dispose_flow_ver.id）';
COMMENT ON COLUMN t_phm_dispose_step.step_code     IS '步骤编码（版本内唯一，如 S1），排序不改变编码，分支按 ID 指向';
COMMENT ON COLUMN t_phm_dispose_step.seq_no        IS '显示顺序号（①②③…），1 为起点';
COMMENT ON COLUMN t_phm_dispose_step.step_type     IS '步骤类型：VIEW 查看 / JUDGE 判断 / OP 操作 / CONTACT 联络上报 / END 结束';
COMMENT ON COLUMN t_phm_dispose_step.step_title    IS '标题（判断类写成问题）';
COMMENT ON COLUMN t_phm_dispose_step.step_desc     IS '给专家看的补充说明';
COMMENT ON COLUMN t_phm_dispose_step.role_codes    IS '参与角色，逗号分隔：DRIVER 司机 / EXPERT 专家 / SYSTEM 系统';
COMMENT ON COLUMN t_phm_dispose_step.safety_tip    IS '安全提示（红字显示在处置单与司机车载屏）';
COMMENT ON COLUMN t_phm_dispose_step.manual_ref    IS '对应司机手册条目';
COMMENT ON COLUMN t_phm_dispose_step.driver_action IS '司机动作 / 指令（同步显示在车载屏，建议用 → 分隔）';
COMMENT ON COLUMN t_phm_dispose_step.conclusion    IS '结束结论（仅 END）：MAINTAIN 维持运行 / SPEED_LIMIT 限速运行 / RESCUE 请求救援 / RETURN_DEPOT 回库处理';
COMMENT ON COLUMN t_phm_dispose_step.push_repair   IS '是否标记回库并向检修推送提示：1 是 0 否';
COMMENT ON COLUMN t_phm_dispose_step.create_by     IS '创建人';
COMMENT ON COLUMN t_phm_dispose_step.create_time   IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_step.update_by     IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_step.update_time   IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_step.del_flag      IS '逻辑删除：0 正常 1 已删除';

CREATE TABLE IF NOT EXISTS t_phm_dispose_card (
    id              BIGSERIAL       PRIMARY KEY,
    step_id         BIGINT          NOT NULL,
    card_code       VARCHAR(16)     NOT NULL,
    seq_no          INTEGER         NOT NULL,
    card_kind       VARCHAR(8)      NOT NULL,
    param_id        BIGINT,
    param_col       VARCHAR(64),
    rel_gzdm        VARCHAR(1024),
    win_pre_sec     INTEGER         NOT NULL DEFAULT 60,
    win_post_sec    INTEGER         NOT NULL DEFAULT 30,
    stat_items      VARCHAR(256)    NOT NULL,
    show_curve      SMALLINT        NOT NULL DEFAULT 0,
    limit_op        VARCHAR(4),
    limit_val       VARCHAR(64),
    target_val      VARCHAR(64),
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_card_code UNIQUE (step_id, card_code),
    CONSTRAINT fk_phm_card_step  FOREIGN KEY (step_id)  REFERENCES t_phm_dispose_step (id),
    CONSTRAINT fk_phm_card_param FOREIGN KEY (param_id) REFERENCES t_phm_rule_param_meta (id),
    CONSTRAINT ck_phm_card_kind  CHECK (card_kind IN ('NUM', 'STATE', 'FAULT')),
    CONSTRAINT ck_phm_card_src   CHECK ((card_kind = 'FAULT' AND rel_gzdm IS NOT NULL) OR (card_kind <> 'FAULT' AND param_id IS NOT NULL AND param_col IS NOT NULL)),
    CONSTRAINT ck_phm_card_win   CHECK (win_pre_sec BETWEEN 0 AND 3600 AND win_post_sec BETWEEN 0 AND 3600),
    CONSTRAINT ck_phm_card_limop CHECK (limit_op IS NULL OR limit_op IN ('>', '>=', '<', '<=', '==', '!=')),
    CONSTRAINT ck_phm_card_curve CHECK (show_curve IN (0, 1)),
    CONSTRAINT ck_phm_card_del   CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_card              IS '步骤数据卡：以故障时刻 T0 为锚点取前后窗口数据给专家看；只负责取数展示，判断在分支里配置（可引用卡片统计值）';
COMMENT ON COLUMN t_phm_dispose_card.id           IS '主键';
COMMENT ON COLUMN t_phm_dispose_card.step_id      IS '步骤 ID（FK t_phm_dispose_step.id）';
COMMENT ON COLUMN t_phm_dispose_card.card_code    IS '卡片编码（步骤内唯一，如 C1），分支条件按它引用';
COMMENT ON COLUMN t_phm_dispose_card.seq_no       IS '显示顺序';
COMMENT ON COLUMN t_phm_dispose_card.card_kind    IS '卡片类型：NUM 数值窗口统计 / STATE 状态量取值 / FAULT 关联故障';
COMMENT ON COLUMN t_phm_dispose_card.param_id     IS 'NUM/STATE：参数 ID（FK t_phm_rule_param_meta.id）';
COMMENT ON COLUMN t_phm_dispose_card.param_col    IS 'NUM/STATE：参数编码冗余';
COMMENT ON COLUMN t_phm_dispose_card.rel_gzdm     IS 'FAULT：关联故障代码，逗号分隔（可含本故障）';
COMMENT ON COLUMN t_phm_dispose_card.win_pre_sec  IS '取数窗口：T0 前秒数（判断故障是否消除时可为 0）';
COMMENT ON COLUMN t_phm_dispose_card.win_post_sec IS '取数窗口：T0 后秒数';
COMMENT ON COLUMN t_phm_dispose_card.stat_items   IS '统计项，逗号分隔：NUM 取 T0值/最大/最小/平均/首值/末值/变化量/越限时长；STATE 取 T0值/变位次数/占用时长/是否出现过；FAULT 取 出现次数/T0后再次出现';
COMMENT ON COLUMN t_phm_dispose_card.show_curve   IS 'NUM：是否显示小曲线 1 是 0 否';
COMMENT ON COLUMN t_phm_dispose_card.limit_op     IS 'NUM：越限比较符';
COMMENT ON COLUMN t_phm_dispose_card.limit_val    IS 'NUM：越限阈值（空表示不设越限）';
COMMENT ON COLUMN t_phm_dispose_card.target_val   IS 'STATE：目标状态编码（用于占用时长 / 是否出现过）';
COMMENT ON COLUMN t_phm_dispose_card.create_by    IS '创建人';
COMMENT ON COLUMN t_phm_dispose_card.create_time  IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_card.update_by    IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_card.update_time  IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_card.del_flag     IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_card_param ON t_phm_dispose_card (param_id);

CREATE TABLE IF NOT EXISTS t_phm_dispose_branch (
    id              BIGSERIAL       PRIMARY KEY,
    step_id         BIGINT          NOT NULL,
    seq_no          INTEGER         NOT NULL,
    branch_label    VARCHAR(64)     NOT NULL,
    next_step_id    BIGINT,
    cond_src        VARCHAR(8)      NOT NULL DEFAULT 'NONE',
    cond_card_id    BIGINT,
    cond_stat       VARCHAR(32),
    cond_op         VARCHAR(4),
    cond_val        VARCHAR(64),
    cond_atom_id    BIGINT,
    cond_group_id   BIGINT,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_branch_seq UNIQUE (step_id, seq_no),
    CONSTRAINT fk_phm_branch_step  FOREIGN KEY (step_id)       REFERENCES t_phm_dispose_step (id),
    CONSTRAINT fk_phm_branch_next  FOREIGN KEY (next_step_id)  REFERENCES t_phm_dispose_step (id),
    CONSTRAINT fk_phm_branch_card  FOREIGN KEY (cond_card_id)  REFERENCES t_phm_dispose_card (id),
    CONSTRAINT fk_phm_branch_atom  FOREIGN KEY (cond_atom_id)  REFERENCES t_phm_rule_atom (id),
    CONSTRAINT fk_phm_branch_group FOREIGN KEY (cond_group_id) REFERENCES t_phm_rule_group (id),
    CONSTRAINT ck_phm_branch_src   CHECK (cond_src IN ('NONE', 'CARD', 'ATOM', 'GROUP', 'ELSE')),
    CONSTRAINT ck_phm_branch_card  CHECK (cond_src <> 'CARD'  OR (cond_card_id IS NOT NULL AND cond_stat IS NOT NULL AND cond_op IS NOT NULL AND cond_val IS NOT NULL)),
    CONSTRAINT ck_phm_branch_atom  CHECK (cond_src <> 'ATOM'  OR cond_atom_id IS NOT NULL),
    CONSTRAINT ck_phm_branch_group CHECK (cond_src <> 'GROUP' OR cond_group_id IS NOT NULL),
    CONSTRAINT ck_phm_branch_op    CHECK (cond_op IS NULL OR cond_op IN ('>', '>=', '<', '<=', '==', '!=')),
    CONSTRAINT ck_phm_branch_self  CHECK (next_step_id IS NULL OR next_step_id <> step_id),
    CONSTRAINT ck_phm_branch_del   CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_branch               IS '步骤出口 / 判断分支：按 seq_no 从上到下判定，第一个成立的为系统预判，都不成立走 ELSE；查看/联络 1 个出口，操作 2 个（成功/未成功），判断 ≥2 个，结束无出口';
COMMENT ON COLUMN t_phm_dispose_branch.id            IS '主键';
COMMENT ON COLUMN t_phm_dispose_branch.step_id       IS '所属步骤 ID（FK t_phm_dispose_step.id）';
COMMENT ON COLUMN t_phm_dispose_branch.seq_no        IS '分支顺序（判定顺序）';
COMMENT ON COLUMN t_phm_dispose_branch.branch_label  IS '分支名称：下一步 / 是 / 否 / 正常 / 异常 / 成功 / 未成功 / 已联络 / 自定义';
COMMENT ON COLUMN t_phm_dispose_branch.next_step_id  IS '去向步骤 ID（FK t_phm_dispose_step.id，须同一流程版本；NULL = 未配置出口，发布校验拦截）';
COMMENT ON COLUMN t_phm_dispose_branch.cond_src      IS '条件类型：NONE 人工判断 / CARD 引用数据卡统计 / ATOM 复用原子规则 / GROUP 复用命名组 / ELSE 否则兜底';
COMMENT ON COLUMN t_phm_dispose_branch.cond_card_id  IS 'CARD：引用的数据卡 ID（FK t_phm_dispose_card.id，须同一步骤）';
COMMENT ON COLUMN t_phm_dispose_branch.cond_stat     IS 'CARD：统计项，如 最小、T0后再次出现';
COMMENT ON COLUMN t_phm_dispose_branch.cond_op       IS 'CARD：比较符';
COMMENT ON COLUMN t_phm_dispose_branch.cond_val      IS 'CARD：阈值';
COMMENT ON COLUMN t_phm_dispose_branch.cond_atom_id  IS 'ATOM：原子 ID（FK t_phm_rule_atom.id）';
COMMENT ON COLUMN t_phm_dispose_branch.cond_group_id IS 'GROUP：命名组 ID（FK t_phm_rule_group.id）';
COMMENT ON COLUMN t_phm_dispose_branch.create_by     IS '创建人';
COMMENT ON COLUMN t_phm_dispose_branch.create_time   IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_branch.update_by     IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_branch.update_time   IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_branch.del_flag      IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_branch_next  ON t_phm_dispose_branch (next_step_id);
CREATE INDEX IF NOT EXISTS idx_phm_branch_atom  ON t_phm_dispose_branch (cond_atom_id);
CREATE INDEX IF NOT EXISTS idx_phm_branch_group ON t_phm_dispose_branch (cond_group_id);

CREATE TABLE IF NOT EXISTS t_phm_dispose_confirm (
    id              BIGSERIAL       PRIMARY KEY,
    step_id         BIGINT          NOT NULL,
    seq_no          INTEGER         NOT NULL,
    confirm_text    VARCHAR(512)    NOT NULL,
    role_code       VARCHAR(16)     NOT NULL,
    is_required     SMALLINT        NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_confirm_seq UNIQUE (step_id, seq_no),
    CONSTRAINT fk_phm_confirm_step FOREIGN KEY (step_id) REFERENCES t_phm_dispose_step (id),
    CONSTRAINT ck_phm_confirm_role CHECK (role_code IN ('DRIVER', 'EXPERT', 'SYSTEM')),
    CONSTRAINT ck_phm_confirm_req  CHECK (is_required IN (0, 1)),
    CONSTRAINT ck_phm_confirm_del  CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_dispose_confirm              IS '步骤确认项：按执行角色定义（一期由专家代录），操作步骤选“成功”前必须全部勾完';
COMMENT ON COLUMN t_phm_dispose_confirm.id           IS '主键';
COMMENT ON COLUMN t_phm_dispose_confirm.step_id      IS '步骤 ID（FK t_phm_dispose_step.id）';
COMMENT ON COLUMN t_phm_dispose_confirm.seq_no       IS '顺序';
COMMENT ON COLUMN t_phm_dispose_confirm.confirm_text IS '确认内容，如 机车已停稳并做好防溜';
COMMENT ON COLUMN t_phm_dispose_confirm.role_code    IS '执行角色：DRIVER 司机 / EXPERT 专家 / SYSTEM 系统';
COMMENT ON COLUMN t_phm_dispose_confirm.is_required  IS '是否必勾：1 是 0 否';
COMMENT ON COLUMN t_phm_dispose_confirm.create_by    IS '创建人';
COMMENT ON COLUMN t_phm_dispose_confirm.create_time  IS '创建时间';
COMMENT ON COLUMN t_phm_dispose_confirm.update_by    IS '最后修改人';
COMMENT ON COLUMN t_phm_dispose_confirm.update_time  IS '最后修改时间';
COMMENT ON COLUMN t_phm_dispose_confirm.del_flag     IS '逻辑删除：0 正常 1 已删除';

-- =====================================================================================
-- 7. 模拟历史事件（历史故障试跑用；原型 TRIALS，非真实回放）
-- =====================================================================================
CREATE TABLE IF NOT EXISTS t_phm_sim_event (
    id              BIGSERIAL       PRIMARY KEY,
    event_code      VARCHAR(32)     NOT NULL,
    fault_rule_id   BIGINT          NOT NULL,
    event_title     VARCHAR(256)    NOT NULL,
    expect_outcome  VARCHAR(64),
    cc              VARCHAR(32),
    sd              VARCHAR(32),
    wz              VARCHAR(256),
    jl              VARCHAR(256),
    sjxm            VARCHAR(64),
    fssj            TIMESTAMP       NOT NULL,
    is_sample       SMALLINT        NOT NULL DEFAULT 1,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_sim_event_code UNIQUE (event_code),
    CONSTRAINT fk_phm_sim_event_fault FOREIGN KEY (fault_rule_id) REFERENCES t_phm_fault_rule (id),
    CONSTRAINT ck_phm_sim_event_sample CHECK (is_sample IN (0, 1)),
    CONSTRAINT ck_phm_sim_event_del    CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_sim_event                IS '历史故障试跑事件（一期为模拟数据）：一条事件对应一个故障的一次报出，T0 = fssj';
COMMENT ON COLUMN t_phm_sim_event.id             IS '主键';
COMMENT ON COLUMN t_phm_sim_event.event_code     IS '事件编码，如 EV1（业务唯一）';
COMMENT ON COLUMN t_phm_sim_event.fault_rule_id  IS '故障规则 ID（FK t_phm_fault_rule.id）';
COMMENT ON COLUMN t_phm_sim_event.event_title    IS '事件标题';
COMMENT ON COLUMN t_phm_sim_event.expect_outcome IS '预期走向，如 正常消除 / 需要升级';
COMMENT ON COLUMN t_phm_sim_event.cc             IS '运行信息：车次';
COMMENT ON COLUMN t_phm_sim_event.sd             IS '运行信息：速度（含单位文本）';
COMMENT ON COLUMN t_phm_sim_event.wz             IS '运行信息：位置';
COMMENT ON COLUMN t_phm_sim_event.jl             IS '运行信息：交路';
COMMENT ON COLUMN t_phm_sim_event.sjxm           IS '运行信息：司机姓名（脱敏）';
COMMENT ON COLUMN t_phm_sim_event.fssj           IS '发生时间 T0';
COMMENT ON COLUMN t_phm_sim_event.is_sample      IS '是否模拟数据：1 模拟 0 真实回放';
COMMENT ON COLUMN t_phm_sim_event.create_by      IS '创建人';
COMMENT ON COLUMN t_phm_sim_event.create_time    IS '创建时间';
COMMENT ON COLUMN t_phm_sim_event.update_by      IS '最后修改人';
COMMENT ON COLUMN t_phm_sim_event.update_time    IS '最后修改时间';
COMMENT ON COLUMN t_phm_sim_event.del_flag       IS '逻辑删除：0 正常 1 已删除';
CREATE INDEX IF NOT EXISTS idx_phm_sim_event_fault ON t_phm_sim_event (fault_rule_id);

CREATE TABLE IF NOT EXISTS t_phm_sim_event_point (
    id              BIGSERIAL       PRIMARY KEY,
    event_id        BIGINT          NOT NULL,
    point_type      VARCHAR(8)      NOT NULL,
    obj_code        VARCHAR(64)     NOT NULL,
    offset_sec      INTEGER         NOT NULL,
    num_val         NUMERIC(18, 4),
    txt_val         VARCHAR(64),
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_sim_point UNIQUE (event_id, point_type, obj_code, offset_sec),
    CONSTRAINT fk_phm_sim_point_event FOREIGN KEY (event_id) REFERENCES t_phm_sim_event (id),
    CONSTRAINT ck_phm_sim_point_type CHECK (point_type IN ('SERIES', 'STATE', 'FAULT')),
    CONSTRAINT ck_phm_sim_point_val  CHECK ((point_type = 'SERIES' AND num_val IS NOT NULL) OR (point_type = 'STATE' AND txt_val IS NOT NULL) OR point_type = 'FAULT'),
    CONSTRAINT ck_phm_sim_point_del  CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_sim_event_point             IS '试跑事件数据点：SERIES 数值曲线点 / STATE 状态变位点 / FAULT 关联故障出现时刻；时间用相对 T0 的秒偏移';
COMMENT ON COLUMN t_phm_sim_event_point.id          IS '主键';
COMMENT ON COLUMN t_phm_sim_event_point.event_id    IS '事件 ID（FK t_phm_sim_event.id）';
COMMENT ON COLUMN t_phm_sim_event_point.point_type  IS '点类型：SERIES 数值 / STATE 状态变位 / FAULT 故障出现';
COMMENT ON COLUMN t_phm_sim_event_point.obj_code    IS 'SERIES/STATE 为参数编码；FAULT 为故障代码';
COMMENT ON COLUMN t_phm_sim_event_point.offset_sec  IS '相对 T0 的秒偏移（负数为 T0 之前）';
COMMENT ON COLUMN t_phm_sim_event_point.num_val     IS 'SERIES：数值';
COMMENT ON COLUMN t_phm_sim_event_point.txt_val     IS 'STATE：变位后的状态编码';
COMMENT ON COLUMN t_phm_sim_event_point.create_by   IS '创建人';
COMMENT ON COLUMN t_phm_sim_event_point.create_time IS '创建时间';
COMMENT ON COLUMN t_phm_sim_event_point.update_by   IS '最后修改人';
COMMENT ON COLUMN t_phm_sim_event_point.update_time IS '最后修改时间';
COMMENT ON COLUMN t_phm_sim_event_point.del_flag    IS '逻辑删除：0 正常 1 已删除';

CREATE TABLE IF NOT EXISTS t_phm_sim_event_answer (
    id              BIGSERIAL       PRIMARY KEY,
    event_id        BIGINT          NOT NULL,
    step_code       VARCHAR(16)     NOT NULL,
    answer_label    VARCHAR(64)     NOT NULL,
    create_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    create_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by       VARCHAR(64)     NOT NULL DEFAULT 'system',
    update_time     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del_flag        SMALLINT        NOT NULL DEFAULT 0,
    CONSTRAINT uk_phm_sim_answer UNIQUE (event_id, step_code),
    CONSTRAINT fk_phm_sim_answer_event FOREIGN KEY (event_id) REFERENCES t_phm_sim_event (id),
    CONSTRAINT ck_phm_sim_answer_del CHECK (del_flag IN (0, 1))
);
COMMENT ON TABLE  t_phm_sim_event_answer              IS '试跑事件预置答案：人工判断 / 操作步骤在该事件里记录的选择（按步骤编码对应，跨流程版本通用）';
COMMENT ON COLUMN t_phm_sim_event_answer.id           IS '主键';
COMMENT ON COLUMN t_phm_sim_event_answer.event_id     IS '事件 ID（FK t_phm_sim_event.id）';
COMMENT ON COLUMN t_phm_sim_event_answer.step_code    IS '步骤编码，如 S3';
COMMENT ON COLUMN t_phm_sim_event_answer.answer_label IS '选择的分支名称，如 成功 / 不能';
COMMENT ON COLUMN t_phm_sim_event_answer.create_by    IS '创建人';
COMMENT ON COLUMN t_phm_sim_event_answer.create_time  IS '创建时间';
COMMENT ON COLUMN t_phm_sim_event_answer.update_by    IS '最后修改人';
COMMENT ON COLUMN t_phm_sim_event_answer.update_time  IS '最后修改时间';
COMMENT ON COLUMN t_phm_sim_event_answer.del_flag     IS '逻辑删除：0 正常 1 已删除';
