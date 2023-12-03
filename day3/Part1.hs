import Data.Char
import Data.List
import Data.Maybe

isSym :: Char -> Bool
isSym = (not .) . (||) <$> isDigit <*> ('.' ==)

addBorder :: [String] -> [String]
addBorder = (repeat '.' :) . (++ [repeat '.']) . map (('.' :) . (++ "."))

splat :: [Bool] -> [Bool]
splat = (tail .) . zipWith (||) <$> (zipWith (||) <$> tail <*> id) <*> (False :)

mask :: [String] -> [Bool]
mask = foldr (zipWith (||)) (repeat False) . map (splat . map isSym)

masks :: [String] -> [[Bool]]
masks = map mask . filter ((== 3) . length) . map (take 3) . tails . addBorder

splitOne :: [(Char, Bool)] -> ([(Char, Bool)], [(Char, Bool)])
splitOne = span (isDigit . fst) . dropWhile (not . isDigit . fst)

takeOne :: [(Char, Bool)] -> Maybe ([(Char, Bool)], [(Char, Bool)])
takeOne = (fmap . const <$> id <*> (listToMaybe . fst)) . splitOne

hasSym :: [(Char, Bool)] -> Bool
hasSym = any snd

handleLine :: String -> [Bool] -> [Int]
handleLine = (.) (map (read . map fst) . filter (any snd) . unfoldr takeOne) . zip

numbers :: String -> [Int]
numbers = concat . (zipWith handleLine <$> id <*> masks) . lines

part1 = sum . numbers

main = readFile "input" >>= print . part1
