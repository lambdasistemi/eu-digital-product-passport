/-
  Reward monotonicity invariant.

  Proves that reporter rewards never decrease across any sequence
  of valid protocol transitions.
-/

import DppProofs.Protocol

namespace DppProofs

-- ============================================================
-- Single credit monotonicity
-- ============================================================

/-- Crediting a reporter strictly increases their accumulated rewards. -/
theorem credit_increases (rleaf : ReporterLeaf) (reward : Nat)
    (hReward : reward > 0) :
    (creditReporter rleaf reward).rewardsAccumulated >
      rleaf.rewardsAccumulated := by
  simp [creditReporter]
  exact hReward

/-- Crediting a reporter never decreases their accumulated rewards. -/
theorem credit_monotone (rleaf : ReporterLeaf) (reward : Nat) :
    (creditReporter rleaf reward).rewardsAccumulated ≥
      rleaf.rewardsAccumulated := by
  simp [creditReporter, Nat.le_add_right]

/-- Crediting preserves the reporter key. -/
theorem credit_preserves_key (rleaf : ReporterLeaf) (reward : Nat) :
    (creditReporter rleaf reward).reporterKey = rleaf.reporterKey := by
  simp [creditReporter]

-- ============================================================
-- Sequential credits monotonicity
-- ============================================================

/-- Two successive credits produce a sum of rewards. -/
theorem double_credit_sum (rleaf : ReporterLeaf) (r1 r2 : Nat) :
    (creditReporter (creditReporter rleaf r1) r2).rewardsAccumulated =
      rleaf.rewardsAccumulated + r1 + r2 := by
  simp [creditReporter, Nat.add_assoc]

/-- After n credits of the same reward, total = initial + n * reward. -/
theorem repeated_credit (rleaf : ReporterLeaf) (reward : Nat) :
    ∀ n : Nat,
      (Nat.repeat (creditReporter · reward) n rleaf).rewardsAccumulated =
        rleaf.rewardsAccumulated + n * reward := by
  intro n
  induction n with
  | zero => simp [Nat.repeat]
  | succ k ih =>
    simp only [Nat.repeat, creditReporter] at ih ⊢
    rw [ih, Nat.succ_mul, Nat.add_assoc]

/-- Monotonicity across any number of credits: rewards after n credits
    are at least as large as after m credits, when n ≥ m. -/
theorem repeated_credit_monotone (rleaf : ReporterLeaf) (reward : Nat)
    (m n : Nat) (h : n ≥ m) :
    (Nat.repeat (creditReporter · reward) n rleaf).rewardsAccumulated ≥
    (Nat.repeat (creditReporter · reward) m rleaf).rewardsAccumulated := by
  simp only [repeated_credit]
  exact Nat.add_le_add_left (Nat.mul_le_mul_right reward h) _

-- ============================================================
-- Initial reporter leaf
-- ============================================================

/-- A new reporter starts with exactly the first reward. -/
theorem initial_reporter_reward (key : Nat) (reward : Nat) :
    (creditReporter ⟨key, 0⟩ reward).rewardsAccumulated = reward := by
  simp [creditReporter]

end DppProofs
