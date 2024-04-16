import Control.Monad (when)
import Control.Monad.Trans.Maybe (runMaybeT)
import Control.Monad.Trans.State (evalStateT)
import qualified Data.Map.Strict as M
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Game (game, getWordMap, introString, loop)
import System.IO (BufferMode (NoBuffering), hSetBuffering, stdout)
import System.Random (mkStdGen, randomR)
import Utils (CharacterStatus (..), GameState (..))

main :: IO ()
main =
  do
    hSetBuffering stdout NoBuffering

    wordMap <- getWordMap

    let gen = mkStdGen 42
        ix = fst $ randomR (0, length wordMap - 1) gen

    when (ix < 0) $ error "Lista de palavras não encontrada"

    T.putStrLn introString

    evalStateT
      (loop $ runMaybeT game)
      $ GS
        { _attemptMap =
            M.fromList $
              map (\letter -> (letter, Untested)) ['A' .. 'Z'],
          _guesses = 1,
          _wordMap = wordMap,
          _answer = fst $ M.elemAt ix wordMap,
          _maxGuesses = 6
        }
