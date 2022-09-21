module Main where
import qualified Data.Set as Set
import Data.Char 
import Data.List 
import System.IO 
import Control.Monad

data Terminal = Terminal Char deriving (Eq, Show, Ord)

data NonTerminal = NonTerminal Char | Empty deriving (Eq, Show, Ord)

trim = f . f where
    f = reverse . dropWhile isSpace

parse :: String -> ([(NonTerminal, [Either Terminal NonTerminal])], String)

parse string = parseAll (lines (trim ((filter (\x -> x /= ' ') string)))) where
    parseAll :: [String] -> ([(NonTerminal, [Either Terminal NonTerminal])], String)
    parseAll strings = if length strings < 3 then error "Недостаточно строк" else (parseRules nonterminalsList terminalsList (drop 2 strings), nonterminalsList) where
        nonterminalsList = parseT (head strings) "nonterminals" 
        terminalsList = parseT (head (tail strings)) "terminals" 
    parseT :: String -> String -> String
    parseT str t = if isPrefixOf (t ++ "=") str then continueParseT (drop (length t + 1) str) [] else error ("Ошибка в указании " ++ t) where
        continueParseT (l : []) acc | not (isLetter l) = error ("Вы указали не букву в " ++ t) 
                                    | elem l acc = error ("Вы указали повторяющийся элемент в " ++ t)  
                                    | otherwise = l : acc
        continueParseT (l : ',' : xs) acc | not (isLetter l) = error ("Вы указали не букву в " ++ t) 
                                          | elem l acc = error ("Вы указали повторяющийся элемент в " ++ t) 
                                          | otherwise = continueParseT xs (l : acc)
        continueParseT xs _ = error ("Ошибка в указании " ++ t)
    parseRules :: String -> String -> [String] -> [(NonTerminal, [Either Terminal NonTerminal])]
    parseRules _ _ [] = []
    parseRules ntl tl (rule : rules) = parseRule rule : parseRules ntl tl rules where
        parseRule :: String -> (NonTerminal, [Either Terminal NonTerminal])
        parseRule (x : '-' : '>' : y : xs) = if elem x ntl then (NonTerminal x, continueParseRule (y : xs)) else error "В левой части правила указан не нетерминал" where
            continueParseRule :: String -> [Either Terminal NonTerminal]
            continueParseRule [] = []
            continueParseRule (x : xs) | elem x ntl = Right (NonTerminal x) : continueParseRule xs | elem x tl = Left (Terminal x) : continueParseRule xs | otherwise = error "В правой части правила замечен неинициализированный символ"
        parseRule _ = error "Ошибка в указании правила"

toTerminalForm :: [(NonTerminal, [Either Terminal NonTerminal])] -> [(NonTerminal, [Either Terminal NonTerminal])]
toTerminalForm [] = []
toTerminalForm ((a, r) : rules) = (a, change r) : toTerminalForm rules where
    change :: [Either Terminal NonTerminal] -> [Either Terminal NonTerminal]
    change [] = []
    change ((Left a) : xs) = (Left a) : change xs
    change ((Right _) : xs) = (Right Empty) : change xs

makeEqClasses :: [(NonTerminal, [Either Terminal NonTerminal])] -> [[NonTerminal]] 
makeEqClasses rules = takeNt (eqClassesMaker (sort (zip  (map makeTerminalFormSet getNonterminalsList) getNonterminalsList)))  where
    takeNt :: [[(Set.Set ([Either Terminal NonTerminal]),NonTerminal)]] -> [[NonTerminal]]
    takeNt [] = []
    takeNt (x : xs) = map snd x : takeNt xs
    eqClassesMaker :: [(Set.Set ([Either Terminal NonTerminal]), NonTerminal)] -> [[(Set.Set ([Either Terminal NonTerminal]),NonTerminal)]]
    eqClassesMaker [] = []
    eqClassesMaker ((a, b) : xs) = ((a, b) : (takeWhile (\(x, y) -> x == a) xs)) : eqClassesMaker (dropWhile (\(x, y) -> x == a) xs) 
    getNonterminalsList :: [NonTerminal]
    getNonterminalsList = helpGetList rules [] where
        helpGetList [] acc = acc
        helpGetList ((a, _) : rules) acc = if elem a acc then helpGetList rules acc else helpGetList rules (a : acc)
    makeTerminalFormSet :: NonTerminal -> Set.Set ([Either Terminal NonTerminal])
    makeTerminalFormSet nt = helpMakeSet nt rules where
        helpMakeSet nt [] = Set.empty  
        helpMakeSet nt ((a, b) : rules) = if nt == a then Set.insert b (helpMakeSet nt rules) else helpMakeSet nt rules

