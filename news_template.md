# 实验室新闻与经验总结发布指南

面向仿生智慧飞行实验室网站 <https://chensong212.github.io/bio-flight-lab/> 的内容维护。站点是纯静态 HTML，没有构建步骤：`main` 分支上的内容就是线上内容。

## 一、权限与流程

| 角色 | 能做什么 |
|---|---|
| 学生维护者（Write） | 推送自己的分支、开 Pull Request、读写 issue |
| PI（Admin） | 审查并合并 PR；紧急时可直接推 `main` |

`main` 由 Ruleset `protect-main` 保护：改动必须经 Pull Request 并由 **PI 作为代码所有者批准**后才能合并；禁止强推、禁止删除分支；合并方式只允许 **Squash**。

因此**不要直接向 `main` 推送**——会收到 403 拒绝，这是预期行为，不是账号出错。

## 二、两种条目

| 类型 | 用于 | 形态 |
|---|---|---|
| **短新闻** | 设备建成、测试成功、会议报告、开放日 | 条目直接写在 `lab-notes.html`，可配一张照片，不单独建页 |
| **经验总结（长文）** | 科研小结、写作与修改复盘、实验踩坑记录 | 单独一个 `lab-notes-<主题>.html` 文章页，News 里放一条带作者署名的摘要条目引流 |

长文条目**必须署名**：学生写自己的姓名（如 `作者：陈家珩`），PI 的稿件写 `作者：陈松老师`。

## 三、发布一条短新闻

```bash
git switch main && git pull                        # 取最新内容
git switch -c news/20261015-morphing-first-flight  # 分支名：news/日期-事件（用英文或拼音）
# 按第四节修改 lab-notes.html 与 index.html，照片放进 img/
git add lab-notes.html index.html img/
git commit -m "News: 仿生变体滑翔机完成首次室内试飞"
git push -u origin news/20261015-morphing-first-flight
```

推送后打开仓库页面，点 **Compare & pull request**，填写标题与一句说明并提交，等 PI 审查合并。合并后约 1–2 分钟线上生效。

## 四、短新闻要改两个位置

日期、标题、锚点三样在两处必须完全一致。

**① `lab-notes.html`（新闻列表页）** —— 新条目插在最上面一条的**上面**（按日期倒序）：

```html
<article class="news-item" id="news-20261015">
  <a class="news-photo" href="./img/morphing_first_flight.jpg">
    <img src="./img/morphing_first_flight.jpg" alt="变体滑翔机首次室内试飞" width="320" height="200" loading="lazy">
  </a>
  <div class="news-body">
    <p class="news-date">2026-10-15</p>
    <h2 class="news-title">仿生变体滑翔机完成首次室内试飞</h2>
    <p>中文正文，一到两句，说清做了什么、结果如何。</p>
    <p class="en">One English sentence describing the same event.</p>
  </div>
</article>
```

**② `index.html`（首页）** —— 在 `<!-- NEWS ITEMS START -->` 与 `<!-- NEWS ITEMS END -->` 之间，同样插到最上面一条的上面：

```html
<div class="note-item">
  <span class="date">2026-10-15</span>
  <a href="./lab-notes.html#news-20261015">仿生变体滑翔机完成首次室内试飞</a>
</div>
```

`id` 与 `href` 中的 `news-20261015` 必须逐字符对应，否则首页链接只会跳到页面顶部。**同一天发多条时**，给锚点加后缀区分：`news-20260819a`、`news-20260819b`（日期部分仍保持 8 位）。

**没有照片时**：删掉 `<a class="news-photo">…</a>` 整块，只保留 `.news-body`。

**有微信推文等外部链接时**：作为"延伸阅读"写进条目正文，例如
`<p>延伸阅读：<a href="https://mp.weixin.qq.com/s/…">报道标题</a></p>`。
首页条目仍指向站内锚点——把首页条目直接做成外链会让列表页与首页脱节。

## 五、发布一篇经验总结（长文）

长文先写成 Markdown（放本地或 `~/Documents` 里，**不要**把草稿 md 提交进这个仓库），再用仓库自带的小工具生成页面。

```bash
ruby tools/md2post.rb 我的总结.md \
  --out   lab-notes-hybrid-wing-perching.html \
  --title "混合驱动扑翼飞行器栖息成功率改进小结" \
  --date  2026-10-20 \
  --author "陈家珩" \
  --desc  "一句话说明这篇总结讲了什么，用于搜索与分享卡片"
```

依赖（只需装一次）：`gem install kramdown kramdown-parser-gfm --user-install`。

