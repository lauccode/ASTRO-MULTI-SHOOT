require("utils")

local KEY_TIMER_LIMIT = 10               -- tempo key push
local updateTimer = 0
local weaponCycleLateral = 0
local weaponCycleBigger = 0
local weaponCycleQuicker = 0
local weaponCycleLaserSight = 0
local weaponCycleSinus = 0
local weaponCycleShield = 0

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

local selectWeaponBar = 1

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

function keyboardMenuUpdate(DEBUG_MODE, menu, toggleDebug, creditsSound)
    local menuSize = tableLength(menu.menuValues)

    if (menu.positionMenu > menuSize) then
        menu.positionMenu = 1
    elseif (menu.positionMenu < 1) then
        menu.positionMenu = menuSize
    end

    -- MENU KEYBOARD UPDATE
    if love.keyboard.isDown("up") or gamepadIsDown('dpup') or gamepadAxisValue('lefty') < -0.5 then
        if not keyPressed then
            menu.positionMenu = menu.positionMenu - 1
            keyPressed = true
        end
    elseif love.keyboard.isDown("down") or gamepadIsDown('dpdown') or gamepadAxisValue('lefty') > 0.5 then
        if not keyPressed then
            menu.positionMenu = menu.positionMenu + 1
            keyPressed = true
        end
    else
        keyPressed = false
    end

    if love.keyboard.isDown("space") or gamepadIsDown('a') then
        menu.startUpdateTitleRebound()
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.START]) then
            menu.selectionMenu = menu.menuValues[menu.START]
        end
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.TUTO_PAD]) then
            menu.selectionMenu = menu.menuValues[menu.TUTO_PAD]
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
            creditsSound:setVolume(0.4)
            creditsSound:seek(0)  -- restart the sound from the beginning
            menu.startCredits() -- reset the credits scroll position
            love.audio.play(creditsSound)
        end
        if (menu.menuValues[menu.positionMenu] == menu.menuValues[menu.QUIT]) then
            love.event.quit()
        end
    else
        keyPressedDebug = false
    end

    if love.keyboard.isDown("escape")then
        love.event.quit()
    end
    return DEBUG_MODE, toggleDebug, creditsSound
end

