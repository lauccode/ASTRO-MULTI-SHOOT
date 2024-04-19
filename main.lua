require("models")
require("collision")
require("update")
require("debugMode")
require("level")
require("menu")

-- Pour debugger avec zeroBrane
if arg[#arg] == "-debug" then require("mobdebug").start() end

-- MANDATORY TO DEBUG WITH VSC + install "local lua debbuger" plugin
-- if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
--   require("lldebugger").start()
-- end
-- OR

-- sudo add-apt-repository ppa:bartbes/love-stable
-- sudo apt update
-- sudo apt install love
-- sudo apt install lua5.4

-- Lua v3.5.3 sumneko
-- Local Lua Debugger v0.3.3 Tom Blind
-- French Language Pack for Visual Studio Code v1.70.8170921 Microsoft

-- Pour debugger avec vsCode
if arg[#arg] == "vsc_debug" then
    require("lldebugger").start()
end

-- 1) Variables
local MAX_ASTEROIDS = 0
local DEBUG_MODE = false
-- 2)
local vaisseaux = nil
local missiles = nil
local asteroids = nil -- also to manage bonus
local bonus = nil
local particles = nil
local particlesTransitionStage = nil

local menu = nil

local toggleDebug = false

local GRAPHICS_SCALE = 1.5

-- global to be used everywhere
SCREEN_WIDTH = 512
SCREEN_HIGH = 512
introSound = nil
gameSound = nil
creditsSound = nil
asteroidExplosion = nil
shootSound = nil
vaisseauImpact = nil

menu = Menu.new()
level = Level.new()

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
        borderless = false
    })
    -- love.window.setFullscreen(true, "desktop")
    -- love.window.setFullscreen( true )

    asteroidExplosion = love.audio.newSource("sound/explosion_asteroid-101886.mp3", "stream")
    asteroidExplosion:setVolume(1)
    shootSound = love.audio.newSource("sound/8-bit-cannon-fire-96505.mp3", "stream")
    shootSound:setVolume(0.4)
    vaisseauImpact = love.audio.newSource("sound/hurt_c_08-102842.mp3", "stream")
    vaisseauImpact:setVolume(1)

    DEBUG_MODE = false
    vaisseaux = {}
    table.insert(vaisseaux, Vaisseau.new(level))
    vaisseaux[1].timeShieldStart = 0 --seconds
    missiles = {}
    asteroids = {}                   --also to manage bonus
    bonuss = {}
    particles = {}
    menu.positionMenu = menu.START
    level.levelDone = false

    local img = love.graphics.newImage('sprites/star.png')
    particlesTransitionStage = love.graphics.newParticleSystem(img, 450)
end

-- ██    ██ ██████  ██████   █████  ████████ ███████
-- ██    ██ ██   ██ ██   ██ ██   ██    ██    ██
-- ██    ██ ██████  ██   ██ ███████    ██    █████
-- ██    ██ ██      ██   ██ ██   ██    ██    ██
--  ██████  ██      ██████  ██   ██    ██    ███████


