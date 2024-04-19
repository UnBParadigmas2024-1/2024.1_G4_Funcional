module Utils (GameState (..), CharacterStatus (..)) where

import qualified Data.Map.Strict as M
import qualified Data.Text as T


data GameState = GS
  { _attemptMap :: !(M.Map Char CharacterStatus),
    _guesses :: !Int,
    _wordMap :: !(M.Map T.Text T.Text),
    _answer :: !T.Text,
    _maxGuesses :: !Int,
    _victories :: !Int, 
    _defeats :: !Int, 
    _totalGames :: !Int 
  }


data CharacterStatus
  = Untested
  | DoesntExist
  | WrongPlace
  | RightPlace
  deriving (Show, Eq, Ord)
