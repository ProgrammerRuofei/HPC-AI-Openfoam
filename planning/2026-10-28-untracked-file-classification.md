# 剩余 119 个 untracked 文件：分类与保存决定

日期：2026-10-28。范围是上一轮结束后仍未跟踪的 119 个文件，合计
37,975,948 bytes；不是重新分析实验、选择最终比赛配置或正式发布 slides。
逐文件的大小、原始 SHA256、决定与原因见
[完整清单](repository-audit/2026-10-28-untracked-files.csv)。

## 分类结果

| 决定 | 文件数 | Bytes | 内容 |
| --- | ---: | ---: | --- |
| `commit` | 53 | 10,067,250 | 30 SVG、5 个独立展示 PNG、6 个设计/内容 source 文件、2 PPTX 历史快照、6 build 文件、3 screening 脚本、1 XLSX |
| `ignore-generated` | 60 | 12,616,786 | 30 个配套 PNG、2 ZIP、25 张 source/preview/QA 截图、3 个工具 QA JSON |
| `local-only-draft` | 6 | 15,291,912 | 未选入归档的历史 PPTX 草稿 |

后两类都使用**精确路径**加入 `.gitignore` 并留在原地。它们不是无价值
文件，也没有被删除；只是本次不随 Git 分发。新文件不会被通配规则自动隐藏。

## 值得 commit 的内容

- **图形 source**：30 个 SVG 是现有图形的可缩放来源，保留原字节；30 个
  配套 PNG 留本地。Google redesign 的五个独立 PNG 没有配套 SVG，保留它们
  与既有 `draw_figures.py`。脚本含硬编码的历史数值，只做语法检查，未执行。
- **设计记录**：两套 `design-system.json`、两份 design catalog、既有
  `openfoam-storyline.md` 与上述 generator 共六个 source 文件。它们保存
  当时的 layout/content 快照，不是当前科学结论或完整 cloud-deck 备份。
- **PPTX 历史代表**：归档 `editable-template-v5` 与
  `openfoam-first-review-v2`，分别保存一个后期模板迭代和一份带内容的 review
  快照。选择它们是历史归档决定，不是视觉最佳评选或最终投递确认。另六份
  保留本地。模板系列文本相同，但图片/布局 parts 不同，不能说它们逐字节重复。
- **运行基础设施**：六个 Gadi build 文件（含 README，五个脚本）和三个
  generic screening 脚本原样归档。保留原路径，不改变 compiler/MPI/resources、
  scientific inputs 或运行行为。见各目录 archive notes；commit 不授权执行。
- **XLSX**：7,424-byte 的 Gadi 汇总原件有保存价值，原样归档；说明单独放在
  [workbook notes](../results/gadi-successful-4n-workbook-notes.md)，不改表中数据。

## 为什么 ignore 或保留本地

- **30 PNG**：逐一确认有同名 SVG；选择 SVG 为版本化的图形 source，并不声称
  PNG 和 SVG 的二进制相同。原 PNG 保持在原路径。
- **2 ZIP**：CRC 检查通过；20 与 6 个成员均与现存文件逐字节匹配，不增加
  独有证据。ZIP 原件仍保留，不重新打包。
- **25 截图**：用于 source/preview/QA 的局部浏览记录，不替代原始 deck、solver
  log 或 correctness evidence。本次不把它们当新的最终交付。
- **3 QA JSON**：零 layout issue 不是 scientific correctness 或 performance
  validity 的证明，保留本地即可。
- **6 PPT 草稿**：早期模板、未选入的 review 和旧 visualized 内容保留本地。
  后者含早期“fastest”“binding helps”等较强标题，不能覆盖后续 repeat/stall
  证据。review-v2 也不是当前最终结果；PGO、分区与提交状态仍须回到运行登记。

## 内容与复现限制

1. SVG、PNG、PPT、workbook 都是派生展示材料，不替代原始测量与同-run Cd。
   历史 storyline 内的 workload 描述、pending 状态和“final”措辞不得直接复用；
   当前 case 身份以 APPLICATION/官方输入为准，当前实验状态以最近 handoff 为准。
2. XLSX 中部分 UCX/UCC 字段是 module/version 标签，不是历史运行实际库版本
   或 active collective component 的证明；记录在独立 workbook notes 中。
3. Gadi build README 保留其早期 pending 快照，不能解读为现在的 scheduler 状态；
   已补 archive notes，指向后续运行记录。generic screening 的 `normal`/192-rank
   路径不是当前 `normalsr`/416-rank baseline。
4. 两套 PPT/JSON 检查是本地结构/文本与来源审阅，没有在 PowerPoint 或云端
   render/发布，也未为归档重新导出文件。只抽看了两张已有图，不宣称全部视觉 QA。
5. 所有原始证据、119 个原文件及它们的路径均保留。未访问密码文件、集群或
   cloud slides；未提交作业、安装软件、修改 SSH、push 或改变实验方向。

## 本地验证

- 起始/结束按清单比对 119 个原文件 SHA256，确保归档与 ignore 未改原件。
- 8 个 shell/PBS 脚本通过 `bash -n`；既有 Python generator 通过语法编译，
  bytecode 只放临时目录；没有执行脚本主体。
- 60 PNG 通过解码完整性检查；30 SVG 解析成功，无 script/foreignObject、
  event handler 或外部 image 资源；8 PPTX + 1 XLSX 的 ZIP/XML 结构检查通过。
- 未发现高置信 private-key/API-token 模式或 Office macro parts；这是限定范围
  检查，不保证能发现任何形式的秘密。检查从未读取仓库外密码文件。
- Spreadsheet skill 的 read-only import/inspect 确认原表结构与值，未 recalculate、
  修改或 export；Presentations skill 的只读边界用于 PPT 结构/版本检查。

具体 commits 与结束状态见
[本轮交接](../progress/2026-10-28-untracked-file-classification.md)。
