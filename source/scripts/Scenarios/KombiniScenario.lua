import "scripts/Bow"

-- KombiniScenario class that extends the Scenario class and represents the Kombini scenario in the game.
class("KombiniScenario").extends()

local Actions = { --for now we can just make sure in the code to not select an action
    --that doesn't work with the current location I guess
    CHECKOUT = 1,
}

function KombiniScenario:init(scenario_type)
    if scenario_type == Actions.CHECKOUT then
        KombiniScenario.super.init(
            self,
            "Checkout",
            nil,
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
function KombiniScenario:calculateScore(player_bow_table, player_intervals)
    return KombiniScenario.super.calculateScore(self, player_bow_table, player_intervals)
end
