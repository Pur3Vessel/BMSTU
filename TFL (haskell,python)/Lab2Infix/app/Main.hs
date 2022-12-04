{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
module Main where
-- Запуск из корневой директории с помощью команды stack exec Lab2Infix-exe
import Parser (parse)
import Regex
    ( Regex(Empty, Alt),
      brzozowskiDerivative,
      getAlphabet,
      regexToString,
      reverseRegex,
      simplifyRegex )
import Data.List ( intercalate, sort )
import qualified Data.Set as Set



brzozowskiAuto :: String -> [Regex] -> [Regex]

brzozowskiAuto alphabet states = if length newStates > length states then brzozowskiAuto alphabet newStates  else Set.toList (Set.fromList (disableAlts (filter (/= Empty) states))) where
    newStates = alphabetIteration states alphabet
    disableAlts :: [Regex] -> [Regex]
    disableAlts [] = []
    disableAlts ((Alt regs) : xs) = regs ++ disableAlts xs
    disableAlts (x : xs) = x : disableAlts xs
    alphabetIteration :: [Regex] -> String -> [Regex]
    alphabetIteration states [] = states
    alphabetIteration states (x : xs) = alphabetIteration newStates2 xs where
        newStates2 = Set.toList (Set.fromList (states ++ map (brzozowskiDerivative x) states))

main :: IO ()
main = do
    putStrLn "Введите название файла"
    filename <- getLine
    contents <- readFile ("tests/" ++ filename)

    let regex = simplifyRegex (parse contents)
    putStrLn ("Регулярка: " ++ regexToString regex)
    --print regex

    let alphabet = getAlphabet regex
    let brzozowski = brzozowskiAuto alphabet [regex]
    --print (map regexToString brzozowski)


    let reversedAnswers = Set.toList (Set.fromList (concatMap ((brzozowskiAuto alphabet . (: [])) . reverseRegex) brzozowski))

    let answers = sort (map (regexToString . reverseRegex) reversedAnswers)
    putStrLn ("->  " ++ intercalate "\n->  " (filter (/= "ɛ") answers))



