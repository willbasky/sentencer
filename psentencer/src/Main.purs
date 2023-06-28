module Main
  ( main
  -- , normalizer
  -- , toJSON
  )
  where

import Prelude

import Effect (Effect, foreachE )
import Effect.Console (log, logShow)
import Effect.Aff (launchAff_, launchAff)
import Effect.Class (liftEffect)

import Node.ChildProcess
import Node.Stream
import Data.Maybe
import Node.Buffer as NB
import Node.Encoding as NE
import Node.FS.Sync as FS -- TODO: consider use Node.FS.Aff
import Data.String.CodeUnits as SCU
import Data.Argonaut as Argo
import Data.Argonaut (Json, _Array, jsonParser)
import Data.Eq ((/=))
import Data.Array as Array
import Data.Either
import Data.Lens
import Data.Functor ((<$>))
import Control.Bind ((=<<))

main :: Effect Unit
main = do
  -- txt <- SU.lines <$> FS.readTextFile NE.UTF8 "sample.txt"
  -- logShow txt
  let source = "Hola. Cómo estás. Dónde está el medico?"
  -- let sourceN = "Hola.\nCómo estás.\nDónde está el medico?"
  -- launchAff_ $ liftEffect $
  -- lns <- foreachE (SU.lines sourceN) $ \t -> do
  buf <- execFileSync "trans" ["es:ru", "-dump", source] defaultExecSyncOptions
  lns <- NB.toString NE.UTF8 buf
  logShow $ foldTranslation $ normalizer lns


normalizer :: String -> String
normalizer = SCU.takeWhile (_ /= '\n')  <<< SCU.dropWhile (_ /= '[')

-- toJSON :: String -> Either String Json
-- toJSON str = jsonParser str

foldTranslation :: String -> Maybe Boolean
foldTranslation e = Argo.isArray <$> (preview ( _Right) $ jsonParser e)
