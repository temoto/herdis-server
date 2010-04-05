module Database.HerdisServer.State where

import Data.ByteString (ByteString)
import qualified Data.Map as M
import qualified Data.Set as S


type HKey = String

data HValue = HNil
            | HBytes String
            | HList [HValue]
            | HSet (S.Set HValue)
            deriving (Eq, Ord, Show)

newtype HerdisState = HerdisState (M.Map HKey HValue)
mkState = HerdisState M.empty

stateGet :: HerdisState -> HKey -> HValue
stateGet (HerdisState state_map) key = M.findWithDefault HNil key state_map

stateSet :: HerdisState -> HKey -> HValue -> HerdisState
stateSet (HerdisState state_map) key value = HerdisState updated
    where
      updated = M.insert key value state_map
