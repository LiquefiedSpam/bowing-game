import "scripts/bowingClass"

class('Player').extends(bowingClass)

function Player:init(x_position, y_position, speed)
    Player.super.init(self, x_position, y_position, speed)
    self.image = gfx.image.new("images/characterMovingPrototype")
    self.sprite = gfx.sprite.new(self.image)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()
end
