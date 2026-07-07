# Vercel 迁移实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Hexo + Butterfly 博客从 GitHub Pages 迁移到 Vercel，修复 url/特效/图片路径问题，完成首次 git 提交并推送。

**Architecture:** 修改 Hexo 配置 + Butterfly 主题配置 + 新增 vercel.json + 迁移图片资源 + git 首次提交推送 main 分支。Vercel 监听 main 分支自动构建部署。

**Tech Stack:** Hexo 6.3.0、Butterfly 主题（手工安装）、Vercel 静态托管、git。

## Global Constraints

- 操作系统: Windows 11，shell 使用 Unix 语法（bash），路径用正斜杠
- Hexo 版本: 6.3.0（`package.json` 已锁）
- 主题: `themes/butterfly` 手工下载，必须随 git 仓库提交
- 域名: 使用 Vercel 默认 `*.vercel.app` 子域名，`url = https://enosmith.vercel.app`
- 工作目录: `F:/Blog`
- 不修改: `source/_posts/`、`scaffolds/`、`themes/butterfly/` 内部文件、`package.json`
- 不提交: `node_modules/`、`public/`、`db.json`、`*.log`、`.deploy*/`、`_multiconfig.yml`、`Thumbs.db`、`.DS_Store`
- 提交信息风格: 中文 「feat: 」/「fix: 」前缀 + 简短描述
- 测试方式: 本项目为配置/部署类，无单元测试；以「构建成功 + 文件存在 + grep 验证配置」作为每个任务的验证手段

---

## Task 1: 创建 vercel.json

**Files:**
- Create: `F:/Blog/vercel.json`

**Interfaces:**
- Produces: `vercel.json` —— Vercel 部署配置，后续 git 提交时纳入版本控制

- [ ] **Step 1: 确认父目录存在**

Run: `ls F:/Blog/package.json`
Expected: 输出 `F:/Blog/package.json`（说明 F:/Blog 存在）

- [ ] **Step 2: 写入 vercel.json**

写入文件 `F:/Blog/vercel.json`，完整内容：

```json
{
  "name": "enosmith-blog",
  "buildCommand": "npx hexo clean && npx hexo generate",
  "outputDirectory": "public",
  "framework": "hexo",
  "cleanUrls": true,
  "trailingSlash": false
}
```

- [ ] **Step 3: 验证文件写入成功 + JSON 合法**

Run: `cat F:/Blog/vercel.json`
Expected: 输出上一步写入的完整 JSON 内容

Run: `node -e "JSON.parse(require('fs').readFileSync('F:/Blog/vercel.json','utf8')); console.log('OK')"`
Expected: 输出 `OK`（JSON 解析无异常）

- [ ] **Step 4: 暂不提交**

本任务不单独 commit，与后续任务一起在 Task 7 统一提交。

---

## Task 2: 修复 _config.yml 的 url

**Files:**
- Modify: `F:/Blog/_config.yml:16`

**Interfaces:**
- Produces: `_config.yml` 中 `url: https://enosmith.vercel.app`，Vercel 部署后页面内绝对链接指向正确域名

- [ ] **Step 1: 读取当前 url 行确认**

Run: `grep -n "^url:" F:/Blog/_config.yml`
Expected: 输出 `16:url: http://enosmith.com`

- [ ] **Step 2: 修改 url**

用 Edit 工具把 `F:/Blog/_config.yml` 中：

```
url: http://enosmith.com
```

替换为：

```
url: https://enosmith.vercel.app
```

- [ ] **Step 3: 验证修改成功**

Run: `grep -n "^url:" F:/Blog/_config.yml`
Expected: 输出 `16:url: https://enosmith.vercel.app`

- [ ] **Step 4: 暂不提交**

后续在 Task 7 统一提交。

---

## Task 3: 精简特效 + 切换 CDN（_config.butterfly.yml）

**Files:**
- Modify: `F:/Blog/_config.butterfly.yml` 多处

