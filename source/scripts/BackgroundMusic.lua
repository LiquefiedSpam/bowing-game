class("BackgroundMusic").extends()

import "CoreLibs/graphics"
import "CoreLibs/animation" -- Required for playdate.graphics.animator

local gfx <const> = playdate.graphics

function BackgroundMusic:init()
    self.music = playdate.sound.fileplayer.new("sounds/bg-music.mp3")
    -- self.music:play(0)
    self.fadeAnimator = nil
    self.currentVolume = 0.0
    self:startFade(1.0, 2000)
end

function BackgroundMusic:startFade(targetVolume, durationMs)
    self.fadeAnimator = gfx.animator.new(durationMs, self.currentVolume, targetVolume, playdate.easingFunctions.linear)
end

function BackgroundMusic:update()
    if not self.music:isPlaying() then
        self.music:setVolume(1, 1, 2000) -- Fade in over 2 seconds
    end
end
