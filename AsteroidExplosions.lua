local Vector2 = require("Vector2")
local GameObject = require("GameObject")

local AsteroidExplosions = {}
AsteroidExplosions.new = function(X_explo, Y_explo, velocityExplosion, tableMissilePackQuicker)
    local self = GameObject.new()
    local timeExplosion = 0
    local TIME_EXPLOSION_END_TIME = 100
    local TIME_EMISSION_RATE_END_TIME = 60
    local emissionRate = 0
    self.asteroDivisionExplosion = true
    self.velocity = velocityExplosion
    self.position = Vector2.new(X_explo, Y_explo)

    -- self.velocity = Vector2.new(0, 0)

    local particlesAsteroDivExplosions = {}
    local img = Assets.images.asteroDust1
    if(tableMissilePackQuicker == self.MSL_PKG_QUICKER) then
        img = Assets.images.asteroDust2
    elseif(tableMissilePackQuicker == self.MSL_PKG_MUCH_QUICKER) then
        img = Assets.images.asteroDust3
    else
        img = Assets.images.asteroDust1
    end
    table.insert(particlesAsteroDivExplosions, love.graphics.newParticleSystem(img, 450))

    function self.particlesAsteroDivExplosionUpdate(dt)
        for particlesAsteroDivExplosion_it = 1, #particlesAsteroDivExplosions do
            particlesAsteroDivExplosions[particlesAsteroDivExplosion_it]:update(dt)
        end
    end

    function self.particlesExplosionLifeDurationUpdate(dt)
        if (self.asteroDivisionExplosion == true) then
            timeExplosion = timeExplosion + (60*dt)
        end
        if(timeExplosion >= TIME_EXPLOSION_END_TIME) then
            self.asteroDivisionExplosion = false
        end
    end

    local function drawParticlesADE()
        love.graphics.draw(particlesAsteroDivExplosions[1], self.position.x, self.position.y)
    end

    function self.move(dt)
        -- update position using velocity vector
        self.position = self.position:add(self.velocity:scale(dt))
    end

    -- Update particle system parameters (do not modify in draw)
    function self.update(dt)
        self.move(dt)
        if (self.asteroDivisionExplosion == true) then
            if(timeExplosion >= TIME_EMISSION_RATE_END_TIME) then
                emissionRate = 0
            else
                emissionRate = math.abs(150*((TIME_EMISSION_RATE_END_TIME-timeExplosion)/TIME_EMISSION_RATE_END_TIME))
            end
            particlesAsteroDivExplosions[1]:setParticleLifetime(1, 1)
            particlesAsteroDivExplosions[1]:setEmissionRate(emissionRate)
            particlesAsteroDivExplosions[1]:setSizeVariation(1)
            particlesAsteroDivExplosions[1]:setLinearAcceleration(-20, -20, 20, 20)
            particlesAsteroDivExplosions[1]:setSpeed(30, 90)
            particlesAsteroDivExplosions[1]:setSizes(1, 0.1)
            particlesAsteroDivExplosions[1]:setDirection((2 * math.pi) * math.random())
        end
    end

    function self.draw()
        if (self.asteroDivisionExplosion == true) then
            if(timeExplosion >= TIME_EMISSION_RATE_END_TIME) then
                emissionRate = 0
            else
                emissionRate = math.abs(150*((TIME_EMISSION_RATE_END_TIME-timeExplosion)/TIME_EMISSION_RATE_END_TIME))
            end
            drawParticlesADE()
        end
    end

    return self
end

return AsteroidExplosions
