require("utils")

local KEY_TIMER_LIMIT = 10               -- tempo key push
local updateTimer = 0
local weaponCycleLateral = 0
local weaponCycleBigger = 0
local weaponCycleQuicker = 0

local key_Pulse = false
local keyPressed = false
local keyPressedDebug = false
local keyPressedDebug2 = false
local shoot_Pulse = false
local shootMachineGun_Pulse = false
local shootMuchMachineGun_Pulse = false

local keyTimerCounter = 0
local shootTimerCounter = 0
local shootMachineGunTimerCounter = 0
local shootMuchMachineGunTimerCounter = 0

function timerPulse(dt, updateTimerCounterSpecific, timerLimit)
    updateTimerCounterSpecific = updateTimerCounterSpecific + (60*dt)
    if (updateTimerCounterSpecific > timerLimit) then
        return 0 , true
    else
        return updateTimerCounterSpecific  , false
    end
end

function timerUpdate(dt, vaisseaux)
    -- updateTimer = updateTimer + (1+dt)

    keyTimerCounter, key_Pulse = timerPulse(dt, keyTimerCounter, KEY_TIMER_LIMIT)

    if (vaisseaux[1] ~= nil) then
        shootTimerCounter, shoot_Pulse = timerPulse(dt, shootTimerCounter,
            vaisseaux[1].SHOOT_TIMER_LIMIT)
        shootMachineGunTimerCounter, shootMachineGun_Pulse = timerPulse(dt,
            shootMachineGunTimerCounter, vaisseaux[1].SHOOT_MACHINE_GUN_TIMER_LIMIT)
        shootMuchMachineGunTimerCounter, shootMuchMachineGun_Pulse = timerPulse(dt,
            shootMuchMachineGunTimerCounter, vaisseaux[1].SHOOT_MUCH_MACHINE_GUN_TIMER_LIMIT)
    end
 end

function keyboardMenuUpdate(DEBUG_MODE, menu, toggleDebug)
    local menuSize = tableLength(menu.menuValues)

    if (menu.positionMenu > menuSize) then
        menu.positionMenu = 1
    elseif (menu.positionMenu < 1) then
        menu.positionMenu = menuSize
    end

    -- MENU KEYBOARD UPDATE
    if love.keyboard.isDown("up") then
        if not keyPressed then
            menu.positionMenu = menu.positionMenu - 1
            keyPressed = true
        end
    elseif love.keyboard.isDown("down") then
        if not keyPressed then
            menu.positionMenu = menu.positionMenu + 1
            keyPressed = true
        end
    else
        keyPressed = false
    end

    if love.keyboard.isDown("space") then
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.START]) then
            menu.selectionMenu = menu.menuValues[menu.START]
        end
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.TUTO]) then
            menu.selectionMenu = menu.menuValues[menu.TUTO]
        end
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.TOGGLE_DEBUG]) then
            if not keyPressedDebug then
                if (toggleDebug == true) then
                    toggleDebug = false
                    keyPressedDebug = true
                else
                    toggleDebug = true
                    keyPressedDebug = true
                end
            end
        end
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.CREDITS]) then
            menu.selectionMenu = menu.menuValues[menu.CREDITS]
            creditsSound = love.audio.newSource("music/retro-wave-style-track-59892.mp3", "stream")
            creditsSound:setVolume(0.4)
            love.audio.play(creditsSound)
        end
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.QUIT]) then
            love.event.quit()
        end
    else
        keyPressedDebug = false
    end
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    return DEBUG_MODE, toggleDebug
end

