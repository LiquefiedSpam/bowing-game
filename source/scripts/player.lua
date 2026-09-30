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

--notes the crank position at the start of a scenario. It's a little clunky that it's its own method
--here because it's not really a universally applicable thing, it is called once per scenario at one time
--also probably not ideal to introduce new self variables in a method like this
function Player:setInitialCrankPos(crankPos)
    if crankPos == 0 then
        self.initial_crank_pos = 1 --this may be a little lazy way of doing this
    else
        self.initial_crank_pos = crankPos
    end
    --if we treat initial_crank_pos to equal 0, max_crank_num is the max of the degrees we can bow with,
    --so it'll be (bow_range). The thing is, the player can start a scenario at any (initial_crank_pos),
    --so max_crank_num needs to adapt to that-- it'll be (initial_crank_pos) + (bow_range). However, when we
    --look at this number as degrees it gets complicated quick when this value is over 360, so we adjust for that
    --and then introduce the crank_can_overflow variable to account for if we cross the 360 -> 0 threshold.
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
function Player:setBowFrameIndex(currentTime)
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

        -- if current bow frame is equal to the lowest, increment the timer by 1/30th of a second (assuming 30 FPS)
    elseif bowFrameIndex == self.current_lowest_bow_frame then
        if bowFrameIndex ~= self.starting_bow_frame then
            self.current_bow_timer = self.current_bow_timer +
                (1 / 30) -- Assuming the update function is called at 30 FPS
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
