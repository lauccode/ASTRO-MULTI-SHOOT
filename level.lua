Level = {}
Level.new = function()
    local self = {}

    self.levelNumber = 1
    self.MAX_LEVEL_NUMBER = 7
    self.levelDone = false

    local function loadLevel1(vaisseaux, asteroids)
        EspacePng = love.graphics.newImage("backgroud/Starfield_08-512x512.png")
        local MAX_ASTEROIDS = 1

        gameSound = love.audio.newSource("music/BlueNavi-Starcade.mp3", "stream")
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)

        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)

        return asteroids
    end

    local function loadLevel2(vaisseaux, asteroids)
        EspacePng = love.graphics.newImage("backgroud/Purple_Nebula_01-512x512.png")
        local MAX_ASTEROIDS = 3
        love.audio.stop(gameSound)

        gameSound = love.audio.newSource("music/Jaunter-Reset.mp3", "stream")
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)

        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)

        return asteroids
    end

    local function loadLevel3(vaisseaux, asteroids)
        EspacePng = love.graphics.newImage("backgroud/Purple_Nebula_04-512x512.png")
        local MAX_ASTEROIDS = 4
        love.audio.stop(gameSound)

        gameSound = love.audio.newSource("music/KarolPiczak-LesChampsEtoiles.mp3", "stream")
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)

        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)

        return asteroids
    end

    local function loadLevel4(vaisseaux, asteroids)
        EspacePng = love.graphics.newImage("backgroud/Blue_Nebula_08-512x512.png")
        local MAX_ASTEROIDS = 5
        love.audio.stop(gameSound)

        gameSound = love.audio.newSource("music/Kubbi-Ember-04Cascade.mp3", "stream")
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)

        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)

        return asteroids
    end

    local function loadLevel5(vaisseaux, asteroids)
        EspacePng = love.graphics.newImage("backgroud/Green_Nebula_07-512x512.png")
        local MAX_ASTEROIDS = 6
        love.audio.stop(gameSound)

        gameSound = love.audio.newSource("music/PunchDeck-ICantStop.mp3", "stream")
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)

        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)

        return asteroids
    end

    local function loadLevel6(vaisseaux, asteroids)
        EspacePng = love.graphics.newImage("backgroud/Green_Nebula_07-512x512.png")
        local MAX_ASTEROIDS = 9
        love.audio.stop(gameSound)

        gameSound = love.audio.newSource("music/LukeHall-Dystopia.mp3", "stream")
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)

        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)

        return asteroids
    end

    function self.levelManager(vaisseaux, asteroids)
        if (self.levelNumber == 1) then
            loadLevel1(vaisseaux, asteroids)
        end
        if (self.levelNumber == 2) then
            loadLevel2(vaisseaux, asteroids)
        end
        if (self.levelNumber == 3) then
            loadLevel3(vaisseaux, asteroids)
        end
        if (self.levelNumber == 4) then
            loadLevel4(vaisseaux, asteroids)
        end
        if (self.levelNumber == 5) then
            loadLevel5(vaisseaux, asteroids)
        end
        if (self.levelNumber == 6) then
            loadLevel6(vaisseaux, asteroids)
        end
        return asteroids
    end

    return self
end
