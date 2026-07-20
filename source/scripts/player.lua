import "scripts/Bowing"
import "scripts/PlayerBow"
local pd = playdate

-- Player class, inherits from the Bowing class and represents the player character in the game.
class('Player').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Player:init(character_sprite, x_position, y_position, speed)
    Player.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)

    self.bow_table = {}
    self.bow_lengths = {}
    self.current_bow_num = 0
    self.current_lowest_bow_frame = 0
    self.current_bow_timer = 0
    self.starting_bow_frame = 0

    self.progress_in_current_frame = 0
    self.last_crank_position = 0
    self.current_frame = 1
    self.in_bow = false

    self.bow_frame_length = self.bow_range / self.max_bow_frames
end

-- Set up the player sprite and any other necessary properties
function Player:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
    self.last_crank_position = pd.getCrankPosition()
end

-- Sets the current frame of the player sprite based on the position of the crank.
-- param crankPosition (number): The position of the crank, which will be translated into a bow frame index (0-360)
function Player:setBowFrameIndex(crankPosition)
    if self.last_crank_position ~= crankPosition then
        local progress_current_frame_update = self.progress_in_current_frame + (crankPosition - self.last_crank_position)

        --if we should switch frames, keep doing so until we stop
        while progress_current_frame_update < 0 do
            progress_current_frame_update = self.bow_frame_length + progress_current_frame_update

            --don't progress past max amt of frames or go below 1
            if (self.current_frame == 1 or self.current_frame == self.max_bow_frames) then
                self.progress_current_frame = 0
                break;
            end

            self.current_frame = self.current_frame - 1
        end

        self.progress_in_current_frame = progress_current_frame_update


        if progress_current_frame_update > self.bow_frame_length then
        end
    end

    local bowFrameIndex = Player.super.setBowFrameIndex(self, crankPosition)
    -- print("Bows: " .. self.current_bow_num .. " | Current Bow Frame Index: " ..
    --     bowFrameIndex .. " | Current Lowest Bow Frame: " .. self.current_lowest_bow_frame)
    if bowFrameIndex > self.current_lowest_bow_frame then
        self.current_lowest_bow_frame = bowFrameIndex
        self.current_bow_timer = 0
        self.in_bow = true
    elseif bowFrameIndex == self.current_lowest_bow_frame then
        if bowFrameIndex ~= self.starting_bow_frame then
            self.current_bow_timer += (1 / 30) -- Assuming the update function is called at 30 FPS
        end
    elseif bowFrameIndex <= self.current_lowest_bow_frame - 2 then
        self.bow_table[self.current_bow_num] = self.current_bow_timer
        if self.in_bow then
            self.current_bow_num += 1
            self.in_bow = false
        end
        self.current_lowest_bow_frame = bowFrameIndex
        self.starting_bow_frame = bowFrameIndex
        self.current_bow_timer = 0
        print("Bow " ..
            self.current_bow_num ..
            " with time: " ..
            self.bow_table[self.current_bow_num - 1] ..
            " deepest bow frame: " .. self.current_lowest_bow_frame)
    end
end

function Player:getCurrentBowNum()
    return self.current_bow_num
end

function Player:getCurrentLowestBowFrame()
    return self.current_lowest_bow_frame
end

function Player:getBowTimer()
    return self.current_bow_timer
end
