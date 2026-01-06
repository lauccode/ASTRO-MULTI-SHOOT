function createAsteroidsFarAwayFromVaisseau(vaisseaux, asteroids, MAX_ASTEROIDS)
    for asteroid_to_create = 1, MAX_ASTEROIDS do
        table.insert(asteroids, Asteroid.new())
        while (vaisseaux[1].collisionWith(asteroids[asteroid_to_create], true)) do
            table.remove(asteroids, asteroid_to_create)
            table.insert(asteroids, Asteroid.new())
        end
    end
    return asteroids
end

function collisionManager(dt, level, objects, objects2, asteroidExplosions, bonuss, asteroidExplosionSound, vaisseauImpactSound)
    local objects_to_manage = {}
    local object_number = 0
    local objects_to_manage2 = {}
    local object_number2 = 0
    local checkDone = false
    local gameOver = false

    -- 1) collision detection
    for objects_it = 1, #objects do
        for objects_it2 = 1, #objects2 do
            if (checkDone == false) then
                if (
                        (objects_it ~= objects_it2) or
                        (objects[objects_it].nameInstance ~= objects2[objects_it2].nameInstance)) then -- no need to check collision between the same asteroid
                    if (   --manage vaisseaux protection when level start
                            objects[objects_it].nameInstance == "VAISSEAU" and
                            objects2[objects_it2].nameInstance == "ASTEROID" and
                            objects[objects_it].timeShieldStart < objects[objects_it].TIME_SHIELD_START_MAX) then
                        if (objects[objects_it].collisionWith(objects2[objects_it2], true)) then
                            object_number = object_number + 1
                            objects_to_manage[object_number] = objects_it
                            object_number2 = object_number2 + 1
                            objects_to_manage2[object_number2] = objects_it2
                            checkDone = true     -- only remove one collision at a time !!!!!
                        end
                    else    --manage vaisseaux protection after levelStart
                        if (objects[objects_it].collisionWith(objects2[objects_it2])) then
                            object_number = object_number + 1
                            objects_to_manage[object_number] = objects_it
                            object_number2 = object_number2 + 1
                            objects_to_manage2[object_number2] = objects_it2
                            checkDone = true     -- only remove one collision at a time !!!!!
                        end
                    end
                end
            end
        end
    end

    -- manage object bounces
    local function objectBounce(objects, objects2)
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

    -- manage asteroids collisions with asteroids
    if (
            objects[objects_to_manage[object_number]] ~= nil and
            objects2[objects_to_manage2[object_number2]] ~= nil) then
        if (
                objects[objects_to_manage[object_number]].nameInstance == "ASTEROID" and
                objects2[objects_to_manage2[object_number2]].nameInstance == "ASTEROID") then
            objectBounce(objects, objects2)
        end
    end

    -- manage missiles collisions with asteroids
    if (
            objects[objects_to_manage[object_number]] ~= nil and
            objects2[objects_to_manage2[object_number2]] ~= nil) then
        for objects_removed_it = #objects_to_manage, 1, -1 do
            for objects_removed_it2 = #objects_to_manage2, 1, -1 do
                if (
                        objects[objects_to_manage[object_number]].nameInstance == "MISSILE" and
                        objects2[objects_to_manage2[object_number2]].nameInstance == "ASTEROID") then
                    love.audio.stop(asteroidExplosionSound)
                        -- add particle explosion
                        table.insert(asteroidExplosions, AsteroidExplosions.new(objects[objects_to_manage[objects_removed_it]].X_pos, objects[objects_to_manage[objects_removed_it]].Y_pos))
                        -- end add particle explosion
                    -- remove missile
                    table.remove(objects, objects_to_manage[objects_removed_it]) -- remove objects from table

                    if (objects2[objects_to_manage2[objects_removed_it2]].asteroidDivision > 0 and objects2[objects_to_manage2[objects_removed_it2]].protection < 1) then
                        -- create Bonus on first division
                        if (objects2[objects_to_manage2[objects_removed_it2]].asteroidDivision == 2) then
                            table.insert(bonuss, Bonus.new()) -- Bonus managed in asteroids table !
                            bonuss[#bonuss + 1 - 1].X_pos = objects2[objects_to_manage2[objects_removed_it2]].X_pos
                            bonuss[#bonuss + 1 - 1].Y_pos = objects2[objects_to_manage2[objects_removed_it2]].Y_pos
                        end

                        -- Create 2 news asteroids more small
                        table.insert(objects2, Asteroid.new())
                        objects2[#objects2 + 1 - 1].X_pos = objects2[objects_to_manage2[objects_removed_it2]].X_pos
                        objects2[#objects2 + 1 - 1].Y_pos = objects2[objects_to_manage2[objects_removed_it2]].Y_pos
                        objects2[#objects2 + 1 - 1].imageRatio = (objects2[objects_to_manage2[objects_removed_it2]].imageRatio) /
                        2
                        objects2[#objects2 + 1 - 1].recalculateImageRadius()
                        objects2[#objects2 + 1 - 1].asteroidDivision = objects2[objects_to_manage2[objects_removed_it2]]
                        .asteroidDivision
                        objects2[#objects2 + 1 - 1].asteroidDivision = objects2[#objects2 + 1 - 1].asteroidDivision - 1
                        objects2[#objects2 + 1 - 1].protection = objects2[#objects2 + 1 - 1].asteroidDivision

                        table.insert(objects2, Asteroid.new())

                        -- add particle explosion
                        table.insert(asteroidExplosions, AsteroidExplosions.new(objects2[objects_to_manage2[objects_removed_it2]].X_pos, objects2[objects_to_manage2[objects_removed_it2]].Y_pos))
                        -- end add particle explosion


                        objects2[#objects2 + 1 - 1].X_pos = objects2[objects_to_manage2[objects_removed_it2]].X_pos
                        objects2[#objects2 + 1 - 1].Y_pos = objects2[objects_to_manage2[objects_removed_it2]].Y_pos
                        objects2[#objects2 + 1 - 1].imageRatio = (objects2[objects_to_manage2[objects_removed_it2]].imageRatio) /
                        2
                        objects2[#objects2 + 1 - 1].recalculateImageRadius()
                        objects2[#objects2 + 1 - 1].asteroidDivision = objects2[objects_to_manage2[objects_removed_it2]]
                        .asteroidDivision
                        objects2[#objects2 + 1 - 1].asteroidDivision = objects2[#objects2 + 1 - 1].asteroidDivision - 1
                        objects2[#objects2 + 1 - 1].protection = objects2[#objects2 + 1 - 1].asteroidDivision

                        -- remove asteroid
                        table.remove(objects2, objects_to_manage2[objects_removed_it2]) -- remove objects from table
                        love.audio.play(asteroidExplosionSound)
                    else
                        -- impact
                        objects2[objects_to_manage2[objects_removed_it2]].protection = objects2[
                        objects_to_manage2[objects_removed_it2]].protection - 1
                        objects2[objects_to_manage2[objects_removed_it2]].asteroidImpact = true
                        love.audio.play(asteroidExplosionSound)


                        if (
                                objects2[objects_to_manage2[objects_removed_it2]].asteroidDivision < 1 and
                                objects2[objects_to_manage2[objects_removed_it2]].protection < 1) then
                            -- remove asteroid
                            table.remove(objects2, objects_to_manage2[objects_removed_it2]) -- remove objects from table
                            love.audio.play(asteroidExplosionSound)

                        end
                    end
                end
            end
        end
    end

    -- manage asteroids collisions (with vaisseau)
    if (
            objects[objects_to_manage[object_number]] ~= nil and
            objects2[objects_to_manage2[object_number2]] ~= nil) then
        for objects_removed_it = #objects_to_manage, 1, -1 do
            for objects_removed_it2 = #objects_to_manage2, 1, -1 do
                if (
                        objects[objects_to_manage[object_number]].nameInstance == "VAISSEAU" and
                        objects2[objects_to_manage2[object_number2]].nameInstance == "ASTEROID") then
                    if (objects[objects_to_manage[object_number]].protection > 0) then
                        objectBounce(objects, objects2)
                        if (objects[objects_to_manage[object_number]].timeShieldStart < objects[objects_to_manage[object_number]].TIME_SHIELD_START_MAX) then
                        else
                            objects[objects_to_manage[object_number]].protection = objects[
                                objects_to_manage[object_number]]
                                .protection - 1
                            love.audio.play(vaisseauImpactSound)
                        end
                        objects[objects_to_manage[object_number]].vaisseauImpact = true
                        love.audio.play(vaisseauImpactSound)
                    else
                        table.remove(objects, objects_to_manage[objects_removed_it]) -- remove vaisseaux from table
                        gameOver = true
                        return gameOver
                    end
                end
            end
        end
    end

    -- manage bonus collisions (with vaisseau)
    if (
            objects[objects_to_manage[object_number]] ~= nil and
            objects2[objects_to_manage2[object_number2]] ~= nil) then
        for objects_removed_it = #objects_to_manage, 1, -1 do
            for objects_removed_it2 = #objects_to_manage2, 1, -1 do
                if (
                        objects[objects_to_manage[object_number]].nameInstance == "VAISSEAU" and
                        objects2[objects_to_manage2[object_number2]].nameInstance == "BONUS") then
                    if (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_PKG_MUCH_QUICKER or objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_PKG_QUICKER) then
                        if (objects[objects_to_manage[object_number]].missilePackQuicker == objects[objects_to_manage[object_number]].MSL_PKG_QUICKER) then
                            objects[objects_to_manage[object_number]].missilePackQuicker = objects
                            [objects_to_manage[object_number]].MSL_PKG_MUCH_QUICKER
                        elseif (objects[objects_to_manage[object_number]].missilePackQuicker == objects[objects_to_manage[object_number]].MSL_PKG_STD) then
                            objects[objects_to_manage[object_number]].missilePackQuicker = objects
                            [objects_to_manage[object_number]].MSL_PKG_QUICKER
                        end
                    end
                    if (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_PKG_MUCH_BIGGER or (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_PKG_BIGGER)) then
                        if (objects[objects_to_manage[object_number]].missilePackBigger == objects[objects_to_manage[object_number]].MSL_PKG_BIGGER) then
                            objects[objects_to_manage[object_number]].missilePackBigger = objects
                            [objects_to_manage[object_number]].MSL_PKG_MUCH_BIGGER
                        elseif (objects[objects_to_manage[object_number]].missilePackBigger == objects[objects_to_manage[object_number]].MSL_PKG_STD) then
                            objects[objects_to_manage[object_number]].missilePackBigger = objects
                            [objects_to_manage[object_number]].MSL_PKG_BIGGER
                        end
                    end
                    if (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_PKG_MUCH_LATERAL or objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_PKG_LATERAL) then
                        if (objects[objects_to_manage[object_number]].missilePackLateral == objects[objects_to_manage[object_number]].MSL_PKG_LATERAL) then
                            objects[objects_to_manage[object_number]].missilePackLateral = objects
                            [objects_to_manage[object_number]].MSL_PKG_MUCH_LATERAL
                        elseif (objects[objects_to_manage[object_number]].missilePackLateral == objects[objects_to_manage[object_number]].MSL_PKG_STD) then
                            objects[objects_to_manage[object_number]].missilePackLateral = objects
                            [objects_to_manage[object_number]].MSL_PKG_LATERAL
                        end
                    end
                    if (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_LASER_SIGHT) then
                        objects[objects_to_manage[object_number]].missileLaserSight = objects
                        [objects_to_manage[object_number]].MSL_LASER_SIGHT
                    end
                    if (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].SHIELD) then
                        objects[objects_to_manage[object_number]].activateShield()
                    end
                    if (objects2[objects_to_manage2[object_number2]].bonus == objects2[objects_to_manage2[object_number2]].MSL_SINUS) then
                        objects[objects_to_manage[object_number]].missileSinus = objects
                        [objects_to_manage[object_number]].MSL_SINUS
                    end
                    table.remove(objects2, objects_to_manage2[objects_removed_it2]) -- remove bonus from table
                end
            end
        end
    end

    -- manage missiles exit screen
    local missiles_to_remove = {}
    local missile_number = 0
    for missiles_it = 1, #objects do
        if (objects[missiles_it].nameInstance == "MISSILE") then
            if (objects[missiles_it].missile_lost()) then -- save missile numbers to remove
                missile_number = missile_number + 1
                missiles_to_remove[missile_number] = missiles_it
            end
        end
    end
    for missiles_removed_it = #missiles_to_remove, 1, -1 do
        table.remove(objects, missiles_to_remove[missiles_removed_it]) -- remove missiles from table
    end

    -- manage time life of Bonus
    local bonuss_to_remove = {}
    local bonus_number = 0
    for bonuss_it = 1, #objects do
        if (objects[bonuss_it].nameInstance == "BONUS") then
            if (objects[bonuss_it].checkLifeTimeFinished()) then -- save bonus numbers to remove
                bonus_number = bonus_number + 1
                bonuss_to_remove[bonus_number] = bonuss_it
            end
        end
    end
    for bonuss_removed_it = #bonuss_to_remove, 1, -1 do
        table.remove(objects, bonuss_to_remove[bonuss_removed_it]) -- remove bonus from table
    end
end
