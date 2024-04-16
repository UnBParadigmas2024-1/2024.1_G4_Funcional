module Game
  ( introduction,
    helpInstructions,
    playGame,
    getWordFromFile,
    loop,
    makeAttempt
  )
where

import Control.Arrow ((&&&))
import Control.Monad (forM_, mzero, when, unless)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.ST.Strict (ST)
import Control.Monad.State
  ( StateT,
    evalStateT,
    gets,
    modify,
    modify',
  )
import Control.Monad.Trans.Maybe (MaybeT, runMaybeT)
import Utils (CharacterStatus (..), GameState (..))

import qualified Data.Map.Strict as M
import qualified Data.Text as T
import System.Console.Pretty
  ( Color (Blue, Green, White, Yellow),
    Style (Bold),
    bgColor,
    color,
    style,
  )
import Text.Printf (printf)

introduction :: T.Text
introduction =
  T.pack "Bem vindo ao G4 Termo!\nDigite "
    <> color Green (T.pack ":?")
    <> T.pack " para as intruções de ajuda\n\n"
    <> color Green (T.pack ":s")
    <> T.pack " para sair."

helpInstructions :: T.Text
helpInstructions =
  style Bold (T.pack "Regras\n\n")
    <> T.pack "Você tem 6 tentativas para adivinhar a palavra. Cada\n"
    <> T.pack "tentativa deve ser uma palavra de 5 letras válida.\n\n"
    <> T.pack "Após cada tentativa, as cores das letras\n"
    <> T.pack "indicarão quão próxima a tentativa está da resposta.\n\n"
    <> T.pack "Ignore acentuação e cedilha.\n\n"
    <> style Bold (T.pack "Exemplos\n\n")
    <> color Green (T.pack " M ")
    <> T.pack " A N G A \nA letra"
    <> color Green (T.pack " M ")
    <> T.pack "existe na palavra e está na posição correta.\n\n"
    <> T.pack " V "
    <> color White (T.pack " I ")
    <> T.pack " O  L  A \nA letra"
    <> color Yellow (T.pack " I ")
    <> T.pack "existe na palavra mas em outra posição.\n\n"
    <> T.pack " P  L  U "
    <> color White (T.pack " M ")
    <> T.pack " A \nA letra M não existe na palavra.\n"

loop :: (Monad m) => m (Maybe a) -> m a
loop action = action >>= maybe (loop action) pure

continue :: Game a
continue = mzero

printLnS :: (MonadIO m) => T.Text -> m ()
printLnS = liftIO . putStrLn . T.unpack

type Game a = MaybeT (StateT GameState IO) a

getWordFromFile :: IO (M.Map T.Text T.Text)
getWordFromFile = do
  fileContent <- readFile "palavras.txt"
  let allWords = T.lines $ T.pack fileContent
  pure $ M.fromList $ map (T.map normalizeAccents &&& id) allWords
  where
    normalizeAccents 'Á' = 'A'
    normalizeAccents 'À' = 'A'
    normalizeAccents 'Ã' = 'A'
    normalizeAccents 'Â' = 'A'
    normalizeAccents 'É' = 'E'
    normalizeAccents 'Ê' = 'E'
    normalizeAccents 'Í' = 'I'
    normalizeAccents 'Õ' = 'O'
    normalizeAccents 'Ó' = 'O'
    normalizeAccents 'Ô' = 'O'
    normalizeAccents 'Ú' = 'U'
    normalizeAccents 'Ç' = 'C'
    normalizeAccents cha = cha

playGame :: Game ()
playGame = do
  let getHelpAndPrint = printLnS helpInstructions

  line <- liftIO getLine
  case line of
    ":s" -> pure ()
    ":?" -> getHelpAndPrint >> continue
    _    -> liftIO (putStrLn "Invalid input!") >> playGame
    word -> makeAttempt $ T.toUpper (T.pack word)

-- atualização da função makeAttempt, utilização de when e unless pra simplificação, utilização da gets para obter multiplos valores de uma vez 
makeAttempt :: T.Text -> Game ()
makeAttempt word = do
  (wordMap, answer, guesses, maxGuesses) <- gets (\s -> (_wordMap s, _answer s, _guesses s, _maxGuesses s))

  unless (M.member word wordMap) $ do
    printLnS $ T.pack "Palavra inválida, por favor tente novamente"
    continue

  let attemptResult = showAttempt word answer
  printLnS $ renderAttempt word attemptResult
  let updm = updateAttemptMap word attemptResult . _attemptMap
  modify' (\s -> s {_attemptMap = updm s})

  let msg = "A palavra era '" <> T.unpack (wordMap M.! answer) <> "'"

  when (word == answer) $ do
    printLnS $ T.pack ("Você ganhou! " ++ msg)
    pure ()

  when (guesses >= maxGuesses) $ do
    printLnS $ T.pack ("Você perdeu! " ++ msg)
    pure ()

  modify (\s -> s {_guesses = _guesses s + 1})
  continue

-- Função atualizada displayattempt, redução nas multiplas chamadas da func gets para apenas 1 e utilização da função printf 
displayAttemptNumbers :: Game ()
displayAttemptNumbers = do
  (currentGuess, maxGuesses) <- gets (\s -> (_guesses s, _maxGuesses s))
  liftIO . putStr $ printf "Digite sua tentativa [%d/%d]: " currentGuess maxGuesses
