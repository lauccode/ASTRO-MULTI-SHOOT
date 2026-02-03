local AsteroidExplosions = {}
AsteroidExplosions.new = function(X_explo, Y_explo)
    local self = {}
    local timeExplosion = 0
    local TIME_EXPLOSION_END_TIME = 100
    local TIME_EMISSION_RATE_END_TIME = 60
    local X_explosionPos = X_explo
    local Y_explosionPos = Y_explo
    local emissionRate = 0
    self.asteroDivisionExplosion = true

    local particlesAsteroDivExplosions = {}
    local img = Assets.images.asteroDust
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
        particlesAsteroDivExplosions[1]:setParticleLifetime(1, 1)
        particlesAsteroDivExplosions[1]:setEmissionRate(emissionRate)
        particlesAsteroDivExplosions[1]:setSizeVariation(1)
        particlesAsteroDivExplosions[1]:setLinearAcceleration(-20, -20, 20, 20)
        particlesAsteroDivExplosions[1]:setSpeed(30, 90)
        particlesAsteroDivExplosions[1]:setSizes(1, 0.1)
        particlesAsteroDivExplosions[1]:setDirection((2 * math.pi) * math.random())
        love.graphics.draw(particlesAsteroDivExplosions[1], X_explosionPos, Y_explosionPos)
    end

    function self.draw()
        if (self.asteroDivisionExplosion == true) then
            if(takeExplosionPosition == false) then
                X_explosionPos = self.position.x
                Y_explosionPos = self.position.y
                takeExplosionPosition = true
            end
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
