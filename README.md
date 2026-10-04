# 仿生智慧飞行实验室

**Bio-inspired Intelligent Flight Lab**

> 从生物机理到自主系统 — From biological mechanisms to autonomous systems.

研究扑翼空气动力学、仿生栖息无人机、变体飞行控制。

## 仓库

- 源码：`https://github.com/chensong212/bio-flight-lab`（公开）
- 网站：`https://chensong212.github.io/bio-flight-lab/`

## 站点形态：纯静态，无构建

本仓库直接就是发布内容，**不经过 Hugo / Jekyll / GitHub Actions**：

- 根目录的 `*.html` 即页面，`assets/` 放 CSS 与图标；
- 根目录 `.nojekyll` 关闭 GitHub 的 Jekyll 预处理，文件原样发布；
- Pages 配置为 `main` 分支 `/` 目录（`build_type=legacy` + `.nojekyll` = 静态直发）；
- 所有站内链接一律用相对路径（`./people.html`），保证项目站子路径 `/bio-flight-lab/` 下正确跳转。

> 2026-09-28 之前的 Hugo + `fwav` 主题骨架已从工作树删除，归档在仓库外
> `~/Documents/Blog/bio-flight-lab-hugo-legacy-20260928-172856.tar.gz`，也可从 git 历史 `b3d50b6` 取回。

## 本地预览

无需安装任何依赖，任选一种：

```bash
cd <仓库目录>
python3 -m http.server 8000   # 然后打开 http://127.0.0.1:8000/
# 或直接双击 index.html（相对链接与样式同样可用）
```

## 本地自查（推送前）

```bash
grep -rn 'href="/\|src="/' --include="*.html" .        # 应无输出：不允许根路径链接
grep -rn '{{\|{%' --include="*.html" .                 # 应无输出：不允许模板语法残留
```

## 发布

`main` 分支的内容就是线上内容，合并/推送后约 1–2 分钟生效。

自 2026-10-03 起，`main` 受 Ruleset `protect-main` 保护（`enforcement=active`）：

- 必须 Pull Request + 1 个批准，且 `.github/CODEOWNERS` 把全部文件归到 `@chensong212`，所以**必须 PI 本人批准**；
- 禁止强推、禁止删除 `main`；合并方式只允许 **Squash**；
- bypass 名单绑的是“仓库管理员”**角色**（不是具体人），因此 PI 可直推 `main` 救火；**不要把其他人提升为 Admin**，那等于授予绕过权。

学生维护者的日常路径与条目模板见 `news_template.md`。构建状态可用 GitHub API 权威核对：

```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  https://api.github.com/repos/chensong212/bio-flight-lab/pages/builds/latest \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status'], d['commit'], d['error'])"
```

返回 `status=built` 且 `commit` 等于刚推送的 sha 即发布成功。

## 内容维护

| 页面 | 文件 | 说明 |
|---|---|---|
| 首页 | `index.html` | 定位语 + 3 个研究方向卡片 + 最近 4 条新闻（文字条目，链到 News 页锚点） |
| 新闻 | `lab-notes.html` | 每条新闻直接写在页内：`<article class="news-item" id="news-YYYYMMDD">` = 照片 + 日期 + 中文正文 + 一句英文（`.en`）。新事件按日期倒序插入，并同步首页条目（`sitemap.xml` 不用动）。维护流程与学生权限边界见 `news_template.md` |
| 研究方向 | `projects.html` | 课题编号与 KB `02_PROJECTS/K01–K13` 对齐 |
| 团队 | `people.html` | PI / 在读学生 / 毕业生三段 |
| 论文 | `publications.html` | **只列已发表论文**，每条带 DOI；段落仅在有条目时显示；在投与修改中的稿件不上页 |
| 资产归档 | `assets.html` | 条目编号与 FWAV_KB 对齐（`EQ_` / `SW_` / `DS_`） |
| 404 | `404.html` | 站内路径缺失时由 GitHub Pages 提供 |
| SEO | `sitemap.xml` / `robots.txt` / 各页 `<meta>` | 新增页面时同步补 `sitemap.xml` 与该页 `og:url`/`canonical` |

## 图片规范

- 新闻照片放 `img/`，文件名描述事件（如 `Wind_wall_test_GuoYH.jpg`），HTML 里用 `./img/…` 引用；
- 列表页缩略显示 320×200（CSS `object-fit: cover` 裁切，原图不变形），点缩略图打开原图；
- 单图控制在 400 KB 以内，长边 ≤ 2300 px；**不做反复重压缩**（JPEG 代际损失不可逆）；
- 对外发布前做一次元数据体检（只读）：
  `python3 ~/.sclaw/agent/skills/jekyll-pages-verify/scripts/exif_scan.py img`；
- 需要备份时先拷到仓库外再处理，并核对“备份数 == 处理数”。

```bash
grep -rn 'href="/\|src="/' --include="*.html" .        # 应无输出：不允许根路径链接
grep -rn '{{\|{%' --include="*.html" .                 # 应无输出：不允许模板语法残留
```

正文与新闻条目可用的元素：`h1/h2/h3/p/ul/ol/li/hr/blockquote/code/pre/table/img`；
表格需包在 `<div class="table-wrap">` 内以适配窄屏。样式全在 `assets/style.css`：
`.post-body` 一节管长文正文，`.news-item` 一节管新闻图文条目。
