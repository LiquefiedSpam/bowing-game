import "CoreLibs/object"
import "CoreLibs/graphics"

-- A parent class for all characters' sprites.
class('CharacterSprite').extends(Object)
local pd = playdate
local gfx = pd.graphics

-- Requires: bottom_sprite (string), sprite_sheet (string)
function CharacterSprite:init(self, bottom_sprite, sprite_sheet)
    self.bottom_sprite = gfx.image.new(bottom_sprite)
    self.top_sprite_sheet = gfx.imagetable.new(sprite_sheet)

    -- current image is preset to the first frame of the sprite sheet
    self.current_image = self.top_sprite_sheet:getImage(1)
    self.playerSprite = gfx.sprite.new(self.current_image)
end

-- Changes the current image of the character sprite to the image at the specified index in the sprite sheet.
-- Requires: image_index (number)
function CharacterSprite:change_current_image(self, image_index)
    local new_image = self.top_sprite_sheet:getImage(image_index)
    if new_image then
        self.current_image = new_image
        self.playerSprite:setImage(self.current_image)
    end
end
