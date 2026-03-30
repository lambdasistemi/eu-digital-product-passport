# Pilots & Implementations

## Major EU-funded projects

### Battery Pass

- **Consortium**: BMW, BASF, Umicore, and others
- **Focus**: Battery passport data model and pilot implementation
- **Output**: Open-source data model on GitHub (`batterypass/BatteryPassDataModel`), aligned with DIN DKE SPEC 99100
- **Status**: Version 1.2.0 released, schema generation in JSON Schema, JSON-LD, OpenAPI, AAS XML
- **Website**: thebatterypass.eu

### CIRPASS

- **Funded by**: European Commission (Horizon Europe)
- **Focus**: Cross-sector DPP architecture for batteries, textiles, and electronics
- **Output**: System architecture document (D3.2), requirements specifications
- **Key contribution**: DID-based and HTTP URI-based dual architecture, GS1 Digital Link integration
- **Status**: Phase 1 complete; CIRPASS-2 continues the work
- **Website**: cirpassproject.eu

### Catena-X / Tractus-X

- **Focus**: Automotive industry data space with DPP as a core use case
- **Output**: Eclipse Tractus-X open-source components, battery pass semantic models
- **Key feature**: Decentralized data exchange using Eclipse Dataspace Connector (EDC)
- **Repository**: `eclipse-tractusx/sldt-semantic-models`

### SURPASS

- **Focus**: DPP for the textile and leather sectors
- **Output**: Textile passport data model and pilot
- **Status**: Active

### CIRFASHION

- **Focus**: Circular fashion and textile DPP
- **Partners**: Fashion brands and technology providers

## Industry initiatives

### GS1 Digital Link

GS1 is the primary identifier standard for DPPs. Their Digital Link standard allows:

- Encoding GTINs and serial numbers in QR codes
- Resolving product identifiers to DPP endpoints
- Interoperability across sectors and countries

### ECLASS / ETIM

Product classification standards used alongside DPPs for technical product data, especially in construction and electronics.

## Technology providers

Several companies offer DPP-as-a-service platforms:

- **SAP** — integrated DPP module in SAP S/4HANA
- **Spherity** — decentralized identity and DPP platform
- **Circulor** — supply chain traceability and DPP
- **iPoint** — product compliance and DPP management
- **R3 (Corda)** — blockchain-based DPP infrastructure

## Open standards and tools

| Resource | URL |
|----------|-----|
| Battery Pass Data Model | github.com/batterypass/BatteryPassDataModel |
| UNTP DPP Schema | uncefact.github.io/spec-untp/docs/specification/DigitalProductPassport |
| Eclipse Tractus-X | github.com/eclipse-tractusx |
| GS1 Digital Link | gs1.org/standards/gs1-digital-link |
| Asset Administration Shell | industrialdigitaltwin.org |
