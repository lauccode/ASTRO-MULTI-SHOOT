# create windows zip game with exe inside to share your game
## do a copy of game directory and go in root directory and remove .git(too big)
cd ..
cp -r ASTRO_MULTI_SHOOT/ astro_multi_shoot
cd astro_multi_shoot/
sudo rm -r .git/
rm astro_multi_shoot.zip
cd ..
## create .love
zip -9 -q -r astro_multi_shoot.love .
## download love (love-11.5-win64) and unzip
## copy the directory as game name
cp -r love-11.5-win64 ASTRO_MULTI_SHOOT_WIN
## put the .love inside to have your game with love framework
cp astro_multi_shoot.love ASTRO_MULTI_SHOOT_WIN/
## create .exe inside
cd ASTRO_MULTI_SHOOT_WIN/
cat love.exe astro_multi_shoot.love > astro_multi_shoot.exe
rm astro_multi_shoot.love 
## zip the directory with all inside, it is your game
cd ..
zip -r astro_multi_shoot.zip ASTRO_MULTI_SHOOT_WIN/
cp astro_multi_shoot.zip ASTRO_MULTI_SHOOT_WIN
## remove useless .love and directory
rm astro_multi_shoot.love 
rm -r astro_multi_shoot
rm -r ASTRO_MULTI_SHOOT_WIN/
