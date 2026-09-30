import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "scripts/CharacterSprite"
import "scripts/Player"
import "scripts/Partner"
import "scripts/ScenarioManager"
import "scripts/HeartScreen"
import "scripts/BackgroundMusic"

--the main script that runs the game

local pd = playdate
local gfx = pd.graphics

local scenarioManager = ScenarioManager()
scenarioManager:init()

--The update function that calls every frame
function pd.update()
    gfx.sprite.update()
    scenarioManager:update()
end
