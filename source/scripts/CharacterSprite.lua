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
    self.slowRadius = 25


    -- current image is preset to the first frame of the sprite sheet
    self.current_image = self.top_sprite_sheet:getImage(1)
    self.playerSprite = gfx.sprite.new(self.current_image)
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

function CharacterSprite:updateWalkIn()
    if not self.walking then return end

    local dist = math.abs(self.walkTarget - self.playerSprite.x)
    if dist <= 1 then
        self.playerSprite:moveTo(self.walkTarget, self.playerSprite.y)
        self.walking = false
        self.hasWalkedIn = true
        return
    end

    local step = self.walkSpeed
    if dist < self.slowRadius then
        step = self.walkSpeed * (dist / self.slowRadius)
    end

    self.playerSprite:moveTo(self.playerSprite.x + step, self.playerSprite.y)
end

function CharacterSprite:startWalkIn(walkIn, playerStartY)
    self.startedWalkingIn = true
    self.walking = true
    if walkIn then
        self.playerSprite:moveTo(0, playerStartY) -- start off-screen
        self.walkTarget = 130
        self.walkSpeed = 3
    else
        self.walkTarget = -50
        self.walkSpeed = -3
    end
end

function CharacterSprite:moveTo(x, y)
    self.playerSprite:moveTo(x, y)
end

function CharacterSprite:add()
    self.playerSprite:add()
end
