Level = {}
Level.new = function()
    local self = {}

    self.levelNumber = 1
    self.MAX_LEVEL_NUMBER = 7
    self.levelDone = false

    function self.levelManager(vaisseaux, asteroids, gameSound)

        if gameSound ~= nil then
            love.audio.stop(gameSound)
        end

        if (self.levelNumber == 1) then
            EspacePng = love.graphics.newImage("backgroud/Starfield_08-512x512.png")
            gameSound = love.audio.newSource("music/BlueNavi-Starcade.mp3", "stream")
            MAX_ASTEROIDS= 1
        end
        if (self.levelNumber == 2) then
            EspacePng = love.graphics.newImage("backgroud/Purple_Nebula_01-512x512.png")
            gameSound = love.audio.newSource("music/Jaunter-Reset.mp3", "stream")
            MAX_ASTEROIDS= 2
        end
        if (self.levelNumber == 3) then
            EspacePng = love.graphics.newImage("backgroud/Purple_Nebula_04-512x512.png")
            gameSound = love.audio.newSource("music/KarolPiczak-LesChampsEtoiles.mp3", "stream")
            MAX_ASTEROIDS= 3
        end
        if (self.levelNumber == 4) then
            EspacePng = love.graphics.newImage("backgroud/Blue_Nebula_08-512x512.png")
            gameSound = love.audio.newSource("music/Kubbi-Ember-04Cascade.mp3", "stream")
            MAX_ASTEROIDS= 4
        end
        if (self.levelNumber == 5) then
            EspacePng = love.graphics.newImage("backgroud/Green_Nebula_07-512x512.png")
            gameSound = love.audio.newSource("music/PunchDeck-ICantStop.mp3", "stream")
            MAX_ASTEROIDS= 5
        end
        if (self.levelNumber == 6) then
            EspacePng = love.graphics.newImage("backgroud/Green_Nebula_07-512x512.png")
            gameSound = love.audio.newSource("music/LukeHall-Dystopia.mp3", "stream")
            MAX_ASTEROIDS= 6
        end
        gameSound:setVolume(0.4)
        love.audio.play(gameSound)
        createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)
        return asteroids, gameSound
    end

    return self
end
