import "CoreLibs/object"
import "scripts/CharacterSprite"

-- A parent class for all bowing objects. This class will handle the bowing logic and provide a base for other classes to inherit from.
class('Bowing').extends(Object)

function Bowing:init(character_sprite, x_position, y_position, speed)
    self.character_sprite = character_sprite
    self.bowValue = 0
    self.x = x_position
    self.y = y_position
    self.speed = speed
    self.max_bow_frames = 10
    self.bow_range = 240
end
