-- PlayerBow class that holds data for a single bow, including the starting frame, current bow number, lowest bow frame, and timer.
class('PlayerBow').extends()

-- current_bow_frame is the starting frame of the bow
-- current_lowest_bow_frame is the lowest frame reached during the bow
-- current_bow_timer is the time spent in the bow.
function PlayerBow:init(starting_bow_frame, current_lowest_bow_frame, current_bow_timer)
    self.current_bow_frame = starting_bow_frame or 0
    self.current_lowest_bow_frame = current_lowest_bow_frame or 0
    self.current_bow_timer = current_bow_timer or 0.0
end

function PlayerBow:getCurrentBowFrame()
    return self.current_bow_frame
end

function PlayerBow:getCurrentLowestBowFrame()
    return self.current_lowest_bow_frame
end

function PlayerBow:getBowTimer()
    return self.current_bow_timer
end

function PlayerBow:setCurrentBowFrame(frame)
    self.current_bow_frame = frame
end

function PlayerBow:setCurrentLowestBowFrame(frame)
    self.current_lowest_bow_frame = frame
end

function PlayerBow:setBowTimer(timer)
    self.current_bow_timer = timer
end
