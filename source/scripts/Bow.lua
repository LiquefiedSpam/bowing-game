-- Bow class that holds data for a single bow, including the starting frame, current bow number, lowest bow frame, and timer.
class('Bow').extends()

function Bow:init(starting_bow_frame)
    self.current_bow_frame = starting_bow_frame
    self.current_lowest_bow_frame = 0
    self.current_bow_timer = 0.0
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
