require("models")
require("collision")
require("update")
require("debugMode")
require("level")
require("menu")

-- Pour debugger avec zeroBrane
-- if arg[#arg] == "-debug" then
-- 	require("mobdebug").start()
-- end

-- MANDATORY TO DEBUG WITH VSC + install "local lua debbuger" plugin
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end
-- OR

-- sudo add-apt-repository ppa:bartbes/love-stable
-- sudo apt update
-- sudo apt install love
-- sudo apt install lua5.4

-- Lua v3.5.3 sumneko
-- Local Lua Debugger v0.3.3 Tom Blind
-- French Language Pack for Visual Studio Code v1.70.8170921 Microsoft

-- Pour debugger avec vsCode
-- if arg[#arg] == "vsc_debug" then
-- 	require("lldebugger").start()
-- end

-- 1) Variables
local DEBUG_MODE = false
-- 2)
local vaisseaux = nil
local missiles = nil
local asteroids = nil -- also to manage bonus
local bonus = nil
local particlesTransitionStage = nil

local menu = nil

local toggleDebug = false

local GRAPHICS_SCALE = 1.5

-- global to be used everywhere
SCREEN_WIDTH = 512
SCREEN_HIGH = 512
-- IntroSound = nil

local vaisseauImpactSound = nil
local shootSound = nil
local asteroidExplosionSound= nil
local creditsSound = nil
local gameSound = nil

menu = Menu.new()
level = Level.new()

-- Fonts
local fontNerd10 = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 10)
local fontNerd11 = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 11)
local fontNerd14 = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 14)
local fontNerd20 = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 20)
local fontVT12 = love.graphics.newFont("fonts/VT323/VT323-Regular.ttf", 12)
local fontVT20 = love.graphics.newFont("fonts/VT323/VT323-Regular.ttf", 20)

-- Central table for assets (images, fonts, etc.)
Assets = {
    images = {
        propulsor = love.graphics.newImage("sprites/propulsor.png"),
        vaisseauImpact = love.graphics.newImage("sprites/vaisseau_retro_impact.png"),
        smoke = love.graphics.newImage('sprites/smoke.png'),
        vaisseauRouge = love.graphics.newImage("sprites/vaisseau_retro_rouge.png"),
        barGrey = love.graphics.newImage("sprites/barGrey.png"),
        barRed = love.graphics.newImage("sprites/barRed.png"),
        barOrange = love.graphics.newImage("sprites/barOrange.png"),
        barGreen = love.graphics.newImage("sprites/barGreen.png"),
        vaisseauGreen = love.graphics.newImage("sprites/vaisseau_retro.png"),
        vaisseauOrange = love.graphics.newImage("sprites/vaisseau_retro_orange.png"),
        missileGreen = love.graphics.newImage("sprites/missile.png"),
        missileOrange = love.graphics.newImage("sprites/missile_orange.png"),
        missileRed = love.graphics.newImage("sprites/missile_violet.png"),
        asteroid = love.graphics.newImage("sprites/asteroid_retro.png"),
        asteroidImpact = love.graphics.newImage("sprites/asteroid_retro_impact.png"),
        asteroDust = love.graphics.newImage("sprites/astero_dust.png"),
        bonusTripleShoot = love.graphics.newImage("sprites/bonus_triple_shoot.png"),
        bonusIncreaseShoot = love.graphics.newImage("sprites/bonus_increase_shoot.png"),
        bonusMachineGunShoot = love.graphics.newImage("sprites/bonus_machine_gun_shoot.png"),
        bonusVise = love.graphics.newImage("sprites/bonus_vise.png"),
        bonusBouclier = love.graphics.newImage("sprites/bonus_bouclier.png"),
    },
    fonts = {
        nerd18 = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 18),
        bar = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 11),
    },
    sounds = {
        explosionAsteroid = love.audio.newSource("sound/explosion_asteroid-101886.mp3", "static"),
        shoot = love.audio.newSource("sound/8-bit-cannon-fire-96505.mp3", "static"),
        vaisseauImpact = love.audio.newSource("sound/hurt_c_08-102842.mp3", "static"),
        credits = love.audio.newSource("music/retro-wave-style-track-59892.mp3", "stream"),
        level1 = love.audio.newSource("music/BlueNavi-Starcade.mp3", "stream"),
        level2 = love.audio.newSource("music/Jaunter-Reset.mp3", "stream"),
        level3 = love.audio.newSource("music/KarolPiczak-LesChampsEtoiles.mp3", "stream"),
        level4 = love.audio.newSource("music/Kubbi-Ember-04Cascade.mp3", "stream"),
        level5 = love.audio.newSource("music/PunchDeck-ICantStop.mp3", "stream"),
        level6 = love.audio.newSource("music/LukeHall-Dystopia.mp3", "stream"),
    }
}

