module Main (main) where

import qualified Shelly as S
import Shelly (Sh)
import qualified Data.Text as T
import Data.Text (Text)
-- import Text.Pretty.Simple
import Control.Lens
import Data.Aeson.Lens ( nth, AsValue(_String, _Array) )
import Data.Foldable ( Foldable(toList))
import Control.Concurrent.Async (mapConcurrently)


main :: IO ()
main = do
  S.shelly $ S.print_stdout False $ do
    txt <- S.readfile "../sample.txt"
    result <- S.liftIO $ mapConcurrently translator (T.lines txt)
    -- S.liftIO $ pPrint result
    S.writefile "../result.txt" $ T.concat result

-- Helpers

translator :: Text -> IO Text
translator source = do
  dump <- S.shelly $ runEsRu source
  pure $ foldTranslation $ normalizer dump

runEsRu :: Text -> Sh Text
runEsRu source =
  S.silently $ S.command "trans" ["es:ru", "-dump"] [source]

normalizer :: Text -> Text
normalizer = T.dropWhileEnd (/=']') . T.dropWhile (/= '[')

foldTranslation :: Text -> Text
foldTranslation t =
  foldrOf
    (_Just . _Array . folded . _Array)
    (\(toList -> a) acc
        -> T.unlines (reverse $ a ^.. taking 2 folded . _String)
        <> "\n"
        <> acc)
    T.empty
    (t ^? nth 0)
