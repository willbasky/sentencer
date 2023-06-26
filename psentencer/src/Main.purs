module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)

import Node.ChildProcess
import Node.Stream
import Data.Maybe
import Node.Buffer as NB
import Node.Encoding as NE

main :: Effect Unit
main = do
  log "The answer is "
  buf <- execSync "ls" defaultExecSyncOptions
  str <- NB.toString NE.UTF8 buf
  log str
