import Control.Monad (when)
import Control.Monad.Trans.Maybe (runMaybeT)
import Control.Monad.Trans.State (evalStateT)
import qualified Data.Map.Strict as M
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Game (game, getWordMap, introString, loop)
import System.IO (BufferMode (NoBuffering), hSetBuffering, stdout)
import System.Random (newStdGen, randomR)
import Utils (CharacterStatus (..), GameState (..))

main :: IO ()
main =
  do
    hSetBuffering stdout NoBuffering

    fileContent <- T.readFile "palavras.txt"
    let allWords = map T.stripEnd $ T.lines fileContent
    print allWords
    let wordMap = getWordMap allWords
    gen <- newStdGen
    let ix = fst $ randomR (0, length allWords - 1) gen


    when (ix < 0) $ error "Lista de palavras não encontrada"

    let printColoredLn = T.putStrLn . T.pack

    T.putStrLn $ T.pack "\ESC[92m████████╗\ESC[0m███████╗\ESC[91m██████╗ \ESC[92m███╗   ███╗ \ESC[0m██████╗ "
    T.putStrLn $ T.pack "\ESC[92m╚══██╔══╝\ESC[0m██╔════╝\ESC[91m██╔══██╗\ESC[92m████╗ ████║\ESC[0m██╔═══██╗"
    T.putStrLn $ T.pack "\ESC[92m   ██║   \ESC[0m█████╗  \ESC[91m██████╔╝\ESC[92m██╔████╔██║\ESC[0m██║   ██║"
    T.putStrLn $ T.pack "\ESC[92m   ██║   \ESC[0m██╔══╝  \ESC[91m██╔══██╗\ESC[92m██║╚██╔╝██║\ESC[0m██║   ██║"
    T.putStrLn $ T.pack "\ESC[92m   ██║   \ESC[0m███████╗\ESC[91m██║  ██║\ESC[92m██║ ╚═╝ ██║\ESC[0m╚██████╔╝"
    T.putStrLn $ T.pack "\ESC[92m   ╚═╝   \ESC[0m╚══════╝\ESC[91m╚═╝  ╚═╝\ESC[92m╚═╝     ╚═╝ \ESC[0m╚═════╝ "

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
          _maxGuesses = 6,
          _victories =0,
          _defeats = 0,
          _totalGames =0
        }