function keyboardUpdate(vaisseaux, missiles, DEBUG_MODE, menu, level, toggleDebug, dt)
    if love.keyboard.isDown("q") then -- restart game
        love.audio.stop(gameSound)
        menu.selectionMenu = menu.MENU
        level.levelNumber = 0
        level.levelDone = false

        love.load()
        love.update(dt)
    end

    -- reactor and smoke update
        vaisseaux[1].updatePropulsor(dt)

    -- shield update
    if (vaisseaux[1].timeShieldStart < vaisseaux[1].TIME_SHIELD_START_MAX) then
        vaisseaux[1].updatePrintWarningStartLevel(dt)
    end
    -- VAISSEAU KEYBOARD UPDATE
    if (vaisseaux[1] ~= nil) then
        if love.keyboard.isDown("right") then
            vaisseaux[1].rotate(true, dt)
        elseif love.keyboard.isDown("left") then
            vaisseaux[1].rotate(false, dt)
        else
            vaisseaux[1].rotateRightorLeft = "neutral"
        end
        if love.keyboard.isDown("up") then
            vaisseaux[1].accelerate(dt,vaisseaux[1].acceleration, vaisseaux[1].accelerationMax)
        elseif love.keyboard.isDown("down") then
            vaisseaux[1].accelerateBack(dt,vaisseaux[1].acceleration, vaisseaux[1].accelerationMax)
        elseif love.keyboard.isDown("s") then
            vaisseaux[1].accelerateBack(dt, 0, 0.1)
            vaisseaux[1].accelerateFWorWW = "neutral"
        else
            vaisseaux[1].accelerateFWorWW = "neutral"
        end

        if (toggleDebug == true) then
            if love.keyboard.isDown("d") then
                if not keyPressed then
                    if DEBUG_MODE == true then
                        DEBUG_MODE = false
                    elseif DEBUG_MODE == false then
                        DEBUG_MODE = true
                    end
                    keyPressed = true
                end
            elseif love.keyboard.isDown("w") then
                if not keyPressed then
                    if (weaponCycleLateral == 0) then vaisseaux[1].missilePackLateral = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleLateral == 1) then vaisseaux[1].missilePackLateral = vaisseaux[1].MSL_PKG_LATERAL end
                    if (weaponCycleLateral == 2) then vaisseaux[1].missilePackLateral = vaisseaux[1]
                        .MSL_PKG_MUCH_LATERAL end
                    weaponCycleLateral = weaponCycleLateral + 1
                    if (weaponCycleLateral > 2) then weaponCycleLateral = 0 end
                    keyPressed = true
                end
            elseif love.keyboard.isDown("x") then
                if not keyPressed then
                    if (weaponCycleBigger == 0) then vaisseaux[1].missilePackBigger = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleBigger == 1) then vaisseaux[1].missilePackBigger = vaisseaux[1].MSL_PKG_BIGGER end
                    if (weaponCycleBigger == 2) then vaisseaux[1].missilePackBigger = vaisseaux[1].MSL_PKG_MUCH_BIGGER end
                    weaponCycleBigger = weaponCycleBigger + 1
                    if (weaponCycleBigger > 2) then weaponCycleBigger = 0 end
                    keyPressed = true
                end
            elseif love.keyboard.isDown("c") then
                if not keyPressed then
                    if (weaponCycleQuicker == 0) then vaisseaux[1].missilePackQuicker = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleQuicker == 1) then vaisseaux[1].missilePackQuicker = vaisseaux[1].MSL_PKG_QUICKER end
                    if (weaponCycleQuicker == 2) then vaisseaux[1].missilePackQuicker = vaisseaux[1]
                        .MSL_PKG_MUCH_QUICKER end
                    weaponCycleQuicker = weaponCycleQuicker + 1
                    if (weaponCycleQuicker > 2) then weaponCycleQuicker = 0 end
                    keyPressed = true
                end
            elseif love.keyboard.isDown("v") then
                if not keyPressed then
                    if (weaponCycleQuicker == 0) then vaisseaux[1].missileLaserSight = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleQuicker == 1) then vaisseaux[1].missileLaserSight = vaisseaux[1].MSL_LASER_SIGHT end
                    weaponCycleQuicker = weaponCycleQuicker + 1
                    if (weaponCycleQuicker > 1) then weaponCycleQuicker = 0 end
                    keyPressed = true
                end
            elseif love.keyboard.isDown("b") then
                if not keyPressed then
                    if (weaponCycleQuicker == 0) then vaisseaux[1].missileSinus = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleQuicker == 1) then vaisseaux[1].missileSinus = vaisseaux[1].MSL_SINUS end
                    weaponCycleQuicker = weaponCycleQuicker + 1
                    if (weaponCycleQuicker > 1) then weaponCycleQuicker = 0 end
                    keyPressed = true
                end
            elseif love.keyboard.isDown("n") then
                if not keyPressed then
                    if (weaponCycleQuicker == 0) then vaisseaux[1].shield = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleQuicker == 1) then
                        -- vaisseaux[1].shield = vaisseaux[1].SHIELD
                        vaisseaux[1].activateShield()
                    end
                    weaponCycleQuicker = weaponCycleQuicker + 1
                    if (weaponCycleQuicker > 1) then weaponCycleQuicker = 0 end
                    keyPressed = true
                end
            else
                keyPressed = false
            end
        end

        -- Manage timer of shoot
        local shoot_timer_pulse_to_use = shoot_Pulse
        if (vaisseaux[1].missilePackQuicker == vaisseaux[1].MSL_PKG_QUICKER) then
            shoot_timer_pulse_to_use = shootMachineGun_Pulse
        elseif (vaisseaux[1].missilePackQuicker == vaisseaux[1].MSL_PKG_MUCH_QUICKER) then
            shoot_timer_pulse_to_use = shootMuchMachineGun_Pulse
        end

        local missileType = { vaisseaux[1].MSL_PKG_STD, vaisseaux[1].missilePackBigger, vaisseaux[1].missilePackQuicker,
            vaisseaux[1].missileSinus }

        if love.keyboard.isDown("space") then
            if (shoot_timer_pulse_to_use) then
                if (vaisseaux[1].missilePackLateral == vaisseaux[1].MSL_PKG_STD) then
                    love.audio.stop(shootSound)
                    local missile = vaisseaux[1].shoot(missileType)
                    table.insert(missiles, missile)
                    love.audio.play(shootSound)
                end
                if (vaisseaux[1].missilePackLateral == vaisseaux[1].MSL_PKG_LATERAL) then
                    love.audio.stop(shootSound)
                    missileType = { vaisseaux[1].LEFT, vaisseaux[1].missilePackBigger, vaisseaux[1].missilePackQuicker,
                        vaisseaux[1].missileSinus }
                    local missile = vaisseaux[1].shoot(missileType)
                    table.insert(missiles, missile)
                    missileType = { vaisseaux[1].RIGHT, vaisseaux[1].missilePackBigger, vaisseaux[1].missilePackQuicker,
                        vaisseaux[1].missileSinus }
                    missile = vaisseaux[1].shoot(missileType)
                    table.insert(missiles, missile)
                    love.audio.play(shootSound)
                end
                if (vaisseaux[1].missilePackLateral == vaisseaux[1].MSL_PKG_MUCH_LATERAL) then
                    love.audio.stop(shootSound)
                    missileType = { vaisseaux[1].MSL_PKG_STD, vaisseaux[1].missilePackBigger, vaisseaux[1]
                        .missilePackQuicker, vaisseaux[1].missileSinus }
                    local missile = vaisseaux[1].shoot(missileType)
                    table.insert(missiles, missile)
                    missileType = { vaisseaux[1].LEFT, vaisseaux[1].missilePackBigger, vaisseaux[1].missilePackQuicker,
                        vaisseaux[1].missileSinus }
                    missile = vaisseaux[1].shoot(missileType)
                    table.insert(missiles, missile)
                    missileType = { vaisseaux[1].RIGHT, vaisseaux[1].missilePackBigger, vaisseaux[1].missilePackQuicker,
                        vaisseaux[1].missileSinus }
                    missile = vaisseaux[1].shoot(missileType)
                    table.insert(missiles, missile)
                    love.audio.play(shootSound)
                end
            end
        end

        vaisseaux[1].move(dt)
    end
    return DEBUG_MODE
end

function asteroidsUpdate(dt, asteroids)
    for asteroids_it = 1, #asteroids do
        asteroids[asteroids_it].move(dt)
        -- asteroids[asteroids_it].rotate(asteroids[asteroids_it].CLOCKWISE, asteroids[asteroids_it].MANEUVERABILITY, dt)
        asteroids[asteroids_it].rotate(asteroids[asteroids_it].CLOCKWISE, dt)
    end
end

function missilesUpdate(dt, vaisseaux, missiles)
    for missiles_it = 1, #missiles do
        missiles[missiles_it].accelerate(dt, vaisseaux[1].missileAcceleration, vaisseaux[1].missileAccelerationMax)
        missiles[missiles_it].move(dt)
    end
end
