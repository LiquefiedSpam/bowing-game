import "scripts/bowingClass"

-- Player class, inherits from the Bowing class and represents the player character in the game.
class('Player').extends(bowingClass)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Player:init(character_sprite, x_position, y_position, speed)
    Player.super.init(self, character_sprite, x_position, y_position, speed)
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- Set up the player sprite and any other necessary properties
function Player:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end
