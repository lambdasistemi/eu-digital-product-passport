/-
  Protocol model for the DPP signed sensor readings protocol.

  Models the core state types and valid transitions as described in
  docs/cardano/signed-readings.md — commitment lifecycle, reporter
  assignment, and reward accumulation.
-/

namespace DppProofs

/-- A commitment binds a reading to a specific slot window. -/
structure Commitment where
  validFrom  : Nat
  validUntil : Nat
  deriving Repr, DecidableEq

/-- Reporter assignment: who reports and what they earn per reading. -/
structure ReporterAssignment where
  reporterKey : Nat   -- abstract key identifier
  nextReward  : Nat
  hReward     : nextReward > 0
  deriving Repr

/-- An item leaf in the operator's MPT. -/
structure ItemLeaf where
  itemKey    : Nat
  reporter   : Option ReporterAssignment
  commitment : Option Commitment
  deriving Repr

/-- A reporter leaf in the operator's MPT. -/
structure ReporterLeaf where
  reporterKey        : Nat
  rewardsAccumulated : Nat
  deriving Repr

/-- The operator's MPT state — item leaves and reporter leaves. -/
structure MptState where
  items     : List ItemLeaf
  reporters : List ReporterLeaf
  deriving Repr

/-- A signed reading submitted by the user. -/
structure SignedReading where
  itemKey   : Nat
  validFrom : Nat
  validUntil : Nat
  deriving Repr

/-- Current slot (for freshness checking). -/
abbrev Slot := Nat

-- ============================================================
-- Transitions
-- ============================================================

/-- Tx 1: Operator sets a commitment on an item leaf. -/
def setCommitment (leaf : ItemLeaf) (c : Commitment) : ItemLeaf :=
  { leaf with commitment := some c }

/-- Tx 2: Submit a reading — clears commitment, returns reward amount.
    Preconditions are encoded in the theorem statements, not here. -/
def submitReading (leaf : ItemLeaf) : ItemLeaf :=
  { leaf with commitment := none }

/-- Update reporter rewards after a successful reading. -/
def creditReporter (rleaf : ReporterLeaf) (reward : Nat) : ReporterLeaf :=
  { rleaf with rewardsAccumulated := rleaf.rewardsAccumulated + reward }

end DppProofs
