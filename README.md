# MoonConcept

纯 MoonBit 实现的有限二元**形式概念分析（Formal Concept Analysis，FCA）**内核：从对象—属性关系计算 Galois 闭包、闭合模式、概念格和精确属性依赖。

原创实现，采用 MIT 许可证。本版本：**0.1.2**。修复规则 JSON 的精确整数校验与严格检查下的快速示例；公开 API 不变。

## 项目解决什么问题

同一套对象—属性模型可以复用于三个完整工作流：

- **特征分析人员**：导入 CSV 观测数据，计算闭合模式与支持度，寻找最小生成元及精确蕴含。结果描述输入数据中的关系，不代表统计显著性。
- **权限模型维护者**：输入具名用户与权限，生成共享权限概念和 Hasse 图，找出违反所提议权限依赖的具体用户。这里只做关系分析，**不执行授权或强制实施安全策略**。
- **产品配置目录维护者**：按名称对齐不同顺序的数据源，合并配置目录，审计规则并查看推理过程。

没有外部第三方模块依赖。JSON 解析使用 `moonbitlang/core`（Apache-2.0）；调用者提供字符串，并自行负责文件、网络等 I/O。

## 安装与快速使用

```sh
moon new consumer
cd consumer
moon add Zh666-lab/moonconcept@0.1.2
```

在消费者包的 `moon.pkg` 中添加导入：

```moonbit
import {
  "Zh666-lab/moonconcept" @fca,
}
```

下面的示例将三个设备表示为对象，将触控、便携和键盘表示为属性：

```moonbit
fn main {
  let labels = try {
    let data = @fca.context_from_sets(
      ["phone", "tablet", "desktop"],
      ["touch", "portable", "keyboard"],
      [[0, 1], [0, 1], [2]],
    )
    data.attribute_labels(data.closure([0]))
  } catch {
    _ => abort("invalid incidence data")
  }
  // 在这份数据中，touch 的闭包包含 touch 和 portable。
  println(labels.join(", "))
}
```

对象名称在对象集合内唯一，属性名称在属性集合内唯一。索引从 0 开始；集合会防御性排序、去重，内部数据由内核持有并复制。

非法输入抛出 `FcaError::Invalid`；超过明确的资源预算抛出 `FcaError::Budget`，而不是返回不完整答案。完整公开接口见 [`pkg.generated.mbti`](pkg.generated.mbti)。

## 已实现的接口

| 功能 | 主要入口 |
|---|---|
| 具备数据所有权的上下文 | `context`、`context_from_sets`、`objects`、`attributes`、`rows`、`has` |
| Galois 导出与闭包 | `intent`、`extent`、`closure`、`object_closure`，名称与索引查找 |
| 概念枚举 | `concept_for`、`valid_concept`、`next_intent`、`concepts`、`frequent_concepts` |
| 概念格 | `lattice`、`covers`、`leq`、`meet`、`join`、上下界、区间、`to_dot` |
| Horn 蕴含推理 | `implication`、`rule_system`、`closure`、`trace`、`entails`、`equivalent` |
| 精确依赖发现 | `canonical_basis`、`minimal_generators`、`generator_rules` |
| 规则分析 | `counterexamples`、`valid_implication`、`rule_metrics`、`filter_rules` |
| 规则理论变换 | `irredundant`、`reduce_premises`、`split_conclusions`、`with_rule` |
| 上下文变换 | `dual`、`project`、不可变观测更新、`clarify`、横向合并 apposition / 纵向合并 subposition |
| 专家审阅 | `exploration`、`next_question`；通过一致性校验的不可变接受 / 反例拒绝操作 |
| 数据交换 | 严格二元 CXT、关联矩阵 CSV、带版本的类型化 JSON |
| 分析报告 | 概念 / 格 JSON、带反例的规则审计、推理 JSON，以及仅使用数字标签的 DOT |

形式概念满足 `extent' = intent` 与 `intent' = extent`，其中 `extent` 为外延（对象集合），`intent` 为内涵（属性集合），撇号表示相应的 Galois 导出。

格的顺序采用**外延包含关系**：cover 边及 DOT 箭头从较小外延（底）指向较大外延（顶）；内涵的包含方向与之相反。

## 三个可运行的下游工作流

```sh
moon run examples/features
moon run examples/roles
moon run examples/catalog
```

- `features`：特征数据 → 闭合模式与支持度 → 最小生成元和规范蕴含基。
- `roles`：用户—权限关系 → 角色概念格 → 所提议权限依赖的违反者；同时输出数字索引的 DOT Hasse 图。
- `catalog`：不同来源的配置目录 → 按名称对齐合并 → JSON/CXT 往返、规则审计、推理报告与专家问题。

示例输出真实的结构化分析结果，每个示例均有预期结果断言。替换示例中的内存或 CSV 输入，即可将库集成到自己的应用中。内核不需要服务器、凭据或文件系统访问。

## 数据格式

### CXT

布局依次为：`B`、空行、对象数量、属性数量、空行、对象名称、属性名称、由 `X` / `.` 组成的关联矩阵行。

支持 LF / CRLF，不接受额外记录。CXT 不能表示多行名称；写出器会拒绝这类名称，而不是静默丢失数据。

### CSV

首个表头必须恰为 `object`，其余表头是属性名称；关联单元格必须恰为 `0` 或 `1`。

支持引号字段，内部双引号以双写方式转义；包含逗号、引号和换行的 Unicode 名称可以往返。引号外支持 LF / CRLF。不自动去除空白、不将其他“真值”转换为 1，也不接受缺失单元格或不等长记录。

