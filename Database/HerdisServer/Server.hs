module Database.HerdisServer.Server where

import Control.Concurrent (forkIO)
import Control.Concurrent.STM
import Control.Exception (finally)
import Control.Parallel (par, pseq)
import qualified Data.ByteString.Char8 as B
import Network (Socket, accept)
import qualified System.IO as IO
import System.IO.Error (isEOFError, try)

import Database.HerdisServer.Internal
import Database.HerdisServer.Protocol
import Database.HerdisServer.State


acceptLoop :: TVar HerdisState -> Socket -> IO ()
acceptLoop state socket = do
    (h, clientHost, clientPort) <- accept socket
    let client = Client h clientHost clientPort
    IO.hSetBuffering h IO.LineBuffering
    forkIO $ clientLoop state client
    acceptLoop state socket


clientLoop :: TVar HerdisState -> Client -> IO ()
clientLoop stmState client = loop `finally` IO.hClose h
    where
      (Client h _ _) = client
      loop = do
          r <- try (B.hGetLine h)
          case r of
               Left e -> if isEOFError e
                            then putStrLn $ "Client " ++ show client ++ " disconnected."
                            else ioError e
               Right line -> do
                   process line
                   loop
      process :: B.ByteString -> IO ()
      process line = do
          --putStrLn $ "From " ++ show client ++ ": " ++ line
          let r = readCommand line
          --case r of
          case r `par` r of
               Left e -> putStrLn $ "  Can't parse:" ++ show e
               Right cmd -> do
                   --putStrLn $ "  " ++ show cmd
                   result <- atomically $ executeCommand cmd stmState
                   IO.hPutStrLn h $ show result

