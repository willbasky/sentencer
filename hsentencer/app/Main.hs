-- {-# LANGUAGE ExtendedDefaultRules #-}
-- {-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main (main) where

import qualified Shelly as S
import qualified Data.Text as T
import Data.Text (Text)
-- import qualified Data.Text.IO as TIO
-- import Text.Pretty.Simple
import Control.Lens
import Data.Aeson.Lens
-- import Data.Aeson
-- import Data.Aeson.Lens
import Data.Foldable ( Foldable(toList), foldrM )
-- import Data.Traversable

main :: IO ()
main = do
  S.shelly $ S.print_stdout False $ do
    txt <- S.readfile "../sample.txt"
    result <- foldrM translator T.empty (T.lines txt)
  -- pPrint result
    S.writefile "../result.txt" result

-- Helpers

translator :: Text -> Text -> S.Sh Text
translator source  acc = do
  dump <- S.run "trans" ["es:ru", "-dump", source]
  -- S.liftIO $ pPrint $ normalizer dump
  let target = T.unlines $ foldTranslation $ normalizer dump
  pure $ target <> "\n" <> acc


normalizer :: Text -> Text
normalizer = T.dropWhileEnd (/=']') . T.dropWhile (/= '[')

foldTranslation :: Text -> [Text]
foldTranslation t =
  foldrOf
    (_Just . _Array . folded . _Array)
    (\(toList -> a) acc ->
        reverse (a ^.. taking 2 folded . _String) <> acc)
    []
    (t ^? nth 0)
