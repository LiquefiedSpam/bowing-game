-- Bow class that holds data for a single bow, including the starting frame, current bow number, lowest bow frame, and timer.
class('Bow').extends()

function Bow:init(starting_bow_frame)
    self.current_bow_frame = starting_bow_frame
    self.current_lowest_bow_frame = 0
    self.current_bow_timer = 0.0
end

-- alternative constructor to initialize a Bow object with specific values for the current bow frame, lowest bow frame, and timer.
-- this is for comparing bows in the Bow Conditions class
function Bow:init(current_lowest_bow_frame, current_bow_timer)
    self.current_bow_frame = 0
    self.current_lowest_bow_frame = current_lowest_bow_frame
    self.current_bow_timer = current_bow_timer
end

function Bow:getCurrentBowFrame()
    return self.current_bow_frame
end

function Bow:getCurrentLowestBowFrame()
    return self.current_lowest_bow_frame
end

function Bow:getBowTimer()
    return self.current_bow_timer
end

function Bow:setCurrentBowFrame(frame)
    self.current_bow_frame = frame
end

function Bow:setCurrentLowestBowFrame(frame)
    self.current_lowest_bow_frame = frame
end

function Bow:setBowTimer(timer)
    self.current_bow_timer = timer
end
