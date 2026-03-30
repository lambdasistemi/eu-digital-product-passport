# UNTP Battery Example

A complete UNTP Digital Product Passport instance for an EV battery, wrapped as a W3C Verifiable Credential.

```json
--8<-- "examples/untp-dpp-ev-battery.json"
```

## Key observations

- **Verifiable Credential envelope** — the DPP is cryptographically signable and verifiable
- **DID-based issuer** — `did:web:identifiers.example-gmbh.de:batteries`
- **GS1 identifiers** — GTIN used for both product and issuer identification
- **Item-level granularity** — this passport is for a specific serial-numbered unit
- **Materials provenance** — 5 materials with origin countries, mass fractions, and recycled content
- **Dual conformity claims** — one for carbon footprint, one for recycled content
- **Hazardous flag** — electrolyte (LiPF6) marked as hazardous

## Comparison with Battery Pass format

| Aspect | UNTP | Battery Pass |
|--------|------|-------------|
| Envelope | W3C Verifiable Credential | Standalone JSON/AAS |
| Identifier | DID + GS1 | URN + product ID |
| Scope | Cross-sector | Battery-specific |
| Carbon data | Summary scorecard | Detailed per-lifecycle-stage |
| Performance | Not included | SoH, cycle count, capacity |
| Materials | Generic provenance | Chemistry-specific composition |

The two formats are complementary — UNTP provides the trust and interoperability layer, Battery Pass provides the domain-specific depth.
