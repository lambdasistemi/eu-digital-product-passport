# Battery Pass Schema

The Battery Pass data model is the most mature DPP schema, developed by the Battery Pass consortium and aligned with **DIN DKE SPEC 99100:2025-02**.

## Source

- **Repository**: [github.com/batterypass/BatteryPassDataModel](https://github.com/batterypass/BatteryPassDataModel)
- **Version**: 1.2.0
- **Framework**: Eclipse Semantic Modeling Framework (ESMF/SAMM)
- **Source format**: RDF/Turtle
- **Generated outputs**: JSON Schema, JSON-LD, OpenAPI, AAS XML

## Sub-models

### GeneralProductInformation

| Field | Type | Description |
|-------|------|-------------|
| `productIdentifier` | string | Unique product ID |
| `batteryPassportIdentifier` | URN | Passport-level unique ID |
| `batteryCategory` | enum | `lmt`, `ev`, `industrial`, `stationary` |
| `batteryStatus` | enum | `Original`, `Repurposed`, `Reused`, `Remanufactured`, `Waste` |
| `batteryMass` | number (kg) | Total battery mass |
| `manufacturingDate` | datetime | Production timestamp |
| `manufacturerInformation` | object | Name, address, contact, identifiers |
| `operatorInformation` | object | Economic operator placing on market |
| `manufacturingPlace` | object | Factory address |

### CarbonFootprint

| Field | Type | Description |
|-------|------|-------------|
| `batteryCarbonFootprint` | number | kgCO2e per kWh |
| `carbonFootprintPerLifecycleStage` | array | Breakdown: extraction, production, distribution, recycling |
| `carbonFootprintPerformanceClass` | string | Class label (A-E) |
| `carbonFootprintStudy` | URI | Link to LCA study |
| `absoluteCarbonFootprint` | number | Total kgCO2e |

### MaterialComposition

| Field | Type | Description |
|-------|------|-------------|
| `batteryChemistry` | string | Cell chemistry (e.g., LFP, NMC, NCA) |
| `criticalRawMaterials` | array | List with origin and mass |
| `hazardousSubstances` | array | SVHC and REACH-listed substances |

### Performance

| Field | Type | Description |
|-------|------|-------------|
| `ratedCapacity` | number (Ah) | Nominal capacity |
| `nominalVoltage` | number (V) | Nominal voltage |
| `stateOfHealth` | number (%) | Current SoH |
| `cycleCount` | integer | Charge/discharge cycles |
| `energyThroughput` | number (kWh) | Cumulative energy delivered |
| `expectedLifetime` | number (cycles) | Design lifetime |

### Circularity

End-of-life management: disassembly instructions, recycling processes, spare parts availability, safety requirements for handling.

### Labels

CE marking, conformity declarations, regulatory labels, test certificates.

### SupplyChainDueDiligence

Third-party audit results, sustainability reports, conflict mineral declarations.
