module Main (main) where

import Data.Text (Text)
import qualified Data.Text as T
import Shelly (Sh)
import qualified Shelly as S
-- import Text.Pretty.Simple
import Config (Config (..), fetchConfig)
import Control.Concurrent.Async (mapConcurrently)
import Control.Lens
import Data.Aeson.Lens (AsValue (_Array, _String), nth)
import Data.Foldable (Foldable (toList))
import Data.List.Extra (takeWhileEnd)

main :: IO ()
main = do
  Config {..} <- fetchConfig
  let inputPath = directory <> "/" <> input
  S.shelly $ S.print_stdout False $ do
    txt <- S.readfile inputPath
    result <- S.liftIO $ mapConcurrently translator (T.lines txt)
    let outputPath
          = directory
          <> "/"
          <> "hs_result_"
          <> takeWhileEnd (/= '_') input
    S.writefile outputPath $ T.concat result

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
