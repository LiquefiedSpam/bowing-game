import "scripts/Bowing"
import "scripts/Bow"

-- Player class, inherits from the Bowing class and represents the player character in the game.
class('Player').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Player:init(character_sprite, x_position, y_position, speed)
    Player.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)

    self.bow_table = {}
    self.current_bow_num = 0
    self.current_bow = Bow(0)
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
    -- print("Current Bow Frame Index: " ..
    --     bowFrameIndex .. " | Current Lowest Bow Frame: " .. self.current_bow:getCurrentLowestBowFrame())
    if bowFrameIndex > self.current_bow:getCurrentLowestBowFrame() then
        self.current_bow:setCurrentLowestBowFrame(bowFrameIndex)
        self.current_bow:setBowTimer(0.0)
    elseif bowFrameIndex == self.current_bow:getCurrentLowestBowFrame() then
        if bowFrameIndex ~= self.current_bow:getCurrentBowFrame() then
            self.current_bow:setBowTimer(self.current_bow:getBowTimer() + (1 / 30)) -- Assuming the update function is called at 30 FPS
        end
    elseif bowFrameIndex <= self.current_bow:getCurrentLowestBowFrame() - 2 then
        self.current_bow:setBowTimer(math.floor(self.current_bow:getBowTimer() + 0.01))
        self.bow_table[self.current_bow_num] = self.current_bow:getBowTimer()

        print("Bow " ..
            self.current_bow_num ..
            " completed with time: " ..
            self.current_bow:getBowTimer() ..
            " deepest bow frame: " .. self.current_bow:getCurrentLowestBowFrame())

        self.current_bow_num += 1
        self.current_bow = Bow(bowFrameIndex)
        self.current_bow:setCurrentLowestBowFrame(bowFrameIndex)
    end
end

function Player:getCurrentBowNum()
    return self.current_bow:getCurrentBowFrame()
end

function Player:getCurrentLowestBowFrame()
    return self.current_bow:getCurrentLowestBowFrame()
end

function Player:getBowTimer()
    return self.current_bow:getBowTimer()
end
