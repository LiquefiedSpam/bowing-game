import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "scripts/CharacterSprite"
import "scripts/Player"
import "scripts/Partner"
import "scripts/ScenarioManager"

local pd = playdate
local gfx = pd.graphics


--Game State
local gameState = "stopped"

local scenarioManager = ScenarioManager()
scenarioManager:init()

-- Main Menu
local mainMenu = gfx.image.new("images/UI_screens/MainMenu.png")

function pd.update()
    gfx.sprite.update()
    scenarioManager:update()
end
