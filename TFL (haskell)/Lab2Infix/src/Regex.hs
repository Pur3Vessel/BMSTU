module Regex where
import Data.List
import qualified Data.Set as Set
 

data Regex = Symbol Char | Alt [Regex] | Concat (Regex, Regex) | KStar Regex | Epcilon | Empty deriving (Eq, Show, Ord)

regexToString :: Regex -> String

regexToString Empty = "Empty set"

regexToString (Symbol s) = [s]

regexToString (KStar (Symbol s)) = s : "*"

regexToString (KStar Epcilon) = "ɛ"

regexToString (KStar reg) = '(' : regexToString reg ++ ")*"

regexToString (Concat (r1, r2)) = regexToString r1 ++ regexToString r2

regexToString (Alt regs) = intercalate "|" (map regexToString regs)

regexToString Epcilon = "ɛ"


reverseRegex :: Regex -> Regex

reverseRegex (Alt regs) = Alt (map reverseRegex regs)

reverseRegex (Concat (r1, r2)) = Concat (reverseRegex r2, reverseRegex r1)

reverseRegex (KStar reg) = KStar (reverseRegex reg)

reverseRegex reg = reg

simplifyRegex :: Regex -> Regex

simplifyRegex (KStar reg) = let simplified = simplifyRegex reg in case simplified of
    Empty -> Empty
    Epcilon -> Epcilon
    _ -> KStar simplified

simplifyRegex (Concat (r1, r2)) = let simplified = (simplifyRegex r1, simplifyRegex r2) in case simplified of
    (Empty, _) -> Empty
    (_, Empty) -> Empty
    (Epcilon, rs2) -> rs2
    (rs1, Epcilon) -> rs1
    _ -> Concat simplified



simplifyRegex (Alt regs) = case changed of 
    Alt [] -> Empty
    _ -> changed
    where
    changed = Alt (Set.toList (Set.fromList filtered))
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

delta (KStar _) = Epcilon

delta (Symbol s) = Empty

delta Epcilon = Epcilon

delta reg = reg

brzozowskiDerivative :: Char -> Regex -> Regex

brzozowskiDerivative sym (Alt regs) = Alt (map (brzozowskiDerivative sym) regs)

brzozowskiDerivative sym (Concat (r1, r2)) = Alt [Concat (brzozowskiDerivative sym r1, r2), Concat (delta r1, brzozowskiDerivative sym r2)]

brzozowskiDerivative sym (KStar reg) = Concat (brzozowskiDerivative sym reg, KStar reg)

brzozowskiDerivative sym (Symbol s) = if s == sym then Epcilon else Empty

brzozowskiDerivative _ reg = reg


getAlphabet :: Regex -> String

getAlphabet (Alt regs) = concatMap getAlphabet regs

getAlphabet (Symbol s) = [s]

getAlphabet (KStar reg) = getAlphabet reg

getAlphabet (Concat (r1, r2)) = getAlphabet r1 ++ getAlphabet r2

getAlphabet reg = ""