**Interfaces:**
- Produces: 5 个特效中关闭 2 个（canvas_nest、activate_power_mode）+ 副标题打字效果关闭 + 第三方 CDN 从 jsdelivr 切到 cdnjs

- [ ] **Step 1: 关闭 canvas_nest**

用 Edit 工具把 `F:/Blog/_config.butterfly.yml` 中：

```
canvas_nest:
  enable: true
  color: '0,0,255' #color of lines, default: '0,0,0'; RGB values: (R,G,B).(note: use ',' to separate.)
```

替换为：

```
canvas_nest:
  enable: false
  color: '0,0,255' #color of lines, default: '0,0,0'; RGB values: (R,G,B).(note: use ',' to separate.)
```

- [ ] **Step 2: 关闭 activate_power_mode**

用 Edit 工具把 `F:/Blog/_config.butterfly.yml` 中：

```
activate_power_mode:
  enable: true
  colorful: true # open particle animation (冒光特效)
```

替换为：

```
activate_power_mode:
  enable: false
  colorful: true # open particle animation (冒光特效)
```

- [ ] **Step 3: 关闭 subtitle 打字效果**

用 Edit 工具把 `F:/Blog/_config.butterfly.yml` 中：

```
subtitle:
  enable: true
  # Typewriter Effect (打字效果)
  effect: true
```

替换为：

```
subtitle:
  enable: true
  # Typewriter Effect (打字效果)
  effect: false
```

- [ ] **Step 4: 切换第三方 CDN 到 cdnjs**

用 Edit 工具把 `F:/Blog/_config.butterfly.yml` 中：

```
  third_party_provider: jsdelivr
```

替换为：

```
  third_party_provider: cdnjs
```

- [ ] **Step 5: 验证 4 处修改全部生效**

Run: `grep -nA1 "^canvas_nest:" F:/Blog/_config.butterfly.yml | head -2`
Expected: 第二行含 `enable: false`

Run: `grep -nA1 "^activate_power_mode:" F:/Blog/_config.butterfly.yml | head -2`
Expected: 第二行含 `enable: false`

Run: `grep -nB1 "effect: false$" F:/Blog/_config.butterfly.yml | head -3`
Expected: 显示 `subtitle:` 段下的 `effect: false`

Run: `grep -n "third_party_provider:" F:/Blog/_config.butterfly.yml`
Expected: 输出 `  third_party_provider: cdnjs`

- [ ] **Step 6: 暂不提交**

后续在 Task 7 统一提交。

---

## Task 4: 迁移图片资源从 public/img 到 source/img

**Files:**
- Move: `F:/Blog/public/img/*` (18 个文件) → `F:/Blog/source/img/`
- 临时创建: `F:/Blog/source/img/` 目录

**Interfaces:**
- Produces: `source/img/` 含 18 张图片，`public/img/` 被清空（hexo 构建时会重新生成 public/img/）

**为什么这样设计**: `public/` 是 Hexo 构建输出目录，`hexo clean` 会清空它；`source/` 下的非 md 文件构建时原样拷贝到 `public/`。把图片放 source/img/ 是正确做法。

- [ ] **Step 1: 确认 public/img 内容**

Run: `ls F:/Blog/public/img/`
Expected: 输出 18 个文件名，包含 `logo.png`、`avatar.jpg`、`index_img.png`、`default_cover1.jpg` 到 `default_cover10.jpg`、`default_top_img.jpg`、`404.jpg`、`friend_404.gif`、`favicon.png`、`IMG_0688.JPG`

- [ ] **Step 2: 创建 source/img 目录**

Run: `mkdir -p F:/Blog/source/img`
Expected: 无输出（目录已创建或已存在）

- [ ] **Step 3: 移动 18 张图片**

Run: `mv F:/Blog/public/img/* F:/Blog/source/img/`
Expected: 无输出

- [ ] **Step 4: 验证 public/img 已空 + source/img 含 18 个文件**

Run: `ls F:/Blog/public/img/ 2>&1`
Expected: 输出空，或者 `ls: cannot access 'F:/Blog/public/img': No such file or directory`（目录可能也被一并移走，无妨）

