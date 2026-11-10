# 机车 PHM 故障规则管理工作台

把原型 V5.1 的单页工作台做成前后端分离项目。故障规则按 **车型 + 来源 + 故障代码** 维护，组合式在服务端展开成零 JSON 表达式并落库；处置流程支持草稿直接发布和历史事件试跑。

示例流程、安全提示和试跑事件都是演示数据，不是正式规程。

## 目录

| 路径 | 内容 |
|---|---|
| `backend/` | Spring Boot 2.7 / JDK 8 / MyBatis-Plus |
| `frontend/` | Vue 2.6 + Vue Router + Vuex + Element UI + Axios + ECharts |
| `db/` | 19 张 `t_phm_` 表的建表、种子、样例查询、ER 图。`01_schema.sql` 不改 |
| `docs/` | 技术栈评估、接口清单、部署说明 |

## 本地启动

需要 JDK 8、Maven、Node.js、PostgreSQL（PG 兼容模式，本地用 PostgreSQL 16 验证过）。

```bash
# 1. 建库并装入设计稿（顺序不能反）
createdb phm_rule
psql -d phm_rule -f db/01_schema.sql
psql -d phm_rule -f db/02_seed.sql

# 2. 后端。口令走环境变量，仓库里没有 .env
cd backend
export DB_URL=jdbc:postgresql://127.0.0.1:5432/phm_rule
export DB_USERNAME=phm
export DB_PASSWORD=
export CORS_ALLOWED_ORIGINS=http://localhost:8081
export PORT=8080
mvn spring-boot:run

# 3. 前端
cd frontend
npm install
npm run serve
```

浏览器打开 `http://localhost:8081/`。接口文档在 `http://localhost:8080/swagger-ui.html`。健康检查是 `GET /api/health`。

操作者写入审计字段时读请求头 `X-Operator`，不传则为 `system`。当前没有登录。

## 测试

```bash
cd backend && mvn test
cd frontend && npm run lint && npm run typecheck && npm run build
```

集成测试会清空并重建 `phm_rule_test`（可用 `DB_URL` 覆盖），再执行 `db/01_schema.sql` 和 `db/02_seed.sql`。请使用单独的测试库，不要指向正式库。

## 环境变量

| 变量 | 用在 | 说明 |
|---|---|---|
| `PORT` | 后端 | HTTP 端口，Render 会注入。默认 8080 |
| `DB_URL` | 后端 | JDBC 地址 |
| `DB_USERNAME` | 后端 | 数据库用户 |
| `DB_PASSWORD` | 后端 | 数据库口令。本地 trust 认证可以留空 |
| `CORS_ALLOWED_ORIGINS` | 后端 | 逗号分隔的前端来源，`*` 表示不限制 |
| `VUE_APP_API_BASE` | 前端构建 | 后端根地址，例如 `https://api.example.com`。开发时空着，走 devServer 代理 |

示例见 `backend/.env.example` 和 `frontend/.env.example`。不要把填了口令的 `.env` 提交进仓库。
