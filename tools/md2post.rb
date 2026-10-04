#!/usr/bin/env ruby
# 把一篇 Markdown 经验总结转成实验室站的静态文章页。
# 用法：
#   ruby tools/md2post.rb 草稿.md \
#     --out   lab-notes-hybrid-wing-perching.html \
#     --title "混合驱动扑翼飞行器栖息成功率改进小结" \
#     --date  2026-10-20 \
#     --author "陈家珩" \
#     [--origin https://example.org/original/] \
#     [--baseurl https://chensong212.github.io] \
#     [--desc "一句话摘要，用于 meta description 与 og:description"]
#
# 依赖（一次性安装）：gem install kramdown kramdown-parser-gfm --user-install
# 说明：站点是纯静态站，本脚本只是写作辅助，不参与任何构建流程；
#       解析器与博客端一致（kramdown + GFM），因此表格、任务清单、围栏代码块行为相同。
require 'kramdown'
require 'kramdown-parser-gfm'

# 命令行参数在非 UTF-8 locale 下会以 ASCII-8BIT 进入，统一转成 UTF-8
ENV['LANG'] = 'zh_CN.UTF-8'
$PROGRAM_NAME = $PROGRAM_NAME.dup.force_encoding('UTF-8')

argv = ARGV.dup.map { |a| a.dup.force_encoding('UTF-8') }
src = argv.shift
Encoding.default_external = Encoding::UTF_8
opt = {}
while argv.any?
  key = argv.shift.sub(/^--/, '').to_sym
  opt[key] = argv.shift.dup.force_encoding('UTF-8')
end

abort "用法：ruby tools/md2post.rb 草稿.md --out 页面.html --title 标题 --date YYYY-MM-DD --author 作者" if src.nil? ||
  %i[out title date author].any? { |k| opt[k].nil? }
abort "找不到输入文件：#{src}" unless File.exist?(src)
abort "--date 必须是 YYYY-MM-DD" unless opt[:date] =~ /\A\d{4}-\d{2}-\d{2}\z/
abort "--out 必须是站内文件名（如 lab-notes-xxx.html）" unless opt[:out] =~ /\Alab-notes-[a-z0-9-]+\.html\z/

raw = File.read(src, encoding: "UTF-8")
body = if raw.start_with?("---")
         parts = raw.split(/^---\s*$/, 3)
         parts.length >= 3 ? parts[2] : raw
       else
         raw
       end
# 从博客迁移过来的稿子常带 {{ site.baseurl }}：给了 --baseurl 就替换成绝对地址，其余模板语法一律拒绝
body = body.gsub(/\{\{\s*site\.baseurl\s*\}\}/, opt[:baseurl]) if opt[:baseurl]
# 站内相对链接与模板变量在静态站里不会被解析，直接拒绝
if body =~ /\{\{|\{%/
  abort "正文含模板语法（{{ }} / {% %}），请先替换成绝对链接或删除"
end
if body =~ /\]\(\//
  abort "正文含根路径链接（](/xxx)），请改成 ./xxx.html 或完整 URL"
end

html = Kramdown::Document.new(body.strip, input: "GFM", auto_ids: true,
                              hard_wrap: false, syntax_highlighter: nil).to_html
# 无高亮器时 kramdown 仍会给 code 加 language-* 类，站内没有对应样式，去掉
html = html.gsub(%r{\s+class="language-[a-zA-Z0-9+#.-]*"}, "")
html = html.gsub(%r{<table>}, %(<div class="table-wrap">\n<table>)).gsub(%r{</table>}, %(</table>\n</div>))
html = html.lines.map { |l| l =~ /\A<(h\d|p|ul|ol|li|div|table|blockquote|hr|pre)/ ? "      #{l}" : "        #{l}" }.join

esc = lambda { |s| s.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;") }
title = opt[:title]
desc  = opt[:desc] || "#{title}——实验室经验总结。"
origin = opt[:origin] ? %( · <a href="#{esc.call(opt[:origin])}">原文发表于此</a>) : ""
date_iso = %(<time datetime="#{opt[:date]}">#{opt[:date]}</time>)

page = <<~HTML
  <!DOCTYPE html>
  <html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#{esc.call(title)} — 仿生智慧飞行实验室</title>
    <meta name="description" content="#{esc.call(desc)}">
    <link rel="icon" href="./assets/favicon.svg" type="image/svg+xml">
    <meta property="og:type" content="article">
    <meta property="og:site_name" content="仿生智慧飞行实验室 | Bio-inspired Intelligent Flight Lab">
    <meta property="og:title" content="#{esc.call(title)}">
    <meta property="og:description" content="#{esc.call(desc)}">
    <meta property="og:url" content="https://chensong212.github.io/bio-flight-lab/#{opt[:out]}">
    <meta name="twitter:card" content="summary">
    <link rel="canonical" href="https://chensong212.github.io/bio-flight-lab/#{opt[:out]}">
    <link rel="stylesheet" href="./assets/style.css">
  </head>
  <body>
    <header class="topbar">
      <div class="container">
        <a class="brand" href="./index.html">仿生智慧飞行实验室</a>
        <nav>
          <a href="./index.html">Home</a>
          <a href="./lab-notes.html">News</a>
          <a href="./projects.html">Research</a>
          <a href="./people.html">People</a>
          <a href="./publications.html">Publications</a>
          <a href="./assets.html">Assets</a>
        </nav>
      </div>
    </header>

    <main class="container post-main">
      <div class="post-body">
        <h1>#{esc.call(title)}</h1>
        <p class="post-meta">作者：<span class="post-author">#{esc.call(opt[:author])}</span> · #{date_iso}#{origin}</p>
  #{html.strip}
      </div>
    </main>

    <footer class="footer">
      <div class="container">
        <p><a href="./lab-notes.html">← News</a></p>
        <p>仿生智慧飞行实验室 — Bio-inspired Intelligent Flight Lab — © 2026</p>
      </div>
    </footer>
  </body>
  </html>
HTML

File.write(opt[:out], page)
puts "已生成 #{opt[:out]}（#{File.size(opt[:out])} 字节）"
puts "别忘了三处同步：lab-notes.html 加条目、index.html 首页加条目、sitemap.xml 加一行 <url>"
