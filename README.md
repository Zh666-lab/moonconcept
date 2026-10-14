# MoonConcept

A pure MoonBit finite binary **formal concept analysis (FCA)** kernel: Galois
closures, closed patterns, concept lattices and exact attribute dependencies.
Original implementation, MIT licensed. Version **0.1.0**.

## Why this package

The same object–attribute model serves three real workflows:

* **Feature analysts:** CSV observations → closed patterns/support → minimal
  generators and exact implications, with no statistical-significance claims.
* **Permission model maintainers:** named users/permissions → shared role
  concepts/Hasse graph → counterexamples to proposed permission dependencies.
  This is descriptive analysis, never authorization or policy enforcement.
* **Configuration catalog authors:** independently ordered product populations
  → identity-aligned composition → rule audits and inference explanations.

No external third-party module dependencies. Core JSON parsing is provided by
`moonbitlang/core` (Apache-2.0); callers supply strings and own file/network I/O.

## Install and use

```sh
moon new consumer
cd consumer
moon add Zh666-lab/moonconcept@0.1.0
```

In the consumer's `moon.pkg`:

```moonbit
import {
  "Zh666-lab/moonconcept" @fca,
}
```

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
  // The touch closure contains both touch and portable.
  println(labels)
}
```

Named labels are unique within each universe. Indices are zero-based;
sets are sorted/deduplicated defensively. Invalid input raises `FcaError::Invalid`,
explicit resource exhaustion raises `FcaError::Budget`, never a partial answer.
See [`pkg.generated.mbti`](pkg.generated.mbti) for the full public interface.

## Delivered APIs

| Area | Main entry points |
|---|---|
| Owned model | `context`, `context_from_sets`, `objects`, `attributes`, `rows`, `has` |
| Derivation | `intent`, `extent`, `closure`, `object_closure`, label/index lookups |
| Enumeration | `concept_for`, `valid_concept`, `next_intent`, `concepts`, `frequent_concepts` |
| Lattices | `lattice`, `covers`, `leq`, `meet`, `join`, extrema, intervals, `to_dot` |
| Horn reasoning | `implication`, `rule_system`, `closure`, `trace`, `entails`, `equivalent` |
| Exact discovery | `canonical_basis`, `minimal_generators`, `generator_rules` |
| Rule analysis | `counterexamples`, `valid_implication`, `rule_metrics`, `filter_rules` |
| Theory transforms | `irredundant`, `reduce_premises`, `split_conclusions`, `with_rule` |
| Context transforms | `dual`, `project`, immutable observation updates, `clarify`, apposition/subposition |
| Expert review | `exploration`, `next_question`, immutable accept/reject with consistent evidence |
| Interchange | strict binary CXT, incidence CSV, versioned typed JSON |
| Reports | concept/lattice JSON, theory audit with witnesses, inference JSON, safe numeric DOT |

A concept satisfies `extent' = intent` and `intent' = extent`. Lattice order is
**extent inclusion**: covers/DOT arrows run from smaller extent (bottom) to
larger extent (top); intent inclusion runs in the reverse direction.

## Runnable downstream workflows

```sh
moon run examples/features
moon run examples/roles
moon run examples/catalog
```

Examples print actual structured analysis; roles additionally prints a DOT
Hasse graph with numeric indices. Every example has a checked expected result.
Replace its in-memory/CSV input and integrate the reusable library in your own
application. No server, credentials or filesystem access are needed by the kernel.

## Formats

* **CXT:** `B`, blank, object count, attribute count, blank, object labels,
  attribute labels, X/. rows. LF/CRLF; no extra records. CXT cannot encode
  multiline labels and the writer rejects them rather than losing data.
* **CSV:** first header is exactly `object`, following headers are attributes.
  Cells are exactly `0`/`1`. Quotes double internally; commas, quotes and
  multiline Unicode labels roundtrip. LF and CRLF outside quotes; no trimming,
  truthy coercion, missing cells or ragged records.
* **JSON:** context schema `moonconcept-context/v1` has `objects`, `attributes`,
  Boolean `rows`; theory schema `moonconcept-rules/v1` has integer `dimension`
  and indexed `rules` with `premise`/`conclusion`. Missing/unknown fields and
  wrong types fail. Core JSON uses **last occurrence wins** for duplicate
  object keys: this is not a signed or security-policy canonicalization format.
* Reports are typed, indexed JSON with the context vocabulary once, not a
  decoder for arbitrary report schemas. JSON member byte order is not promised.

## Bounds and non-goals

| Operation | Explicit limit |
|---|---|
| Context | 4096 objects, 128 attributes, unique nonempty labels ≤4096 UTF-16 units |
| Text parsers | 32 Mi UTF-16 units; CSV field ≤4096; JSON nesting ≤16 |
| Concepts | default 4096, caller limit up to 65536, failure before partial return |
| Materialized lattice | at most 256 concepts; cubic cover reduction |
| Theory | at most 4096 implications, 128 attributes; reductions at most 512 rules |
| Canonical base | at most 16 attributes, 65536 subset candidates; default 1M work units, max 10M |
| Minimal generators | at most 16 target attributes; up to 65536 candidates, default 4096 results |
| Expert question | at most 16 attributes; complete bounded subset scan |

Closure and NextClosure are straightforward array algorithms, not bitset-scale
optimized mining. Canonical-base work units count candidates/pseudo-intent
comparisons, not CPU instructions or memory. Large accepted inputs can still be
expensive. Frequent patterns enumerate first, then filter; the support threshold
is not a search-pruning guarantee. `dual` must also fit the context limits after
swapping universes. Clarification removes duplicates, not all reducible rows.
Premise/rule reductions are equivalent theories, not globally smallest theories.
`Exploration` is a finite exhaustive expert-review assistant, not canonical
attribute-exploration question order or a proof about unseen real-world objects.

Empty selected object sets derive all attributes; empty attribute sets derive
all objects. Empty populations have support 0, while implications remain
vacuously valid. Undefined confidence/lift are `None`/JSON null, never NaN.

Not included: general Datalog/HOL/SMT/CSP/BDD, policy enforcement, statistical
significance, learning, distributed mining, infinite/temporal/fuzzy contexts,
interactive GUI, or automatic competition registration.

## Verification

```sh
moon info && moon fmt
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon build --deny-warn
python scripts/measure.py
# bash/Linux, each of wasm-gc / wasm / js / native:
bash scripts/verify.sh js
```

49 named tests include independent scalar-matrix/subset oracles over **all 689
binary contexts of dimensions 0..3 by 0..3**, **5054 attribute seeds** (including
all 512 3×3 contexts), exact pseudo-intents/minimal generators, lattice covers
and greatest/least bounds, parser negatives, ownership mutation and budgets.
A further deterministic inventory feeds 1000 short malformed strings to each
parser. This is finite exhaustive evidence, not a proof for arbitrary sizes.

Release-validation Windows toolchain: moon 0.1.20261012 / moonc v0.10.15 stable build.
Check/test/build and workflows were run on wasm-gc, wasm and js. Native checking
works locally; native build/test require a C compiler not installed locally.
CI runs all four targets including native on Ubuntu with GCC, and records its
actual tool versions. CI downloads the official October 12 snapshot using
object ETag preconditions; moved upstream objects fail closed. ETags are identity
pins, not independent signature verification. See the actual Actions run for
release validation, not this text as a claim that a pending run has passed.

## Sources, ownership and contest scope

See [architecture](docs/ARCHITECTURE.md), [security](SECURITY.md),
[references](docs/REFERENCES.md), [AI disclosure](AI-USE.md),
[changelog](CHANGELOG.md), and the dated
[bounded duplication review](docs/competition/duplicate-check.md).
No third-party implementation or dataset is vendored. Fixtures are original
synthetic data. The private Chinese competition document is not distributed.
