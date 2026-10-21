import "CoreLibs/easing"

-- CutsceneBox class: one box in the intro cutscene. It owns everything that is specific to
-- that box (image, position, its own state).
-- Cutscene loops over boxes without caring what kind they are.
class("CutsceneBox").extends()

local gfx = playdate.graphics
local box_sfx = playdate.sound.fileplayer.new("sounds/box_add_sfx.mp3") --one resource shared by all boxes

-- SHARED CONSTANTS: written once, identical for every box.
CutsceneBox.starting_y = 64                                 --each box starting y coord
CutsceneBox.offscreen_y = -300                              --where a box ends up after sliding up
CutsceneBox.slide_duration = 1.5                            --seconds a box takes to slide off screen
CutsceneBox.slide_easing = playdate.easingFunctions.inCubic --slow start, fast finish
CutsceneBox.animation_duration = 1                          --seconds an animated box takes to play its frames

-- Constructor. Only takes what the box cannot work out for itself ("given" values).
-- image_path: a single image, or an imagetable if is_animated is true.
-- is_animated: true if image_path is an imagetable (frames), false for a single image.
-- appear_time / slide_start: cutscene clock times (seconds) at which this box appears / starts sliding up.
-- blank_frames_at_end: (optional, default 0) how many empty cells the spritesheet has after the last real
-- frame. A spritesheet has to be a full grid, so these cells exist but must never be shown.
-- The x position is not given here: it depends on every box's width, so the Cutscene sets it
-- afterwards with set_x once the layout is known.
function CutsceneBox:init(image_path, is_animated, appear_time, slide_start, blank_frames_at_end)
    -- GIVEN
    self.is_animated = is_animated
    if is_animated then
        self.frames = gfx.imagetable.new(image_path)
        --DERIVED: the frames that actually have something in them
        self.frame_count = #self.frames - (blank_frames_at_end or 0)
    else
        self.image = gfx.image.new(image_path)
    end
    self.appear_time = appear_time
    self.slide_start = slide_start

    -- DERIVED (never changes after creation, so computed once)
    self.slide_end = slide_start + CutsceneBox.slide_duration

    --values that change while the cutscene runs
    self.x = 0
    self.y = CutsceneBox.starting_y
    self.visible = false
    self.finished = false
    self.sound_played = false
    self.cur_anim_frame = 1 --only used by animated boxes
end

function CutsceneBox:set_x(x)
    self.x = x
end

-- The image to draw right now (the current frame for animated boxes).
function CutsceneBox:current_image()
    if self.is_animated then
        return self.frames:getImage(self.cur_anim_frame)
    end
    return self.image
end

function CutsceneBox:get_width()
    local width = self:current_image():getSize()
    return width
end

-- Work out where this box is at the given cutscene clock time (seconds).
-- Everything is calculated from the clock, so nothing accumulates and nothing can drift.
function CutsceneBox:update(clock)
    self.visible = clock >= self.appear_time

    if self.visible and not self.sound_played then
        box_sfx:play()
        self.sound_played = true
    end

    if self.is_animated then
        --spread the frames evenly over animation_duration, starting when the box appears
        local progress = (clock - self.appear_time) / CutsceneBox.animation_duration
        progress = math.max(0, math.min(1, progress))
        self.cur_anim_frame = math.min(self.frame_count, math.floor(progress * self.frame_count) + 1)
    end

    --easing(elapsed, start value, change in value, duration)
    local elapsed = math.max(0, math.min(CutsceneBox.slide_duration, clock - self.slide_start))
    self.y = CutsceneBox.slide_easing(
        elapsed,
        CutsceneBox.starting_y,
        CutsceneBox.offscreen_y - CutsceneBox.starting_y,
        CutsceneBox.slide_duration)

    self.finished = clock >= self.slide_end
end

-- Draw this box at its current position. Called every frame, including while it is moving.
function CutsceneBox:draw()
    if self.visible then
        self:current_image():draw(self.x, self.y)
    end
end

-- True once this box has finished sliding off screen.
function CutsceneBox:is_finished()
    return self.finished
end
