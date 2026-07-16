class("ScenarioManager").extends()

local Location = {
    KONBINI = 1,
    --TAXI = 2
}

local Actions = { --for now we can just make sure in the code to not select an action
    --that doesn't work with the current location I guess
    CHECKOUT = 1,
}

local ScenarioState = {
    INTERVAL = 1,
    INTRO = 2,
    --WALKIN = 3,
    GAMEPLAY = 4,
    OUTRO = 5
}

local Npc = {
    KONBINI_CLERK = 1
}


local pd = playdate
local gfx = pd.graphics

-- Player
local playerSprite = CharacterSprite(
    "images/player/playerBottom.png",
    "images/player/playerSpriteSheet-table-300-300",
    0)
local playerObj = Player(playerSprite, -100, 100, 3)
playerSprite:add()

-- Partner
local partnerSprite = CharacterSprite(
    "images/player/playerBottom.png",
    "images/player/playerSpriteSheet-table-300-300",
    130)
local partnerObj = Partner(partnerSprite, 590, 100, 3)
partnerSprite:add()

-- Main Menu
local mainMenu = gfx.image.new("images/UI_screens/MainMenu.png")


local currentLocation
local currentAction
local currentNpc
local currentState = ScenarioState.INTERVAL

local hasScenario

local timer = 0

local dt = 0

local bowTimeStamps = {}

local score = 0

function ScenarioManager:init()
    self.hasScenario = true
    self.currentState = ScenarioState.INTERVAL
end

function ScenarioManager:update()
    if self.currentState == nil then
        self.currentState = ScenarioState.INTERVAL
    end
    dt = playdate.getElapsedTime()
    playdate.resetElapsedTime()


    -- if hasScenario == false then
    --     --self.ConstructScenario()
    --     hasScenario = true
    -- end

    -- print(self.currentState)

    if self.currentState == ScenarioState.INTERVAL then
        mainMenu:draw(0, 0)
        -- gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)
        if pd.buttonJustPressed(pd.kButtonA) then
            self.currentState = ScenarioState.INTRO
        end
        --playdate.wait(1000)
        --self.currentState = ScenarioState.INTRO
    end

    if self.currentState == ScenarioState.INTRO then
        self:RunIntro()
    end

    if self.currentState == ScenarioState.GAMEPLAY then
        timer += dt
        --dummy ending for a scenario
        if timer > 20 then
            self.currentState = ScenarioState.OUTRO
        end
        --local crankPos = pd.getCrankPosition()
        playerObj:setBowFrameIndex(pd.getCrankPosition())

        gfx.drawTextAligned("Score: " .. score, 390, 1, kTextAlignment.right)
        gfx.drawTextAligned("Bows: " .. playerObj:getCurrentBowNum(), 240, 20, kTextAlignment.right)
        gfx.drawTextAligned("Lowest Bow Frame: " .. playerObj:getCurrentLowestBowFrame(), 240, 40, kTextAlignment.right)
        gfx.drawTextAligned("Bow Timer: " .. playerObj:getBowTimer(), 240, 60, kTextAlignment.right)
    end

    if self.currentState == ScenarioState.OUTRO then
        timer = 0
        self:RunOutro()
    end
end

function ScenarioManager:ConstructScenario()
    local randomIndex = math.random(#Location)
    self.currentLocation = Location[randomIndex]
    randomIndex = math.random(#Actions)
    self.currentAction = randomIndex
    randomIndex = math.random(#Npc)
    self.currentNpc = randomIndex
end

function ScenarioManager:RunIntro()
    --first display visuals of location and action and all that, then...

    if not playerSprite.startedWalkingIn then
        playerSprite:startWalkIn(true, 100)
        partnerSprite:startWalkIn(false, 100)
    end

    if playerSprite.startedWalkingIn then
        playerSprite:updateWalkIn()
        partnerSprite:updateWalkIn()
    end

    if playerSprite.hasWalkedIn then
        --print("success")
        self.currentState = ScenarioState.GAMEPLAY
    end
end

function ScenarioManager:RunOutro()
    if not playerSprite.startedWalkingIn then
        playerSprite:startWalkIn(false, -100)
        partnerSprite:startWalkIn(true, 500)
    end

    if playerSprite.startedWalkingIn then
        playerSprite:updateWalkIn()
        partnerSprite:updateWalkIn()
    end

    if playerSprite.hasWalkedIn then
        self.currentState = ScenarioState.INTERVAL
    end
end
