import "CoreLibs/object"

-- A parent class for all bowing objects. This class will handle the bowing logic and provide a base for other classes to inherit from.
class('Bowing').extends(Object)

function Bowing:init(self, bottom_sprite, top_sprite, x_position, y_position, speed)
    self.bowValue = 0
    self.bowFrameIndex = 0
    self.x = x_position
    self.y = y_position
    self.speed = speed
end

-- sets the `bowFrameIndex` based on object's current `bowValue`.
function Bowing:setBowFrameIndex()
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
    return bowFrameIndex
end
