# ASTRO-MULTI-SHOOT

## Overview 
This is a small asteroids game inspired by the nostalgic Blasteroid game on **AMSTRAD CPC 464** of my childwood.
For now, there are only 6 stages, with an increase of the number of asteroids
Each first destruction of asteroid releases a random bonus. There are a lot of weapons to discover.

![Texte alternatif](https://github.com/lauccode/ASTRO-MULTI-SHOOT/blob/main/inGame.png?raw=true)
![Texte alternatif](https://github.com/lauccode/ASTRO-MULTI-SHOOT/blob/main/inGame2.png?raw=true)
![Texte alternatif](https://github.com/lauccode/ASTRO-MULTI-SHOOT/blob/main/inGame3.png?raw=true)
![Texte alternatif](https://github.com/lauccode/ASTRO-MULTI-SHOOT/blob/main/inGame4.png?raw=true)

## dependencies only for linux debian based as Ubuntu
- `love` version at least to 11.3
- `lua` version at least to 5.1.5

### example
#### for love

> sudo apt install love

check version with

> love --version

#### for lua

> sudo apt search lua5

You should find a lua version as lua5.x, so install it

> sudo apt install lua5.x

check version with

> lua -v

## launch

### linux
1. In Terminal, 'git clone' this repository
> git clone https://github.com/lauccode/ASTRO-MULTI-SHOOT.git
2. Go in the root of the repository
> cd ASTRO-MULTI-SHOOT/
3. Type `love .` to start the game
> love .

### windows 10
1. Click on `astro_multi_shoot.zip` file of this page
2. Select icon `Download raw file`
3. Save the zip file on your PC
4. Unzip the zip file and go in the directory `astro_multi_shoot`
5. Double click on `astro_multi_shoot.exe`

## debug mode
A debug mode can be activated.
It allows to cheat during game and also to activate the game information as :
- FPS information
- object information
- velocity vectors of objects
- keys to activate/desactivate the bonus that you want

## Shortcuts to play
### In game

- `UP ARROW`    to go forward
- `DOWN ARROW`  to go backward
- `LEFT ARROW`  to turn left
- `RIGHT ARROW` to turn right
- `SPACE`       to fire
- `s`           stop the ship

### SHORTCUTS if debug mode activated
- `d`           activate/desactivate debug game information

#### for BONUS
- `w`           Side fire activated FIRST, main fire put back in SECOND
- `x`           Missile size can be increased TWICE
- `c`           Rate of fire can be increased TWICE
- `v`           Laser sight
- `b`           Shot with sinusoidal trajectory
- `n`           Shield protection for limited time

