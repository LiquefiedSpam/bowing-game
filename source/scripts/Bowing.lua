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
end

-- sets the `bowFrameIndex` based on object's current `bowValue`, and adjust the sprite's image accordingly
function Bowing:setBowFrameIndex(crankPosition)
    --translate crank position to a percentage of bow from 0 to 100. 0 is upright,
    -- 100 is maximum bow.
    local bowDistance = crankPosition
    if bowDistance > 180 then
        bowDistance = 360 - bowDistance
    end
    bowDistance = (bowDistance / 180) * 100

    --choose frame based on crank angle. Rounds to nearest whole number 0-10
    --and chooses corresponding frame
    local bowFrameIndex = math.floor((bowDistance / 10) + .5)
    self.character_sprite:change_current_image(bowFrameIndex)
end
