/-
  Single-use commitment invariant.

  Proves that a commitment set in Tx 1 is consumed exactly once in Tx 2,
  and that after consumption the commitment slot is empty.
-/

import DppProofs.Protocol

namespace DppProofs

-- ============================================================
-- Single-use commitment
-- ============================================================

/-- After submitting a reading, the commitment is cleared. -/
theorem commitment_cleared_after_submit (leaf : ItemLeaf)
    (_h : leaf.commitment = some c) :
    (submitReading leaf).commitment = none := by
  simp [submitReading]

/-- A leaf with no commitment remains empty after submit. -/
theorem no_commitment_no_submit (leaf : ItemLeaf)
    (_h : leaf.commitment = none) :
    (submitReading leaf).commitment = none := by
  simp [submitReading]

/-- Setting a commitment then submitting returns to no commitment. -/
theorem set_then_submit_clears (leaf : ItemLeaf) (c : Commitment) :
    (submitReading (setCommitment leaf c)).commitment = none := by
  simp [submitReading, setCommitment]

/-- A commitment cannot be consumed twice: after submit, the leaf
    has no commitment, so a second submit is a no-op on an empty slot. -/
theorem double_submit_still_none (leaf : ItemLeaf)
    (_h : leaf.commitment = some c) :
    (submitReading (submitReading leaf)).commitment = none := by
  simp [submitReading]

/-- Setting a commitment preserves the reporter assignment. -/
theorem set_commitment_preserves_reporter (leaf : ItemLeaf) (c : Commitment) :
    (setCommitment leaf c).reporter = leaf.reporter := by
  simp [setCommitment]

/-- Submitting a reading preserves the reporter assignment. -/
theorem submit_preserves_reporter (leaf : ItemLeaf) :
    (submitReading leaf).reporter = leaf.reporter := by
  simp [submitReading]

/-- Submitting a reading preserves the item key. -/
theorem submit_preserves_item_key (leaf : ItemLeaf) :
    (submitReading leaf).itemKey = leaf.itemKey := by
  simp [submitReading]

-- ============================================================
-- Commitment freshness
-- ============================================================

/-- A reading is fresh if the current slot is within the commitment window. -/
def isFresh (c : Commitment) (currentSlot : Slot) : Prop :=
  c.validFrom ≤ currentSlot ∧ currentSlot ≤ c.validUntil

/-- A commitment whose window has passed is not fresh. -/
theorem expired_not_fresh (c : Commitment) (slot : Slot)
    (h : c.validUntil < slot) :
    ¬ isFresh c slot := by
  intro ⟨_, h2⟩
  exact Nat.not_le.mpr h h2

/-- A commitment before its window is not fresh. -/
theorem early_not_fresh (c : Commitment) (slot : Slot)
    (h : slot < c.validFrom) :
    ¬ isFresh c slot := by
  intro ⟨h1, _⟩
  exact Nat.not_le.mpr h h1

end DppProofs
