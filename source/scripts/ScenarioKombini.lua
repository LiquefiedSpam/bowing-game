<<<<<<< HEAD
import "scripts/PlayerBow"
import "scripts/PartnerBow"

local pd <const> = playdate
local gfx <const> = pd.graphics
=======
import "scripts/Bow"
>>>>>>> main
import "scripts/Scenario"
import "scripts/Cutscene"

-- ScenarioKombini class that extends the Scenario class and represents the Kombini scenario in the game.
class("ScenarioKombini").extends(Scenario)

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

local Actions = { --for now we can just make sure in the code to not select an action
    --that doesn't work with the current location I guess
    CHECKOUT = 1,
}

local temp_cutscene = Cutscene(
    "images/background/temp-box1.png",
    "images/background/temp-box2.png",
    "images/background/temp-box3.png")

function ScenarioKombini:init(scenario_type)
    self.partner_bow_table = {}
    if scenario_type == Actions.CHECKOUT then
        ScenarioKombini.super.init(
            self,
            "Checkout",
            temp_cutscene,
            10,
            20,
            5,
            1,
            2,
            1,
            1,
            1,
            1,
            { 1, 2, 3 },
            0.5
        )
        -- temp partner bow code
        self.partner_bow_table = { PartnerBow(0, 2, 4, 1), PartnerBow(2, 2, 4, 1), PartnerBow(4, 2, 4, 1) }
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

-- Runs the intro sequence for the Kombini scenario, which includes the player and partner walking into the scene.
-- returns a boolean indicating whether the intro sequence has completed (true) or is still in progress (false).
function ScenarioKombini:runIntro()
    if not playerSprite.startedWalkingIn then
        playerSprite:startWalkIn(true, 100)
        partnerSprite:startWalkIn(false, 100)
    end

    if playerSprite.startedWalkingIn then
        playerSprite:updateWalkIn()
        partnerSprite:updateWalkIn()
    end

    if playerSprite.hasWalkedIn then
        return true
    end

    return false
end

function ScenarioKombini:runCutscene()
    ScenarioKombini.super.runCutscene(self)
end

-- Updates the player's bowing state based on the current crank position.
-- Returns playerObj for debugging purpose in scenarioManager.lua
function ScenarioKombini:updatePlayerBowing()
    playerObj:setBowFrameIndex(pd.getCrankPosition())
    return playerObj
end

-- Updates the partner's bowing state based on time
-- param: currentTime (number): The current time in seconds since the start of the scenario, used to determine the partner's bowing state.
-- Returns partnerObj for debugging purpose in scenarioManager.lua
function ScenarioKombini:updatePartnerBowing(currentTime)
    if not (currentTime >= 0) then
        error("currentTime parameter is invalid. Cannot update partner bowing state.")
    end

    print("Current Time: " .. currentTime .. ", Partner Bow Index: " .. self.partner_bow_index)

    local currentPartnerBow = self.partner_bow_table[self.partner_bow_index]
    if not self.bows_complete and partnerObj:adjustBowPosition(currentPartnerBow, currentTime) then
        self.partner_bow_index = self.partner_bow_index + 1
        if self.partner_bow_index > #self.partner_bow_table then
            self.bows_complete = true
        end
    end

    return partnerObj
end

-- Returns the total time provided for the Kombini scenario, which is based on the scenario.
function ScenarioKombini:getTotalTimeProvided()
    return ScenarioKombini.super.getTotalTimeProvided(self)
end
