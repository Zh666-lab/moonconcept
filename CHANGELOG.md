# Changelog

## 0.1.2 — 2026-10-20

- 精确校验规则 JSON 的十进制整数，拒绝浮点舍入或下溢造成的非法维度/索引。
- 增加两项回归测试，保留合法整数小数、指数表示和负零。
- 中文 README 快速示例改为打印拼接字符串，避免严格检查中的数组 Show 弃用错误。

- 更新匹配的官方 CI 工具链快照 ETag，增加 SHA-256 校验，修复上游 latest 更新导致的 HTTP 412 安装失败。
- 补验 Linux/GCC native 严格检查、测试、构建和三个下游工作流；不宣称已验证 Windows 原生 native。

## 0.1.1 — 2026-10-14

- 将 README 完整改为中文，保留安装示例、接口、三个工作流、格式与资源边界、验证及来源说明。
- 明确补充 CSV 电子表格公式安全提示；更新安装命令至 0.1.1。
- 核心实现、公开 API 与测试行为不变。

## 0.1.0 — 2026-10-14

* Owned validated incidence contexts and canonical finite index-set utilities.
* Galois derivations, NextClosure, bounded formal concept lattices and queries.
* Horn implications, inference traces, exact bounded canonical bases/generators,
  equivalent reductions, metrics and concrete counterexamples.
* Immutable transforms, duplicate clarification, identity-aligned composition
  and consistency-checked expert review.
* Strict binary CXT/incidence CSV and typed versioned JSON interchange;
  indexed reports and safe numeric DOT.
* Three tested complete downstream workflows and exhaustive small-context
  independent-oracle verification; portable CI.

All limits and intentionally unsupported capabilities are documented. No
benchmark speedup, arbitrary-size proof or organizer approval is claimed.
