# 博客迁移到 Vercel 设计文档

日期: 2026-07-07
作者: 邓晖（与 Claude 协作）
状态: 已确认待实施

## 一、背景与问题

当前博客基于 Hexo + Butterfly 主题搭建，原本部署在 GitHub Pages 上，存在两个问题：

1. **国内访问慢**: GitHub Pages 在国内访问非常慢，有时打不开
2. **特效卡顿**: 开启了 5 个特效（彩带、动态彩带、粒子连线、点击烟火、打字震动），其中粒子连线持续重绘 99 条线 + 打字震动持续触发，造成明显卡顿

补充发现:

- `_config.yml` 中 `url: http://enosmith.com` 但用户实际并未购买 `enosmith.com` 域名
- 博客引用的 18 张图片资源错放在 `F:/Blog/public/img/`，而 `public/` 是 Hexo 构建输出目录，运行 `hexo clean` 会被清空，存在丢失风险
- 本地 git 仓库 `F:/Blog` 与远程 `Enosmith/Enosmith.git` 尚无任何提交（`git ls-files` 返回 0）；`themes/butterfly` 是手工下载的主题，未通过 npm 安装

## 二、目标

1. 把博客迁移到 Vercel，国内访问速度显著优于 GitHub Pages
2. 使用 Vercel 免费子域名 `*.vercel.app`，无需购买域名
3. 精简特效到 3 个核心项，保留视觉风格同时降低 CPU 负载
4. 修复图片资源的错放路径，避免 `hexo clean` 后丢失
5. 把项目源码首次提交到 git 远程仓库，让 Vercel 能监听并自动部署

## 三、方案

### 3.1 部署平台：Vercel

- 新建 `vercel.json`，Hexo 静态站点配置
- 输出目录: `public`
- 构建命令: `npx hexo clean && npx hexo generate`
- 监听 main 分支（本地 master 推送后，Vercel 自动构建）
- 域名: 直接使用 Vercel 默认分配的 `*.vercel.app`，免费 + 自动 HTTPS + 全球 CDN（含香港/新加坡节点，国内友好）
- 将来若购买自定义域名，可在 Vercel 控制台一键绑定（不在本次范围内）

### 3.2 修复 `_config.yml`

- `url`: `http://enosmith.com` → `https://enosmith.vercel.app`
- 保留 `deploy`（git deployer）作为备用，不影响 Vercel 部署

### 3.3 精简特效（`_config.butterfly.yml`）

| 特效 | 原 | 新 | 原因 |
|---|---|---|---|
| `canvas_ribbon`（静止彩带） | enable: true | 保持 true | 轻量美观 |
| `canvas_fluttering_ribbon`（动态彩带） | enable: true | 保持 true | 视觉核心 |
| `canvas_nest`（粒子连线，99 条线持续重绘） | enable: true | **enable: false** | 最耗 CPU |
| `fireworks`（点击烟火） | enable: true | 保持 true | 保留点击反馈 |
| `activate_power_mode`（打字震动+粒子） | enable: true | **enable: false** | 持续触发最卡顿 |
| `subtitle.effect`（typed.js 打字效果） | true | **false** | 依赖 jsdelivr CDN，国内不稳 |

最终保留 3 个特效：canvas_ribbon + canvas_fluttering_ribbon + fireworks。

### 3.4 CDN 配置（`_config.butterfly.yml`）

- `CDN.third_party_provider`: `jsdelivr` → `cdnjs`（国内更稳）
- `CDN.internal_provider` 保持 `local`

### 3.5 图片资源迁移

- 18 张图片从 `F:/Blog/public/img/` 移动（mv，非复制）到 `F:/Blog/source/img/`
- Hexo 构建会自动把 `source/` 下非 md 文件原样拷贝到 `public/`，永久存在
- 验证清单: `logo.png`、`avatar.jpg`、`index_img.png`、`default_top_img.jpg`、`default_cover1.jpg ~ default_cover10.jpg`、`404.jpg`、`friend_404.gif`、`favicon.png`、`IMG_0688.JPG`
- 不动 `source/_posts/` 下的文章图片资产

