import "CoreLibs/object"
import "CoreLibs/graphics"

-- A parent class for all characters' sprites.
class('CharacterSprite').extends(Object)

function CharacterSprite:init(self, bottom_sprite, top_sprite, sprite_sheet)
    self.bottom_sprite = gfx.image.new(bottom_sprite)
    self.top_sprite = gfx.image.new(top_sprite)
    self.sprite_sheet = gfx.image.new(top_sprite)
end