Run: `ls F:/Blog/source/img/ | wc -l`
Expected: 输出 `18`

- [ ] **Step 5: 验证关键文件存在**

Run: `ls F:/Blog/source/img/logo.png F:/Blog/source/img/avatar.jpg F:/Blog/source/img/index_img.png F:/Blog/source/img/default_top_img.jpg F:/Blog/source/img/404.jpg F:/Blog/source/img/friend_404.gif`
Expected: 6 行文件路径全部列出，无 `No such file` 错误

Run: `ls F:/Blog/source/img/default_cover1.jpg F:/Blog/source/img/default_cover10.jpg`
Expected: 2 行文件路径全部列出

- [ ] **Step 6: 暂不提交**

后续在 Task 7 统一提交。

---

## Task 5: 本地构建验证

**Files:**
- 无文件变更，仅执行构建命令验证

**Interfaces:**
- Produces: 验证 `public/` 被重新生成且含 `public/img/` 的 18 张图片（证明 source/img → public/img 自动拷贝链路正确）

- [ ] **Step 1: 执行 hexo clean**

Run: `cd F:/Blog && npx hexo clean`
Expected: 输出 `INFO  Deleted database.json.` 和 `INFO  Deleted public folder.`（或类似 INFO 行），无 ERROR

如报 `npx: command not found`：先确认 Node 已安装 `node -v`；该错误应不出现，因 package.json 已存在。

- [ ] **Step 2: 执行 hexo generate**

Run: `cd F:/Blog && npx hexo generate`
Expected: 大量 `INFO  Generated: ...` 行，最后一行类似 `INFO  Files generated in ...ms`，无 ERROR/FATAL

如出现 FATAL，最可能的原因：
- `themes/butterfly` 缺文件（不太可能，刚验证存在）
- `_config.butterfly.yml` YAML 语法错误（返回 Task 3 检查缩进）

- [ ] **Step 3: 验证 public/img 重新生成且含 18 张图**

Run: `ls F:/Blog/public/img/ | wc -l`
Expected: 输出 `18`

Run: `ls F:/Blog/public/img/logo.png F:/Blog/public/img/avatar.jpg`
Expected: 2 行路径列出，无错误

- [ ] **Step 4: 启动本地 server 抽查（可选，需手动浏览器访问）**

Run（后台）: `cd F:/Blog && npx hexo server`
Expected: 输出 `INFO  Start processing`、`INFO  Hexo is running at http://localhost:4000/`

用户可选地用浏览器打开 http://localhost:4000/ 抽查首页图片、3 个保留特效（彩带、动态彩带、点击烟火）是否正常，2 个已关特效（粒子连线、打字震动）是否消失。

执行后用 Ctrl+C 停止，或后续 Task 7 提交前用 TaskStop 停止后台进程。

---

## Task 6: 检查 .gitignore 与 themes/butterfly 入库准备

**Files:**
- Verify: `F:/Blog/.gitignore`
- Verify: `F:/Blog/themes/butterfly/` 是否就绪提交

**Interfaces:**
- Produces: 确认 `.gitignore` 忽略 `public/`、`node_modules/`、`db.json` 等，但**不**忽略 `themes/butterfly/`、`source/`、`_config*.yml`、`vercel.json`

- [ ] **Step 1: 读取当前 .gitignore**

Run: `cat F:/Blog/.gitignore`
Expected: 输出含
```
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
_multiconfig.yml
```

- [ ] **Step 2: 确认 themes/butterfly 未被忽略**

Run: `grep -n "themes" F:/Blog/.gitignore`
Expected: 无输出（说明 .gitignore 没有忽略 themes/）

- [ ] **Step 3: 确认 themes/butterfly 体积可控**

Run: `du -sh F:/Blog/themes/butterfly`
Expected: 输出小于 50MB（典型值 5-15MB）

