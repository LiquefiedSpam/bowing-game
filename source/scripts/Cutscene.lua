import "scripts/CutsceneBox"

-- Cutscene class, represents a cutscene in the game, which displays a sequence of boxes with sound effects.
--should note that this is only a cutscene for the introduction of what a scenario will be comprised of.
class("Cutscene").extends()

-- SHARED CONSTANTS for the whole sequence
local interval_between_boxes = 1 --the time in seconds between boxes appearing
local slide_stagger = .3         --seconds after a box starts sliding before the next one starts
local max_gap = 24               --widest gap allowed between boxes, so a few boxes stay grouped

-- Cutscene class constructor.
-- box_specs: a list with one entry per box, in order.
-- Any number of boxes technically works.
-- Each box_specs spec is: {path = ..., is_animated = ..., blank_frames_at_end = ... (optional)}
function Cutscene:init(box_specs)
    --the single clock the whole sequence is calculated from. Pausing = not advancing it.
    self.clock = 0

    --first part is defined as all the boxes showing up before they move off screen. It ends one
    --interval after the last box appears.
    local slide_phase_start = (#box_specs + 1) * interval_between_boxes

    self.boxes = {}
    for i, spec in ipairs(box_specs) do
        local appear_time = i * interval_between_boxes
        local slide_start = slide_phase_start + (i - 1) * slide_stagger
        self.boxes[i] = CutsceneBox(spec.path, spec.is_animated, appear_time, slide_start, spec.blank_frames_at_end)
    end

    self:layout_boxes()
end

-- Spreads the boxes across the screen. Gaps are equal and fill the screen (outer margins equal to the
-- gaps) but never wider than max_gap; the resulting group is then centered.
function Cutscene:layout_boxes()
    local count = #self.boxes
    if count == 0 then
        return
    end

    local total_width = 0
    for _, box in ipairs(self.boxes) do
        total_width = total_width + box:get_width()
    end

    local screen_width = playdate.display.getWidth()
    local gap = (screen_width - total_width) / (count + 1)
    gap = math.max(0, math.min(max_gap, gap))

    local group_width = total_width + gap * (count - 1)
    local x = (screen_width - group_width) / 2
    for _, box in ipairs(self.boxes) do
        box:set_x(math.floor(x))
        x = x + box:get_width() + gap
    end
end

-- Advances the cutscene by dt seconds and draws it. Returns true once every box has slid off screen.
function Cutscene:draw(dt)
    self.clock = self.clock + dt

    local all_finished = true
    for _, box in ipairs(self.boxes) do
        box:update(self.clock)
        box:draw()
        if not box:is_finished() then
            all_finished = false
        end
    end

    return all_finished
end