changeEqClasses :: [[NonTerminal]] -> [[NonTerminal]]-> [(NonTerminal, [Either Terminal NonTerminal])] -> [[NonTerminal]]
changeEqClasses eqClasses nonTerminating rules = if (length iteration /= length eqClasses) then changeEqClasses iteration nonTerminating rules else eqClasses where
    iteration :: [[NonTerminal]]
    iteration = if nonTerminating == [[]] then makeEqClasses (getNewEqRule rules) else makeEqClasses (getNewEqRule rules) ++ nonTerminating
    replaceNt :: Either Terminal NonTerminal -> Either Terminal NonTerminal
    replaceNt (Left a) = Left a
    replaceNt (Right a) = Right (head (eqClasses !! (getIndexOfNt a eqClasses)))
    getNewEqRule :: [(NonTerminal, [Either Terminal NonTerminal])] -> [(NonTerminal, [Either Terminal NonTerminal])]
    getNewEqRule [] = []
    getNewEqRule ((a, b) : xs) = (a, map replaceNt b) : getNewEqRule xs 

getIndexOfNt :: NonTerminal -> [[NonTerminal]]-> Int
getIndexOfNt nt eqClasses = case findIndex (\c -> elemIndex nt c /= Nothing) eqClasses of 
    Just a -> a
    Nothing -> error (nonTerminalToChar nt : " не найден :(")

addNonTerminating :: [(NonTerminal, [Either Terminal NonTerminal])] -> String -> [[NonTerminal]]
addNonTerminating rules nonterminals = [filter (\a -> not (elem a (map fst rules))) (map NonTerminal nonterminals)]

makeNewRule :: [[NonTerminal]] -> [(NonTerminal, [Either Terminal NonTerminal])] -> [(NonTerminal, [Either Terminal NonTerminal])]
makeNewRule eqClasses rules = Set.toList (Set.fromList (changeRules rules)) where 
    replaceNt :: Either Terminal NonTerminal -> Either Terminal NonTerminal
    replaceNt (Left a) = Left a
    replaceNt (Right a) = Right (head (eqClasses !! (getIndexOfNt a eqClasses)))
    changeRules :: [(NonTerminal, [Either Terminal NonTerminal])] -> [(NonTerminal, [Either Terminal NonTerminal])]
    changeRules [] = []
    changeRules ((a, b) : xs) = (head (eqClasses !! (getIndexOfNt a eqClasses)), map replaceNt b) : changeRules xs

eitherToChar :: Either Terminal NonTerminal -> Char
eitherToChar (Left (Terminal a)) = a 
eitherToChar (Right (NonTerminal a)) = a 
    

nonTerminalToChar :: NonTerminal -> Char
nonTerminalToChar (NonTerminal a) = a

makeAnswer :: [[NonTerminal]] -> [(NonTerminal, [Either Terminal NonTerminal])] -> String
makeAnswer eqClasses rules = eqClassesToString eqClasses ++ "\n\n" ++ rulesToString rules where
    eqClassesToString :: [[NonTerminal]] -> String
    eqClassesToString [] = []
    eqClassesToString (eqClass : otherClasses) = "{" ++ map nonTerminalToChar eqClass ++ "} " ++ eqClassesToString otherClasses 
    rulesToString :: [(NonTerminal, [Either Terminal NonTerminal])] -> String
    rulesToString [] = []
    rulesToString ((a, b) : rules) = ((nonTerminalToChar a : " -> ") ++ map eitherToChar b) ++ "\n" ++ rulesToString rules 
    

-- Для запуска нужно вызвать функцию main, а затем ввести название файла с входными данными
main = do 
    putStrLn "Введите название файла"
    filename <- getLine
    contents <- readFile filename
    
    --print . lines . filter (\x -> x /= ' ') $ contents

    rules <- return (parse contents)
    changedRules <- return (toTerminalForm (fst rules))
    
    startEqClasses <- return (makeEqClasses changedRules)
    nonTerminating <- return ((uncurry addNonTerminating) rules)
    startEqClasses <- return (if nonTerminating == [[]] then startEqClasses else startEqClasses ++ nonTerminating)
    finalEqClasses <- return (changeEqClasses startEqClasses nonTerminating (fst rules))
    newRules <- return (makeNewRule finalEqClasses (fst rules))
    answer <- return (makeAnswer finalEqClasses newRules)
    {--
    print rules
    print startEqClasses
    print finalEqClasses
    print newRules
    --}
    putStr answer
