# Bounded ecosystem review — 2026-10-14 (Asia/Shanghai)

This is an engineering duplication record, not a competition application or an organizer verdict.
The installed `osc2026-guide` Project Research Guide was read and executed: `moon search <keyword> --limit 100`, package documentation/metadata, then linked source/interface/tests. The builder's fixed September hackathon requirements and October 30 participant deadline apply; no August rules were substituted.

## Candidate comparison (scores 1–5)

| Candidate/domain | breadth | demand | reuse | distinctness | depth | verification | feasibility | maintenance | disposition |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Rectangle packing / manufacturing and graphics |5|4|5|1|4|5|5|4|Reject: rectloom directly implements this workflow|
| Stratified Datalog / logic queries |5|4|5|1|5|5|4|4|Reject: moondatalog directly implements this workflow|
| IPP codec and job model / printing |4|4|5|1|4|5|4|4|Reject: moon-ipp directly implements this workflow|
| MoonConcept / finite binary FCA and attribute dependencies |4|4|5|5|5|5|4|4|Selected, subject to the bounded limitations below|

Hard duplication failures are not compensated by scores. The selected original library supports data/feature analysts, permission model maintainers, and product attribute catalog authors through one reusable object–attribute API. It is not a general theorem prover, query engine, policy enforcement tool, or ML trainer.

## Searches actually executed

MoonCakes keywords at limit 100: packing, rectangle, maxrects, guillotine, atlas, nesting; datalog, prolog, logic; ipp, printing, printer; fca, formal concept, concept lattice, NextClosure, rough set, lattice, Galois, attribute closure, implication basis, association rules, feature selection, 概念格, 形式概念, 闭包, intent extent, formal context, closure system, Duquenne, Guigues, stem base, attribute implication, concept analysis. Search is fuzzy; `logic`, `printer`, and `formal context` hit the 100-module cap and are not exhaustive. Exact central FCA terms, Chinese terms, Duquenne, Guigues and attribute implication yielded no direct package. Fuzzy hits were classified by behavior, not by names alone.

GitHub repository searches (limit 100): `"formal concept" language:MoonBit`, `"NextClosure" moonbit`, `"concept lattice" moonbit`; no results. Code reverse-searches (limit 100): `NextClosure language:MoonBit`, `"concept lattice" language:MoonBit`, `"formal concept" language:MoonBit`, `"canonical_basis" language:MoonBit`, `"attribute exploration" moonbit`; no results. The public [official ecosystem list](https://github.com/moonbitlang/awesome-moonbit) was read; no FCA entry was seen. Generic web searches included MoonBit/FCA/concept-lattice and GitHub competition discovery; no pertinent additional implementation was found. Search indexes cannot expose private or unindexed competition entries.

## Inspected capabilities

| Project | evidence inspected | behavior | relation/decision |
|---|---|---|---|
| [rectloom 0.1.0](https://mooncakes.io/docs/YM-ai-nb/rectloom) | [interface](https://github.com/YM-ai-nb/rectloom/blob/main/pkg.generated.mbti), rectloom_test.mbt; MIT; pushed 2026-08-22 | shelf/guillotine/skyline packing, layout validation | Direct, rectangle candidate rejected |
| [moondatalog 0.1.1](https://mooncakes.io/docs/haol-05/moondatalog) | [interface](https://github.com/haol-05/moondatalog/blob/main/pkg.generated.mbti), engine_test.mbt; Apache-2.0; pushed 2026-08-17 | recursive rules, stratified negation, aggregation, query tuples | Direct, Datalog candidate rejected; not FCA |
| [moon-ipp 0.1.1](https://mooncakes.io/docs/liyun6666/moon-ipp) | [interface](https://github.com/liyun6666/moon-ipp/blob/main/pkg.generated.mbti), codec_test.mbt; Apache-2.0; pushed 2026-10-05 | IPP binary messages, operations, capabilities, jobs | Direct, printing candidate rejected |
| [static_analysis 0.4.29](https://mooncakes.io/docs/riantr/moonbit_static_analysis) | README, [AbsVal source](https://github.com/riantr/moonbit_static_analysis/blob/main/src/interp/interp.mbt), interp/pkg.generated.mbti | fixed reduced abstract-value lattice and joins for program analysis | Same mathematical vocabulary, different workflow; does not enumerate binary formal contexts |
| bobzhang/hol_light 0.1.0; bobzhang/prove 0.0.3 | search package summaries | HOL theorem proving / arithmetic proof examples | Different inputs/outputs; linked hol_light GitHub source returned 404, so no source audit or comprehensive capability claim |

The existing permanent registry was searched by capability and the relevant full fingerprints reviewed: MoonCSP/MoonWeave (constraint modelling), MoonPolicyProof (packet-policy BDDs), MoonTopo (geometry), MoonRestrict (DNA), MoonWFST (weighted transducers). None reserves object–attribute Galois derivations or FCA concept lattices. This account's earlier MoonSunCalc and MoonRFB were also read and excluded. All other reserved/completed/rejected boundaries, including MoonBench, MoonContract, MoonRecur, MoonShard, MoonOT, MoonQP and MoonOpenFeature, remain reserved.

## Selected fingerprint and independent value

Input: finite named object–attribute Boolean incidence, not code/clauses/packets. Central algorithms: Galois derivations, NextClosure, Hasse covers, Armstrong implication closure, pseudo-intents and Duquenne–Guigues base, minimal generators. Output: closed extent/intent pairs, lattice relations, dependency witnesses and deterministic data exchange. Extension of a compiler abstract-value lattice would not provide these data models or workflows; an independent portable analysis kernel is the appropriate boundary. Algorithms are implemented independently, with only standard mathematical references and the MIT Python [concepts](https://github.com/xflr6/concepts) project used for capability comparison, not copied code.

## Limitations and release recheck

This review establishes only that no mature direct FCA substitute was found in the recorded accessible scope. Metadata is not proof of implementation, zero hits are not proof of uniqueness, and capped fuzzy results are incomplete. `mooncakes.io/docs` is client rendered in the browser fetch; linked public source and CLI metadata were inspected instead. Release-time searches and actual validation results will be recorded in the delivery audit. A private/unindexed substitute remains possible. No contest registration or organizer approval is claimed.
