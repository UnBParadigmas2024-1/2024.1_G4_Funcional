module Game
  ( getWordMap,
    loop,
    game,
    helpString,
    continue,
    printLnS,
    Game,
    makeAttempt,
    renderAttempt,
    updateAttemptMap,
    introString,
  )
where

import Control.Arrow ((&&&))
import Control.Monad (forM_, mzero, when, unless)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.ST.Strict (ST)
import Control.Monad.State
  (
    StateT,
    evalStateT,
    gets,
    modify,
    modify',
  )
import Control.Monad.Trans.Maybe (MaybeT,)
import Data.Array (Array, (!))
import Data.Array.ST
  ( MArray (newArray),
    STArray,
    readArray,
    runSTArray,
    writeArray,
  )
import Data.Foldable (Foldable (toList), foldl')
import qualified Data.Map.Strict as M
import qualified Data.Text as T
import System.Console.Pretty
  ( Color (Blue, Green, White, Yellow),
    Style (Bold),
    bgColor,
    color,
    style,
  )

import Utils (CharacterStatus (..), GameState (..))
import Text.Printf (printf)

getWordMap :: [T.Text] -> M.Map T.Text T.Text
getWordMap allWords = M.fromList $ map (T.map normalizeAccents &&& removeNewline) allWords
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
    removeNewline = T.filter (/= '\r')

introString :: T.Text
introString =
  T.pack "Bem vindo ao Termo.hs!\nDigite "
    <> color Green (T.pack ":?")
    <> T.pack " para ajuda, "
    <> color Green (T.pack ":l")
    <> T.pack " para ver as letras adivinhadas, ou "
    <> color Green (T.pack ":s")
    <> T.pack " para sair."

loop :: (Monad m) => m (Maybe a) -> m a
loop action = action >>= maybe (loop action) pure

continue :: Game a
continue = mzero

printLnS :: (MonadIO m) => T.Text -> m ()
printLnS = liftIO . putStrLn . T.unpack

type Game a = MaybeT (StateT GameState IO) a

game :: Game ()
game = do
  displayAttemptNumbers

  let drawHelp = printLnS helpString
  let drawAttemptMap = gets _attemptMap >>= printLnS . showAttemptMap

  line <- liftIO getLine
  case line of
    ":s" -> pure ()
    ":?" -> drawHelp >> continue
    ":l" -> drawAttemptMap >> continue
    word -> makeAttempt $ T.toUpper (T.pack word)

 
  (victories, defeats, totalGames) <- gets (\s -> (_victories s, _defeats s, _totalGames s))
  printLnS $ T.pack $ printf "Vitórias: %d, Derrotas: %d, Partidas: %d" victories defeats totalGames

-- redução das multiplas chamadas da função gets e utilização de when e unless para facilitar o entendimento do fluxo

makeAttempt :: T.Text -> Game ()
makeAttempt word = do
  (wordMap, answer, guesses, maxGuesses, victories, defeats, totalGames) <- gets (\s -> (_wordMap s, _answer s, _guesses s, _maxGuesses s, _victories s, _defeats s, _totalGames s))

  unless (M.member word wordMap) $ do
    printLnS $ T.pack "Palavra inválida, por favor tente novamente"
    continue

  let attemptResult = showAttempt word answer
  printLnS $ renderAttempt word attemptResult
  let updm = updateAttemptMap word attemptResult . _attemptMap
  modify' (\s -> s {_attemptMap = updm s})

  let msg = "A palavra era '" <> T.unpack (wordMap M.! answer) <> "'"

  if word == answer
    then do
      let updatedVictories = victories + 1
      let updatedTotalGames = totalGames + 1
      printLnS $ T.pack ("Você ganhou! " ++ msg)
      modify (\s -> s {_victories = updatedVictories, _totalGames = updatedTotalGames})
    else if guesses >= maxGuesses
      then do
        let updatedDefeats = defeats + 1
        let updatedTotalGames = totalGames + 1
        printLnS $ T.pack ("Você perdeu! " ++ msg)
        modify (\s -> s {_defeats = updatedDefeats, _totalGames = updatedTotalGames})
      else do
        modify (\s -> s {_guesses = _guesses s + 1})
        continue

helpString :: T.Text
helpString =
  style Bold (T.pack "Regras\n\n")
    <> T.pack "Você tem 6 tentativas para adivinhar a palavra. Cada\n"
    <> T.pack "tentativa deve ser uma palavra de 5 letras válida.\n\n"
    <> T.pack "Após cada tentativa, as cores das letras\n"
    <> T.pack "indicarão quão próxima a tentativa está da resposta.\n\n"
    <> T.pack "Ignore acentuação e cedilha.\n\n"
    <> style Bold (T.pack "Exemplos\n\n")
    <> colour RightPlace (T.pack " M ")
    <> T.pack " A N G A \nA letra"
    <> color Green (T.pack " M ")
    <> T.pack "existe na palavra e está na posição correta.\n\n"
    <> T.pack " V "
    <> colour WrongPlace (T.pack " I ")
    <> T.pack " O  L  A \nA letra"
    <> color Yellow (T.pack " I ")
    <> T.pack "existe na palavra mas em outra posição.\n\n"
    <> T.pack " P  L  U "
    <> colour DoesntExist (T.pack " M ")
    <> T.pack " A \nA letra M não existe na palavra.\n"

colour :: CharacterStatus -> T.Text -> T.Text
colour Untested = id
colour DoesntExist = style Bold . color Blue . bgColor White
colour WrongPlace = style Bold . color White . bgColor Yellow
colour RightPlace = style Bold . color White . bgColor Green

showAttemptMap :: M.Map Char CharacterStatus -> T.Text
showAttemptMap amap = T.concatMap showColoredChar (T.pack letters)
  where
    letters = "QWERTYUIOP\nASDFGHJKL\n ZXCVBNM"
    showColoredChar c = colour (M.findWithDefault Untested c amap) (showPrettyChar c)

-- utilização da função printf e redução das multiplas chamadas da função gets
displayAttemptNumbers :: Game ()
displayAttemptNumbers = do
  (currentGuess, maxGuesses) <- gets (\s -> (_guesses s, _maxGuesses s))
  liftIO . putStr $ printf "Digite sua tentativa [%d/%d]: " currentGuess maxGuesses

showPrettyChar :: Char -> T.Text
showPrettyChar c = T.singleton ' ' <> T.singleton c

showAttempt :: T.Text -> T.Text -> Array Int CharacterStatus
showAttempt attempt answer = runSTArray $ do
  let n = T.length answer - 1
  res <- newArray (0, n) DoesntExist
  amap <- newArray ('A', 'Z') 0 :: ST s (STArray s Char Int)

  forM_ (T.unpack answer) $ \c -> do
    val <- readArray amap c
    writeArray amap c (val + 1)

  forM_ [0 .. n] $ \i -> do
    let answerC = T.index answer i
    let attemptC = T.index attempt i
    when (answerC == attemptC) $ do
      writeArray res i RightPlace
      val <- readArray amap answerC
      writeArray amap answerC (val - 1)

  forM_ [0 .. n] $ \i -> do
    let answerC = T.index answer i
    let attemptC = T.index attempt i
    val <- readArray amap attemptC
    when (answerC /= attemptC && val > 0) $ do
      writeArray amap attemptC (val - 1)
      writeArray res i WrongPlace

  pure res

renderAttempt :: T.Text -> Array Int CharacterStatus -> T.Text
renderAttempt word arr =
  T.concat $
    zipWith
      (\c s -> colour s $ showPrettyChar c)
      (T.unpack word)
      (toList arr)

updateAttemptMap ::
  T.Text ->
  Array Int CharacterStatus ->
  M.Map Char CharacterStatus ->
  M.Map Char CharacterStatus
updateAttemptMap word res amap =
  foldl' (\acc (n, c) -> M.adjust (\cha -> max cha $ res ! n) c acc) amap $
    zip [0 ..] $
      T.unpack word
