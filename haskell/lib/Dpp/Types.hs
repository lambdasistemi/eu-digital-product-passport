{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Dpp.Types
-- Description : PlutusData types for the DPP signed readings protocol
-- License     : Apache-2.0
--
-- Haskell types matching the Aiken on-chain datum/redeemer
-- structures and their PlutusData encoding.
--
-- These types use Plutus primitives directly so they model the exact
-- on-chain data layout expected by the Aiken validator.
-- 'ToData'/'FromData' instances are hand-written to guarantee
-- constructor indices and field ordering match the Aiken source.
module Dpp.Types
    ( -- * Protocol types
      Commitment (..)
    , ReporterAssignment (..)
    , ItemLeaf (..)
    , ReporterLeaf (..)

      -- * Constructor indices (pinned, tested)
    , commitmentConstrIdx
    , reporterAssignmentConstrIdx
    , itemLeafConstrIdx
    , reporterLeafConstrIdx
    ) where

import Data.ByteString (ByteString)
import PlutusCore.Data (Data (..))
import PlutusTx.Builtins.Internal
    ( BuiltinByteString (..)
    , BuiltinData (..)
    )
import PlutusTx.IsData.Class
    ( FromData (..)
    , ToData (..)
    , UnsafeFromData (..)
    )

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

mkD :: Data -> BuiltinData
mkD = BuiltinData

unD :: BuiltinData -> Data
unD (BuiltinData d) = d

bsToD :: ByteString -> Data
bsToD = B

bsFromD :: Data -> Maybe ByteString
bsFromD (B bs) = Just bs
bsFromD _ = Nothing

bbsToD :: BuiltinByteString -> Data
bbsToD (BuiltinByteString bs) = B bs

bbsFromD :: Data -> Maybe BuiltinByteString
bbsFromD (B bs) = Just (BuiltinByteString bs)
bbsFromD _ = Nothing

-- ---------------------------------------------------------
-- Pinned constructor indices
-- ---------------------------------------------------------

-- | Constructor index for 'Commitment'. Aiken: @Commitment { ... }@
commitmentConstrIdx :: Integer
commitmentConstrIdx = 0

-- | Constructor index for 'ReporterAssignment'. Aiken: @ReporterAssignment { ... }@
reporterAssignmentConstrIdx :: Integer
reporterAssignmentConstrIdx = 0

-- | Constructor index for 'ItemLeaf'. Aiken: @ItemLeaf { ... }@
itemLeafConstrIdx :: Integer
itemLeafConstrIdx = 0

-- | Constructor index for 'ReporterLeaf'. Aiken: @ReporterLeaf { ... }@
reporterLeafConstrIdx :: Integer
reporterLeafConstrIdx = 0

-- ---------------------------------------------------------
-- Commitment
-- ---------------------------------------------------------

-- | A commitment binding a reading to a specific slot window.
-- Matches Aiken @dpp/reading.Commitment@.
--
-- Fields:
--   1. valid_from  : Int (slot)
--   2. valid_until : Int (slot)
data Commitment = Commitment
    { commitValidFrom :: !Integer
    , commitValidUntil :: !Integer
    }
    deriving stock (Show, Eq)

instance ToData Commitment where
    toBuiltinData Commitment{..} =
        mkD
            $ Constr
                commitmentConstrIdx
                [ I commitValidFrom
                , I commitValidUntil
                ]

instance FromData Commitment where
    fromBuiltinData bd = case unD bd of
        Constr 0 [I from, I until] ->
            Just $ Commitment from until
        _ -> Nothing

instance UnsafeFromData Commitment where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [I from, I until] ->
            Commitment from until
        _ -> error "unsafeFromBuiltinData: Commitment"

-- ---------------------------------------------------------
-- ReporterAssignment
-- ---------------------------------------------------------

-- | Reporter assignment on an item leaf.
-- Matches Aiken @dpp/reading.ReporterAssignment@.
--
-- Fields:
--   1. reporter_key : ByteArray (verification key hash)
--   2. next_reward  : Int
data ReporterAssignment = ReporterAssignment
    { assignmentReporterKey :: !BuiltinByteString
    , assignmentNextReward :: !Integer
    }
    deriving stock (Show, Eq)

instance ToData ReporterAssignment where
    toBuiltinData ReporterAssignment{..} =
        mkD
            $ Constr
                reporterAssignmentConstrIdx
                [ bbsToD assignmentReporterKey
                , I assignmentNextReward
                ]

instance FromData ReporterAssignment where
    fromBuiltinData bd = case unD bd of
        Constr 0 [key, I reward] ->
            ReporterAssignment
                <$> bbsFromD key
                <*> pure reward
        _ -> Nothing

instance UnsafeFromData ReporterAssignment where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B key, I reward] ->
            ReporterAssignment
                (BuiltinByteString key)
                reward
        _ ->
            error
                "unsafeFromBuiltinData: ReporterAssignment"

