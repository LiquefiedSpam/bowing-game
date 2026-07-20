import "CoreLibs/object"
import "CoreLibs/graphics"

-- A parent class for all characters' sprites.
class('CharacterSprite').extends(Object)
local pd = playdate
local gfx = pd.graphics

-- Requires: bottom_sprite (string), sprite_sheet (string)
function CharacterSprite:init(bottom_sprite, sprite_sheet)
    self.bottom_sprite = gfx.image.new(bottom_sprite)
    self.top_sprite_sheet = gfx.imagetable.new(sprite_sheet)


    --walking state for the walk-in animation
    -- state for the walk-in animation
    self.walking = false
    self.walkTarget = 0
    self.walkSpeed = 4
    self.slowRadius = 25 --distance from target when we start slowing down


    -- current image is preset to the first frame of the sprite sheet
    self.current_image = self.top_sprite_sheet:getImage(1)
    self.playerSprite = gfx.sprite.new(self.current_image)

    -- if blow_up then
    --     self.playerSprite:setScale(1.5)
    -- else
    --     self.playerSprite:setScale(1)
    -- end
end

-- Changes the current image of the character sprite to the image at the specified index in the sprite sheet.
-- Requires: image_index (number)
function CharacterSprite:change_current_image(image_index)
    local new_image = self.top_sprite_sheet:getImage(image_index)
    if new_image then
        self.current_image = new_image
        self.playerSprite:setImage(self.current_image)
    end
end

--update the walk-in 'animation'
function CharacterSprite:updateWalkIn()
    if not self.walking then return end
    --this logic handles advancing the x value
    local dist = math.abs(self.walkTarget - self.playerSprite.x)
    if dist <= 1 then
        self.playerSprite:moveTo(self.walkTarget, self.playerSprite.y)
        self.walking = false
        self.hasWalkedIn = true
        self.startedWalkingIn = false
        return
    end

    local step = self.walkSpeed
    if dist < self.slowRadius then
        step = self.walkSpeed * (dist / self.slowRadius)
    end

    local newX = self.playerSprite.x + step

    --this logic handles the y value 'bounce'
    --we tie the bounce speed to 'step' from above
    self.bouncePhase += math.abs(step) * self.bounceFrequency
    local bounceOffset = math.sin(self.bouncePhase) * self.bounceAmplitude

    --clamp offset
    --bounceOffset = math.abs(bounceOffset)

    self.playerSprite:moveTo(newX, self.baseY + bounceOffset)
end

--start the walk-in 'animation'
function CharacterSprite:startWalkIn(walkIn, isPlayer)
    self.hasWalkedIn = false
    self.startedWalkingIn = true
    self.walking = true
    self.baseY = 240
    self.bouncePhase = 0
    self.bounceAmplitude = 4   --small bounce
    self.bounceFrequency = 0.3 --how many 'bounces' per pixel walked

    if walkIn then
        if isPlayer then
            self.playerSprite:moveTo(0, self.baseY) -- start off-screen, 0 is dummy approximate value
            self.walkTarget = 230
            self.walkSpeed = 3
        else
            --self.playerSprite:moveTo(600, self.baseY) -- start off-screen, 600 is dummy approximate value
            self.walkTarget = 600 -- dummy approximate value
            self.walkSpeed = 3
        end
    else
        if isPlayer then
            --self.playerSprite:moveTo(0, self.baseY) -- start off-screen, 0 is dummy approximate value
            self.walkTarget = 0
            self.walkSpeed = -3
        else
            self.playerSprite:moveTo(550, self.baseY) -- start off-screen, 600 is dummy approximate value
            self.walkTarget = 430                     -- dummy approximate value
            self.walkSpeed = -3
        end
    end
end

function CharacterSprite:moveTo(x, y)
    self.playerSprite:moveTo(x, y)
end

function CharacterSprite:add()
    self.playerSprite:add()
end