-- ██       ██████   █████  ██████
-- ██      ██    ██ ██   ██ ██   ██
-- ██      ██    ██ ███████ ██   ██
-- ██      ██    ██ ██   ██ ██   ██
-- ███████  ██████  ██   ██ ██████
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest") -- keep pixel effect
	love.window.setMode(SCREEN_WIDTH * GRAPHICS_SCALE, SCREEN_HIGH * GRAPHICS_SCALE, {
		resizable = false,
		highdpi = false,
		borderless = false,
	})
	-- love.window.setFullscreen(true, "desktop")
	-- love.window.setFullscreen( true )

	asteroidExplosionSound = Assets.sounds.explosionAsteroid
	asteroidExplosionSound:setVolume(1)
	shootSound = Assets.sounds.shoot
	shootSound:setVolume(0.4)
	vaisseauImpactSound = Assets.sounds.vaisseauImpact
	vaisseauImpactSound:setVolume(1)
	creditsSound = Assets.sounds.credits

    -- gameSound = love.audio.newSource("music/BlueNavi-Starcade.mp3", "stream")
    -- gameSound:setVolume(0.4)

	DEBUG_MODE = false
	vaisseaux = {}
	table.insert(vaisseaux, Vaisseau.new(level))
	vaisseaux[1].timeShieldStart = 0 --seconds
	missiles = {}
	asteroids = {} --also to manage bonus
    asteroidExplosions = {}
	bonuss = {}
	menu.positionMenu = menu.START
	level.levelDone = false

	local img = love.graphics.newImage("sprites/star.png")
	particlesTransitionStage = love.graphics.newParticleSystem(img, 450)

end

-- ██    ██ ██████  ██████   █████  ████████ ███████
-- ██    ██ ██   ██ ██   ██ ██   ██    ██    ██
-- ██    ██ ██████  ██   ██ ███████    ██    █████
-- ██    ██ ██      ██   ██ ██   ██    ██    ██
--  ██████  ██      ██████  ██   ██    ██    ███████

function love.update(dt) -- 60 fps by defaut
	timerUpdate(dt, vaisseaux)

	if menu.selectionMenu == menu.MENU then
		menu.updateTitleRebound(dt)
		DEBUG_MODE, toggleDebug, creditsSound = keyboardMenuUpdate(DEBUG_MODE, menu, toggleDebug, creditsSound)
	end

	if menu.selectionMenu == menu.menuValues[menu.START] then
		if menu.isPresentStageDone == false then
			menu.selectionMenu = menu.PRESENT_STAGE
			menu.timerPresentStage = 1
		end

		-- level manager
		if level.levelDone == false then
			if level.levelNumber > 1 then
				love.load() -- reset all before new level
			end
			asteroids, gameSound = level.levelManager(vaisseaux, asteroids, gameSound)
			level.levelDone = true
		end
		DEBUG_MODE, gameSound = keyboardUpdate(vaisseaux, missiles, DEBUG_MODE, menu, level, toggleDebug, gameSound, shootSound, dt)

		asteroidsUpdate(dt, asteroids)
		missilesUpdate(dt, vaisseaux, missiles)
		vaisseaux[1].smokeParticlesUpdate(dt)

        -- update explosion
        local removeAsteroidExplosionNumber = nil
        for asteroDivExplosion_it = 1, #asteroidExplosions do
            if asteroidExplosions[asteroDivExplosion_it].asteroDivisionExplosion == false then
                removeAsteroidExplosionNumber = asteroDivExplosion_it
            end
            asteroidExplosions[asteroDivExplosion_it].particlesExplosionLifeDurationUpdate(dt)
            asteroidExplosions[asteroDivExplosion_it].particlesAsteroDivExplosionUpdate(dt)
        end
        if (removeAsteroidExplosionNumber ~= nil) then
                table.remove(asteroidExplosions, removeAsteroidExplosionNumber) -- remove objects from table
        end

		-----------------------------------------
		-- COLLISION MANAGER (REFACTORED) --
		-----------------------------------------
		CollisionManagerAsteroids(dt, level, asteroids, asteroids)
		CollisionManagerAsteroidsAndMissiles(dt, level, missiles, asteroids, asteroidExplosions, bonuss, asteroidExplosionSound)
		CollisionManagerVaisseauxAndBonus(dt, level, vaisseaux, bonuss)
		local gameOver = CollisionManagerVaisseauxAndAsteroids(dt, level, vaisseaux, asteroids, vaisseauImpactSound)
		
		if gameOver then
			menu.selectionMenu = menu.GAMEOVER
			love.audio.stop(gameSound)
			level.levelNumber = 1
			level.levelDone = false
			menu.isPresentStageDone = false
		elseif level.levelNumber == level.MAX_LEVEL_NUMBER then
			menu.selectionMenu = menu.CONGRATULATION
			love.audio.stop(gameSound)
			level.levelNumber = 1
			level.levelDone = false
			menu.isPresentStageDone = false
		elseif next(asteroids) == nil then
			level.levelNumber = level.levelNumber + 1
			level.levelDone = false
			menu.isPresentStageDone = false
		end
	end

	if menu.selectionMenu == menu.PRESENT_STAGE then
		menu.updatePresentStage(dt)
		particlesTransitionStage:update(dt)
		if love.keyboard.isDown("s") then
			particlesTransitionStage = nil  -- optim(TBT)
			menu.isPresentStageDone = true
			menu.selectionMenu = menu.menuValues[menu.START]
		end
	end

	if menu.selectionMenu == menu.GAMEOVER or menu.selectionMenu == menu.CONGRATULATION then
		if love.keyboard.isDown("r") then
			menu.selectionMenu = menu.MENU -- come back to menu
			love.load()
		end
	end

	if menu.selectionMenu == menu.menuValues[menu.TUTO] then
		if love.keyboard.isDown("q") then
			menu.selectionMenu = menu.MENU -- come back to menu
			-- love.audio.stop(creditsSound)
		end
	end

	if menu.selectionMenu == menu.menuValues[menu.CREDITS] then
		menu.updateResetOffsetPrintCreditsStart(dt)
		if love.keyboard.isDown("q") then
			menu.selectionMenu = menu.MENU -- come back to menu
			love.audio.stop(creditsSound)
		end
	end