CSV 导出保留名称，**不会做电子表格公式注入清洗**。将不可信名称交给 Excel 等电子表格软件前，调用方应采用适合目标软件的安全处理；详见 [安全边界](SECURITY.md)。

### JSON

- 上下文模式 `moonconcept-context/v1`：包含 `objects`、`attributes` 和布尔矩阵 `rows`。
- 规则理论模式 `moonconcept-rules/v1`：包含整数 `dimension`，以及使用索引的 `rules`；每条规则有 `premise` / `conclusion`。

缺少字段、未知字段及类型不符均报错。规则中的数值按原始十进制值校验整数性和范围，拒绝因浮点舍入或下溢而看似为整数的非整数；合法的整数小数、指数写法和负零仍可使用。核心 JSON 解析器对重复对象键采用**后出现的值覆盖先出现的值**；该格式不适合直接用作签名或安全策略的规范化表示。

报告采用类型化、带索引的 JSON，上下文名称表只存一次；它们不是任意报告模式的通用解码器。不保证 JSON 成员的字节排列顺序。

## 资源边界与不支持的范围

| 操作 | 明确限制 |
|---|---|
| 上下文 | 最多 4096 对象、128 属性；名称唯一、非空，最多 4096 个 UTF-16 单元 |
| 文本解析 | 最多 32 Mi 个 UTF-16 单元；CSV 字段最多 4096；JSON 嵌套深度最多 16 |
| 概念枚举 | 默认最多 4096 个概念；调用方上限最多 65536；失败时不返回部分结果 |
| 实体化概念格 | 最多 256 个概念；cover 关系约简采用立方级算法 |
| 规则理论 | 最多 4096 条蕴含、128 属性；规则约简最多 512 条规则 |
| 规范蕴含基 | 最多 16 属性、65536 个子集候选；默认 100 万工作单元，最多 1000 万 |
| 最小生成元 | 目标最多含 16 属性；最多 65536 个候选，默认最多 4096 个结果 |
| 专家提问 | 最多 16 属性；执行完整但有界的子集扫描 |

闭包和 NextClosure 使用直接的数组算法，不是面向大规模数据的位集优化挖掘器。规范基的工作单元计算候选检查与伪意向比较次数，并不等于 CPU 指令数或内存消耗；即使输入满足限制，也可能需要较多计算。

频繁模式先完整枚举，再按支持度过滤；支持度阈值不代表搜索剪枝保证。`dual` 交换对象与属性后仍须满足上下文限制。`clarify` 只合并重复行列，不删除所有可约简行列。

前提 / 规则约简保持理论等价，但不保证得到全局最小理论。`Exploration` 是有限穷举的专家审阅辅助器，不承诺采用规范属性探索的提问顺序，也不证明未观测真实对象的性质。

空对象集合导出全部属性，空属性集合导出全部对象。空总体的支持度为 0，蕴含仍可能因无反例而成立。未定义的置信度 / 提升度返回 `None` 或 JSON `null`，不返回 NaN。

**不包含**：通用 Datalog / HOL / SMT / CSP / BDD、权限强制执行、统计显著性、机器学习、分布式挖掘、无限 / 时间 / 模糊上下文、交互 GUI 或自动赛事报名。

## 验证与复现

```sh
moon info && moon fmt
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon build --deny-warn
python scripts/measure.py
# Bash/Linux：分别验证 wasm-gc / wasm / js / native。
bash scripts/verify.sh js
```

本版本有 51 项命名测试（0.1.1 为 49 项），包括独立的标量矩阵 / 子集判定器，遍历**全部 689 个维度为 0..3 × 0..3 的二元上下文**及 **5054 个属性种子**（包含全部 512 个 3×3 上下文），核对精确伪意向、最小生成元、格 cover 关系与最大下界 / 最小上界，以及解析失败、所有权隔离和预算边界。

此外，每个解析器还接受 1000 个确定性生成的短畸形字符串测试。这是有限范围的穷举证据，不是对任意规模输入的形式证明。

发布验证的 Windows 工具链为 moon `0.1.20261012` / moonc `v0.10.15` 稳定版。本地已运行 wasm-gc、wasm、js 的严格检查、测试、构建与工作流；另在本机 Ubuntu 24.04 WSL / GCC 13.3 上使用 moon `0.1.20261016` / moonc `v0.10.16`，实际通过 native 严格检查、测试、构建与三个工作流。Windows 原生 native 仍需要 MSVC C++ 工具及 Windows SDK，本机未安装；WSL 验证不等于 Windows 原生验证。

CI 在 Ubuntu / GCC 上执行全部四个目标，并记录实际工具版本。CI 下载官方 2026 年 10 月 19 日更新的快照（工具版本构建于 10 月 16 日），使用对象 ETag 前置条件和 SHA-256 内容摘要校验：若上游对象改变，则拒绝继续，需要审核新快照后同步更新两项约束。ETag 与本项目记录的摘要不是上游数字签名。每次发布是否通过验证，应以对应提交的实际 Actions 记录为准。

## 来源、许可证与赛事资料

请参阅 [架构说明](docs/ARCHITECTURE.md)、[安全边界](SECURITY.md)、[参考资料](docs/REFERENCES.md)、[AI 辅助披露](AI-USE.md)、[更新记录](CHANGELOG.md)，以及注明日期和范围的 [语义查重报告](docs/competition/duplicate-check.md)。

没有内置第三方实现或数据集，测试样例为原创合成数据。查重结论受记录中的检索范围、结果上限和不可访问来源限制，不代表绝对唯一性或赛事官方裁决。

中文赛事申报书仅保存在本地，不随 GitHub、MoonCakes 或 Release 分发；本项目不自动报名。
