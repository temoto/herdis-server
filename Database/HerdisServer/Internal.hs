-- Internal utility functions.

module Database.HerdisServer.Internal where

import Network (HostName, PortNumber)
import System.IO
import Text.Printf


data Client = Client Handle HostName PortNumber

instance Show Client where
    show client = client_str
        where
          (Client _ host port) = client
          port_int = fromIntegral port :: Integer
          client_str = printf "%s:%d" host port_int