如异常巨大（>100MB），检查是否有 `themes/butterfly/.git` 子目录（如有则需先删除，避免子模块冲突），但**本任务不主动删除**，仅记录状况。

执行: `ls F:/Blog/themes/butterfly/.git 2>&1`
Expected: 输出 `ls: cannot access ...: No such file or directory`（说明无内嵌 git，正常）

如发现有内嵌 .git，停下来询问用户，不要继续。

- [ ] **Step 4: 暂不提交**

后续在 Task 7 统一提交。

---

## Task 7: git 首次提交并推送到 main

**Files:**
- 无新文件，仅 git 操作

**Interfaces:**
- Produces: 远程仓库 `https://github.com/Enosmith/Enosmith.git` 的 `main` 分支含一次完整提交，Vercel 将来导入此仓库即可触发部署

**重要前置**: 本任务涉及 git 推送（影响远程共享状态），**执行前需向用户确认**。

- [ ] **Step 1: 当前状态摸底**

Run: `cd F:/Blog && git status --short | head -30`
Expected: 大量 `??` 开头的未跟踪文件（因为从未提交过）

Run: `cd F:/Blog && git log --oneline -3 2>&1`
Expected: 输出 `fatal: your current branch 'master' does not have any commits yet`（确认无历史提交）

Run: `cd F:/Blog && git branch --show-current`
Expected: 输出 `master`

- [ ] **Step 2: 把本地 master 分支重命名为 main**

Run: `cd F:/Blog && git branch -M main`
Expected: 无输出

Run: `cd F:/Blog && git branch --show-current`
Expected: 输出 `main`

- [ ] **Step 3: 选择性添加文件到暂存区**

**注意**: 不使用 `git add -A` 或 `git add .`，避免误加 `node_modules/`。但 `.gitignore` 已正确忽略 `node_modules/`、`public/`、`db.json`，所以用 `git add` 配合路径是安全的。

执行以下命令一个一个 add（或用 `git add` 加多个路径）:

```bash
cd F:/Blog && \
git add .gitignore .github _config.yml _config.butterfly.yml _config.landscape.yml \
        package.json package-lock.json scaffolds source themes vercel.json \
        docs "新建文章.cmd" "本地预览.cmd"
```

Expected: 无输出（或可能有若干 `warning: LF will be replaced by CRLF` 警告，无视）

**说明**: `node_modules/`、`public/` 因 `.gitignore` 被自动排除；`db.json` 也被忽略。

- [ ] **Step 4: 确认暂存区状态干净**

Run: `cd F:/Blog && git status --short | head -20`
Expected: 大量 `A` 开头行（Added），无 `node_modules/` 路径、无 `public/` 路径

Run: `cd F:/Blog && git status --short | grep -E "node_modules|public/" | head -5`
Expected: 无输出（说明 node_modules 和 public 都没进暂存区）

Run: `cd F:/Blog && git diff --cached --stat | tail -3`
Expected: 输出类似 `N files changed, M insertions(+)`，文件数应 > 100（含 themes/butterfly 全部）

- [ ] **Step 5: 暂停并向用户确认推送**

**这是关键确认点。** 输出以下信息给用户：

```
即将提交并推送到远程仓库：
- 远程: https://github.com/Enosmith/Enosmith.git
- 分支: main（从本地 master 重命名而来）
- 提交内容: 整个博客项目（约 N 个文件，含 themes/butterfly 主题）
- 提交后 Vercel 不会自动部署，需要你登录 vercel.com 导入这个 GitHub 仓库
确认推送吗？(yes / 暂不推送)
```

等待用户回复 `yes` 或拒绝。

- [ ] **Step 6: 创建首次提交**

**前置**: 用户回复 yes 后执行。

```bash
cd F:/Blog && git commit -m "$(cat <<'EOF'
feat: 博客初始化 + Vercel 部署配置

- Hexo 6.3.0 + Butterfly 主题（手工安装版）
- vercel.json 静态托管配置
- url 切到 https://enosmith.vercel.app
- 精简特效：关闭 canvas_nest 和 activate_power_mode，保留彩带/动态彩带/点击烟火
- 第三方 CDN 从 jsdelivr 切到 cdnjs
- 图片资源从 public/img 迁到 source/img
EOF
)"
```

