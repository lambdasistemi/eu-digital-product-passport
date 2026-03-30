# Data Model

## Core concepts

A Digital Product Passport consists of:

1. **Unique identifier** — links the physical product to its digital record
2. **Data carrier** — physical tag (QR code, DataMatrix, RFID, NFC) on the product
3. **Data record** — structured information stored in a registry or decentralized system
4. **Access control** — different visibility levels for different actors

## Identifier standards

The ESPR mandates the use of **unique product identifiers** conforming to ISO/IEC 15459 (unique identification). In practice:

| Standard | Use |
|----------|-----|
| GS1 Digital Link | Primary identifier scheme — GTIN + serial via URI |
| ISO/IEC 15459 | Unique identification of transport units |
| DID (W3C) | Decentralized identifiers for issuer/product identity |
| UUID / URN | Passport-level identifiers |

## Data carrier requirements

The data carrier on the product must:

- Be **physically affixed** to the product (or its packaging/documentation)
- Link to the **full DPP record** via a URI
- Support scanning by **standard devices** (smartphones for QR, readers for RFID/NFC)
- Be **durable** for the expected product lifetime
- Comply with **ISO/IEC 18004** (QR Code) or equivalent

## Data schemas in use

### Battery Pass (ESMF/SAMM)

Built on the Eclipse Semantic Modeling Framework. Source definitions in RDF/Turtle, generated outputs in JSON Schema, JSON-LD, OpenAPI, and AAS (Asset Administration Shell) XML.

7 sub-models:

| Sub-model | Content |
|-----------|---------|
| GeneralProductInformation | Identity, manufacturer, status, mass, dates |
| CarbonFootprint | Total and per-lifecycle-stage CO2, performance class |
| Circularity | Recyclability, disassembly, spare parts, end-of-life |
| MaterialComposition | Chemistry, critical raw materials, hazardous substances |
| Performance | Capacity, voltage, SoH, cycle count, energy throughput |
| Labels | CE marking, conformity declarations, regulatory labels |
| SupplyChainDueDiligence | Third-party audits, sustainability reports |

### UNTP Digital Product Passport (W3C VC)

The UN Transparency Protocol wraps the DPP as a **W3C Verifiable Credential** (VCDM 2.0) in JSON-LD.

Top-level structure of `credentialSubject`:

| Field | Content |
|-------|---------|
| `product` | Identity, description, classification, manufacturer, facility |
| `granularityLevel` | item / batch / model |
| `emissionsScorecard` | Carbon footprint, scope, primary-sourced ratio |
| `circularityScorecard` | Recyclable/recycled content, MCI |
| `materialsProvenance[]` | Origin country, mass fraction, hazardous flag |
| `conformityClaim[]` | Certifications, declarations, test results |
| `traceabilityInformation[]` | Supply chain events with hashes |
| `dueDiligenceDeclaration` | Link to due diligence report |

### Asset Administration Shell (AAS)

The German Industry 4.0 platform uses AAS as the DPP carrier format. The Battery Pass also publishes AAS XML exports. AAS is an IEC standard (IEC 63278) that provides a technology-neutral digital twin model.
