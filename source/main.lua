--WE DO NOT NEED ALL THESE IMPORTS
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "scripts/CharacterSprite"
import "scripts/Player"
import "scripts/Partner"
import "scripts/ScenarioManager"
import "scripts/BackgroundMusic"

--the main script that runs the game

local pd = playdate
local gfx = pd.graphics

local scenarioManager = ScenarioManager()
scenarioManager:init()

--Called by the system when the player opens or closes the system menu
function pd.gameWillPause()
    scenarioManager:onPause()
end

function pd.gameWillResume()
    scenarioManager:onResume()
end

--The update function that calls every frame
function pd.update()
    gfx.sprite.update()
    scenarioManager:update()
end
