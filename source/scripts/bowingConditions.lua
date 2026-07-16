-- class to handle bowing conditions and logic in a given scene
class('BowingConditions').extends()

-- param: table_of_conditions is a table of the Bow class of conditions for a Scenario class
-- param: time_fogiveness is a factor that determines how lenient the scoring is
-- IN PROGRESS
function BowingConditions:init(table_of_conditions, time_fogiveness)
    self.conditions = table_of_conditions
    self.time_fogiveness = time_fogiveness
end

-- Compares the player's bow table with the conditions for the scenario. Returns the number of points accordingly.
-- param: player_bow_table is a table of the Bow class of the player's performance in a scenario
-- scoring: wrong number of bows = 0 points, correct number of bows but not enough time = 1 point, correct number of bows and enough time = 2 points
function BowingConditions:compareConditionsAndScore(player_bow_table)
    if #player_bow_table ~= #self.conditions then
        return false
    end

    for i = 1, #self.conditions do
        if player_bow_table[i] < self.conditions[i] then
            return false
        end
    end

    return true
end

function BowingConditions:getConditions()
    return self.conditions
end
