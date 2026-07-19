import "scripts/PartnerBow"

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
    size_bow_humility,
    player_bowing_intervals,
    player_bowing_intervals_forgiveness
)
    self.name = name
    self.cutscene = cutscene
    self.player_humility_score = 0
    self.humility_low_range_score = humility_low_range_score
    self.humility_high_range_score = humility_high_range_score
    self.humility_forgiveness = humility_forgiveness
    self.many_bows_humility = many_bows_humility
    self.deep_bows_humility = deep_bows_humility
    self.time_bows_humility = time_bows_humility
    self.size_bow_humility = size_bow_humility

    self.player_bowing_intervals = player_bowing_intervals
    self.player_bowing_intervals_forgiveness = player_bowing_intervals_forgiveness
    self.calculatedScore = false
    self.total_time_provided = 10
end

-- returns a string result representing the score of the scenario based on the player's performance and the conditions of the scenario
-- highest possible score ("HIGH") is achieved by being within humility low and high range
-- medium possible score ("MEDIUM") is achieved by being within humility low and high range +- the forgiveness range
-- lowest possible score ("LOW") is achieved by being outside of the humility low and high range +- the forgiveness range
function Scenario:score()
    if not self.calculatedScore then
        error("Score has not been calculated yet. Please call calculateScore() before calling score().")
    end
    if self.player_humility_score >= self.humility_low_range_score and self.player_humility_score <= self.humility_high_range_score then
        return "HIGH"
    elseif self.player_humility_score >= self.humility_low_range_score - self.humility_forgiveness and self.player_humility_score <= self.humility_high_range_score + self.humility_forgiveness then
        return "MEDIUM"
    else
        return "LOW"
    end
end

-- checks the player's bowing events (in terms of time) and ensures that they are in the correct order.
-- this compares required intervals with player bowing times (with forgiveness)
-- player_intervals is a table of decimal values that represents the times at which the player bowed during the scenario
-- if it is correct, then return true. Else, return false.
function Scenario:checkOrderOfEvents(player_intervals)
    if #player_intervals <= 0 then
        error("Player intervals table is empty. Cannot check order of events.")
    end
    for i = 1, #self.player_bowing_intervals do
        local checked_interval = self.player_bowing_intervals[i]
        local correct_inveral = false

        for j = 1, #player_intervals do
            local player_interval = player_intervals[j]

            if math.abs(checked_interval - player_interval) <= self.player_bowing_intervals_forgiveness then
                correct_inveral = true
                break
            end
        end

        if not correct_inveral then
            return false
        end
    end

    return true
end

-- calculates the player score based on the player's bow table and the conditions of the scenario. Updates the player_humility_score property accordingly.
-- player_bow_table is a table of the Bow class of the player's performance in a scenario
-- player_intervals is a table of decimal values that represents the times at which the player bowed during the scenario
-- sets and returns the player_humility_score property based on the player's performance and the conditions of the scenario
function Scenario:calculateScore(player_bow_table, player_intervals)
    if (#player_bow_table <= 0) then
        error("Player bow table is empty. Cannot calculate score.")
    end

    -- checks whether the player's bowing events are in the correct order based on the scenario's conditions. If not, the player score is set to 0 and returned.
    if not (self:checkOrderOfEvents(player_intervals)) then
        self.player_humility_score = 0
        self.calculatedScore = true
        return 0
    end

    local num_of_bows = #player_bow_table
    local deepest_bow_frame = player_bow_table[1]:getCurrentLowestBowFrame()
    local longest_bow_frame = player_bow_table[1]:getBowTimer()
    local total_bow_size = 0
    for _, bow in ipairs(player_bow_table) do
        if bow:getCurrentLowestBowFrame() > deepest_bow_frame then
            deepest_bow_frame = bow:getCurrentLowestBowFrame()
        end
        if bow:getBowTimer() > longest_bow_frame then
            longest_bow_frame = bow:getBowTimer()
        end

        total_bow_size += (bow:getCurrentLowestBowFrame() - bow:getCurrentBowFrame())
    end

    local ave_bow_size = total_bow_size / num_of_bows

    self.player_humility_score = num_of_bows * self.many_bows_humility + deepest_bow_frame * self.deep_bows_humility +
        longest_bow_frame * self.time_bows_humility + ave_bow_size * self.size_bow_humility
    self.calculatedScore = true
    return self.player_humility_score
end

function Scenario:runCutscene()
    self.cutscene:draw()
end

function Scenario:getTotalTimeProvided()
    return self.total_time_provided
end
