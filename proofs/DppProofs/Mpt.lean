/-
  MPT consistency invariant.

  Models a simplified Merkle Patricia Trie as a hash-indexed structure.
  Proves that valid leaf updates produce valid root transitions —
  the new root is determined entirely by the updated leaves.
-/

import DppProofs.Protocol

namespace DppProofs

-- ============================================================
-- Abstract hash model
-- ============================================================

/-- An abstract MPT where the root is a function of the leaves. -/
structure AbstractMpt where
  leaves : List (Nat × Nat)    -- (key, valueHash) pairs
  root   : Nat                 -- hash of all leaves
  deriving Repr

/-- Deterministic root computation from leaves. -/
def computeRoot (leaves : List (Nat × Nat)) : Nat :=
  leaves.foldl (fun acc (k, v) => acc * 31 + k * 17 + v) 0

/-- An MPT is consistent if its root matches the computed root. -/
def isConsistent (mpt : AbstractMpt) : Prop :=
  mpt.root = computeRoot mpt.leaves

/-- Update a single leaf value in the leaf list. -/
def updateLeaf (leaves : List (Nat × Nat)) (key : Nat) (newValue : Nat) :
    List (Nat × Nat) :=
  leaves.map fun (k, v) => if k = key then (k, newValue) else (k, v)

/-- Transition: update a leaf and recompute the root. -/
def mptTransition (mpt : AbstractMpt) (key : Nat) (newValue : Nat) :
    AbstractMpt :=
  let newLeaves := updateLeaf mpt.leaves key newValue
  { leaves := newLeaves, root := computeRoot newLeaves }

-- ============================================================
-- Consistency preservation
-- ============================================================

/-- A transition always produces a consistent MPT. -/
theorem transition_consistent (mpt : AbstractMpt) (key : Nat)
    (newValue : Nat) :
    isConsistent (mptTransition mpt key newValue) := by
  simp [isConsistent, mptTransition]

/-- If the original MPT is consistent and we apply a transition,
    the result is also consistent. -/
theorem transition_preserves_consistency (mpt : AbstractMpt) (key : Nat)
    (newValue : Nat) (_h : isConsistent mpt) :
    isConsistent (mptTransition mpt key newValue) := by
  exact transition_consistent mpt key newValue

-- ============================================================
-- Update properties
-- ============================================================

/-- Updating a leaf preserves the list length. -/
theorem updateLeaf_length (leaves : List (Nat × Nat)) (key val : Nat) :
    (updateLeaf leaves key val).length = leaves.length := by
  simp [updateLeaf]

/-- Updating the same key twice is the same as updating once with
    the final value. -/
theorem updateLeaf_idempotent (leaves : List (Nat × Nat))
    (key v1 v2 : Nat) :
    updateLeaf (updateLeaf leaves key v1) key v2 =
    updateLeaf leaves key v2 := by
  simp [updateLeaf, List.map_map]
  congr 1
  intro a b _
  split <;> simp_all

/-- A transition preserves the number of leaves. -/
theorem transition_preserves_length (mpt : AbstractMpt) (key val : Nat) :
    (mptTransition mpt key val).leaves.length = mpt.leaves.length := by
  simp [mptTransition, updateLeaf]

-- ============================================================
-- Reading submission as MPT transition
-- ============================================================

/-- A reading submission updates two leaves (item + reporter)
    and the result is consistent. -/
theorem reading_submission_consistent (mpt : AbstractMpt)
    (itemKey reporterKey : Nat) (itemVal reporterVal : Nat) :
    isConsistent
      (mptTransition (mptTransition mpt itemKey itemVal)
        reporterKey reporterVal) := by
  exact transition_consistent _ _ _

/-- Sequential transitions preserve leaf count. -/
theorem double_transition_preserves_length (mpt : AbstractMpt)
    (k1 k2 v1 v2 : Nat) :
    (mptTransition (mptTransition mpt k1 v1) k2 v2).leaves.length =
      mpt.leaves.length := by
  simp [mptTransition, updateLeaf]

end DppProofs