-- ---------------------------------------------------------
-- ItemLeaf
-- ---------------------------------------------------------

-- | An item leaf in the operator's MPT.
-- Matches Aiken @dpp/reading.ItemLeaf@.
--
-- Fields:
--   1. item_key   : ByteArray
--   2. reporter   : Option<ReporterAssignment>
--   3. commitment : Option<Commitment>
data ItemLeaf = ItemLeaf
    { itemKey :: !ByteString
    , itemReporter :: !(Maybe ReporterAssignment)
    , itemCommitment :: !(Maybe Commitment)
    }
    deriving stock (Show, Eq)

-- | Encode 'Maybe a' as Aiken Option: Some(x) = Constr 0 [x], None = Constr 1 []
optionToData :: (ToData a) => Maybe a -> Data
optionToData (Just x) = Constr 0 [unD (toBuiltinData x)]
optionToData Nothing = Constr 1 []

optionFromData :: (FromData a) => Data -> Maybe (Maybe a)
optionFromData (Constr 0 [d]) = Just <$> fromBuiltinData (mkD d)
optionFromData (Constr 1 []) = Just Nothing
optionFromData _ = Nothing

instance ToData ItemLeaf where
    toBuiltinData ItemLeaf{..} =
        mkD
            $ Constr
                itemLeafConstrIdx
                [ bsToD itemKey
                , optionToData itemReporter
                , optionToData itemCommitment
                ]

instance FromData ItemLeaf where
    fromBuiltinData bd = case unD bd of
        Constr 0 [key, rep, com] -> do
            k <- bsFromD key
            r <- optionFromData rep
            c <- optionFromData com
            Just $ ItemLeaf k r c
        _ -> Nothing

instance UnsafeFromData ItemLeaf where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B key, rep, com] ->
            ItemLeaf
                key
                (case rep of
                    Constr 0 [d] ->
                        Just (unsafeFromBuiltinData (mkD d))
                    Constr 1 [] -> Nothing
                    _ -> error "unsafeFromBuiltinData: ItemLeaf.reporter"
                )
                (case com of
                    Constr 0 [d] ->
                        Just (unsafeFromBuiltinData (mkD d))
                    Constr 1 [] -> Nothing
                    _ -> error "unsafeFromBuiltinData: ItemLeaf.commitment"
                )
        _ -> error "unsafeFromBuiltinData: ItemLeaf"

-- ---------------------------------------------------------
-- ReporterLeaf
-- ---------------------------------------------------------

-- | A reporter leaf in the operator's MPT.
-- Matches Aiken @dpp/reading.ReporterLeaf@.
--
-- Fields:
--   1. reporter_key        : ByteArray (verification key hash)
--   2. rewards_accumulated : Int
data ReporterLeaf = ReporterLeaf
    { reporterKey :: !BuiltinByteString
    , reporterRewardsAccumulated :: !Integer
    }
    deriving stock (Show, Eq)

instance ToData ReporterLeaf where
    toBuiltinData ReporterLeaf{..} =
        mkD
            $ Constr
                reporterLeafConstrIdx
                [ bbsToD reporterKey
                , I reporterRewardsAccumulated
                ]

instance FromData ReporterLeaf where
    fromBuiltinData bd = case unD bd of
        Constr 0 [key, I acc] ->
            ReporterLeaf
                <$> bbsFromD key
                <*> pure acc
        _ -> Nothing

instance UnsafeFromData ReporterLeaf where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B key, I acc] ->
            ReporterLeaf
                (BuiltinByteString key)
                acc
        _ ->
            error
                "unsafeFromBuiltinData: ReporterLeaf"
