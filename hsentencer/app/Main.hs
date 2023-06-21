{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main (main) where

import Shelly qualified as S
import qualified Data.Text as T
-- import qualified Data.Text.IO as TIO
-- import Text.Pretty.Simple
-- import Data.Maybe
import Control.Lens
import Data.Aeson.Lens
import Data.Foldable

main :: IO ()
main = do
  S.shelly $ S.print_stdout False $ do
    txt <- S.readfile "../sample.txt"
    let texts = T.lines txt
    S.writefile "../result.txt" T.empty
    for_ texts $ \t -> do
      dump <- S.run "trans" ["es:ru", "-dump", t]
      let normilised = normalizer dump
      let tr = foldTranslation normilised
      S.appendfile "../result.txt" $ T.unlines $ pairSwap tr


pairSwap :: [a] -> [a]
pairSwap [] = []
pairSwap [a] = [a]
pairSwap (a:b:ss) = b : a : pairSwap ss

normalizer :: T.Text -> T.Text
normalizer = T.dropWhileEnd (/=']') . T.dropWhile (/= '[')

foldTranslation :: T.Text -> [T.Text]
foldTranslation t = (t ^? nth 0)
            ^.. _Just
            . _Array
            . folded
            . _Array
            . taking 2 folded
            . _String
