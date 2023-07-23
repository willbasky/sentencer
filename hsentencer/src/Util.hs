module Util where

import Data.Text (Text)
import qualified Data.Text as T
import Shelly (Sh)
import qualified Shelly as S
import Data.Foldable (foldr')

listToTuple :: [a] -> (a, a)
listToTuple (take 2 -> xs) = (head xs, last xs)

flatten :: [[(Text,Text)]] -> [Text]
flatten tss =
  let flat t acc = foldr' unline acc t
      unline (a,b) acc = (a <>"\n" <> b) : acc
  in foldr' flat [] tss

runEsRu :: Text -> Sh Text
runEsRu source =
  S.silently $ S.command "trans" ["es:ru", "-dump"] [source]

normalizer :: Text -> Text
normalizer = T.dropWhileEnd (/=']') . T.dropWhile (/= '[')
