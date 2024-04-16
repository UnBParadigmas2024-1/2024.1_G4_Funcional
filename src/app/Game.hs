module Game
  ( 
    introduction,
    helpInstructions
  )
where

import qualified Data.Map.Strict as M
import qualified Data.Text as T
import System.Console.Pretty
  ( Color (Blue, Green, White, Yellow),
    Style (Bold),
    bgColor,
    color,
    style,
  )

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