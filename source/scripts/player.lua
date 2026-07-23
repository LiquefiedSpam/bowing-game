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
    self.bow_intervals = {}
    self.current_bow_start_time = 0
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
end

function Player:setInitialCrankPos(crankPos)
    if crankPos == 0 then
        self.initial_crank_pos = 1
    else
        self.initial_crank_pos = crankPos
    end
    self.max_crank_num = crankPos + self.bow_range
    if self.max_crank_num > 360 then
        self.max_crank_num = self.max_crank_num - 360
        self.crank_can_overflow = true
    else
        self.crank_can_overflow = false
    end
end

-- Sets the current frame of the player sprite based on the position of the crank.
-- param crankPosition (number): The position of the crank, which will be translated into a bow frame index (0-360)
-- param currentTime (number): The current time in seconds since the start of the scenario
function Player:setBowFrameIndex(crankPosition, currentTime)
    if (self.crank_can_overflow ~= true and crankPosition >= self.initial_crank_pos and crankPosition <= self.max_crank_num) then
        self.current_frame = math.floor((crankPosition - self.initial_crank_pos) / self.bow_frame_length)
    else
        if self.crank_can_overflow then
            if crankPosition <= 360 and crankPosition >= self.initial_crank_pos then
                self.current_frame = math.floor((crankPosition - self.initial_crank_pos) / self.bow_frame_length)
            else
                if crankPosition >= 0 and crankPosition <= self.max_crank_num then
                    self.current_frame = math.floor((crankPosition + 360 - self.initial_crank_pos) /
                    self.bow_frame_length)
                end
            end
        end
    end
    self.character_sprite:change_current_image(self.current_frame)

    local bowFrameIndex = self.current_frame
    -- print("Bows: " .. self.current_bow_num .. " | Current Bow Frame Index: " ..
    --     bowFrameIndex .. " | Current Lowest Bow Frame: " .. self.current_lowest_bow_frame)

    -- if current bow frame is deeper than the lowest, update the lowest bow frame and reset the timer.
    if bowFrameIndex > self.current_lowest_bow_frame then
        self.current_lowest_bow_frame = bowFrameIndex
        self.current_bow_timer = 0
        self.current_bow_start_time = currentTime
        self.in_bow = true

        -- if current bow frame is equal to the lowest, increment the timer by 1/30th of a second (assuming 30 FPS)
    elseif bowFrameIndex == self.current_lowest_bow_frame then
        if bowFrameIndex ~= self.starting_bow_frame then
            self.current_bow_timer += (1 / 30) -- Assuming the update function is called at 30 FPS
        end

        -- if the current bow frame is 2 frames less than the lowest, then the player has completed a bow. If the player then bows forward, a new bow is created.
    elseif bowFrameIndex <= self.current_lowest_bow_frame - 2 then
        -- if we are in a bow, stop being in the bow.
        -- else, update the current bow data to append to table
        if self.in_bow then
            local completed_bow = PlayerBow(
                self.starting_bow_frame,
                self.current_lowest_bow_frame,
                self.current_bow_timer)
            table.insert(self.bow_table, completed_bow)

            table.insert(self.bow_intervals, { self.current_bow_start_time, self.current_bow_start_time +
            self.current_bow_timer })

            self.current_bow_num = #self.bow_table
            self.in_bow = false

            print("Bow " ..
                self.current_bow_num ..
                " with time: " ..
                completed_bow:getBowTimer() ..
                " deepest bow frame: " .. self.current_lowest_bow_frame)
        end

        self.current_lowest_bow_frame = bowFrameIndex
        self.starting_bow_frame = bowFrameIndex
        self.current_bow_timer = 0
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

function Player:getCurrentBowFrame()
    return self.current_frame
end