Expected: 输出 `N files changed, M insertions(+)`，`create mode 100644 ...` 多行，无 ERROR

- [ ] **Step 7: 推送到远程 main**

```bash
cd F:/Blog && git push -u origin main
```

Expected: 输出 `Writing objects: 100%`、`Branch 'main' set up to track 'origin/main'`，`* [new branch] main -> main`

如提示认证失败（`Authentication failed`）：停下来告诉用户需要 GitHub PAT（的个人访问令牌），让用户用 `! gh auth login` 或手动配置凭据后再次执行 push；**不要尝试用任何方式绕过认证**。

- [ ] **Step 8: 验证远程 main 已有提交**

Run: `cd F:/Blog && git log --oneline -3`
Expected: 输出 1 行提交摘要（刚才那次），hash 为 7-40 位十六进制

Run: `cd F:/Blog && git status`
Expected: `On branch main`、`Your branch is up to date with 'origin/main'`、`nothing to commit, working tree clean`

---

## Task 8: 用户在 Vercel 控制台完成导入（手动步骤说明）

**Files:**
- 无文件操作，纯指引

**Interfaces:**
- Produces: Vercel 项目上线，访问 `https://enosmith.vercel.app` 可见博客

**这一步用户手动执行，Claude 仅提供指引。**

- [ ] **Step 1: 登录 Vercel**

用户打开 https://vercel.com/ ，用 GitHub 账号登录（一键登录）。

- [ ] **Step 2: 导入项目**

- 点击 `Add New...` → `Project`
- 在 `Import Git Repository` 列表里找到 `Enosmith/Enosmith`
- 点 `Import`

- [ ] **Step 3: 确认构建配置**

- Framework Preset: Vercel 应自动识别为 `Hexo`，如未识别手动选 `Hexo`
- Build Command: 应显示 `npx hexo clean && npx hexo generate`（来自 vercel.json）
- Output Directory: 应显示 `public`
- Install Command: 留默认（`npm install`）或填 `npm install`
- 点 `Deploy`

- [ ] **Step 4: 等待构建完成**

Vercel 控制台会显示构建日志，预计 1-3 分钟。绿色 `Ready` 状态即成功。

- [ ] **Step 5: 验证访问**

用户浏览器打开 Vercel 给的域名（格式 `enosmith-blog-xxx.vercel.app` 或 `enosmith.vercel.app` 视项目名）。

验证清单：
- 首页加载正常，无白屏
- `source/img/` 引用的图片正常显示（logo、avatar、index_img、default_cover）
- 3 个保留特效正常（静止彩带、动态彩带、点击烟火）
- 2 个已关特效消失（粒子线条、打字震动）
- 文章页打开测试一篇文章，图片正常

- [ ] **Step 6: 若后续要修改 url 为最终域名**

如果 Vercel 实际分配的项目域名不是 `enosmith.vercel.app`（可能是 `enosmith-blog.vercel.app` 或带哈希后缀），用户告诉 Claude 实际域名后，Claude 修改 `_config.yml` 的 `url` 为实际域名，commit + push，Vercel 自动重新部署。

---

## Spec 覆盖自检

- 3.1 Vercel 部署 → Task 1（vercel.json）+ Task 8（控制台导入）
- 3.2 修复 url → Task 2
- 3.3 精简特效 → Task 3 Step 1-3
- 3.4 CDN 切换 → Task 3 Step 4
- 3.5 图片迁移 → Task 4
- 3.6 git 提交与推送 → Task 5-7（含本地构建验证、.gitignore 检查、提交推送）
- 测试验证（spec 七）→ Task 5 + Task 8 Step 5
- 风险（themes/butterfly 未入库）→ Task 6 Step 2-3 + Task 7 Step 3 显式 add themes/

无遗漏。