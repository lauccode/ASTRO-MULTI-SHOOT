Menu = {}
Menu.new = function()
    local self = {}

    self.START = 1
    self.TUTO = 2
    self.TOGGLE_DEBUG = 3
    self.CREDITS = 4
    self.QUIT = 5
    self.menuValues = { "START", "SHORTCUTS AND BONUS", "TOGGLE DEBUG", "CREDITS", "QUIT" }

    self.MENU = "menu"
    self.GAMEOVER = "gameover"
    self.CONGRATULATION = "congratulation"
    self.positionMenu = 1
    self.PRESENT_STAGE = "present stage"
    self.isPresentStageDone = false

    local offsetPrintCreditsStart = 0
    local offsetPrintCreditsEnd = 0
    local offsetPrintCredits = offsetPrintCreditsStart
    local horizontalTitlePosition = 15
    local verticalTitlePosition = -100
    local gravity = 10 / 60
    local verticalAcceleration = gravity
    local finalTitlePosition = 60
    local updateTitleReboundFinished = false
    local reboundTimer = 0
    self.timerPresentStage = 1

    self.selectionMenu = self.MENU

    local function ratioPosition(timer, timeOfmove)
        timer = timer % timeOfmove
        return (math.sin((math.pi / (2 * timeOfmove)) * timer))
    end

    local function drawParticlesTS(particlesTransitionStage)
        particlesTransitionStage:setParticleLifetime(3, 3) -- Particles live at least 3s and at most 3s.
        particlesTransitionStage:setEmissionRate(150)
        particlesTransitionStage:setSizeVariation(1)
        particlesTransitionStage:setLinearAcceleration(-30, -30, 30, 30)     -- Random movement in all directions.
        particlesTransitionStage:setSpeed(100, 500)                          -- min,max
        particlesTransitionStage:setSizes(1, 0.1)
        particlesTransitionStage:setDirection((2 * math.pi) * math.random()) -- radians

        love.graphics.draw(particlesTransitionStage, SCREEN_WIDTH * 0.5, SCREEN_HIGH * 0.5)
    end

    function self.updatePresentStage(dt)
        self.timerPresentStage   = self.timerPresentStage + (dt*60)
	end
    
    function self.presentStage(levelNumberForMenu, particlesTransitionStage)
        local X_text_position    = 1
        local timeMove           = 120 -- 2 sec
        local textStartS1        = ((3 * SCREEN_WIDTH) / 4)
        local textArrivedS1      = (SCREEN_WIDTH / 4)
        local textDistanceMoveS1 = ((3 * SCREEN_WIDTH) / 4)
        local textStartS2        = textArrivedS1
        local textArrivedS2      = 0
        local textDistanceMoveS2 = 4 * ((SCREEN_WIDTH) / 4)

        particlesTransitionStage = drawParticlesTS(particlesTransitionStage)

        love.graphics.setColor(255, 0, 0) -- red
        if (self.timerPresentStage < timeMove) then
            X_text_position = textArrivedS1 + textStartS1 -
                ((ratioPosition(self.timerPresentStage, timeMove) * textDistanceMoveS1))
        elseif (self.timerPresentStage >= timeMove and self.timerPresentStage < timeMove * 2) then
            X_text_position = textArrivedS1
        elseif (self.timerPresentStage >= timeMove * 2 and self.timerPresentStage < timeMove * 3) then
            X_text_position = textArrivedS2 + textStartS2 -
                ((ratioPosition(self.timerPresentStage, timeMove) * textDistanceMoveS2))
        elseif (self.timerPresentStage >= timeMove * 3) then
            self.timerPresentStage = 1
            X_text_position = textArrivedS1 + textStartS1 -
                ((ratioPosition(self.timerPresentStage, timeMove) * textDistanceMoveS1))
        end

        if (levelNumberForMenu == 1) then
            love.graphics.print("YOU WILL START STAGE " .. tostring(levelNumberForMenu), X_text_position, SCREEN_HIGH / 3)
        else
            love.graphics.print(
                "STAGE " ..
                tostring(levelNumberForMenu - 1) .. " CLEAR - PREPARE TO STAGE " .. tostring(levelNumberForMenu),
                X_text_position, SCREEN_HIGH / 3)
        end
        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 10)
        love.graphics.setFont(font)
        love.graphics.print("Press 's' to start when you are ready to fight", SCREEN_WIDTH / 4, SCREEN_HIGH / 3 + 30)
        love.graphics.setColor(255, 255, 255, 255) -- reset
    end

    function self.updateTitleRebound(dt)
        if (reboundTimer < 17) then
            reboundTimer = reboundTimer + dt
            if ((verticalTitlePosition + verticalAcceleration*60*dt)> finalTitlePosition) then
                verticalAcceleration = -verticalAcceleration * 0.9
            else
                verticalAcceleration = verticalAcceleration + gravity*60*dt
            end
            verticalTitlePosition = verticalTitlePosition + verticalAcceleration*60*dt
            updateTitleReboundFinished = false
        else
            updateTitleReboundFinished = true
        end
    end

    local function menuItemDraw(positionMenu,expectedMenu, offsetPrint)
        local OFF_SET_PRINT_DRAW = 12
        local menuItem = self.menuValues[expectedMenu]
        local locked = (positionMenu == expectedMenu) and true or false

        if (locked == true) then
            love.graphics.setColor(255, 0, 0)          -- red
            love.graphics.print("> " .. tostring(menuItem), SCREEN_WIDTH / 2, SCREEN_HIGH / 2 + offsetPrint)
            love.graphics.setColor(255, 255, 255, 255) -- reset
        else
            love.graphics.print("  " .. tostring(menuItem), SCREEN_WIDTH / 2, SCREEN_HIGH / 2 + offsetPrint)
        end
        offsetPrint = offsetPrint + OFF_SET_PRINT_DRAW
        return offsetPrint
    end

    local function menuItemDrawToggle(positionMenu,expectedMenu, offsetPrint, toggleDebug)
        local OFF_SET_PRINT_DRAW = 12
        local menuItem = self.menuValues[expectedMenu]
        local locked = (positionMenu == expectedMenu) and true or false

        if (locked == true) then
            love.graphics.setColor(255, 0, 0)          -- red
            love.graphics.print("> ".. tostring(menuItem) , SCREEN_WIDTH / 2,
                SCREEN_HIGH / 2 + offsetPrint)
            if(toggleDebug == true) then
                love.graphics.setColor(0, 255, 0) -- green
            else
                love.graphics.setColor(255, 0, 0) -- red
            end
            love.graphics.print("" .. tostring(toggleDebug), (SCREEN_WIDTH+260) / 2,
                SCREEN_HIGH / 2 + offsetPrint)
            love.graphics.setColor(255, 255, 255, 255) -- reset
        else
            love.graphics.print("  ".. tostring(menuItem) , SCREEN_WIDTH / 2,
                SCREEN_HIGH / 2 + offsetPrint)
            if(toggleDebug == true) then
                love.graphics.setColor(0, 255, 0) -- green
            else
                love.graphics.setColor(255, 0, 0) -- red
            end
            love.graphics.print("" .. tostring(toggleDebug), (SCREEN_WIDTH+260) / 2,
                SCREEN_HIGH / 2 + offsetPrint)
            love.graphics.setColor(255, 255, 255, 255) -- reset
        end

        offsetPrint = offsetPrint + OFF_SET_PRINT_DRAW
        return offsetPrint
    end

    function self.draw(toggleDebug)
        local offsetPrint = -50
        local OFF_SET_PRINT_DRAW = 12

        MenuPng = love.graphics.newImage("backgroud/background_vaisseau-512x512.png")
        love.graphics.draw(MenuPng, 0, 0, 0)

        -- TODO: add projectX effect
        -- if rebound finished, add missile image to know calculation is stopped
        TitlePng = love.graphics.newImage("sprites/title.png")
        if(updateTitleReboundFinished) then
            MissilePng = love.graphics.newImage("sprites/missile.png")
            local xMsgPosition = horizontalTitlePosition + TitlePng:getWidth() + 20
            local yMsgPosition = verticalTitlePosition + (TitlePng:getHeight() / 2) - MissilePng:getHeight() / 2
            love.graphics.draw(MissilePng, xMsgPosition, yMsgPosition, 0, 7 / 10, 7 / 10)
        end
        love.graphics.draw(TitlePng, horizontalTitlePosition, verticalTitlePosition, 0)
        offsetPrint = offsetPrint + OFF_SET_PRINT_DRAW * 4

        -- keep to debug updateTitleReboundFinished
        -- love.graphics.print("Vertical acceleration : " .. tostring(verticalAcceleration), 50, 50)
        -- love.graphics.print("Rebound time          : " .. tostring(reboundTimer), 50, 60)

        offsetPrint = menuItemDraw(self.positionMenu, self.START, offsetPrint)
        offsetPrint = menuItemDraw(self.positionMenu ,self.TUTO, offsetPrint)
        offsetPrint = menuItemDrawToggle(self.positionMenu ,self.TOGGLE_DEBUG, offsetPrint, toggleDebug)
        offsetPrint = menuItemDraw(self.positionMenu , self.CREDITS, offsetPrint)
        offsetPrint = menuItemDraw(self.positionMenu , self.QUIT, offsetPrint)

        offsetPrint = offsetPrint + OFF_SET_PRINT_DRAW

        local font = love.graphics.newFont("fonts/VT323/VT323-Regular.ttf", 12)
        love.graphics.setFont(font)
        love.graphics.print("( UP and DOWN arrow to move and space to select )", SCREEN_WIDTH / 2,
            SCREEN_HIGH / 2 + offsetPrint)
        love.graphics.print("( UP and DOWN arrow to move and space to select )", SCREEN_WIDTH / 2,
            SCREEN_HIGH / 2 + offsetPrint)
    end

    function self.updateResetOffsetPrintCreditsStart(dt)
        offsetPrintCreditsStart = offsetPrintCreditsStart - (0.5*dt*60)
        if (offsetPrintCreditsEnd < -(SCREEN_HIGH)) then
            offsetPrintCreditsStart = 0
        end
    end

    local function printNextCredit(stringToPrint, setRedColor)
        local OFF_SET_PRINT_CREDITS = 10
        local HORIZONTAL_POSITION = 50
        setRedColor = setRedColor or false
        if (setRedColor) then
            love.graphics.setColor(255 / 255, 165 / 255, 0 / 255) -- orange
            love.graphics.print(stringToPrint, HORIZONTAL_POSITION, SCREEN_HIGH + offsetPrintCredits)
            love.graphics.setColor(255, 255, 255, 255)            -- reset
        else
            love.graphics.print(stringToPrint, HORIZONTAL_POSITION, SCREEN_HIGH + offsetPrintCredits)
        end
        offsetPrintCredits = offsetPrintCredits + OFF_SET_PRINT_CREDITS
    end

    function self.creditsDraw()
        offsetPrintCredits = offsetPrintCreditsStart

        printNextCredit("********************************* CREDITS ***********************************", true)
        printNextCredit("******************************  (q) to quit *********************************", true)
        printNextCredit("")

        printNextCredit("V Music For level 1", true)
        printNextCredit("Titre:  Starcade")
        printNextCredit("Auteur: Blue Navi")
        printNextCredit("Source: https://soundcloud.com/blue-navi")
        printNextCredit("Licence: https://creativecommons.org/licenses/by-sa/3.0/deed.fr")
        printNextCredit("Téléchargement: https://www.auboutdufil.com")
        printNextCredit("")

        printNextCredit("V Music For level 2", true)
        printNextCredit("Titre:  Reset")
        printNextCredit("Auteur: Jaunter")
        printNextCredit("Source: https://jaunter.bandcamp.com")
        printNextCredit("Licence: https://creativecommons.org/licenses/by/3.0/")
        printNextCredit("Téléchargement: https://www.auboutdufil.com")
        printNextCredit("")

        printNextCredit("V Music For level 3", true)
        printNextCredit("Titre:  Les Champs Etoilés")
        printNextCredit("Auteur: Karol Piczak")
        printNextCredit("Source: https://soundcloud.com/karol-piczak")
        printNextCredit("Licence: https://creativecommons.org/licenses/by/3.0/deed.fr")
        printNextCredit("Téléchargement: https://www.auboutdufil.com")
        printNextCredit("")

        printNextCredit("V Music For level 4", true)
        printNextCredit("Titre:  Cascade")
        printNextCredit("Auteur: Kubbi")
        printNextCredit("Source: http://www.kubbimusic.com/")
        printNextCredit("Licence: https://creativecommons.org/licenses/by-sa/3.0/deed.fr")
        printNextCredit("Téléchargement: https://www.auboutdufil.com")
        printNextCredit("")

        printNextCredit("V Music For level 5", true)
        printNextCredit("Titre:  I Can't Stop")
        printNextCredit("Auteur: Punch Deck")
        printNextCredit("Source: https://soundcloud.com/punch-deck")
        printNextCredit("Licence: https://creativecommons.org/licenses/by/4.0/deed.fr")
        printNextCredit("Téléchargement: https://www.auboutdufil.com")
        printNextCredit("")

        printNextCredit("V Music For level 6", true)
        printNextCredit("Titre:  Dystopia")
        printNextCredit("Auteur: Luke Hall")
        printNextCredit("Source: https://soundcloud.com/c_luke_hall")
        printNextCredit("Licence: https://creativecommons.org/licenses/by-sa/3.0/deed.fr")
        printNextCredit("Téléchargement: https://www.auboutdufil.com")
        printNextCredit("")

        printNextCredit("V Music For Credits", true)
        printNextCredit("retro-wave-style-track-59892.mp3")
        printNextCredit("Sound Effect from https://pixabay.com/sound-effects/retro-wave-style-track-59892/")
        printNextCredit("Pixabay license://pixabay.com/sound-effects/retro-wave-style-track-59892/")
        printNextCredit("")

        printNextCredit("V explosion_asteroid-101886.mp3", true)
        printNextCredit("Sound Effect from https://pixabay.com/sound-effects/explosion-asteroid-101886/")
        printNextCredit("Pixabay license://pixabay.com/sound-effects/retro-wave-style-track-59892/")
        printNextCredit("")

        printNextCredit("V 8-bit-cannon-fire-96505.mp3", true)
        printNextCredit("Sound Effect from https://pixabay.com/sound-effects/8-bit-cannon-fire-96505/")
        printNextCredit("Pixabay license://pixabay.com/sound-effects/retro-wave-style-track-59892/")
        printNextCredit("")

        printNextCredit("V hurt_c_08-102842.mp3", true)
        printNextCredit("Sound Effect from https://pixabay.com/sound-effects/hurt-c-08-102842/")
        printNextCredit("Pixabay license://pixabay.com/sound-effects/retro-wave-style-track-59892/")
        printNextCredit("")

        printNextCredit("V BACKGROUNDS", true)
        printNextCredit("Backgrounds are coming from :")
        printNextCredit("https://screamingbrainstudios.itch.io/seamless-space-backgrounds")
        printNextCredit("")

        printNextCredit("V FONTS", true)
        printNextCredit("Heavy Data is developed by Vic Fieger")
        printNextCredit("  Licence : Vic Fieger License.")
        printNextCredit("VT323 is developed by Peter Hull")
        printNextCredit("  Licence : SIL Open Font License, Version 1.1 License.")

        offsetPrintCreditsEnd = offsetPrintCredits
    end

    function self.gameover()
        local HORIZONTAL_GOVER_POSITION = 0
        local VERTICAL_POSITION = 140
        local OFF_SET_PRINT_GAMEOVER = 10
        local offsetPrintGameOver = 0


        local loseGamePng = love.graphics.newImage("backgroud/lose512x512.png")
		love.graphics.draw(loseGamePng, 0, 0, 0)

        love.graphics.print("******************* GAMEOVER **************************", HORIZONTAL_GOVER_POSITION,
            VERTICAL_POSITION + offsetPrintGameOver)
        offsetPrintGameOver = offsetPrintGameOver + OFF_SET_PRINT_GAMEOVER
        love.graphics.print("*******************************************************", HORIZONTAL_GOVER_POSITION,
            VERTICAL_POSITION + offsetPrintGameOver)
        offsetPrintGameOver = offsetPrintGameOver + OFF_SET_PRINT_GAMEOVER
        love.graphics.print("*********** Press 'R' to restart and continue **********", HORIZONTAL_GOVER_POSITION,
            VERTICAL_POSITION + offsetPrintGameOver)
        offsetPrintGameOver = offsetPrintGameOver + OFF_SET_PRINT_GAMEOVER
    end

    function self.shortcutsAndBonus()
        local HORIZONTAL_SHORTCUT_POSITION = 50
        local VERTICAL_POSITION = 20
        local OFF_SET_PRINT_SHORTCUTS = 10
        local OffsetPrintBonus = 0
        local xBonusPosition = 0
        local yBonusPosition = 0

        love.graphics.print("********************************* Shortcuts And Bonus **************************",
            HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 3

        love.graphics.setColor(255 / 255, 165 / 255, 0 / 255) -- orange
        love.graphics.print("**** SHORTCUTS during the game *************", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        love.graphics.print("UP ARROW       to go forward", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.print("DOWN ARROW     to go backward", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.print("LEFT ARROW     to turn left", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.print("RIGHT ARROW    to turn right", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.print("SPACE          to fire", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.print("(s)            to stop the ship", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.print("(q)            to go back menu", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        love.graphics.setColor(255 / 255, 165 / 255, 0 / 255) -- orange
        love.graphics.print("**** SHORTCUTS if debug mode activated *****", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2
        love.graphics.print("(d) activate/desactivate debug game information", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("In red for BONUS, the key to press in debug mode to activate/desactivate the BONUS",
            HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 4

        love.graphics.setColor(255 / 255, 165 / 255, 0 / 255) -- orange
        love.graphics.print("**** BONUS *****", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255)            -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        BonusPng = love.graphics.newImage("sprites/bonus_triple_shoot.png")
        xBonusPosition = HORIZONTAL_SHORTCUT_POSITION
        HORIZONTAL_SHORTCUT_POSITION = HORIZONTAL_SHORTCUT_POSITION + 25
        yBonusPosition = VERTICAL_POSITION + OffsetPrintBonus
        love.graphics.draw(BonusPng, xBonusPosition, yBonusPosition, 0, 1 / 3, 1 / 3)
        love.graphics.print("Side fire activated FIRST, main fire put back in SECOND", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("(w) to activate/desactivate in debug mode", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        BonusPng = love.graphics.newImage("sprites/bonus_increase_shoot.png")
        yBonusPosition = VERTICAL_POSITION + OffsetPrintBonus
        love.graphics.draw(BonusPng, xBonusPosition, yBonusPosition, 0, 1 / 3, 1 / 3)
        love.graphics.print("Missile size can be increased TWICE", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("(x) to activate/desactivate in debug mode", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        BonusPng = love.graphics.newImage("sprites/bonus_machine_gun_shoot.png")
        yBonusPosition = VERTICAL_POSITION + OffsetPrintBonus
        love.graphics.draw(BonusPng, xBonusPosition, yBonusPosition, 0, 1 / 3, 1 / 3)
        love.graphics.print("Rate of fire can be increased TWICE", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("(c) to activate/desactivate in debug mode", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        BonusPng = love.graphics.newImage("sprites/bonus_vise.png")
        yBonusPosition = VERTICAL_POSITION + OffsetPrintBonus
        love.graphics.draw(BonusPng, xBonusPosition, yBonusPosition, 0, 1 / 3, 1 / 3)
        love.graphics.print("Laser sight", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("(v) to activate/desactivate in debug mode", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        BonusPng = love.graphics.newImage("sprites/bonus_sinus_shoot.png")
        yBonusPosition = VERTICAL_POSITION + OffsetPrintBonus
        love.graphics.draw(BonusPng, xBonusPosition, yBonusPosition, 0, 1 / 3, 1 / 3)
        love.graphics.print("Shot with sinusoidal trajectory", HORIZONTAL_SHORTCUT_POSITION, VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("(b) to activate/desactivate in debug mode", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 2

        BonusPng = love.graphics.newImage("sprites/bonus_bouclier.png")
        yBonusPosition = VERTICAL_POSITION + OffsetPrintBonus
        love.graphics.draw(BonusPng, xBonusPosition, yBonusPosition, 0, 1 / 3, 1 / 3)
        love.graphics.print("Shield protection for limited time", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS
        love.graphics.setColor(255, 0, 0) -- red
        love.graphics.print("(n) to activate/desactivate in debug mode", HORIZONTAL_SHORTCUT_POSITION,
            VERTICAL_POSITION + OffsetPrintBonus)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        OffsetPrintBonus = OffsetPrintBonus + OFF_SET_PRINT_SHORTCUTS * 3

        love.graphics.print("***************************          (q) to quit          **********************",
            HORIZONTAL_SHORTCUT_POSITION - 25, VERTICAL_POSITION + OffsetPrintBonus)
    end

    function self.congratulation()
        local HORIZONTAL_CONGRAT_POSITION = 50
        local VERTICAL_POSITION = 90
        local OFF_SET_PRINT_CONGRAT = 10
        local offsetPrintWin = 0

        local winGamePng = love.graphics.newImage("backgroud/512x512_win.png")
		love.graphics.draw(winGamePng, 0, 0, 0)

        love.graphics.print("******************************************* CONGRATULATION **************************",
            HORIZONTAL_CONGRAT_POSITION, VERTICAL_POSITION + offsetPrintWin)
        offsetPrintWin = offsetPrintWin + OFF_SET_PRINT_CONGRAT
        love.graphics.print(
            "*********************************** You succeed to finish this small game   ***********************",
            HORIZONTAL_CONGRAT_POSITION, VERTICAL_POSITION + offsetPrintWin)
        offsetPrintWin = offsetPrintWin + OFF_SET_PRINT_CONGRAT
        love.graphics.print("***********************************Press 'R' to restart and continue **********", HORIZONTAL_CONGRAT_POSITION,
            VERTICAL_POSITION + offsetPrintWin)
        offsetPrintWin = offsetPrintWin + OFF_SET_PRINT_CONGRAT
    end

    return self
end