end

--  ██████  ██████   █████  ██     ██
--  ██   ██ ██   ██ ██   ██ ██     ██
--  ██   ██ ██████  ███████ ██  █  ██
--  ██   ██ ██   ██ ██   ██ ██ ███ ██
--  ██████  ██   ██ ██   ██  ███ ███
function love.draw()
	love.graphics.scale(GRAPHICS_SCALE, GRAPHICS_SCALE)

	if menu.selectionMenu == menu.MENU then
		love.graphics.setFont(fontVT20)
		menu.draw(toggleDebug, fontVT12)
	end

	if menu.selectionMenu == menu.PRESENT_STAGE and particlesTransitionStage ~= nil then  -- optim(TBT)
		love.graphics.setFont(fontNerd20)
		menu.presentStage(level.levelNumber, particlesTransitionStage, fontNerd10)
	end

	if menu.selectionMenu == menu.menuValues[menu.START] then
		love.graphics.draw(EspacePng, 0, 0, 0)

		-- VAISSEAU DRAW
		if vaisseaux[1] ~= nil then
			vaisseaux[1].draw()
			if DEBUG_MODE then
				debugMode(vaisseaux, fontNerd11)
			end
		end

		-- ASTEROIDS DRAW
		for asteroids_it = 1, #asteroids do
			asteroids[asteroids_it].draw()

			if DEBUG_MODE then
				debugMode(asteroids, fontNerd11)
			end
		end

		-- BONUSS DRAW
		for bonuss_it = 1, #bonuss do
			bonuss[bonuss_it].draw()
		end

		-- ASTEROID EXPLOSIONS
        for particlesAsteroDivExplosion_it = 1, #asteroidExplosions do
            asteroidExplosions[particlesAsteroDivExplosion_it].draw()
        end

		-- MISSILE DRAW
		for missiles_it = 1, #missiles do
			if missiles[missiles_it] ~= nil then
				missiles[missiles_it].draw()
			end

			if DEBUG_MODE then
				debugMode(missiles, fontNerd11)
			end
		end
	end

	if menu.selectionMenu == menu.GAMEOVER then
		love.graphics.setFont(fontNerd14)
		menu.gameover()
	end

	if menu.selectionMenu == menu.CONGRATULATION then
		love.graphics.setFont(fontNerd14)
		menu.congratulation()
	end

	if menu.selectionMenu == menu.menuValues[menu.TUTO] then
		love.graphics.setFont(fontVT12)
		menu.shortcutsAndBonus()
	end

	if menu.selectionMenu == menu.menuValues[menu.CREDITS] then
		love.graphics.setFont(fontVT12)
		menu.creditsDraw()
	end
end