### 3.6 git 提交策略

- 调整 `.gitignore`: 保留 `node_modules/`、`public/`、`db.json` 等忽略项
- 把 `themes/butterfly` 整个目录纳入 git 跟踪（手工安装的主题必须随仓库提交，否则 Vercel 构建失败）
- 把整个项目首次提交并推送到 `origin/main`
  - 本地仓库当前 master 分支无任何提交，远程 `Enosmith/Enosmith.git` 是空仓库
  - 步骤: `git branch -M main`（把本地 master 重命名为 main）→ `git add ...` → `git commit` → `git push -u origin main`
  - 使用 main 作为默认分支（Vercel 期望）
- 提交内容范围: `_config.yml`、`_config.butterfly.yml`、`package.json`、`package-lock.json`、`scaffolds/`、`source/`（含迁移后的 img/）、`themes/butterfly/`、`vercel.json`、`.gitignore`、`.github/`
- 不提交: `node_modules/`、`public/`、`db.json`、`*.log`、`.deploy*/`、`_multiconfig.yml`、`Thumbs.db`、`.DS_Store`

## 四、组件与文件清单

| 文件 | 操作 | 说明 |
|---|---|---|
| `vercel.json` | 新建 | Hexo 静态站构建配置 |
| `_config.yml` | 修改 | 修复 url |
| `_config.butterfly.yml` | 修改 | 精简特效 + 切换 CDN |
| `source/img/*` (18 张图) | 新增 | 从 public/img 迁入 |
| `public/img/*` | 删除 | 迁移后清理 |
| `.gitignore` | 保留现状 | 忽略规则已正确 |
| `themes/butterfly/` | git add | 首次纳入版本控制 |
| `git 首次提交 + 推送 main` | 执行 | 让 Vercel 能拉到完整源码 |

## 五、数据流

1. 本地修改文件 → git commit → push origin main
2. Vercel 监听 main 分支 push → 自动拉取
3. Vercel 执行 `npx hexo clean && npx hexo generate`
4. Hexo 从 `source/`（含 source/img/）构建到 `public/`
5. Vercel 把 `public/` 作为静态资源发布到全球 CDN
6. 用户访问 `https://enosmith.vercel.app` → 命中最近 CDN 节点

## 六、错误处理

- 若 Vercel 构建失败：
  - 检查 `themes/butterfly` 是否完整提交
  - 检查 `package.json` 与 `package-lock.json` 一致性
- 若图片 404：核对 `_config.butterfly.yml` 引用路径与 `source/img/` 实际文件名
- 若特效仍卡：进一步关闭 `fireworks` 或关闭 `canvas_fluttering_ribbon`

## 七、测试验证

- 本地 `npx hexo clean && npx hexo generate` 构建成功
- `npx hexo server` 本地预览 http://localhost:4000 看特效正常、图片正常
- 推送后 Vercel 控制台构建绿色（成功）
- 浏览器访问 `https://enosmith.vercel.app` 首页正常加载
- 检查 3 个保留特效正常工作（彩带、动态彩带、点击烟火）
- 检查文章页图片正常显示
- 测试国内网络下首次加载耗时（应显著优于 GitHub Pages）

## 八、不在本次范围

- 自定义域名 `enosmith.com` 的购买与绑定
- PWA、Algolia 搜索、评论系统等额外功能
- 文章内容本身的修改
- 文章 `_posts/` 下的图片资产整理

## 九、风险

- Vercel 免费版每月 100GB 流量，对个人博客足够
- `themes/butterfly` 体积较大（含 languages、layout、source 等），首次推送可能较慢
- Vercel 节点国内访问虽优于 GitHub Pages，但仍可能受网络波动影响；如需更稳，未来可迁到 Cloudflare Pages 或国内 CDN