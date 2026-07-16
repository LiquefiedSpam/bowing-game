import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "scripts/CharacterSprite"
import "scripts/Player"
import "scripts/Partner"
import "scripts/ScenarioManager"

local pd = playdate
local gfx = pd.graphics

local scenarioManager = ScenarioManager()
scenarioManager:init()

function pd.update()
    gfx.sprite.update()
    scenarioManager:update()
end
