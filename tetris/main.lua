-- Main file that LOVE runs
--
-- @author Ryuho Kudo

-- Require HUMP
require "hump.vector"
require "hump.camera"
Gamestate = require "hump.gamestate"
Class = require "hump.class"

-- highscore lib
highscore = require("sick")

-- For Random numbers
require "math"

-- Global Vars (technically, there's no constants)
-- Also, sadly we can't pull in from config...
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

ASSETS = { }

local gameState      = require("gameState")

-- convenience renaming (Aliases for ease of typing)
local vector = hump.vector
local camera = hump.camera

function love.load()
   -- Init all of our textures and fonts
   ASSETS.verySmallFont = love.graphics.newFont(15)
   ASSETS.smallFont     = love.graphics.newFont(25)
   ASSETS.largeFont     = love.graphics.newFont(50)
   ASSETS.bgMusic       = love.audio.newSource("assets/music/teru_-_Goodbye_War_Hello_Peace.mp3")

   -- Initialize the pseudo random number generator
   math.randomseed(os.time())
   -- The description page for Math says the first few values aren't so random. Burn a few.
   math.random(); math.random(); math.random()

   Gamestate.registerEvents()
   Gamestate.switch(menuGameState)

   -- Start the music, and just keep it looping
   love.audio.play(ASSETS.bgMusic)

   -- Init the Camera
   cam = camera.new(vector.new(0,0))

   -- Load the Highscore (Only call once!)
   highscore_filename = "highscores.txt"
   local places = 10

   highscore.set(highscore_filename, places, "Anony", 0)
end


function love.update(dt)
end

function love.draw()
end

function love.keypressed(key, unicode)
end

function love.quit()
   highscore.save()

   for i, score, name in highscore() do
      -- print(i .. '. ' .. name .. "\t:\t" .. score)
   end

   print("Thanks for playing. Please play again soon!")
end
