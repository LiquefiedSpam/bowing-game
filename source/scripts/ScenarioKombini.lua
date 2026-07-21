import "scripts/PlayerBow"
import "scripts/PartnerBow"
import "scripts/Scenario"
import "scripts/Cutscene"
import "scripts/CharacterSprite"

-- ScenarioKombini class that extends the Scenario class and represents the Kombini scenario in the game.
class("ScenarioKombini").extends(Scenario)

local pd = playdate
local gfx = pd.graphics

-- Player
local playerSprite = CharacterSprite(
    "images/player/spriteSheet-table-400-240",
    0)
local playerObj = Player(playerSprite, 130, 100, 3)

-- Partner
local partnerSprite = CharacterSprite(
    "images/player/clerkSpriteSheet3-table-400-240",
    0)
local partnerObj = Partner(partnerSprite, 500, 100, 3)

local Actions = { --for now we can just make sure in the code to not select an action
    --that doesn't work with the current location I guess
    CHECKOUT = 1,
}

function ScenarioKombini:init(scenario_type)
    self.playerSprite = CharacterSprite(
        "images/player/spriteSheet-table-400-240",
        0)
    self.playerObj = Player(self.playerSprite, 130, 100, 3)

    self.partnerSprite = CharacterSprite(
        "images/player/clerkSpriteSheet-table-400-240",
        0)
    self.partnerObj = Partner(self.partnerSprite, 500, 100, 3)

    self.cutscene = Cutscene(
        "images/background/temp-box1.png",
        "images/background/temp-box2.png",
        "images/background/temp-box3.png")

    if scenario_type == Actions.CHECKOUT then
        ScenarioKombini.super.init(
            self,
            "Checkout",
            self.cutscene,
            10,
            20,
            5,
            1,
            2,
            1,
            1,
            { 1, 2, 3 },
            3
        )
        self.partner_bow_table = self:generatePartnerBowTable_CHECKOUT()
        self.partner_bow_index = 1
        self.bows_complete = false
    else
        error("Invalid scenario type: " .. tostring(scenario_type))
    end
end

-- calculates the player score based on the player's bow table and the conditions of the scenario. Updates the player_humility_score property accordingly.
-- player_bow_table is a table of the Bow class of the player's performance in a scenario
-- player_intervals is a table of decimal values that represents the times at which the player bowed during the scenario
-- sets and returns the player_humility_score property based on the player's performance and the conditions of the scenario
function ScenarioKombini:calculateScore(player_bow_table, player_intervals)
    return ScenarioKombini.super.calculateScore(self, player_bow_table, player_intervals)
end

function ScenarioKombini:generatePartnerBowTable_CHECKOUT()
    local num_bows = 1
    local totalTime = 1
    local partner_bow_table = {}
    for i = 1, num_bows do
        local bow_start_time = totalTime + math.random(0, 1) / 2 + 1
        local bow_duration = 0.5 + math.random(-2, 2) / 6
        local deepness = 8 + math.random(-2, 2)
        local reset_position = 1
        local partner_bow = PartnerBow(bow_start_time, bow_duration, deepness, reset_position)
        table.insert(partner_bow_table, partner_bow)
        totalTime = bow_start_time + bow_duration + 0.5 -- 0.5 is a small extra time increment

        print("Partner Bow Table:")
        partner_bow:printBowDetails()
    end
    print("Generated partner bow table for CHECKOUT scenario with " .. num_bows .. " bows.")
    return partner_bow_table
end

-- Runs the intro sequence for the Kombini scenario, which includes the player and partner walking into the scene.
-- returns a boolean indicating whether the intro sequence has completed (true) or is still in progress (false).
function ScenarioKombini:runIntro()
    if not self.playerSprite.startedWalkingIn then
        self.playerSprite:startWalkIn(true, 100)
        self.partnerSprite:startWalkIn(false, 100)
    end

    if self.playerSprite.startedWalkingIn then
        self.playerSprite:updateWalkIn()
        self.partnerSprite:updateWalkIn()
    end

    if self.playerSprite.hasWalkedIn then
        return true
    end

    return false
end

function ScenarioKombini:runCutscene()
    ScenarioKombini.super.runCutscene(self)
end

-- Updates the player's bowing state based on the current crank position.
-- Returns playerObj for debugging purpose in scenarioManager.lua
function ScenarioKombini:updatePlayerBowing(currentTime)
    self.playerObj:setBowFrameIndex(pd.getCrankPosition(), currentTime)
    return self.playerObj
end

-- Updates the partner's bowing state based on time
-- param: currentTime (number): The current time in seconds since the start of the scenario, used to determine the partner's bowing state.
-- Returns partnerObj for debugging purpose in scenarioManager.lua
function ScenarioKombini:updatePartnerBowing(currentTime)
    if not (currentTime >= 0) then
        error("currentTime parameter is invalid. Cannot update partner bowing state.")
    end

    -- print("Current Time: " .. currentTime .. ", Partner Bow Index: " .. self.partner_bow_index)

    local currentPartnerBow = self.partner_bow_table[self.partner_bow_index]
    if not self.bows_complete and self.partnerObj:adjustBowPosition(currentPartnerBow, currentTime) then
        self.partner_bow_index = self.partner_bow_index + 1
        if self.partner_bow_index > #self.partner_bow_table then
            self.bows_complete = true
        end
    end

    return self.partnerObj
end

-- Returns the total time provided for the Kombini scenario, which is based on the scenario.
function ScenarioKombini:getTotalTimeProvided()
    return ScenarioKombini.super.getTotalTimeProvided(self)
end

function ScenarioKombini:runOutro()
    if not playerSprite.startedWalkingIn then
        playerSprite:change_current_image(1)
        partnerSprite:change_current_image(1)
        playerSprite:startWalkIn(false, true)
        partnerSprite:startWalkIn(true, false)
    end

    if self.playerSprite.startedWalkingIn then
        self.playerSprite:updateWalkIn()
        self.partnerSprite:updateWalkIn()
    end

    if self.playerSprite.hasWalkedIn then
        return true
    end

    return false
end

function ScenarioKombini:destruct()
    self.playerSprite:removeSprite()
    self.partnerSprite:removeSprite()
    --hi
end
