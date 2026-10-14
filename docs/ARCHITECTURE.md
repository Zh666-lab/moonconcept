# Architecture

## Ownership boundary

Context privately stores copied labels and row arrays. RuleSystem normalizes and
owns every implication; Lattice owns concepts, edges and its Boolean order
matrix. Clarification privately stores groups and returns nested copies.
Concept/Implication/trace/metric results are caller-owned data. All consumers of
public implication/set values revalidate indices. Immutable transforms retain
original instances safely. Strings are immutable MoonBit values.

## Algorithms and contracts

1. Derivations scan Boolean incidence; closure is two Galois derivations.
2. NextClosure walks a fixed attribute order and checks the lectic prefix.
   It requires a closed seed; full enumeration either completes or raises.
3. Hasse construction compares extent inclusions then removes relations with
   intermediate nodes. Meet intersects extents; join intersects intents.
4. Horn closure repeatedly fires rules with included premises, recording only
   new attributes. Positive finite monotonicity bounds successful additions.
5. The canonical base follows the pseudo-intent definition in numeric subset
   order, which visits proper subsets first. The set P is a pseudo-intent iff
   P != P'' and every previously found pseudo-intent Q properly included in P
   satisfies Q'' included in P. Generated P -> P'' minus P rules are normalized.
6. Minimal generators enumerate subsets of a closed target in inclusion-compatible
   order, ignoring supersets of already found generators. This finds all
   inclusion-minimal sets, not just minimum-size ones.
7. Expert review maintains consistency of observations and accepted theory.
   Acceptance requires a new empirically valid rule. Rejection requires a new
   complete observation violating that rule while respecting accepted rules.
   Exhaustive question completion says only that closures agree on this finite
   observed vocabulary; it does not assert domain completeness.

No caching, global mutable state, platform I/O or external service dependencies.
Outputs use original vocabulary order and canonical sorted index sets. Basis
and inference order are deterministic for fixed input; JSON byte member order
is not an interoperability contract.

## Interchange and report layers

CXT has strict line/cardinality/symbol validation without label trimming.
CSV uses explicit field-start/unquoted/quoted/closed states and bounded
records/fields. JSON delegates syntax to core, checks nesting lexically, then
validates exact schemas/types/dimensions. Duplicate JSON keys have core's
last-wins semantics, deliberately not advertised as security canonicalization.
Reports include vocabularies once and use numeric DOT labels only, so untrusted
label strings cannot inject graph statements. File/network integration belongs
to the application.

## Test independence

The exhaustive oracle reconstructs closures directly from scalar matrix loops;
it does not call library extent/intent/set helpers. Its independent powerset
and subset routines determine closed sets, pseudo-intents and minimal generators.
Lattice tests inspect every pair/intermediate node and check GLB/LUB conditions.
Other tests check error classification, boundaries and mutable input/output
ownership. Assertions are exact, not self-updating snapshots. No timing or
cross-language performance advantage is claimed.
