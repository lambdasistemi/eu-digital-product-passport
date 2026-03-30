# UNTP Digital Product Passport

The UN Transparency Protocol (UNTP) defines a cross-sector DPP format wrapped as a **W3C Verifiable Credential** (VCDM 2.0) in JSON-LD.

## Source

- **Spec**: [uncefact.github.io/spec-untp/docs/specification/DigitalProductPassport](https://uncefact.github.io/spec-untp/docs/specification/DigitalProductPassport/)
- **Version**: 0.6.0
- **JSON Schema**: `https://test.uncefact.org/vocabulary/untp/dpp/untp-dpp-schema-0.6.0.json`
- **JSON-LD context**: `https://test.uncefact.org/vocabulary/untp/dpp/0.6.0/`

## Structure

The UNTP DPP is a Verifiable Credential with this top-level shape:

```json
{
  "type": ["DigitalProductPassport", "VerifiableCredential"],
  "@context": ["https://www.w3.org/ns/credentials/v2", "..."],
  "id": "...",
  "issuer": { ... },
  "validFrom": "...",
  "validUntil": "...",
  "credentialSubject": {
    "type": ["ProductPassport"],
    "product": { ... },
    "emissionsScorecard": { ... },
    "circularityScorecard": { ... },
    "materialsProvenance": [ ... ],
    "conformityClaim": [ ... ],
    "traceabilityInformation": [ ... ],
    "dueDiligenceDeclaration": { ... }
  }
}
```

## credentialSubject fields

### product

| Field | Type | Description |
|-------|------|-------------|
| `id` | URI | GS1 Digital Link or equivalent |
| `name` | string | Product name |
| `registeredId` | string | GTIN + serial |
| `description` | string | Product description |
| `productCategory` | array | UN CPC classification |
| `producedByParty` | object | Manufacturer identity |
| `producedAtFacility` | object | Factory identity |
| `productionDate` | date | Manufacturing date |
| `countryOfProduction` | string | ISO 3166-1 alpha-2 |
| `serialNumber` | string | Item-level serial |
| `dimensions` | object | Weight, length, width, height, volume |

### emissionsScorecard

| Field | Type | Description |
|-------|------|-------------|
| `carbonFootprint` | number | CO2e per declared unit |
| `declaredUnit` | string | Unit (KGM, kWh, etc.) |
| `operationalScope` | enum | `CradleToGate`, `CradleToGrave` |
| `primarySourcedRatio` | number (0-1) | Ratio of primary vs. secondary data |

### circularityScorecard

| Field | Type | Description |
|-------|------|-------------|
| `recyclableContent` | number (0-1) | Fraction recyclable |
| `recycledContent` | number (0-1) | Fraction from recycled sources |
| `utilityFactor` | number | Functional utility ratio |
| `materialCircularityIndicator` | number (0-1) | Ellen MacArthur MCI |

### materialsProvenance

Array of materials, each with:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Material name |
| `originCountry` | string | ISO country code |
| `massFraction` | number (0-1) | Fraction of total mass |
| `mass` | object | Absolute mass with unit |
| `recycledMassFraction` | number (0-1) | Recycled fraction |
| `hazardous` | boolean | Hazardous substance flag |

### conformityClaim

Array of claims/certifications with conformance status, topic, assessment date, and declared values.

### traceabilityInformation

Supply chain events with cryptographic hashes for tamper evidence.

## Key difference from Battery Pass

The UNTP DPP is **sector-agnostic** — it works for any product. The Battery Pass schema is **battery-specific** with domain fields like SoH, cycle count, and cell chemistry. In practice, a battery DPP could use UNTP as the envelope and Battery Pass sub-models for the detailed content.
