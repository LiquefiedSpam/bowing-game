import "CoreLibs/easing"
import "scripts/Clock"
import "scripts/PlayerBow"
import "scripts/PartnerBow"
import "scripts/Scenario"
import "scripts/Cutscene"
import "scripts/CharacterSprite"

-- ScenarioKombini class that extends the Scenario class and represents the Kombini scenario in the game.
class("ScenarioKombini").extends(Scenario)

local pd = playdate
local gfx = pd.graphics

local Actions = { --for now we can just make sure in the code to not select an action
    --that doesn't work with the current location I guess
    CHECKOUT = 1,
    CHECKOUT_DOUBLE_BOW = 2,
    CHECKOUT_MONEY_FELL = 3
}

--in the full game should scenariokonbini contain actions like this? I guess it depends on how we scope
--what this class should really mean. Because we could just have a separate data class for all scenarios' stuff
--or really short individual ones that override a main template / abstract class

local bg = gfx.image.new("images/background/konbiniBackground2.png")
local bg_sprite = gfx.sprite.new(bg)

local bg_slide_in_easing = playdate.easingFunctions.outQuad  --fast start, slow finish
local bg_slide_out_easing = playdate.easingFunctions.inCubic --slow start, fast finish

-- OUTRO CONSTANTS (seconds, measured on the outro clock)
local emote_step_duration = 0.33 --how long the emotes stay at each bounce position
local emote_duration = 1.5       --how long the emotes show before the characters walk out
local walk_out_delay = 0.5       --pause after the walk-out starts before the characters actually update

--y positions of the emotes at each bounce step (the last step is held until the emotes end)
local player_emote_ys = { 100, 105, 110, 115, 120 }
local partner_emote_ys = { 100, 105, 100, 105, 100 }

