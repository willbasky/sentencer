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
  res <- exec "ls" defaultExecOptions (\_ -> pure unit)
  mBuffer <- read (stdout res) Nothing
  case mBuffer of
    Nothing -> log "No buffer"
    Just b -> do
      s <- NB.toString NE.UTF8 b
      log s
