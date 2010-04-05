module Database.HerdisServer.Protocol where

import Control.Concurrent.STM (STM, TVar, readTVar, writeTVar)
import qualified Data.ByteString.Char8 as B
import qualified Data.Set as S
--import Text.ParserCombinators.Parsec
import Data.Attoparsec.Char8

import Database.HerdisServer.State


data Command
    = CmdNop
    | CmdGet HKey
    | CmdSet HKey HValue
    | CmdDelete HKey
    deriving (Show)

readCommand :: B.ByteString -> Either String Command
readCommand bs = case parse parseCommand bs of
                      Done _ cmd -> Right $! cmd
                      _ -> Left "parse error"

parseCommand :: Parser Command
parseCommand = choice [parseGet, parseSet, parseDelete]
           <?> "command"

parseGet :: Parser Command
parseGet = do string (B.pack "GET")
              space
              key <- many1 anyChar
              return $ CmdGet key

parseSet :: Parser Command
parseSet = do string (B.pack "SET")
              space
              key <- many1 (notChar ' ')
              space
              value <- parseValue
              return $ CmdSet key value

parseDelete :: Parser Command
parseDelete = do string (B.pack "DELETE")
                 space
                 key <- many1 anyChar
                 return $ CmdDelete key

parseValue :: Parser HValue
parseValue = choice [parseValueNil, parseValueOther]

parseValueNil :: Parser HValue
parseValueNil = do string (B.pack "n:")
                   return HNil
parseValueOther :: Parser HValue
parseValueOther = do tag <- anyChar
                     char ':'
                     case tag of
                          'b' -> do len <- decimal
                                    bytes <- len `count` anyChar
                                    return $ HBytes bytes
                          'l' -> do len <- decimal
                                    values <- len `count` parseValue
                                    return $ HList values
                          's' -> do len <- decimal
                                    values <- len `count` parseValue
                                    return $ HSet (S.fromList values)
                          other -> fail $ "Invalid HValue tag: " ++ show other
                  <?> "value"


--data Response = Response HValue (STM ())
type Response = STM HValue

executeCommand :: Command -> TVar HerdisState -> Response
executeCommand CmdNop _ = return HNil
executeCommand (CmdGet key) s_state = do
    state <- readTVar s_state
    return $ stateGet state key
executeCommand (CmdSet key value) s_state = do
    state <- readTVar s_state
    let new_state = stateSet state key value
    writeTVar s_state new_state
    return HNil

