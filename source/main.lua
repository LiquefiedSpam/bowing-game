import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd = playdate
local gfx = pd.graphics


-- Player
local playerStartX = 80
local playerStartY = 80
local playerSpeed = 3
local playerImages = gfx.imagetable.new("images/player/playerSpriteSheet-table-300-300")
local playerImage = playerImages:getImage(1)
local playerSprite = gfx.sprite.new(playerImage)
playerSprite:moveTo(playerStartX, playerStartY)
playerSprite:add()

--Game State
local gameState = "stopped"
local score = 0

function pd.update()
    gfx.sprite.update()

    --game start / game over state
    if gameState == "stopped" then
        gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)
        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "active"
            score = 0
            playerSprite:moveTo(playerStartX, playerStartY)
        end
    elseif gameState == "active" then
        --translate crank position to a percentage of bow from 0 to 100. 0 is upright,
        -- 100 is maximum bow.
        local bowDistance = playdate.getCrankPosition()
        if bowDistance > 180 then
            bowDistance = 360 - bowDistance
        end
        bowDistance = (bowDistance / 180) * 100

        --choose frame based on crank angle. Rounds to nearest whole number 0-10
        --and chooses corresponding frame
        local bowFrameIndex = math.floor((bowDistance / 10) + .5)
        local bowFrameImage = playerImages:getImage(bowFrameIndex)
        if bowFrameImage then
            playerSprite:setImage(bowFrameImage)
        end

        --placeholder game over screen activation
        if pd.buttonJustPressed(pd.kButtonB) then
            gameState = "stopped"
        end
    end

    gfx.drawTextAligned("Score: " .. score, 390, 1, kTextAlignment.right)
end

-- -- Below is a small example program where you can move a circle
-- -- around with the crank. You can delete everything in this file,
-- -- but make sure to add back in a playdate.update function since
-- -- one is required for every Playdate game!
-- -- =============================================================

-- -- Importing libraries used for drawCircleAtPoint and crankIndicator
-- import "CoreLibs/graphics"
-- import "CoreLibs/ui"

-- -- Localizing commonly used globals
-- local pd <const> = playdate
-- local gfx <const> = playdate.graphics

-- -- Defining player variables
-- local playerSize = 10
-- local playerVelocity = 3
-- local playerX, playerY = 200, 120

-- -- Drawing player image
-- local playerImage = gfx.image.new(32, 32)
-- gfx.pushContext(playerImage)
--     -- Draw outline
--     gfx.drawRoundRect(4, 3, 24, 26, 1)
--     -- Draw screen
--     gfx.drawRect(7, 6, 18, 12)
--     -- Draw eyes
--     gfx.drawLine(10, 12, 12, 10)
--     gfx.drawLine(12, 10, 14, 12)
--     gfx.drawLine(17, 12, 19, 10)
--     gfx.drawLine(19, 10, 21, 12)
--     -- Draw crank
--     gfx.drawRect(27, 15, 3, 9)
--     -- Draw A/B buttons
--     gfx.drawCircleInRect(16, 20, 4, 4)
--     gfx.drawCircleInRect(21, 20, 4, 4)
--     -- Draw D-Pad
--     gfx.drawRect(8, 22, 6, 2)
--     gfx.drawRect(10, 20, 2, 6)
-- gfx.popContext()

-- -- Defining helper function
-- local function ring(value, min, max)
-- 	if (min > max) then
-- 		min, max = max, min
-- 	end
-- 	return min + (value - min) % (max - min)
-- end

-- -- playdate.update function is required in every project!
-- function playdate.update()
--     -- Clear screen
--     gfx.clear()
--     -- Draw crank indicator if crank is docked
--     if pd.isCrankDocked() then
--         pd.ui.crankIndicator:draw()
--     else
--         -- Calculate velocity from crank angle
--         local crankPosition = pd.getCrankPosition() - 90
--         local xVelocity = math.cos(math.rad(crankPosition)) * playerVelocity
--         local yVelocity = math.sin(math.rad(crankPosition)) * playerVelocity
--         -- Move player
--         playerX += xVelocity
--         playerY += yVelocity
--         -- Loop player position
--         playerX = ring(playerX, -playerSize, 400 + playerSize)
--         playerY = ring(playerY, -playerSize, 240 + playerSize)
--     end
--     -- Draw text
--     gfx.drawTextAligned("Template configured!", 200, 30, kTextAlignment.center)
--     -- Draw player
--     playerImage:drawAnchored(playerX, playerY, 0.5, 0.5)
-- end
