-- class for a scenario, which is a collection of events that can happen in the game
class("Scenario").extends()

-- player_bowing_intervals is a table of decimal values that represents the required times for the player to bow within the scenario
-- player_bowing_intervals_forgiveness is a decimal value that represents the forgiveness range for the player to bow within the scenario
function Scenario:init(
    name,
    cutscene,
    humility_low_range_score,
    humility_high_range_score,
    humility_forgiveness,
    many_bows_humility,
    deep_bows_humility,
    time_bows_humility,
    player_bowing_intervals,
    player_bowing_intervals_forgiveness)
    self.name = name
    -- cutscene for later
    self.cutscene = cutscene

    self.player_humility_score = 0
    self.humility_low_range_score = humility_low_range_score
    self.humility_high_range_score = humility_high_range_score
    self.humility_forgiveness = humility_forgiveness
    self.many_bows_humility = many_bows_humility
    self.deep_bows_humility = deep_bows_humility
    self.time_bows_humility = time_bows_humility

    self.player_bowing_intervals = player_bowing_intervals
    self.player_bowing_intervals_forgiveness = player_bowing_intervals_forgiveness
end

-- returns a string result representing the score of the scenario based on the player's performance and the conditions of the scenario
-- highest possible score ("HIGH") is achieved by being within humility low and high range
-- medium possible score ("MEDIUM") is achieved by being within humility low and high range +- the forgiveness range
-- lowest possible score ("LOW") is achieved by being outside of the humility low and high range +- the forgiveness range
function Scenario:score()
    if self.player_humility_score >= self.humility_low_range_score and self.player_humility_score <= self.humility_high_range_score then
        return "HIGH"
    elseif self.player_humility_score >= self.humility_low_range_score - self.humility_forgiveness and self.player_humility_score <= self.humility_high_range_score + self.humility_forgiveness then
        return "MEDIUM"
    else
        return "LOW"
    end
end

-- checks the player's bowing events (in terms of time) and ensures that they are in the correct order.
-- if it is correct, then return true. Else, return false.
function Scenario:checkOrderOfEvents(player_intervals)
    -- scaffholding for the actual method, not completed


    -- for i = 1, #self.player_bowing_intervals do
    --     local expected_interval = self.player_bowing_intervals[i]
    --     local actual_interval = player_intervals[i]

    --     if not actual_interval then
    --         return false
    --     end

    --     if math.abs(expected_interval - actual_interval) > self.player_bowing_intervals_forgiveness then
    --         return false
    --     end
    -- end
    -- return true
end

-- calculates the player score based on the player's bow table and the conditions of the scenario. Updates the player_humility_score property accordingly.
-- player_bow_table is a table of the Bow class of the player's performance in a scenario
-- sets and returns the player_humility_score property based on the player's performance and the conditions of the scenario
function Scenario:calculateScore(player_bow_table)
    if (#player_bow_table <= 0) then
        error("Player bow table is empty. Cannot calculate score.")
    end

    local num_of_bows = #player_bow_table
    local deepest_bow_frame = player_bow_table[1]:getCurrentLowestBowFrame()
    local longest_bow_frame = player_bow_table[1]:getBowTimer()

    for _, bow in ipairs(player_bow_table) do
        if bow:getCurrentLowestBowFrame() > deepest_bow_frame then
            deepest_bow_frame = bow:getCurrentLowestBowFrame()
        end
        if bow:getBowTimer() > longest_bow_frame then
            longest_bow_frame = bow:getBowTimer()
        end
    end

    self.player_humility_score = num_of_bows * self.many_bows_humility + deepest_bow_frame * self.deep_bows_humility +
        longest_bow_frame * self.time_bows_humility
    return self.player_humility_score
end

class("Scenario").extends()

function Scenario:init(
    name,
    cutscene,
    humility_low_range_score,
    humility_high_range_score,
    humility_forgiveness,
    many_bows_humility,
    deep_bows_humility)
    self.name = name
    -- cutscene for later
    self.cutscene = cutscene
    self.event_table = {}


    self.player_humility_score = 0
    self.humility_low_range_score = humility_low_range_score
    self.humility_high_range_score = humility_high_range_score
    self.humility_forgiveness = humility_forgiveness
    self.many_bows_humility = many_bows_humility
    self.deep_bows_humility = deep_bows_humility
end
