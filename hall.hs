-- Copyright © 2015 Bart Massey
-- [This program is licensed under the "3-clause ('new') BSD License"]
-- Please see the file COPYING in the source
-- distribution of this software for license terms.

-- Simulation of Monty Hall problem.

import Control.Monad.Random
import System.Environment (getArgs)
import Text.Printf (printf)

data Door = Goat | Car

-- | Given a player's pick and an arrangement of doors,
-- return the pick representing the player switching
-- based on Monty's choice of goat.
pickWithMonty :: Int -> [Door] -> Rand StdGen Int
pickWithMonty playerPick doors = do
  let numberedDoors = zip [1..] doors
  -- Monty must pick a goat that the player did not.
  let candidates = filter ok numberedDoors
                   where
                     ok (p, Goat) | p /= playerPick = True
                     ok _ = False
  -- There will be either one or two such goats. Pick one.
  pick <- getRandomR (1, length candidates)
  let (montyPick, _) = candidates !! (pick - 1)
  -- `head` can never fail here, since there will always
  -- be at least one door left over.
  let (switchPick, _) = head (filter ok numberedDoors)
                        where
                          ok (p, _) = p /= playerPick && p /= montyPick
  return switchPick

-- | Run a single experiment. Switch if indicated. Return
-- the door chosen by the player.
experiment :: Bool -> Rand StdGen Door
experiment switch = do
  -- Arrange the doors randomly.
  doors <- shuffle [Car, Goat, Goat]
  -- Have the player pick a door position.
  playerPick <- getRandomR (1, 3)
  -- Figure out the player's switch option.
  switchPick <- pickWithMonty playerPick doors
  -- If the player is switching, do so.
  let playerPick' = if switch then switchPick else playerPick
  -- Return what was behind the door.
  return (doors !! (playerPick' - 1))

-- | Run a sequence of n experiments. Return the
-- count of experiments in which the player chose
-- a car.
runExperiments :: Int -> Bool -> Rand StdGen Int
-- No experiments gives no wins.
runExperiments 0 _ = return 0
runExperiments n switch = do
  -- Run a single experiment.
  ok <- experiment switch
  -- Score 1 point for a car, 0 points for a goat.
  let cur = case ok of
              Car -> 1
              Goat -> 0
  -- Get the score from running the rest of the experiments.
  rest <- runExperiments (n - 1) switch
  -- Return the modified score.
  return (cur + rest)

-- | Slow implementation of KMP shuffle.
shuffle :: [Door] -> Rand StdGen [Door]
-- Shuffle 0 or 1 element lists by doing nothing.
shuffle [] = return []
shuffle [door] = return [door]
shuffle doors = do
  -- Pick a position to move to the front of the list.
  pos <- getRandomR (1, length doors)
  -- Break the doors into those before, at and after the position.
  let (left, door : right) = splitAt (pos  - 1) doors
  -- Join the before and after doors and shuffle them.
  rest <- shuffle (left ++ right)
  -- Stick the at door on the front and return.
  return (door : rest)
           

-- | Run a bunch of experiments with stay or switch as indicated
-- on the command line.
main :: IO ()
main = do
  -- The usage message.
  let usage = "usage: [stay|switch] <count>"
  -- Get the list of arguments from the command line.
  args <- getArgs
  -- The arguments should be either "stay" or "switch" and a count.
  let (switch, countStr) = case args of
                 ["stay", cs] -> (False, cs)
                 ["switch", cs] -> (True, cs)
                 _ -> error usage
  -- Try to convert the count to an integer.
  let n = case reads countStr of
            [(count, "")] -> count
            _ -> error ("bad count: " ++ usage)
  -- Make a random number generator and run the experiments with it.
  result <- evalRandIO (runExperiments n switch)
  -- Find the percentage of wins.
  let percent = 100.0 * fromIntegral result / fromIntegral n
  -- Show how many times the player won a car, and the percentage.
  printf "%d / %d (%2.0f%%)\n" result n (percent :: Double)