function love.update(dt) -- 60 fps by defaut

    local fps = 60
    dt = dt * fps
    timerUpdate(dt)

    if (menu.selectionMenu == menu.MENU) then
        DEBUG_MODE, toggleDebug = keyboardMenuUpdate(DEBUG_MODE, menu, toggleDebug)
    end

    if (menu.selectionMenu == menu.menuValues[menu.START]) then
        if (menu.isPresentStageDone == false) then
            menu.selectionMenu = menu.PRESENT_STAGE
            menu.timerPresentStage = 1
        end

        -- level manager
        vaisseaux[1].timeShieldStart = vaisseaux[1].timeShieldStart + 1 -- count time from start of level
        if (level.levelDone == false) then
            if (level.levelNumber > 1) then
                love.load() -- reset all before new level
            end
            asteroids = level.levelManager(vaisseaux, asteroids)
            level.levelDone = true
        end
        DEBUG_MODE = keyboardUpdate(vaisseaux, missiles, DEBUG_MODE, menu, level, toggleDebug, dt)

        asteroidsUpdate(dt, asteroids)
        missilesUpdate(dt, missiles)
        particlesUpdate(dt/fps, particles)

        -----------------------------------------
        -- COLLISSION MANAGER (FACTORIZED) --
        -----------------------------------------
        collisionManager(level, asteroids, asteroids)
        collisionManager(level, missiles, asteroids)
        local gameOver = collisionManager(level, vaisseaux, asteroids)
        if (gameOver) then
            menu.selectionMenu = menu.GAMEOVER
            love.audio.stop(gameSound)
            level.levelNumber = 1
            level.levelDone = false
            menu.isPresentStageDone = false
        elseif (level.levelNumber == level.MAX_LEVEL_NUMBER) then
            menu.selectionMenu = menu.CONGRATULATION
            love.audio.stop(gameSound)
            level.levelNumber = 1
            level.levelDone = false
            menu.isPresentStageDone = false
        elseif (next(asteroids) == nil) then
            level.levelNumber = level.levelNumber + 1
            level.levelDone = false
            menu.isPresentStageDone = false
        end
    end

    if (menu.selectionMenu == menu.PRESENT_STAGE) then
        particlesTransitionStage:update(dt/fps)
        if love.keyboard.isDown("s") then
            menu.isPresentStageDone = true
            menu.selectionMenu = menu.menuValues[menu.START]
        end
    end

    if (menu.selectionMenu == menu.GAMEOVER or menu.selectionMenu == menu.CONGRATULATION) then
        if love.keyboard.isDown("r") then
            menu.selectionMenu = menu.MENU -- come back to menu
            love.load()
        end
    end

    if (menu.selectionMenu == menu.menuValues[menu.TUTO]) then
        if love.keyboard.isDown("q") or love.keyboard.isDown("escape") then
            menu.selectionMenu = menu.MENU -- come back to menu
            -- love.audio.stop(creditsSound)
        end
    end

    if (menu.selectionMenu == menu.menuValues[menu.CREDITS]) then
        if love.keyboard.isDown("q") or love.keyboard.isDown("escape") then
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

    if (menu.selectionMenu == menu.MENU) then
        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 16)
        love.graphics.setFont(font)
        menu.draw(toggleDebug)
    end

    if (menu.selectionMenu == menu.PRESENT_STAGE) then
        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 20)
        love.graphics.setFont(font)
        menu.presentStage(level.levelNumber, particlesTransitionStage)
    end

    if (menu.selectionMenu == menu.menuValues[menu.START]) then
        love.graphics.draw(EspacePng, 0, 0, 0)

        -- VAISSEAU DRAW
        if (vaisseaux[1] ~= nil) then
            vaisseaux[1].draw(particles)
            if (DEBUG_MODE) then
                debugMode(vaisseaux)
            end
        end

        -- ASTEROIDS DRAW
        for asteroids_it = 1, #asteroids do
            asteroids[asteroids_it].draw()

            if (DEBUG_MODE) then
                debugMode(asteroids)
            end
        end

        -- MISSILE DRAW
        for missiles_it = 1, #missiles do
            if (missiles[missiles_it] ~= nil) then
                missiles[missiles_it].draw()
            end

            if (DEBUG_MODE) then
                debugMode(missiles)
            end
        end
    end

    if (menu.selectionMenu == menu.GAMEOVER) then
        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 14)
        love.graphics.setFont(font)
        menu.gameover()
    end

    if (menu.selectionMenu == menu.CONGRATULATION) then
        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 14)
        love.graphics.setFont(font)
        menu.congratulation()
    end

    if (menu.selectionMenu == menu.menuValues[menu.TUTO]) then
        local font = love.graphics.newFont("fonts/VT323/VT323-Regular.ttf", 12)
        love.graphics.setFont(font)
        menu.shortcutsAndBonus()
    end

    if (menu.selectionMenu == menu.menuValues[menu.CREDITS]) then
        local font = love.graphics.newFont("fonts/VT323/VT323-Regular.ttf", 12)
        love.graphics.setFont(font)
        menu.creditsDraw()
    end
end