function keyboardUpdate(vaisseaux, missiles, DEBUG_MODE, menu, level, toggleDebug, gameSound, shootSound, dt)
    if love.keyboard.isDown("q") or gamepadIsDown('guide') or gamepadIsDown('start') then -- restart game
        if gameSound ~= nil then
            love.audio.stop(gameSound)
        end
        menu.selectionMenu = menu.MENU
        level.levelNumber = 0
        level.levelDone = false

        love.load()
        love.update(dt)
    end

    -- reactor and smoke update
        vaisseaux[1].updatePropulsor(dt)

    -- shield update
    -- if (vaisseaux[1].timeShieldStart < vaisseaux[1].timeShieldStartMax) then
        vaisseaux[1].updatePrintWarningStartLevel(dt)
    -- end
    -- VAISSEAU KEYBOARD UPDATE
    if (vaisseaux[1] ~= nil) then
        -- rotation: right/left keys OR left stick horizontal OR dpad left/right
        if love.keyboard.isDown("right") or gamepadAxisValue('leftx') > 0.5 then
            vaisseaux[1].rotate(true, dt)
        elseif love.keyboard.isDown("left") or gamepadAxisValue('leftx') < -0.5 then
            vaisseaux[1].rotate(false, dt)
        else
            vaisseaux[1].rotateRightorLeft = "neutral"
        end
        -- forward/back: up/down keys OR triggers (right trigger = forward, left trigger = backward) OR left stick vertical OR dpad
        local rt = gamepadAxisValue('triggerright', 'righttrigger', 'rtrigger', 'triggerright')
        local lt = gamepadAxisValue('triggerleft', 'lefttrigger', 'ltrigger')
        if love.keyboard.isDown("up") or rt > 0.3 or gamepadAxisValue('lefty') < -0.5 then
            vaisseaux[1].accelerate(dt, vaisseaux[1].speed, vaisseaux[1].accelerationMax)
        elseif love.keyboard.isDown("down") or lt > 0.3 or gamepadAxisValue('lefty') > 0.5 then
            vaisseaux[1].accelerateBack(dt, vaisseaux[1].speed, vaisseaux[1].accelerationMax)
        elseif love.keyboard.isDown("s") or gamepadIsDown('leftshoulder') or gamepadIsDown('rightshoulder') then
            vaisseaux[1].accelerateBack(dt, 0, 0.1)
            vaisseaux[1].accelerateFWorWW = "neutral"
        else
            vaisseaux[1].accelerateFWorWW = "neutral"
        end

        if love.keyboard.isDown("c") or gamepadIsDown('dpright') then
            if not keyPressed then
                selectWeaponBar = selectWeaponBar + 1
                if selectWeaponBar > 6 then selectWeaponBar = 1 end
                vaisseaux[1].selectWeaponBar = selectWeaponBar
                keyPressed = true
            end
        elseif love.keyboard.isDown("w") or gamepadIsDown('dpleft') then
            if not keyPressed then
                selectWeaponBar = selectWeaponBar - 1
                if selectWeaponBar < 1 then selectWeaponBar = 6 end
                vaisseaux[1].selectWeaponBar = selectWeaponBar
                keyPressed = true
            end
        else
            keyPressed = false
        end

        if (toggleDebug == true) then
            if love.keyboard.isDown("d") or gamepadIsDown('dpdown') then
                if not keyPressed then
                    if DEBUG_MODE == true then
                        DEBUG_MODE = false
                    elseif DEBUG_MODE == false then
                        DEBUG_MODE = true
                    end
                    keyPressed = true
                end
            elseif selectWeaponBar == 1 and (love.keyboard.isDown("x") or gamepadIsDown('dpup')) then
                if not keyPressed then
                    weaponCycleLateral = weaponCycleLateral + 1
                    if (weaponCycleLateral > 2) then weaponCycleLateral = 0 end
                    if (weaponCycleLateral == 0) then vaisseaux[1].missilePackLateral = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleLateral == 1) then vaisseaux[1].missilePackLateral = vaisseaux[1].MSL_PKG_LATERAL end
                    if (weaponCycleLateral == 2) then vaisseaux[1].missilePackLateral = vaisseaux[1]
                        .MSL_PKG_MUCH_LATERAL end
                    keyPressed = true
                end
            elseif selectWeaponBar == 2 and (love.keyboard.isDown("x") or gamepadIsDown('dpup')) then
                if not keyPressed then
                    weaponCycleBigger = weaponCycleBigger + 1
                    if (weaponCycleBigger > 2) then weaponCycleBigger = 0 end
                    if (weaponCycleBigger == 0) then vaisseaux[1].missilePackBigger = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleBigger == 1) then vaisseaux[1].missilePackBigger = vaisseaux[1].MSL_PKG_BIGGER end
                    if (weaponCycleBigger == 2) then vaisseaux[1].missilePackBigger = vaisseaux[1].MSL_PKG_MUCH_BIGGER end
                    keyPressed = true
                end
            elseif selectWeaponBar == 3 and (love.keyboard.isDown("x") or gamepadIsDown('dpup')) then
                if not keyPressed then
                    weaponCycleQuicker = weaponCycleQuicker + 1
                    if (weaponCycleQuicker > 2) then weaponCycleQuicker = 0 end
                    if (weaponCycleQuicker == 0) then vaisseaux[1].missilePackQuicker = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleQuicker == 1) then vaisseaux[1].missilePackQuicker = vaisseaux[1].MSL_PKG_QUICKER end
                    if (weaponCycleQuicker == 2) then vaisseaux[1].missilePackQuicker = vaisseaux[1]
                        .MSL_PKG_MUCH_QUICKER end
                    keyPressed = true
                end
            elseif selectWeaponBar == 4 and (love.keyboard.isDown("x") or gamepadIsDown('dpup')) then
                if not keyPressed then
                    weaponCycleLaserSight = weaponCycleLaserSight + 1
                    if (weaponCycleLaserSight > 1) then weaponCycleLaserSight = 0 end
                    if (weaponCycleLaserSight == 0) then vaisseaux[1].missileLaserSight = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleLaserSight == 1) then vaisseaux[1].missileLaserSight = vaisseaux[1].MSL_LASER_SIGHT end
                    keyPressed = true
                end
            elseif selectWeaponBar == 5 and (love.keyboard.isDown("x") or gamepadIsDown('dpup')) then
                if not keyPressed then
                    weaponCycleSinus = weaponCycleSinus + 1
                    if (weaponCycleSinus > 1) then weaponCycleSinus = 0 end
                    if (weaponCycleSinus == 0) then vaisseaux[1].missileSinus = vaisseaux[1].MSL_PKG_STD end
                    if (weaponCycleSinus == 1) then vaisseaux[1].missileSinus = vaisseaux[1].MSL_SINUS end
                    keyPressed = true
                end
            elseif selectWeaponBar == 6 and (love.keyboard.isDown("x") or gamepadIsDown('dpup')) then
                if not keyPressed then
                    weaponCycleShield = weaponCycleShield + 1
                    if (weaponCycleShield > 1) then weaponCycleShield = 0 end
                    if (weaponCycleShield == 0) then vaisseaux[1].activateShield(false) end-- deactivate infinite shield
                    if (weaponCycleShield == 1) then vaisseaux[1].activateShield(true) end-- activate infinite shield
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

        if love.keyboard.isDown("space") or gamepadIsDown('a') then
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
    return DEBUG_MODE, gameSound
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
        missiles[missiles_it].accelerate(dt, vaisseaux[1].missileSpeedMax, vaisseaux[1].missileAccelerationMax)
        missiles[missiles_it].move(dt)
    end
end
