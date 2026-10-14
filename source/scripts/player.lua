import "scripts/Bowing"
import "scripts/PlayerBow"
local pd = playdate

-- Player class, inherits from the Bowing class and represents the player character in the game.
class('Player').extends(Bowing)

-- Requires: character_sprite (CharacterSprite), x_position (number), y_position (number), speed (number)
function Player:init(character_sprite, x_position, y_position, speed)
    Player.super.init(self, character_sprite, x_position, y_position, speed)
    self.setUp(self)

    self.bow_table = {}      --what's this?
    self.bow_intervals = {}  --what's this?
    self.current_bow_start_time = 0
    self.current_bow_num = 0 --maybe 'total_bow_num'
    self.current_lowest_bow_frame = 0
    self.current_bow_timer = 0
    self.last_update_time = nil --scenario time of the previous setBowFrameIndex call
    self.starting_bow_frame = 0

    self.progress_in_current_frame = 0
    self.last_crank_position = 0
    self.current_frame = 1 --this being different from starting_bow_frame, does this mess anything up
    self.in_bow = false

    --the range of degrees in which each now frame can hold
    self.bow_frame_length = self.bow_range / self.max_bow_frames
end

-- Set up the player sprite and any other necessary properties
--can be abstracted to another class w Partner's setUp
function Player:setUp()
    self.character_sprite:moveTo(self.x, self.y)
    self.character_sprite:add()
end

-- Makes wherever the crank is right now count as the start of the frame the player is currently in.
-- The crank is tracked by how far it has moved since the last check, so this throws away any movement
-- that hasn't been used yet and forgets how far into the current frame the player had got.
-- Call it whenever the crank wasn't being read for a while: before a scenario starts, and when the game resumes.
function Player:resetCrank()
    pd.getCrankChange()
    self.progress_in_current_frame = 0
end

-- Sets the current frame of the player sprite based on the position of the crank.
-- param crankPosition (number): The position of the crank, which will be translated into a bow frame index (0-360)
-- param currentTime (number): The current time in seconds since the start of the scenario
function Player:setBowFrameIndex(currentTime)
    --seconds since the last call, taken from the scenario clock so it stays accurate at any frame rate
    --and freezes with the clock when paused
    local dt = currentTime - (self.last_update_time or currentTime)
    self.last_update_time = currentTime

    local change = pd.getCrankChange() --change in degrees since last check
    --progress_in_current_frame means the amount of degrees above this frame's 'starting point' we are
    --this is a little clunky because ideally we should never have a blip of time where progress_in_current_frame
    --is higher than the max
    self.progress_in_current_frame = self.progress_in_current_frame + change
    local framesToJump = math.floor(self.progress_in_current_frame / self.bow_frame_length)
    self.progress_in_current_frame = self.progress_in_current_frame % self.bow_frame_length

    self.current_frame = self.current_frame + framesToJump
    if self.current_frame > self.max_bow_frames then
        self.current_frame = self.max_bow_frames --cap out at the maximum bow frame
        self.progress_in_current_frame = self.bow_frame_length - 1
    end

    if self.current_frame < 1 then
        self.current_frame = 1
        self.progress_in_current_frame = 0
    end

    self.character_sprite:change_current_image(self.current_frame)

    --do we need bowFrameIndex if it's just current_frame?
    local bowFrameIndex = self.current_frame

    -- print("Bows: " .. self.current_bow_num .. " | Current Bow Frame Index: " ..
    --     bowFrameIndex .. " | Current Lowest Bow Frame: " .. self.current_lowest_bow_frame)

    -- if current bow frame is deeper than the lowest, update the lowest bow frame and reset the timer.
    if bowFrameIndex > self.current_lowest_bow_frame then
        self.current_lowest_bow_frame = bowFrameIndex
        self.current_bow_timer = 0 --this is looking eerily similar to data from partner. Could be abstracted
        self.current_bow_start_time = currentTime
        self.in_bow = true

        -- if current bow frame is equal to the lowest, add the time since the last update to the timer
    elseif bowFrameIndex == self.current_lowest_bow_frame then
        if bowFrameIndex ~= self.starting_bow_frame then
            self.current_bow_timer = self.current_bow_timer + dt
        end

        -- if the current bow frame is 2 frames less than the lowest, then the player has completed a bow. If the player then bows forward, a new bow is created.
        --this should probably be defined elsewhere, and be applicable to both player and partner
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
