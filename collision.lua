-- Helper for bounce
local function objectBounce(dt, objects, objects2, objects_to_manage, objects_to_manage2)
    for objects_moved_it = #objects_to_manage, 1, -1 do
        for objects_moved_it2 = #objects_to_manage2, 1, -1 do
            local speedX_Object1 = objects2[objects_to_manage2[objects_moved_it2]].speedX
            local speedY_Object1 = objects2[objects_to_manage2[objects_moved_it2]].speedY
            local speedX_Object2 = objects[objects_to_manage[objects_moved_it]].speedX
            local speedY_Object2 = objects[objects_to_manage[objects_moved_it]].speedY

            local X_posObject1 = (objects[objects_to_manage[objects_moved_it]].X_pos + speedX_Object1*dt)
            local Y_posObject1 = (objects[objects_to_manage[objects_moved_it]].Y_pos + speedY_Object1*dt)
            local X_posObject2 = (objects2[objects_to_manage2[objects_moved_it2]].X_pos + speedX_Object2*dt)
            local Y_posObject2 = (objects2[objects_to_manage2[objects_moved_it2]].Y_pos + speedY_Object2*dt)
            local dx = X_posObject2 - X_posObject1
            local dy = Y_posObject2 - Y_posObject1
            local newDist = math.sqrt(dx * dx + dy * dy)

            local actualDist = objects[objects_to_manage[objects_moved_it]].distanceWith(objects2[
            objects_to_manage2[objects_moved_it2]])

            if (newDist > actualDist) then
                objects[objects_to_manage[objects_moved_it]].speedX = speedX_Object1
                objects[objects_to_manage[objects_moved_it]].speedY = speedY_Object1
                objects2[objects_to_manage2[objects_moved_it2]].speedX = speedX_Object2
                objects2[objects_to_manage2[objects_moved_it2]].speedY = speedY_Object2
            end
        end
    end
end

local function findFirstCollisionSimple(list1, list2)
    local objects_to_manage = {}
    local object_number = 0
    local objects_to_manage2 = {}
    local object_number2 = 0
    local checkDone = false
    for i = 1, #list1 do
        for j = 1, #list2 do
            if not checkDone and list1[i].collisionWith(list2[j]) then
                if list1[i].nameInstance == "ASTEROID" and list2[j].nameInstance == "ASTEROID" and i == j then
                else
                    object_number = object_number + 1
                    objects_to_manage[object_number] = i
                    object_number2 = object_number2 + 1
                    objects_to_manage2[object_number2] = j
                    checkDone = true
                end
            end
        end
    end
    return objects_to_manage, object_number, objects_to_manage2, object_number2
end

function CreateAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)
    for asteroid_to_create = 1, MAX_ASTEROIDS do
        table.insert(asteroids, Asteroid.new())
        while (vaisseaux[1].collisionWith(asteroids[asteroid_to_create], true)) do
            table.remove(asteroids, asteroid_to_create)
            table.insert(asteroids, Asteroid.new())
        end
    end
    return asteroids
end

-- Asteroids <-> Asteroids
function CollisionManagerAsteroids(dt, level, asteroids1, asteroids2)
    local objects_to_manage, object_number, objects_to_manage2, object_number2 = findFirstCollisionSimple(asteroids1, asteroids2)
    if asteroids1[objects_to_manage[object_number]] and asteroids2[objects_to_manage2[object_number2]] then
        if asteroids1[objects_to_manage[object_number]].nameInstance == "ASTEROID" and asteroids2[objects_to_manage2[object_number2]].nameInstance == "ASTEROID" then
            objectBounce(dt, asteroids1, asteroids2, objects_to_manage, objects_to_manage2)
        end
    end
end