--stuff like this obviously should be abstracted
function ScenarioKombini:init(scenario_type)
    bg_sprite:moveTo(200, 400)
    bg_sprite:add()
    self.playerSprite = CharacterSprite(
        "images/player/playerSpriteSheet2-table-400-240",
        0)
    self.playerObj = Player(self.playerSprite, 80, 100, 3)

    self.partnerSprite = CharacterSprite(
        "images/player/clerkSpriteSheet4-table-400-240",
        0)
    self.partnerObj = Partner(self.partnerSprite, 500, 100, 3)

    self.bg_move_duration = 3 --seconds the background takes to slide in (intro) or out (outro)

    self.bg_start_y = 400
    self.bg_target_y = 120
    self.bg_target_y_out = -300

    self.intro_clock = Clock()      --time elapsed in the intro; never reset, everything is scheduled from it
    self.outro_clock = Clock()      --time elapsed in the outro; never reset, everything is scheduled from it
    self.outro_walk_started = false --true once the characters have started walking out

    if scenario_type ~= Actions.CHECKOUT_MONEY_FELL then
        self.cutscene = Cutscene({
            { path = "images/background/miniKonbini.png",                 is_animated = false },
            { path = "images/background/moneyTransfer-table-114-114.png", is_animated = true, blank_frames_at_end = 1 },
            { path = "images/background/miniLady.png",                    is_animated = false },
        })
    else
        self.cutscene = Cutscene({
            { path = "images/background/miniKonbini.png",                     is_animated = false },
            { path = "images/background/moneyTransferFall-table-114-114.png", is_animated = true, blank_frames_at_end = 1 },
            { path = "images/background/shockedLady.png",                     is_animated = false },
        })
    end


    self.partner_bow_index = 1 --what's this?
    self.bows_complete = false
    self.bow_intervals_for_player = {}

    if scenario_type == Actions.CHECKOUT then
        --yeah this looks nasty lol
        self.partner_bow_table = self:generatePartnerBowTable_CHECKOUT()
        ScenarioKombini.super.init(
            self,
            "Checkout",
            self.cutscene,
            15,
            18,
            3,
            1,
            2,
            -1,
            1,
            self.bow_intervals_for_player,
            1
        )
    elseif scenario_type == Actions.CHECKOUT_DOUBLE_BOW then
        self.partner_bow_table = self:generatePartnerBowTable_CHECKOUT_DOUBLE_BOW()
        ScenarioKombini.super.init(
            self,
            "Checkout Double Bow",
            self.cutscene,
            15,
            18,
            4,
            1,
            2,
            -1,
            1,
            self.bow_intervals_for_player,
            1
        )
    elseif scenario_type == Actions.CHECKOUT_MONEY_FELL then
        self.partner_bow_table = self:generatePartnerBowTable_CHECKOUT()
        ScenarioKombini.super.init(
            self,
            "Checkout Money Fell",
            self.cutscene,
            30,
            27,
            4,
            4,
            3,
            2,
            1,
            self.bow_intervals_for_player,
            1
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

--I think ideally this should just give the partner AI parameters, and the partner AI's logic in a separate class
--carries it out
function ScenarioKombini:generatePartnerBowTable_CHECKOUT()
    local num_bows = 1
    local totalTime = 0
    local partner_bow_table = {}
    for i = 1, num_bows do
        local bow_start_time = totalTime + math.random(0, 1) / 2 + 1
        local bow_duration = 0.5 + math.random(-2, 2) / 6
        local deepness = 6 + math.random(-2, 2)
        local reset_position = 1
        local partner_bow = PartnerBow(bow_start_time, bow_duration, deepness, reset_position)
        table.insert(partner_bow_table, partner_bow)
        table.insert(self.bow_intervals_for_player, { bow_start_time + bow_duration + 0.5 })
        totalTime = bow_start_time + bow_duration + 0.5 -- 0.5 is a small extra time increment

        print("Partner Bow Table:")
        partner_bow:printBowDetails()
        print("Bow Interval for Player: " .. tostring(bow_start_time + bow_duration + 0.5))
    end
    print("Generated partner bow table for CHECKOUT scenario with " .. num_bows .. " bows.")
    return partner_bow_table
end

function ScenarioKombini:generatePartnerBowTable_CHECKOUT_DOUBLE_BOW()
    local num_bows = 2
    local totalTime = 0
    local partner_bow_table = {}

    -- bow one
    local bow_start_time = totalTime + math.random(0, 1) / 2 + 1
    local bow_duration = 0.5 + math.random(-2, 2) / 6
    local deepness = 6 + math.random(-2, 2)
    local reset_position = 1

    local partner_bow = PartnerBow(bow_start_time, bow_duration, deepness, reset_position)
    table.insert(partner_bow_table, partner_bow)
    table.insert(self.bow_intervals_for_player, { bow_start_time + bow_duration + 0.5 })

    totalTime = bow_start_time + bow_duration + 0.5 -- 0.5 is a small extra time increment
    print("Bow Interval for Player: " .. tostring(bow_start_time + bow_duration + 0.5))

    -- bow two
    local bow_start_time = totalTime + math.random(0, 1) / 2 + 1
    local bow_duration = 0.5 + math.random(-2, 2) / 6
    local deepness = 6 + math.random(-2, 2)
    local reset_position = 1
    local partner_bow = PartnerBow(bow_start_time, bow_duration, deepness, reset_position)
    table.insert(partner_bow_table, partner_bow)
    table.insert(self.bow_intervals_for_player, { bow_start_time + bow_duration + 0.5 })
    print("Bow Interval for Player: " .. tostring(bow_start_time + bow_duration + 0.5))



    print("Generated partner bow table for CHECKOUT scenario with " .. num_bows .. " bows.")
    return partner_bow_table
end

-- function ScenarioKombini:generatePartnerBowTable_CHECKOUT_MONEY_FALL()
--     local num_bows = 1
--     local totalTime = 0
--     local partner_bow_table = {}
--     for i = 1, num_bows do
--         local bow_start_time = totalTime + math.random(0, 1) / 2 + 1
--         local bow_duration = 0.5 + math.random(-2, 2) / 6
--         local deepness = 6 + math.random(-2, 2)
--         local reset_position = 1
--         local partner_bow = PartnerBow(bow_start_time, bow_duration, deepness, reset_position)
--         table.insert(partner_bow_table, partner_bow)
--         table.insert(self.bow_intervals_for_player, { bow_start_time + bow_duration + 0.5 })
--         totalTime = bow_start_time + bow_duration + 0.5 -- 0.5 is a small extra time increment

--         print("Partner Bow Table:")
--         partner_bow:printBowDetails()
--         print("Bow Interval for Player: " .. tostring(bow_start_time + bow_duration + 0.5))
--     end
--     print("Generated partner bow table for CHECKOUT scenario with " .. num_bows .. " bows.")
--     return partner_bow_table
-- end

-- Runs the intro sequence for the Kombini scenario, which includes the player and partner walking into the scene.
-- returns a boolean indicating whether the intro sequence has completed (true) or is still in progress (false).
function ScenarioKombini:runIntro(dt)
    self.intro_clock:advance(dt)
    local time = self.intro_clock:now()
    local bg_done = self:slide_bg(true, time)

    local walk_start_time = self.bg_move_duration / 2 --the characters walk in once the background is half way in
    if time > walk_start_time then
        if not self.playerSprite.startedWalkingIn then
            self.playerSprite:startWalkIn(true, true, walk_start_time)
            self.partnerSprite:startWalkIn(false, false, walk_start_time)
        end

        if self.playerSprite.startedWalkingIn then
            self.playerSprite:updateWalkIn(time)
            self.partnerSprite:updateWalkIn(time)
        end

        if self.playerSprite.hasWalkedIn and bg_done then
            self.playerObj:resetCrank()
            self.playerSprite.hasWalkedIn = false
            return true
        end
    end

    return false
end

-- Positions the background for the given number of seconds into its slide (in or out).
-- Everything is calculated from elapsed, so nothing accumulates and nothing can overshoot.
-- Returns true once the slide has finished.
function ScenarioKombini:slide_bg(slide_in, elapsed)
    local ease, from, to
    if slide_in then
        ease, from, to = bg_slide_in_easing, self.bg_start_y, self.bg_target_y
    else
        ease, from, to = bg_slide_out_easing, self.bg_target_y, self.bg_target_y_out
    end

    --easing(elapsed, start value, change in value, duration)
    elapsed = math.max(0, math.min(self.bg_move_duration, elapsed))
    bg_sprite:moveTo(200, ease(elapsed, from, to - from, self.bg_move_duration))

    return elapsed >= self.bg_move_duration
end

function ScenarioKombini:runCutscene(dt)
    return ScenarioKombini.super.runCutscene(self, dt)
end

-- Updates the player's bowing state based on the current crank position.
-- Returns playerObj for debugging purpose in scenarioManager.lua
function ScenarioKombini:updatePlayerBowing(currentTime)
    self.playerObj:setBowFrameIndex(currentTime)
    return self.playerObj
end

-- Checks whether movement has been detected for more than a set duration. If not, end the scene prematurely.
-- Returns a boolean that indicates whether movement has been detected (true) or not (false).
function ScenarioKombini:checkPlayerMovement(current_player_position, current_partner_position, current_time)
    return ScenarioKombini.super.checkPlayerMovement(self, current_player_position, current_partner_position,
        current_time)
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

-- Moves the emotes to their bounce position for the given outro time (seconds).
function ScenarioKombini:show_emotes(time)
    local step = math.min(#player_emote_ys, math.floor(time / emote_step_duration) + 1)
    self.emote_player:moveTo(100, player_emote_ys[step])
    self.emote_player:add()
    self.emote_partner:moveTo(300, partner_emote_ys[step])
    self.emote_partner:add()
end

-- Removes the emotes (if there are any) and sets both characters to start walking out at start_time (outro seconds).
function ScenarioKombini:start_walk_out(start_time)
    self.playerSprite:startWalkIn(false, true, start_time)
    self.partnerSprite:startWalkIn(true, false, start_time)
    if self.emote_partner ~= nil then
        self.emote_partner:remove()
    end
    if self.emote_player ~= nil then
        self.emote_player:remove()
    end
    self.outro_walk_started = true
end

-- Runs the outro: the emotes bounce, then the characters walk out while the background slides away.
-- Everything is scheduled from the outro clock. Returns true once the outro is finished.
function ScenarioKombini:runOutro(dt)
    self.outro_clock:advance(dt)
    local time = self.outro_clock:now()

    local has_emotes = self.emote_player ~= nil and self.emote_partner ~= nil
    local walk_start_time = has_emotes and emote_duration or 0

    if not self.outro_walk_started then
        self.playerSprite:change_current_image(1)
        self.partnerSprite:change_current_image(1)
        if time < walk_start_time then
            self:show_emotes(time)
            return false
        end
        self:start_walk_out(walk_start_time + walk_out_delay)
    end

    local bg_done = self:slide_bg(false, time - walk_start_time) --the background slides out as the walk-out starts
    if time < walk_start_time + walk_out_delay then
        return false
    end

    if self.playerSprite.startedWalkingIn then
        self.playerSprite:updateWalkIn(time)
    end

    if self.partnerSprite.startedWalkingIn then
        self.partnerSprite:updateWalkIn(time)
    end

    -- if self.playerSprite.hasWalkedIn then
    --     self.playerSprite.startedWalkingIn = false
    -- end

    -- if self.partnerSprite.hasWalkedIn then
    --     self.partnerSprite.startedWalkingIn = false
    -- end

    if self.playerSprite.hasWalkedIn and bg_done then
        return true
    end

    return false
end

function ScenarioKombini:destruct()
    self.playerSprite:removeSprite()
    self.partnerSprite:removeSprite()
end
