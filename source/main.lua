import "scripts/GameStateManager"
import "scripts/BackgroundMusic"

--the main script that runs the game

local pd = playdate
local gfx = pd.graphics

local gameManager = GameStateManager()
gameManager:init()

--Called by the system when the player opens or closes the system menu
function pd.gameWillPause()
    gameManager:onPause()
end

function pd.gameWillResume()
    gameManager:onResume()
end

--The update function that calls every frame
function pd.update()
    gfx.sprite.update()
    gameManager:update()
end
