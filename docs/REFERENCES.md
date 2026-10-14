# References and rights

This is an original MoonBit implementation under MIT, not a source port.
No external source, benchmark fixture or production dataset is copied/vendored.
All test data and runnable example incidence matrices are synthetic and original.

Mathematical background:

* Bernhard Ganter and Rudolf Wille, *Formal Concept Analysis: Mathematical
  Foundations*, Springer, 1999: formal contexts, derivations and concept lattices.
* Bernhard Ganter, *Two Basic Algorithms in Concept Analysis*, technical report,
  1984 (reprinted in 2010): NextClosure's lectic enumeration principle.
* Vincent Duquenne and Jean-Louis Guigues, *Familles minimales d'implications
  informatives résultant d'un tableau de données binaires*, 1986: pseudo-intent
  implication bases. Implemented by the definition, with explicit finite bounds.
* Armstrong's positive implication inference principles motivate monotone
  forward chaining; this is not a general logic interpreter.

Capability/format comparison: [xflr6/concepts](https://github.com/xflr6/concepts),
MIT. Its public CXT format writer was inspected to confirm the layout;
implementation was not copied. MoonConcept has pure MoonBit finite FCA plus
implication discovery/review/metrics and typed interchange; it does not claim
all Python concepts features or cross-language differential-test results.
CSV uses the familiar doubled-quote/comma/CRLF convention with its documented
incidence profile; no broad spreadsheet interoperability/security claim.

Runtime/standard-library dependency:
[moonbitlang/core](https://github.com/moonbitlang/core), Apache-2.0, supplied by
the official toolchain; core's JSON parser/stringifier is called, not copied.
Core is not relicensed by this project. No optional dependency is silently
required. CI uses the official MoonBit toolchain and GitHub checkout action.

Adjacent ecosystem packages and their investigated boundaries/licenses are
recorded separately in docs/competition/duplicate-check.md. They are not
implementation dependencies.
