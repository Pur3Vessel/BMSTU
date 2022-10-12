{-# OPTIONS_GHC -Wno-missing-export-lists #-}
module Regex where
import Data.List ( sortBy, intercalate )
import qualified Data.Set as Set
 

data Regex = Symbol Char | Alt [Regex] | Concat (Regex, Regex) | KStar Regex | Epsilon | Empty deriving (Eq, Show, Ord)

regexToString :: Regex -> String

regexToString Empty = "Empty set"

regexToString (Symbol s) = [s]

regexToString (KStar (Symbol s)) = s : "*"

regexToString (KStar Epsilon) = "ɛ"

regexToString (KStar reg) = '(' : regexToString reg ++ ")*"

regexToString (Concat (r1, r2)) = regexToString r1 ++ regexToString r2

regexToString (Alt regs) = "(" ++ intercalate "|" (map regexToString regs) ++ ")"

regexToString Epsilon = "ɛ"


reverseRegex :: Regex -> Regex

reverseRegex (Alt regs) = Alt (sortBy (\x y -> compare (regexToString x) (regexToString y)) (map reverseRegex regs))

reverseRegex (Concat (r1, r2)) = Concat (reverseRegex r2, reverseRegex r1)

reverseRegex (KStar reg) = KStar (reverseRegex reg)

reverseRegex reg = reg

simplifyRegex :: Regex -> Regex

simplifyRegex (KStar reg) = let simplified = simplifyRegex reg in case simplified of
    Empty -> Empty
    Epsilon -> Epsilon
    _ -> KStar simplified

simplifyRegex (Concat (r1, r2)) = let simplified = (simplifyRegex r1, simplifyRegex r2) in case simplified of
    (Empty, _) -> Empty
    (_, Empty) -> Empty
    (Epsilon, rs2) -> rs2
    (rs1, Epsilon) -> rs1
    _ -> Concat simplified



simplifyRegex (Alt regs) = case changed of 
    Alt [] -> Empty
    Alt [reg] -> reg
    _ -> changed
    where
    changed = Alt (sortBy (\x y -> compare (regexToString x) (regexToString y)) (Set.toList (Set.fromList filtered)))
    filtered = filter (/= Empty) (changeAlts simplified)
    simplified = map simplifyRegex regs

    changeAlts :: [Regex] -> [Regex]
    changeAlts [] = []
    changeAlts ((Alt r) : xs) = r ++ changeAlts xs
    changeAlts (x : xs) = x : changeAlts xs

simplifyRegex reg = reg

delta :: Regex -> Regex

delta (Alt regs) = Alt (map delta regs)

delta (Concat (r1, r2)) = Concat (delta r1, delta r2)

delta (KStar _) = Epsilon

delta (Symbol _) = Empty

delta reg = reg

brzozowskiDerivative :: Char -> Regex -> Regex

brzozowskiDerivative sym  = simplifyRegex . brzozowskiDerivativeHelp where

    brzozowskiDerivativeHelp :: Regex -> Regex

    brzozowskiDerivativeHelp (Alt regs) = Alt (map brzozowskiDerivativeHelp  regs)

    brzozowskiDerivativeHelp (Concat (r1, r2)) = Alt [Concat (brzozowskiDerivativeHelp r1, r2), Concat (delta r1, brzozowskiDerivativeHelp r2)]

    brzozowskiDerivativeHelp (KStar reg) = Concat (brzozowskiDerivativeHelp reg, KStar reg)

    brzozowskiDerivativeHelp (Symbol s) = if s == sym then Epsilon else Empty

    brzozowskiDerivativeHelp reg = reg

getAlphabet :: Regex -> String

getAlphabet reg = Set.toList (Set.fromList (getAlphabetHelp reg)) where

    getAlphabetHelp :: Regex -> String

    getAlphabetHelp (Alt regs) = concatMap getAlphabetHelp regs

    getAlphabetHelp (Symbol s) = [s]

    getAlphabetHelp (KStar re) = getAlphabetHelp re

    getAlphabetHelp (Concat (r1, r2)) = getAlphabetHelp r1 ++ getAlphabetHelp r2

    getAlphabetHelp _ = ""