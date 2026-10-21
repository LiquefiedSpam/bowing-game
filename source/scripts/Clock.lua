-- Clock class: a single source of "how many seconds have passed" that you advance by hand.
-- Everything time-based should be calculated from now() instead of keeping its own counter.
-- Pausing = the clock stops advancing, so everything derived from it freezes together.
class("Clock").extends()

function Clock:init()
    self.time = 0
    self.paused = false
end

-- Advances the clock by dt seconds. Does nothing while paused.
function Clock:advance(dt)
    if not self.paused then
        self.time = self.time + dt
    end
end

-- Seconds elapsed on this clock.
function Clock:now()
    return self.time
end

function Clock:pause()
    self.paused = true
end

function Clock:resume()
    self.paused = false
end

function Clock:is_paused()
    return self.paused
end

-- Sets the clock back to 0. Does not change whether it is paused.
function Clock:reset()
    self.time = 0
end
