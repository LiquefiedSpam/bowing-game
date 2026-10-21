import "scripts/Clock"
import "scripts/ResumeCountdown"
import "scripts/ScenarioKombini"
import "scripts/HeartScreen"
import "scripts/ScoreScreen"

class("GameStateManager").extends()

local LocationScenarios = {
    KONBINI = 1,
    --TAXI = 2
}

-- number of actions per location (keys have to be the same name as the location keys in LocationScenarios)
local Actions = {
    KONBINI = 3,
}

local ScenarioState = {
    INTERVAL = 1,  --interval between 'runs'
    CUTSCENE = 2,  --the cutscene that plays before gameplay where we get the person, action, place
    INTRO = 3,     --character(s) walking in
    GAMEPLAY = 4,  --actual gameplay portion
    SCORING = 5,   --internal scoring time
    OUTRO = 6,     --icons show, character(s) move out
    BUILDSCENE = 7 --build the next scenario
}

-- NOT NEEDED
local Npc = {
    KONBINI_CLERK = 1
}

local pd = playdate
local gfx = pd.graphics

-- Main Menu
-- ofc later this should be relocated to its own class
local mainMenu = gfx.image.new("images/UI_screens/BowMainMenu.png")

local score = 0 --unused?

function ScenarioManager:init()
    self.hasScenario = true --why is this true if current scenario is nil?
    self.currentState = ScenarioState.INTERVAL

    -- IS THIS GOOD PRACTICE? I CANNOT TELL
    self.currentScenario = nil
    self.playerObj = nil
    self.partnerObj = nil

    self.totalTimeGivenSec = 60
    self.dt = 0                              --seconds since the last update, set once per frame in update()
    self.gameplay_clock = Clock()            --time elapsed in the gameplay portion of the current scenario
    self.resumeCountdown = ResumeCountdown() --shown after the player closes the system menu mid-scenario
    self.backgroundPlayer = BackgroundMusic()

    -- Heart Screen
    self.heartScreen = HeartScreen()

    --Score Screen
    self.scoreScreen = ScoreScreen()
end

function ScenarioManager:update()
    if self.currentState == nil then
        self.currentState = ScenarioState.INTERVAL
    end
    self.dt = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    --while the resume countdown shows, the game stays frozen: nothing below runs, so no clock advances
    if self.resumeCountdown:is_active() then
        if not self.resumeCountdown:update(self.dt) then
            self.backgroundPlayer:update()
            return
        end

        --the countdown just finished: wherever the crank is now is the start of the player's current bow frame
        if self.currentScenario ~= nil and self.currentScenario.playerObj ~= nil then
            self.currentScenario.playerObj:resetCrank()
        end
    end

    if self.currentState == ScenarioState.INTERVAL then
        mainMenu:draw(0, 0)
        if pd.buttonJustPressed(pd.kButtonA) then
            self.heartScreen:resetHearts()
            self.scoreScreen:resetScore()
            self.currentState = ScenarioState.CUTSCENE
            self:ConstructScenario()
        end
    end

    if self.currentState == ScenarioState.CUTSCENE then
        if self.currentScenario == nil then
            error("No scenario has been created. Cannot run cutscene sequence.")
        end
        playdate.graphics.clear()
        local fin = self.currentScenario:runCutscene(self.dt) --run this every frame until true basically
        self.heartScreen:drawHearts()
        self.scoreScreen:drawScore()

        if fin == true then
            self.currentState = ScenarioState.INTRO
        end
    end

    if self.currentState == ScenarioState.INTRO then
        self:RunIntro()
        self.heartScreen:drawHearts() --the draw hearts and score get repetitive; abstract it
        self.scoreScreen:drawScore()
    end

    if self.currentState == ScenarioState.GAMEPLAY then
        self:RunGameplay()
        self.heartScreen:drawHearts()
        self.scoreScreen:drawScore()
    end

    if self.currentState == ScenarioState.SCORING then
        self:RunScoring()
        self.heartScreen:drawHearts()
        self.scoreScreen:drawScore()
    end

    if self.currentState == ScenarioState.OUTRO then
        self:RunOutro()
        self.heartScreen:drawHearts()
        self.scoreScreen:drawScore()
    end

    if self.currentState == ScenarioState.BUILDSCENE then
        self:BuildScene()
    end

    self.backgroundPlayer:update()
end

-- True while a scenario is in progress (anything other than the main menu).
function ScenarioManager:isScenarioRunning()
    return self.currentState ~= nil and self.currentState ~= ScenarioState.INTERVAL
end

-- Called when the system pauses the game. Keeps a picture of the screen to show behind the countdown.
function ScenarioManager:onPause()
    if self:isScenarioRunning() then
        self.resumeCountdown:capture()
    end
end

