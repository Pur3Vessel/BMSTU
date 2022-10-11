{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -Wno-compat-unqualified-imports #-}
 {-# LANGUAGE UnicodeSyntax #-}
module Regex where
import Data.List
import qualified Data.Set as Set
 

data Regex = Symbol Char | Alt [Regex] | Concat (Regex, Regex) | KStar Regex | Epsilon | Empty deriving (Eq, Show, Ord)

regexToString :: Regex -> String

regexToString Empty = "Empty set"

regexToString (Symbol s) = [s]

regexToString (KStar (Symbol s)) = s : "*"

regexToString (KStar Epsilon) = "ɛ"

regexToString (KStar reg) = '(' : regexToString reg ++ ")*"

regexToString (Concat (r1, r2)) = regexToString r1 ++ regexToString r2

regexToString (Alt regs) = intercalate "|" (map regexToString regs)

regexToString Epsilon = "ɛ"


reverseRegex :: Regex -> Regex

reverseRegex (Alt regs) = Alt (map reverseRegex regs)

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
    changed = Alt (sort (Set.toList (Set.fromList filtered)))
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

delta Epsilon = Epsilon

delta reg = reg

brzozowskiDerivative :: Char -> Regex -> Regex

brzozowskiDerivative sym  = simplifyRegex . brzozowskiDerivativeHelp sym

brzozowskiDerivativeHelp :: Char -> Regex -> Regex

brzozowskiDerivativeHelp sym (Alt regs) = Alt (map (brzozowskiDerivativeHelp sym) regs)

brzozowskiDerivativeHelp sym (Concat (r1, r2)) = Alt [Concat (brzozowskiDerivativeHelp sym r1, r2), Concat (delta r1, brzozowskiDerivativeHelp sym r2)]

brzozowskiDerivativeHelp sym (KStar reg) = Concat (brzozowskiDerivativeHelp sym reg, KStar reg)

brzozowskiDerivativeHelp sym (Symbol s) = if s == sym then Epsilon else Empty

brzozowskiDerivativeHelp _ reg = reg


getAlphabet :: Regex -> String

getAlphabet (Alt regs) = concatMap getAlphabet regs

getAlphabet (Symbol s) = [s]

getAlphabet (KStar reg) = getAlphabet reg

getAlphabet (Concat (r1, r2)) = getAlphabet r1 ++ getAlphabet r2

getAlphabet _ = ""