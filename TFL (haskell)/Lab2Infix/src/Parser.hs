{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
module Parser where
import Data.Char ( isSpace, isLetter )
import Data.List ( intercalate )
import Regex (Regex(KStar, Epsilon, Symbol, Alt, Concat))


trim :: [Char] -> [Char]
trim = f . f where
    f = reverse . dropWhile isSpace

parse :: String -> Regex

parse s | checkBracketLevels ms = parseRegex ms | otherwise = error "Уровень скобок нарушен" where
    ms = replaceUnary (fillConcat (checkSymbols (trim (filter (/= ' ') s))))
    parseRegex :: String -> Regex
    parseRegex [] =  Epsilon
    parseRegex [s] = Symbol s
    parseRegex ('(' : reg) = if last reg == ')' && areBracketsConnected reg then parseAlt (init reg) else parseAlt ('(' : reg)
    parseRegex reg = parseAlt reg

    parseAlt :: String -> Regex
    parseAlt reg = if length splitted == 1 then parseConcat (head splitted) else Alt (map parseRegex splitted) where
        splitted = zeroLevelSplit reg '|'

    parseConcat :: String -> Regex
    parseConcat reg = if length splitted == 1 then parseUnary (head splitted) else Concat (parseRegex (head splitted), parseConcat (intercalate "$" (tail splitted))) where
        splitted = zeroLevelSplit reg '$'

    parseUnary :: String -> Regex
    parseUnary reg | last reg == '+' = Concat (parseRegex (init reg), KStar (parseRegex (init reg)))
                   | last reg == '*' = KStar (parseRegex (init reg))
                   | otherwise = parseRegex reg


areBracketsConnected :: String ->  Bool
areBracketsConnected s = iterate s 1 where
    iterate :: String -> Int -> Bool
    iterate [] level = level == 0
    iterate (x : xs) level | x == '(' = iterate xs (level + 1)  
                           | x == ')' = iterate xs (level - 1)  
                           | level == 0 = False 
                           | otherwise = iterate xs level


checkBracketLevels :: String -> Bool
checkBracketLevels [] = True
checkBracketLevels (x : xs) | x == '(' = findRight xs 0 | x == ')' = False | otherwise = checkBracketLevels xs where
    findRight :: String -> Int -> Bool
    findRight [] _ = False
    findRight (x : xs) level | x == ')' = if level == 0 then checkBracketLevels xs else findRight xs (level - 1)
                             | x == '(' = findRight xs (level + 1)
                             | otherwise = findRight xs level

fillConcat :: String -> String
fillConcat [] = []
fillConcat [x] = [x]
fillConcat (x : xs) = if isLeft x && isRight (head xs) then x : '$' : fillConcat xs else x : fillConcat xs where
    isLeft x = isLetter x || elem x ")+*"
    isRight x = isLetter x || x == '('

checkSymbols :: String -> String
checkSymbols [] = []
checkSymbols (x : xs) = if isLetter x || elem x avaible then x : checkSymbols xs else error "Недопустимый символ" where
    avaible = "()*+|"

replaceUnary :: String -> String
replaceUnary [] = []
replaceUnary (x : xs) = if x == '+' || x == '*' then repElem (x : xs) : replaceUnary (dropWhile (\x -> x == '+' || x == '*') xs) else x : replaceUnary xs where
    repElem :: String -> Char
    repElem [] = '+'
    repElem (x : xs)
      | x == '*' = x
      | x == '+' = repElem xs
      | otherwise = '+'

zeroLevelSplit :: String -> Char -> [String]

zeroLevelSplit [] _ = []
zeroLevelSplit s sym = take (splitIndex 0 0 s) s : zeroLevelSplit (drop (splitIndex 0 0 s + 1) s) sym where
    splitIndex :: Int -> Int -> String -> Int
    splitIndex _ acc [] = acc
    splitIndex level acc (x : xs) | x == sym && level == 0 = acc
                                  | x == '(' = splitIndex (level + 1) (acc + 1) xs
                                  | x == ')' = splitIndex (level - 1) (acc + 1) xs
                                  | otherwise = splitIndex level (acc + 1) xs





{-
Берут как-то раз интервью у мудреца, который живёт уже 103 года.
Репортёр спрашивает
-Мудрец, а как вы прожили так долго?
А мудрец отвечает
-Я никогда не спорил, поэтому так долго прожил.
Репортёр, немного подумав, возразил
-Это не правда!
Мудрец ответил
-Правда!
И умер
-}