-- Called when the system resumes the game. Starts the resume countdown, but not on the main menu.
function ScenarioManager:onResume()
    if self:isScenarioRunning() then
        playdate.resetElapsedTime() --the time spent in the system menu must not count towards the countdown
        self.resumeCountdown:start()
    end
end

-- Creates a new scenario based on the current location and action. Initializes the scenario and sets it as the current scenario.
function ScenarioManager:ConstructScenario()
    self.gameplay_clock:reset()
    -- self.currentScenario = ScenarioKombini(1)

    local location_count = 0

    -- MAYBE LOCATIONSCENARIOS SHOULD BE CONSTANTS?
    for _ in pairs(LocationScenarios) do
        location_count = location_count + 1
    end

    local location_keys = {}
    for key in pairs(LocationScenarios) do
        table.insert(location_keys, key)
    end

    local randomLocationIndex = math.random(location_count) --ofc right now it's just the one
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

    local intro_result = self.currentScenario:runIntro(self.dt)
    if intro_result then
        self.currentState = ScenarioState.GAMEPLAY
    end
end

function ScenarioManager:RunGameplay()
    if self.currentScenario == nil then
        error("No scenario has been created. Cannot run gameplay sequence.")
    end

    self.gameplay_clock:advance(self.dt)
    local gameplay_time = self.gameplay_clock:now()
    --dummy ending for a s1cenario
    if gameplay_time > self.currentScenario:getTotalTimeProvided() then
        self.currentState = ScenarioState.SCORING
    end

    self.playerObj = self.currentScenario:updatePlayerBowing(gameplay_time)
    self.partnerObj = self.currentScenario:updatePartnerBowing(gameplay_time)
    local player_moved = self.currentScenario:checkPlayerMovement(
        self.playerObj:getCurrentBowFrame(),
        self.partnerObj:getCurrentBowFrame(),
        gameplay_time)
    if not player_moved then --wait how does this work?
        self.currentState = ScenarioState.SCORING
    end

    -- gfx.drawTextAligned("Score: " .. score, 390, 1, kTextAlignment.right)
    -- gfx.drawTextAligned("Bows: " .. self.playerObj:getCurrentBowNum(), 240, 20, kTextAlignment.right)
    -- gfx.drawTextAligned("Lowest Bow Frame: " .. self.playerObj:getCurrentLowestBowFrame(), 240, 40, kTextAlignment.right)
    -- gfx.drawTextAligned("Bow Timer: " .. self.playerObj:getBowTimer(), 240, 60, kTextAlignment.right)
end

function ScenarioManager:RunScoring()
    if self.currentScenario == nil then
        --this can be abstracted
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

    --definitely can use abstracting work
    local scoring_result = self.currentScenario:calculateScore(self.playerObj.bow_table, self.playerObj.bow_intervals)
    print("Scoring Result: " .. tostring(scoring_result))
    local score_status = self.currentScenario:score()
    if score_status == "LOW" then
        local player_low_image = pd.graphics.image.new("images/emotes/sweat_teardrop.png")
        self.currentScenario.emote_player = pd.graphics.sprite.new(player_low_image)
        local partner_low_image = pd.graphics.image.new("images/emotes/question_mark.png")
        self.currentScenario.emote_partner = pd.graphics.sprite.new(partner_low_image)
        self.heartScreen:loseLife()
    elseif score_status == "MEDIUM" then
        local player_medium_image = pd.graphics.image.new("images/emotes/blank.png")
        self.currentScenario.emote_player = pd.graphics.sprite.new(player_medium_image)
        local partner_medium_image = pd.graphics.image.new("images/emotes/thumbs_up.png")
        self.currentScenario.emote_partner = pd.graphics.sprite.new(partner_medium_image)
        self.scoreScreen:addScore(1)
    elseif score_status == "HIGH" then
        local player_high_image = pd.graphics.image.new("images/emotes/blank.png")
        self.currentScenario.emote_player = pd.graphics.sprite.new(player_high_image)
        local partner_high_image = pd.graphics.image.new("images/emotes/smiley.png")
        self.currentScenario.emote_partner = pd.graphics.sprite.new(partner_high_image)
        self.scoreScreen:addScore(2)
    end

    if scoring_result then
        self.currentState = ScenarioState.OUTRO
    end
end

function ScenarioManager:RunOutro()
    if self.currentScenario == nil then
        error("No scenario has been created. Cannot run outro sequence.")
    end

    local outro_result = self.currentScenario:runOutro(self.dt)
    if outro_result then
        self.currentState = ScenarioState.BUILDSCENE
        self.currentAction = nil
    end
end

function ScenarioManager:BuildScene()
    self.currentScenario:destruct()
    if self.heartScreen:getHearts() > 0 then
        self:ConstructScenario()
        self.currentState = ScenarioState.CUTSCENE
    else
        self.currentState = ScenarioState.INTERVAL
        self.currentAction = nil
    end
end
