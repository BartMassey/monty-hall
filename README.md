# Monty Hall Problem Simulation
Copyright © 2015 Bart Massey

The
[Monty Hall Problem](http://en.wikipedia.org/wiki/Monty_Hall_problem)
is one of the most celebrated paradoxes in probability. One
can easily convince oneself that switching wins, but nothing
beats a simulation for verifying this.  This simulation is
written in Haskell for clarity (?) and verifiability. The
source code is thoroughly commented.

To try the simulation, just say "`runghc hall.hs stay
3000`".  The simulation will run 3000 times with the player
staying with their initial choice each time. The other
alternative, "`switch`", represents the case in which the
player switches to the door that neither they nor Monty
has picked yet. The output shows the number of runs in
which the player won a car, the total number of runs, and
the percentage of car wins.

This program is licensed under the "3-clause ('new') BSD
License".  Please see the file COPYING in the source
distribution of this software for license terms.