-- Missiles <-> Asteroids
function CollisionManagerAsteroidsAndMissiles(dt, level, missiles, asteroids, asteroidExplosions, bonuss, asteroidExplosionSound)
    local objects_to_manage, object_number, objects_to_manage2, object_number2 = findFirstCollisionSimple(missiles, asteroids)
    if missiles[objects_to_manage[object_number]] and asteroids[objects_to_manage2[object_number2]] then
        for i = #objects_to_manage, 1, -1 do
            for j = #objects_to_manage2, 1, -1 do
                love.audio.stop(asteroidExplosionSound)
                table.insert(asteroidExplosions, AsteroidExplosions.new(missiles[objects_to_manage[i]].X_pos, missiles[objects_to_manage[i]].Y_pos))
                table.remove(missiles, objects_to_manage[i])
                local asteroid = asteroids[objects_to_manage2[j]]
                if asteroid.asteroidDivision > 0 and asteroid.protection < 1 then
                    if asteroid.asteroidDivision == 2 then
                        table.insert(bonuss, Bonus.new())
                        bonuss[#bonuss].X_pos = asteroid.X_pos
                        bonuss[#bonuss].Y_pos = asteroid.Y_pos
                    end
                    for k = 1, 2 do
                        table.insert(asteroids, Asteroid.new())
                        local newAsteroid = asteroids[#asteroids]
                        newAsteroid.X_pos = asteroid.X_pos
                        newAsteroid.Y_pos = asteroid.Y_pos
                        newAsteroid.imageRatio = asteroid.imageRatio / 2
                        newAsteroid.recalculateImageRadius()
                        newAsteroid.asteroidDivision = asteroid.asteroidDivision - 1
                        newAsteroid.protection = newAsteroid.asteroidDivision
                        table.insert(asteroidExplosions, AsteroidExplosions.new(newAsteroid.X_pos, newAsteroid.Y_pos))
                    end
                    table.remove(asteroids, objects_to_manage2[j])
                    love.audio.play(asteroidExplosionSound)
                else
                    asteroid.protection = asteroid.protection - 1
                    asteroid.asteroidImpact = true
                    love.audio.play(asteroidExplosionSound)
                    if asteroid.asteroidDivision < 1 and asteroid.protection < 1 then
                        table.remove(asteroids, objects_to_manage2[j])
                        love.audio.play(asteroidExplosionSound)
                    end
                end
            end
        end
    end
    -- Missiles exit screen
    local missiles_to_remove = {}
    local missile_number = 0
    for i = 1, #missiles do
        if missiles[i].nameInstance == "MISSILE" and missiles[i].missile_lost() then
            missile_number = missile_number + 1
            missiles_to_remove[missile_number] = i
        end
    end
    for i = #missiles_to_remove, 1, -1 do
        table.remove(missiles, missiles_to_remove[i])
    end
end

-- Vaisseaux <-> Asteroids
function CollisionManagerVaisseauxAndAsteroids(dt, level, vaisseaux, asteroids, vaisseauImpactSound)
    local objects_to_manage = {}
    local object_number = 0
    local objects_to_manage2 = {}
    local object_number2 = 0
    local checkDone = false
    local gameOver = false
    for i = 1, #vaisseaux do
        for j = 1, #asteroids do
            if not checkDone then
                if (vaisseaux[i].nameInstance == "VAISSEAU" and asteroids[j].nameInstance == "ASTEROID") then
                    if vaisseaux[i].timeShieldStart < vaisseaux[i].TIME_SHIELD_START_MAX then
                        if vaisseaux[i].collisionWith(asteroids[j], true) then
                            object_number = object_number + 1
                            objects_to_manage[object_number] = i
                            object_number2 = object_number2 + 1
                            objects_to_manage2[object_number2] = j
                            checkDone = true
                        end
                    else
                        if vaisseaux[i].collisionWith(asteroids[j]) then
                            object_number = object_number + 1
                            objects_to_manage[object_number] = i
                            object_number2 = object_number2 + 1
                            objects_to_manage2[object_number2] = j
                            checkDone = true
                        end
                    end
                end
            end
        end
    end
    if vaisseaux[objects_to_manage[object_number]] and asteroids[objects_to_manage2[object_number2]] then
        for i = #objects_to_manage, 1, -1 do
            for j = #objects_to_manage2, 1, -1 do
                local vaisseau = vaisseaux[objects_to_manage[object_number]]
                local asteroid = asteroids[objects_to_manage2[object_number2]]
                if vaisseau.protection > 0 then
                    objectBounce(dt, vaisseaux, asteroids, objects_to_manage, objects_to_manage2)
                    if vaisseau.timeShieldStart < vaisseau.TIME_SHIELD_START_MAX then
                    else
                        vaisseau.protection = vaisseau.protection - 1
                        love.audio.play(vaisseauImpactSound)
                    end
                    vaisseau.vaisseauImpact = true
                    love.audio.play(vaisseauImpactSound)
                else
                    table.remove(vaisseaux, objects_to_manage[i])
                    gameOver = true
                    return gameOver
                end
            end
        end
    end
    return false
end

-- Vaisseaux <-> Bonus
function CollisionManagerVaisseauxAndBonus(dt, level, vaisseaux, bonuss)
    local objects_to_manage, object_number, objects_to_manage2, object_number2 = findFirstCollisionSimple(vaisseaux, bonuss)
    if vaisseaux[objects_to_manage[object_number]] and bonuss[objects_to_manage2[object_number2]] then
        for i = #objects_to_manage, 1, -1 do
            for j = #objects_to_manage2, 1, -1 do
                local vaisseau = vaisseaux[objects_to_manage[object_number]]
                local bonus = bonuss[objects_to_manage2[object_number2]]

                local function upgradePack(bonusTypeMuch, bonusType, vaisseauField, vaisseauTypeStd, vaisseauType, vaisseauTypeMuch)
                    if bonus.bonus == bonusTypeMuch or bonus.bonus == bonusType then
                        if vaisseau[vaisseauField] == vaisseau[vaisseauType] then
                            vaisseau[vaisseauField] = vaisseau[vaisseauTypeMuch]
                        elseif vaisseau[vaisseauField] == vaisseau[vaisseauTypeStd] then
                            vaisseau[vaisseauField] = vaisseau[vaisseauType]
                        end
                    end
                end
                upgradePack(bonus.MSL_PKG_MUCH_QUICKER, bonus.MSL_PKG_QUICKER, "missilePackQuicker", "MSL_PKG_STD", "MSL_PKG_QUICKER", "MSL_PKG_MUCH_QUICKER")
                upgradePack(bonus.MSL_PKG_MUCH_BIGGER, bonus.MSL_PKG_BIGGER, "missilePackBigger", "MSL_PKG_STD", "MSL_PKG_BIGGER", "MSL_PKG_MUCH_BIGGER")
                upgradePack(bonus.MSL_PKG_MUCH_LATERAL, bonus.MSL_PKG_LATERAL, "missilePackLateral", "MSL_PKG_STD", "MSL_PKG_LATERAL", "MSL_PKG_MUCH_LATERAL")

                if bonus.bonus == bonus.MSL_LASER_SIGHT then
                    vaisseau.missileLaserSight = vaisseau.MSL_LASER_SIGHT 
                end
                if bonus.bonus == bonus.SHIELD then
                    vaisseau.activateShield()
                end
                if bonus.bonus == bonus.MSL_SINUS then
                    vaisseau.missileSinus = vaisseau.MSL_SINUS
                end
                table.remove(bonuss, objects_to_manage2[j])
            end
        end
    end
    -- Bonus lifetime
    local bonuss_to_remove = {}
    local bonus_number = 0
    for i = 1, #bonuss do
        if bonuss[i].nameInstance == "BONUS" and bonuss[i].checkLifeTimeFinished() then
            bonus_number = bonus_number + 1
            bonuss_to_remove[bonus_number] = i
        end
    end
    for i = #bonuss_to_remove, 1, -1 do
        table.remove(bonuss, bonuss_to_remove[i])
    end
end
