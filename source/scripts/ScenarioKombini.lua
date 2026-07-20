import "scripts/Bow"
import "scripts/Scenario"
import "scripts/Cutscene"

-- ScenarioKombini class that extends the Scenario class and represents the Kombini scenario in the game.
class("ScenarioKombini").extends(Scenario)

local pd = playdate

-- Player
local playerSprite = CharacterSprite(
    "images/player/playerBottom.png",
    "images/player/playerSpriteSheet-table-300-300",
    0)
local playerObj = Player(playerSprite, 130, 100, 3)
playerSprite:add()

-- Partner
local partnerSprite = CharacterSprite(
    "images/player/playerBottom.png",
    "images/player/spritesheet-table-400-480",
    0)
local partnerObj = Partner(partnerSprite, 500, 100, 3)
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

function ScenarioKombini:runOutro()
    if not playerSprite.startedWalkingIn then
        playerSprite:change_current_image(1)
        partnerSprite:change_current_image(1)
        playerSprite:startWalkIn(false, -100)
        partnerSprite:startWalkIn(true, 500)
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
