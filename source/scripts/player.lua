import "scripts/Bowing"

-- Player class, inherits from the Bowing class and represents the player character in the game.
class('Player').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Player:init(character_sprite, x_position, y_position, speed)
    Player.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)

    self.bow_table = {}
    self.current_bow_num = 0
    self.current_lowest_bow_frame = 0
    self.current_bow_timer = 0
end

-- Set up the player sprite and any other necessary properties
function Player:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- Sets the current frame of the player sprite based on the position of the crank.
-- param crankPosition (number): The position of the crank, which will be translated into a bow frame index (0-360)
function Player:setBowFrameIndex(crankPosition)
    local bowFrameIndex = Player.super.setBowFrameIndex(self, crankPosition)
    if bowFrameIndex < self.current_lowest_bow_frame then
        self.current_lowest_bow_frame = bowFrameIndex
        self.current_bow_timer = 0
    elseif bowFrameIndex == self.current_lowest_bow_frame then
        self.current_bow_timer += (1 / 30) -- Assuming the update function is called at 30 FPS
    elseif bowFrameIndex >= self.current_lowest_bow_frame + 2 then
        self.current_bow_timer = math.floor(self.current_bow_timer + 0.01)
        self.bow_table[self.current_bow_num] = self.current_bow_timer
        self.current_bow_num += 1
        self.current_lowest_bow_frame = bowFrameIndex
        self.current_bow_timer = 0
    end
end