工具会生成一个带导航、署名行、页脚的完整页面，并自动做三件事：表格包进 `<div class="table-wrap">`（窄屏横向滚动）、把 Markdown 标题转成带 id 的 `h2/h3`、检查并**拒绝**模板语法与根路径链接。

改完再补三处：

1. `lab-notes.html` 加一条摘要条目（无照片，标题带链接，末行署名）：

   ```html
   <article class="news-item" id="news-20261020">
     <div class="news-body">
       <p class="news-date">2026-10-20</p>
       <h2 class="news-title"><a href="./lab-notes-hybrid-wing-perching.html">混合驱动扑翼飞行器栖息成功率改进小结</a></h2>
       <p>一到两句摘要，说明这篇总结解决了什么问题、结论是什么。</p>
       <p class="news-byline">作者：陈家珩</p>
     </div>
   </article>
   ```

2. `index.html` 首页 `<!-- NEWS ITEMS START/END -->` 之间加一行，`href` **直接指向文章页**（不再走 News 页锚点）。

3. `sitemap.xml` 加一条 `<url>`（新增整页必须登记，只加条目不用）。

**长文写作要求**：

- 正文用 `##` / `###` 分节，小标题自带判断（如"三、成功率上不去的三个原因：只有一个能靠调参解决"）；
- 关键结论用 `> 引用块`，全文 3–5 处；
- **不写 LaTeX 数学式**（站内不渲染数学）：变量与上下标用 HTML 标签写，如 `R<sup>2</sup> = 0.9940`、`S<sub>x</sub> = 0.012 m<sup>2</sup>`；只有当文章讨论的就是 LaTeX 源码本身时，才把这类写法放进反引号或代码块里。
- 涉及具体数据、图表、未发表结果，先与 PI 确认可公开范围；
- 提到其他同学的工作时写明分工，不代替他人表态；
- 站内文章**不加**"原文发表于此"一类回链；若同一篇也发在个人博客，由博客那边放实验室站链接。

## 六、照片规范

- 放入 `img/`，文件名描述事件（如 `Wind_wall_test_GuoYH.jpg`），HTML 里用 `./img/…` 引用；
- 长边不超过 2300 px，单张不超过 400 KB；不要反复另存压缩，JPEG 每多一代都有损失；
- 每张图必须有 `alt`（一句话说清画面内容）与 `loading="lazy"`；
- 提交前做一次元数据体检（只读，检查是否含 GPS 位置）：

  ```bash
  python3 ~/.sclaw/agent/skills/jekyll-pages-verify/scripts/exif_scan.py img
  ```

  期望输出 `含 GPS IFD 0 个`。若含 GPS，先去除再提交。
- **画面中出现可辨识的人脸、他人实验记录或未公开成果时，合并前必须经 PI 确认。**

## 七、提交前自查与本地预览

```bash
grep -rn 'href="/\|src="/' --include="*.html" .   # 应无输出：站内链接一律用 ./ 相对路径
grep -rn '{{\|{%' --include="*.html" .            # 应无输出：不留模板语法残留
python3 -m http.server 8000                       # 本地预览：http://127.0.0.1:8000/
```

## 八、不要提交到本仓库的内容

本仓库是**公开仓库**，任何人都能读取全部文件与全部历史。以下内容一律不要提交：

- 未发表的数据、结果、论文正文与审稿材料；
- 设备采购价格、供应商信息、内部台账与内部编号体系；
- 学生的个人信息、联系方式、成绩与内部评语；
- 任何令牌、密码、私钥（包括截图里的）。

误提交后仅删除文件不够——历史里仍可查见，需要重写历史。发现后请立刻告知 PI。

## 九、常见情况

| 现象 | 原因与处理 |
|---|---|
| `git push origin main` 返回 403 | 正常。`main` 受保护，改走第三节的分支 + PR |
| PR 显示 "Review required"，自己无法合并 | 正常。需要 PI 的代码所有者批准，其他同学的批准不能替代 |
| PR 被要求"额外批准"（unattributed changes） | 提交邮箱未与 GitHub 账号验证绑定。`git config --global user.email "<账号已验证邮箱>"` 后重新提交 |
| `md2post.rb` 报"正文含模板语法" | 稿子里有 `{{ }}` 或 `{% %}`。从博客迁移的稿子用 `--baseurl https://chensong212.github.io` 替换站点前缀，其余请改成绝对链接 |
| 页面在手机上表格撑破版面 | 表格必须在 `<div class="table-wrap">` 内，工具会自动包裹；手写 HTML 时记得自己加 |
| 合并后线上没有变化 | 再等 1–2 分钟；仍无变化告知 PI 查看 Pages 构建状态 |
