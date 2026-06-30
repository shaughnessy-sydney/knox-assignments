import System.IO (hFlush, stdout)
import Data.Char (ord)

main :: IO ()
main = do
  putStrLn "<3 Welcome to the Compatibility Tester! <3"
  putStrLn "" 
  compatibilityLoop

-- actual test loop
compatibilityLoop :: IO ()
compatibilityLoop = do
  putStr "Enter the first name: "
  hFlush stdout
  name1 <- getLine
  putStr "Enter the second name: "
  hFlush stdout
  name2 <- getLine
  let score = calculateCompatibility name1 name2
  putStrLn "" 
  putStrLn $ "The Romance Rating between " ++ name1 ++ " and " ++ name2 ++ " is: " ++ show score ++ "% - " ++ compatibilityComment score
  putStrLn ""  
  printStarRating score

  -- do we loop again
  putStr "Test another pair of names? (yes/no): "
  hFlush stdout
  answer <- getLine
  putStrLn "" 
  if answer == "yes"
    then compatibilityLoop
    else do
      putStrLn "Thank you for using the Compatibility Tester!!!"
      putStrLn "" 

--compatibility score calculation
calculateCompatibility :: String -> String -> Int
calculateCompatibility name1 name2 = 
  let totalAscii = sum $ map ord (name1 ++ name2) --converts both names to ints
      score = (totalAscii `mod` 101)  --results ints to a percentage
  in score

-- comment based on the compatibility score
compatibilityComment :: Int -> String
compatibilityComment score
  | score < 1 = "Couldn't be worse."
  | score < 9 = "Hopeless."
  | score < 19 = "Rarely Reconciled!"
  | score < 29 = "Just Stay Friends!"
  | score < 49 = "Worse Than It Looks!"
  | score < 60 = "Some potential."
  | score < 69 = "Cutest Couple."
  | score < 80 = "Lovey-Dovey Duo!"
  | score < 99 = "Star-Crossed Lovers! <3"
  | otherwise   = "Perfect match! <3 <3"

-- Print a star rating based on the compatibility score
printStarRating :: Int -> IO ()
printStarRating score = do
  let maxStars = 5  -- Maximum number of stars
      starScore = (score * maxStars) `div` 100  -- Calculate how many stars to show
      stars = replicate starScore '★' ++ replicate (maxStars - starScore) '☆'  -- Create the star string
  putStrLn $ "Star Rating: " ++ stars
