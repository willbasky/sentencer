{-# LANGUAGE NamedFieldPuns #-}
module Main (main) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Shelly as S
import Config (Config (..), fetchConfig)
import Util ( flatten, listToTuple, normalizer, runEsRu )
import Control.Concurrent.Async (mapConcurrently)
import Control.Lens
    ( (^..), (^?), folded, foldrOf', _Just, taking )
import Data.Aeson.Lens (AsValue (_Array, _String), nth)
import Data.Foldable (Foldable (toList))
import Data.List.Extra (takeWhileEnd)
import qualified Data.List.NonEmpty as NE
import Data.List.NonEmpty (NonEmpty)
import qualified Data.ByteString.Char8 as B


main :: IO ()
main = do
  Config {directory,input} <- fetchConfig
  let inputPath = directory <> "/" <> input
  S.shelly $ S.print_stdout False $ do
    txt <- S.readfile inputPath
    result <- S.liftIO $ mapConcurrently translator (T.lines txt)
    let outputPath
          = directory
          <> "/"
          <> "hs_result_"
          <> takeWhileEnd (/= '_') input
        list = flatten result
    -- liftIO $ mapM_ TIO.putStrLn list
    S.writefile outputPath $ T.intercalate "\n\n" list

-- Helpers

translator :: Text -> IO [(Text, Text)]
translator source = do
  dump <- S.shelly $ runEsRu source
  case parseTranslation $ normalizer dump of
    Nothing -> do
      B.putStrLn $ "LOG: There is not translation for\n<<<\n" <> TE.encodeUtf8 source
      B.putStrLn ">>>"
      pure []
    Just list -> pure $ NE.toList list

parseTranslation :: Text -> Maybe (NonEmpty (Text, Text))
parseTranslation t =
    let addValid xs acc = if length xs >= 2 then listToTuple xs : acc else acc
        stringOnly2 a = reverse (a ^.. taking 2 folded . _String)
    in NE.nonEmpty $ foldrOf'
      (_Just . _Array . folded . _Array)
      (\(toList -> a) acc
          -> addValid (stringOnly2 a) acc)
      []
      (t ^? nth 0)


