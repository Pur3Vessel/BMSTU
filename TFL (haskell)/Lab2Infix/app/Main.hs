{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
{-# OPTIONS_GHC -Wno-compat-unqualified-imports #-}
module Main where

import Parser (parse)
import Regex
import Data.List
import qualified Data.Set as Set



brzozowskiAuto :: String -> [Regex] -> [Regex]

brzozowskiAuto alphabet states = if length newStates > length states then brzozowskiAuto alphabet newStates  else filter (/= Empty) states where
    newStates = alphabetIteration states alphabet
    alphabetIteration :: [Regex] -> String -> [Regex]
    alphabetIteration states [] = states
    alphabetIteration states (x : xs) = alphabetIteration newStates2 xs where
        newStates2 = Set.toList (Set.fromList (states ++ map (brzozowskiDerivative x) states))

main :: IO ()
main = do
    putStrLn "Введите название файла"
    filename <- getLine
    contents <- readFile ("tests/" ++ filename)

    let regex = parse contents
    putStrLn ("Регулярка: " ++ regexToString regex)
    --print regex

    let alphabet = getAlphabet regex
    let brzozowski = brzozowskiAuto alphabet [regex]
    --print (map regexToString brzozowski)

    let reversedAnswers = Set.toList (Set.fromList (concatMap ((brzozowskiAuto alphabet . (: [])) . reverseRegex) brzozowski))

    let answers = map (regexToString . reverseRegex) reversedAnswers
    putStrLn ("->  " ++ intercalate "\n->  " answers)



