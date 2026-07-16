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
            { 1, 2, 3 },
            0.5
        )
    else
        error("Invalid scenario type: " .. tostring(scenario_type))
    end
end
