import qualified Data.Text as T
import qualified Data.Text.IO as T
import Game (introduction)

main :: IO ()
main =
  do
    T.putStrLn introduction

getSeedFromSomewhere :: IO Int
getSeedFromSomewhere = undefined