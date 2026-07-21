import "scripts/ScenarioKombini"

class("ScenarioManager").extends()

local LocationScenarios = {
    KONBINI = 1,
    --TAXI = 2
}

-- number of actions per location (keys have to be the same name as the location keys in LocationScenarios)
local Actions = {
    KONBINI = 1,
}

local ScenarioState = {
    INTERVAL = 1,
    CUTSCENE = 2,
    INTRO = 3,
    GAMEPLAY = 4,
    SCORING = 5,
    OUTRO = 6
}

local Npc = {
    KONBINI_CLERK = 1
}

local pd = playdate
local gfx = pd.graphics

-- Main Menu
local mainMenu = gfx.image.new("images/UI_screens/MainMenu.png")

local timer = 0
local totalTimer = 0

local dt = 0

local score = 0

function ScenarioManager:init()
    self.hasScenario = true
    self.currentState = ScenarioState.INTERVAL
    self.currentScenario = nil
    self.playerObj = nil
    self.totalTimeGivenSec = 60
end

function ScenarioManager:update()
    if self.currentState == nil then
        self.currentState = ScenarioState.INTERVAL
    end
    dt = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    if self.currentState == ScenarioState.INTERVAL then
        mainMenu:draw(0, 0)
        if pd.buttonJustPressed(pd.kButtonA) then
            self.currentState = ScenarioState.CUTSCENE
            self:ConstructScenario()
        end
        --playdate.wait(1000)
        --self.currentState = ScenarioState.INTRO
    end

    if self.currentState == ScenarioState.CUTSCENE then
        if self.currentScenario == nil then
            error("No scenario has been created. Cannot run cutscene sequence.")
        end
        playdate.graphics.clear()
        self.currentScenario:runCutscene()
        self.currentState = ScenarioState.INTRO
    end

    if self.currentState == ScenarioState.INTRO then
        self:RunIntro()
    end

    if self.currentState == ScenarioState.GAMEPLAY then
        self:RunGameplay()
    end

    if self.currentState == ScenarioState.SCORING then
        self:RunScoring()
    end

    if self.currentState == ScenarioState.OUTRO then
        timer = 0
        self:RunOutro()
    end
end

-- Creates a new scenario based on the current location and action. Initializes the scenario and sets it as the current scenario.
function ScenarioManager:ConstructScenario()
    -- self.currentScenario = ScenarioKombini(1)

    local location_count = 0
    for _ in pairs(LocationScenarios) do
        location_count = location_count + 1
    end

    local location_keys = {}
    for key in pairs(LocationScenarios) do
        table.insert(location_keys, key)
    end

    local randomLocationIndex = math.random(location_count)
    self.currentLocation = location_keys[randomLocationIndex]
    local totalPossibleActions = Actions[self.currentLocation]
    local randomActionIndex = math.random(totalPossibleActions)
    self.currentAction = randomActionIndex

    print("Constructing scenario for location: " ..
        tostring(self.currentLocation) .. " and action: " .. tostring(self.currentAction))
    if LocationScenarios[self.currentLocation] == LocationScenarios.KONBINI then
        self.currentScenario = ScenarioKombini(self.currentAction)
    else
        error("Invalid location index: " .. tostring(randomLocationIndex))
    end
end

function ScenarioManager:RunIntro()
    --first display visuals of location and action and all that, then...
    if self.currentScenario == nil then
        error("No scenario has been created. Cannot run intro sequence.")
    end

    local intro_result = self.currentScenario:runIntro()
    if intro_result then
        self.currentState = ScenarioState.GAMEPLAY
    end
end

function ScenarioManager:RunGameplay()
    if self.currentScenario == nil then
        error("No scenario has been created. Cannot run gameplay sequence.")
    end

    timer += dt
    totalTimer += dt
    --dummy ending for a scenario
    if timer > self.currentScenario:getTotalTimeProvided() then
        self.currentState = ScenarioState.SCORING
    end

    self.playerObj = self.currentScenario:updatePlayerBowing(timer)
    local partnerObj = self.currentScenario:updatePartnerBowing(timer)

    gfx.drawTextAligned("Score: " .. score, 390, 1, kTextAlignment.right)
    gfx.drawTextAligned("Bows: " .. self.playerObj:getCurrentBowNum(), 240, 20, kTextAlignment.right)
    gfx.drawTextAligned("Lowest Bow Frame: " .. self.playerObj:getCurrentLowestBowFrame(), 240, 40, kTextAlignment.right)
    gfx.drawTextAligned("Bow Timer: " .. self.playerObj:getBowTimer(), 240, 60, kTextAlignment.right)
end

function ScenarioManager:RunScoring()
    if self.currentScenario == nil then
        error("No scenario has been created. Cannot run scoring sequence.")
    end

    if self.playerObj == nil then
        error("Player object is nil. Cannot calculate score without player data.")
    end


    for key, value in ipairs(self.playerObj.bow_table) do
        if type(value) == "table" then
            print("Bow: " ..
                key ..
                ", Starting Bow Frame: " ..
                tostring(value:getCurrentBowFrame()) ..
                ", CurrentBowFrame: " ..
                tostring(value:getCurrentLowestBowFrame()) .. ", Bow Timer: " .. tostring(value:getBowTimer()))
        else
            print("Bow Interval: " .. key .. ", Value: " .. tostring(value))
        end
    end
    for key, value in ipairs(self.playerObj.bow_intervals) do
        if type(value) == "table" then
            print("Bow Interval: " .. key .. ", Start: " .. tostring(value[1]) .. ", End: " .. tostring(value[2]))
        else
            print("Bow Interval: " .. key .. ", Value: " .. tostring(value))
        end
    end

    local scoring_result = self.currentScenario:calculateScore(self.playerObj.bow_table, self.playerObj.bow_intervals)
    print("Scoring Result: " .. tostring(scoring_result))
    if scoring_result then
        self.currentState = ScenarioState.OUTRO
    end
end

function ScenarioManager:RunOutro()
    if self.currentScenario == nil then
        error("No scenario has been created. Cannot run outro sequence.")
    end

    local outro_result = self.currentScenario:runOutro()
    if outro_result and self.totalTimeGivenSec >= totalTimer then
        self.currentScenario:runOutro()
        self:ConstructScenario()
        self.currentState = ScenarioState.CUTSCENE
    elseif outro_result and self.totalTimeGivenSec < totalTimer then
        self.currentState = ScenarioState.INTERVAL
        self.currentAction = nil
    end
end
