import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "scripts/CharacterSprite"
import "scripts/Player"
import "scripts/Partner"
import "scripts/ScenarioManager"

local pd = playdate
local gfx = pd.graphics

-- Player
local playerSprite = CharacterSprite(
    "images/player/playerBottom.png",
    "images/player/playerSpriteSheet-table-300-300",
    0)
local playerObj = Player(playerSprite, 110, 100, 3)
playerSprite:add()

-- Partner
local partnerSprite = CharacterSprite(
    "images/player/playerBottom.png",
    "images/player/playerSpriteSheet-table-300-300",
    130)
local partnerObj = Partner(partnerSprite, 590, 100, 3)
partnerSprite:add()

--Game State
local gameState = "stopped"
local score = 0

local scenarioManager = ScenarioManager()
scenarioManager:add()

function pd.update()
    gfx.sprite.update()
    playerSprite:updateWalkIn()
    partnerSprite:updateWalkIn()
    if playerSprite.hasWalkedIn then
        gameState = "active"
    end

    --game start / game over state
    if gameState == "stopped" and not playerSprite.walking then
        gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)
        if pd.buttonJustPressed(pd.kButtonA) and not playerSprite.startedWalkingIn then
            playerSprite:startWalkIn(true, 100)
            partnerSprite:startWalkIn(false, 100)
        end
    elseif gameState == "active" then
        playerObj:setBowFrameIndex(pd.getCrankPosition())
        if pd.buttonJustPressed(pd.kButtonB) then
            gameState = "stopped"
        end
    end

    gfx.drawTextAligned("Score: " .. score, 390, 1, kTextAlignment.right)
    gfx.drawTextAligned("Bows: " .. playerObj:getCurrentBowNum(), 240, 20, kTextAlignment.right)
    gfx.drawTextAligned("Lowest Bow Frame: " .. playerObj:getCurrentLowestBowFrame(), 240, 40, kTextAlignment.right)
    gfx.drawTextAligned("Bow Timer: " .. playerObj:getBowTimer(), 240, 60, kTextAlignment.right)
end
