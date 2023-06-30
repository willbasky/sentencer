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
-- import Node.Buffer.Immutable as NBI
import Node.Encoding as NE
import Node.FS.Sync as FS -- TODO: consider use Node.FS.Aff
import Data.String as S
import Data.Argonaut as Argo
import Data.Argonaut (Json, _Array, jsonParser, _String, isString, fromArray, decodeJson)
import Data.Eq ((/=))
import Prim.Boolean
import Data.Array as Array
import Data.List (List)
import Data.List as List
import Data.Either
import Data.Lens
import Data.Functor ((<$>))
import Control.Bind ((=<<))
import Data.Maybe
import Debug
import Data.Tuple
import Data.String.CodePoints
import Data.String.Pattern
import Data.Traversable

main :: Effect Unit
main = do
  sources <- S.split (Pattern "\n") <$> FS.readTextFile NE.UTF8 "sample.txt"
  -- logShow txt
  -- let source = "Hola. Cómo estás. \nDónde está el medico?"
  -- let sourceN = "Hola.\nCómo estás.\nDónde está el medico?"
  -- launchAff_ $ liftEffect $
  resres <- for sources $ \t -> do
    buf <- execFileSync "trans" ["es:ru", "-dump", t] defaultExecSyncOptions
    lns <- NB.toString NE.UTF8 buf
    let target = normalizer lns
    let targetJsonM = preview ( _Right) $ jsonParser target
  -- traceM targetJsonM
    pure $ case foldTranslation target of
      Nothing -> []
      Just res -> res
    -- traceM resRaw
  let res = Array.concatMap (\arr -> map (\(Tuple a b) -> a<> "\n"<> b<> "\n") arr) resres
  let resS = S.joinWith "\n" res
  FS.writeTextFile NE.UTF8 "ps-result.txt" resS



normalizer :: String -> String
normalizer = S.takeWhile (_ /= codePointFromChar '\n')  <<< S.dropWhile (_ /= codePointFromChar '[')

foldTranslation :: String -> Maybe (Array (Tuple String String))
foldTranslation e = (preview ( _Right) $ jsonParser e)
  <#> (_ ^. _Array) >>= Array.head
  <#> (_ ^. _Array)
  <#> Array.filter (\x
        -> x ^. _Array
        # Array.head
        <#> isString
        # isTrueMaybe)
  <#> map (Array.take 2 <<< (_ ^. _Array))
  >>= (\x -> preview _Right $ decodeJson $ fromArray $ map fromArray x)


isTrueMaybe :: Maybe Boolean -> Boolean
isTrueMaybe (Just true) = true
isTrueMaybe _           = false
