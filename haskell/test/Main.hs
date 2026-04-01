{-# OPTIONS_GHC -Wno-orphans #-}

module Main (main) where

import Data.ByteString qualified as BS
import Dpp.Types
import PlutusCore.Data (Data (..))
import PlutusTx.Builtins.Internal (BuiltinByteString (..), BuiltinData (..))
import PlutusTx.IsData.Class (FromData (..), ToData (..))
import Test.Hspec
import Test.QuickCheck

-- ---------------------------------------------------------
-- Arbitrary instances
-- ---------------------------------------------------------

instance Arbitrary BuiltinByteString where
    arbitrary = BuiltinByteString . BS.pack <$> arbitrary

instance Arbitrary Commitment where
    arbitrary =
        Commitment
            <$> (getNonNegative <$> arbitrary)
            <*> (getNonNegative <$> arbitrary)

instance Arbitrary ReporterAssignment where
    arbitrary =
        ReporterAssignment
            <$> arbitrary
            <*> (getPositive <$> arbitrary)

instance Arbitrary ItemLeaf where
    arbitrary =
        ItemLeaf
            <$> (BS.pack <$> arbitrary)
            <*> arbitrary
            <*> arbitrary

instance Arbitrary ReporterLeaf where
    arbitrary =
        ReporterLeaf
            <$> arbitrary
            <*> (getNonNegative <$> arbitrary)

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

roundTrip :: (ToData a, FromData a, Eq a, Show a) => a -> Property
roundTrip x = fromBuiltinData (toBuiltinData x) === Just x

constrIdx :: (ToData a) => a -> Integer
constrIdx x = case toBuiltinData x of
    BuiltinData (Constr i _) -> i
    _ -> error "not a Constr"

-- ---------------------------------------------------------
-- Tests
-- ---------------------------------------------------------

main :: IO ()
main = hspec $ do
    describe "Commitment" $ do
        it "round-trips through PlutusData" $ property $
            \(c :: Commitment) -> roundTrip c
        it "uses constructor index 0" $
            constrIdx (Commitment 100 200) `shouldBe` commitmentConstrIdx
        it "constructor index is 0" $
            commitmentConstrIdx `shouldBe` 0

    describe "ReporterAssignment" $ do
        it "round-trips through PlutusData" $ property $
            \(r :: ReporterAssignment) -> roundTrip r
        it "uses constructor index 0" $
            constrIdx (ReporterAssignment (BuiltinByteString "key") 10)
                `shouldBe` reporterAssignmentConstrIdx
        it "constructor index is 0" $
            reporterAssignmentConstrIdx `shouldBe` 0

    describe "ItemLeaf" $ do
        it "round-trips through PlutusData" $ property $
            \(l :: ItemLeaf) -> roundTrip l
        it "uses constructor index 0" $
            constrIdx (ItemLeaf "key" Nothing Nothing)
                `shouldBe` itemLeafConstrIdx
        it "round-trips with Some reporter and Some commitment" $
            let leaf =
                    ItemLeaf
                        "item1"
                        (Just $ ReporterAssignment (BuiltinByteString "rk") 5)
                        (Just $ Commitment 100 200)
            in  fromBuiltinData (toBuiltinData leaf) `shouldBe` Just leaf
        it "round-trips with None fields" $
            let leaf = ItemLeaf "item2" Nothing Nothing
            in  fromBuiltinData (toBuiltinData leaf) `shouldBe` Just leaf

    describe "ReporterLeaf" $ do
        it "round-trips through PlutusData" $ property $
            \(r :: ReporterLeaf) -> roundTrip r
        it "uses constructor index 0" $
            constrIdx (ReporterLeaf (BuiltinByteString "key") 0)
                `shouldBe` reporterLeafConstrIdx
        it "constructor index is 0" $
            reporterLeafConstrIdx `shouldBe` 0

    describe "Edge cases" $ do
        it "empty ByteString fields round-trip" $
            let leaf = ItemLeaf "" Nothing Nothing
            in  fromBuiltinData (toBuiltinData leaf) `shouldBe` Just leaf
        it "zero reward round-trips" $
            let r = ReporterLeaf (BuiltinByteString "") 0
            in  fromBuiltinData (toBuiltinData r) `shouldBe` Just r
        it "large slot values round-trip" $
            let c = Commitment 999999999999 999999999999
            in  fromBuiltinData (toBuiltinData c) `shouldBe` Just c
