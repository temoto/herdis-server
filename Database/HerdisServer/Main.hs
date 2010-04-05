module Main where

import Control.Concurrent.STM
import Control.Exception (finally)
import Network (withSocketsDo, listenOn, sClose)
import qualified Network (PortID(..))

import Database.HerdisServer.Server
import Database.HerdisServer.State


port = 19292


main = withSocketsDo $ do
    state <- atomically (newTVar mkState)
    sock <- listenOn $ Network.PortNumber port
    acceptLoop state sock `finally` sClose sock

