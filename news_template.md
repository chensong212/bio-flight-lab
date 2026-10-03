# 实验室新闻发布指南 / Lab News Publishing Guide

## 发布一条新闻只需两步

### 第一步：填写模板

将下面一行中的日期和标题替换为你的新闻内容。如果有微信链接，填在 `url` 里。

```yaml
- date: "YYYY-MM-DD"
  text: "新闻标题"
  url: "微信链接（可选，没有写 #）"
```

示例：

```yaml
- date: "2026-10-15"
  text: "仿生变体滑翔机完成首次室内试飞"
  url: "https://mp.weixin.qq.com/s/xxxxxxxxxx"
```

### 第二步：插入 HTML

打开 `index.html`，找到 `<!-- NEWS ITEMS START -->` 和 `<!-- NEWS ITEMS END -->` 之间的区域。

将新新闻的 HTML 代码**插在最上面一条的上面**：

```html
<div class="note-item">
  <span class="date">2026-10-15</span>
  <a href="https://mp.weixin.qq.com/s/xxxxxxxxxx">仿生变体滑翔机完成首次室内试飞</a>
</div>
```

> 没有链接时，`<a href="...">` 改成 `<span>`，不写 `href`。

保存后在 VS Code 中 Commit + Push 即可，主页「News」自动更新。

---

## GitHub 授权（PI 操作，只需一次）

1. 打开 [https://github.com/chensong212/bio-flight-lab/settings/access](https://github.com/chensong212/bio-flight-lab/settings/access)
2. 点击 **Add people**
3. 输入同学的 GitHub 用户名
4. 角色选 **Write**
5. 点击 **Add**

同学接受邀请后，即可在 VS Code 中 clone → 编辑 → commit → push，无需您中转。