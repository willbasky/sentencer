module Config
  (
    Config(..)
  , fetchConfig
  ) where

import Toml ( decode, Result(Success, Failure) )
import Toml.FromValue
    ( FromTable(..), FromValue(fromValue), defaultTableFromValue )
import Toml.FromValue.Generic ( genericFromTable )
import qualified Data.ByteString.Char8 as B
import GHC.Generics (Generic)


data Config = Config
  { directory :: FilePath
  , input :: FilePath
  }
  deriving stock (Eq, Show, Generic)

instance FromTable Config where fromTable = genericFromTable
instance FromValue Config where fromValue = defaultTableFromValue

fetchConfig :: IO Config
fetchConfig = do
  toml <- B.unpack <$> B.readFile "content.toml"
  case decode toml of
    Failure errs -> fail $ unlines errs
    Success _ c -> pure c
