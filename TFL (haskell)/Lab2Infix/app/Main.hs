module Main where

import Parser (parse)
import Regex
import qualified Data.Set as Set

brzozowskiAuto :: String -> [Regex] -> [Regex]

brzozowskiAuto alphabet states = if length newStates > length states then brzozowskiAuto alphabet newStates  else filter (/= Empty) states where
    newStates = alphabetIteration states alphabet 
    alphabetIteration :: [Regex] -> String -> [Regex]
    alphabetIteration states [] = states
    alphabetIteration states (x : xs) = alphabetIteration newStates2 xs where
        newStates2 = Set.toList (Set.fromList (states ++ map (simplifyRegex . (brzozowskiDerivative x)) states))

main :: IO ()
main = do
    putStrLn "Введите название файла"
    filename <- getLine
    contents <- readFile ("tests/" ++ filename)

    let regex = parse contents
    print regex

    let alphabet = getAlphabet regex
    brzozowski <- return (brzozowskiAuto alphabet [regex])
    print (map regexToString brzozowski)

    let reversedAnswers = Set.toList (Set.fromList (concat (map (brzozowskiAuto alphabet) (map (: []) (map reverseRegex brzozowski)))))

    let answers = map regexToString (map reverseRegex reversedAnswers)
    print answers



