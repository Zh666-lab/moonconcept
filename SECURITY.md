# Security and resource boundaries

This library analyses data; it must never be used by itself to grant access,
verify a security policy, prove a medical/financial conclusion or automatically
accept expert knowledge. Observed implications can be vacuously valid and are
not claims about all possible future objects. Metrics are descriptive, not
significance tests. Expert acceptance is a caller decision.

Treat public labels as untrusted data. CXT rejects multiline labels; CSV and
JSON preserve them. **CSV exports are not spreadsheet-formula sanitized**:
opening labels beginning with =, +, -, @ in a spreadsheet may interpret them.
Perform context-appropriate escaping before displaying/exporting into other
systems. DOT uses only numeric safe identifiers/labels. Raw report JSON is not
HTML. Never interpolate labels directly into SQL/HTML/shell commands.

Core JSON uses last duplicate key wins; the interchange is not a canonical
signed serialization or security-policy parser. Reject duplicate keys externally
when your application requires that stricter boundary.

Dimension/candidate/work limits prevent unbounded enumerations but are not
wall-clock or memory guarantees. Core JSON parsing and intermediate arrays
allocate up to documented input limits. Choose smaller application-level budgets
for untrusted workloads and sandbox/time out externally. Canonical bases and
minimal generators are exponential, and Hasse reduction is cubic.

No credential is required in library/example/consumer flows. Build and publish
credentials belong outside the repository and must not be committed. Report a
reproducible library bug using repository issues with a small synthetic context;
do not send tokens or personal datasets. This project does not operate an
emergency security response service or promise response times.
