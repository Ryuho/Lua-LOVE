
--constants
local unit = 24
local xDim = 11
local yDim = 21



local selected = 1

-- tetrisGameState and it's global variable
tetrisGameState = Gamestate.new()
local score = 0
local lines = 0
local playTime = 0
local nextBlock = -1
local swapBlock = -1

blocks = {}

local current
local currBlocks

-- Initialize the pseudo random number generator
math.randomseed(os.time())
-- The description page for Math says the first few values aren't so random. Burn a few.
math.random(); math.random(); math.random()



-- settingsGameState
settingsGameState = Gamestate.new()

-- highScoreState
highScoreState = Gamestate.new()


-- menuGameState
menuGameState = Gamestate.new()

-- gameOverState
gameOverState = Gamestate.new()

local blockTable = {{1, {0,0},{1,0},{0,1},{1,1}},  -- cube
               {2, {0,0},{1,0},{-1,0},{-2,0}},        -- tetirs
               {4, {0,0},{1,0},{-1,0},{0,1}},       -- stand
               {2, {0,0},{-1,0},{0,1},{1,1}},        -- Z
               {2, {0,0},{1,0},{0,1},{-1,1}},        -- reverse Z
               {4, {0,0},{1,0},{-1,0},{-1,1}},        -- L
               {4, {0,0},{-1,0},{1,0},{1,1}}}      -- reverse L
               
               
local colorTable = {{255, 0, 0, 255},  -- pure red
               {0, 255, 0, 255},       -- pure green
               {0, 0, 255, 255},       -- pure blue
               {0, 255, 255, 255},     -- cyan
               {255, 0, 255, 255},     -- purple
               {255, 255, 0, 255},     -- yellow
               {255, 165, 0, 255}}     -- orange


               
function menuGameState:draw()
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("Tetris", SCREEN_WIDTH/2 - 90, 100, 0, 1, 1)

   local madeByText = {
      "Made by: Ryuho Kudo",
      "         (ryuhokudo@gmail.com)"
   }

   love.graphics.setColor(255, 255, 255)
   love.graphics.setFont(ASSETS.verySmallFont)
   for i, line in pairs(madeByText) do
      love.graphics.print(line, SCREEN_WIDTH-250, (i * 15) + SCREEN_HEIGHT-50)
   end

   drawMenuItems()
   
end

function menuGameState:keyreleased(key)
   if key == 'escape' then
      love.event.push('q')
   end
   if key == 'up' or key == 'k' or key == 'w' then
      if selected ~= 1 then
         selected = selected - 1
         drawMenuItems()
      else 
         selected = 4
      end
   elseif key == 'down' or key == 'j' or key == 's' then
      if selected ~= #menuText then
         selected = selected + 1
         drawMenuItems()
      else
         selected = 1
      end
   elseif key == 'return' then
      if selected == 1 then
         newGame()
      end
      if selected == 2 then
         Gamestate.switch(highScoreState)
      end
      if selected == 3 then
         Gamestate.switch(settingsGameState)
      end
      if selected == 4 then
         love.event.push('q')
      end
   end
end

function menuGameState:mousepressed(x, y, button)
   local textStartX = 150
   local textStartY = 200
   if x > textStartX and x < textStartX + 275 and y > textStartY  + 90*0 and y < textStartY + 90*1 then
      newGame()
   elseif x > textStartX and x < textStartX + 300 and y > textStartY  + 90*1 and y < textStartY + 90*2 then
      Gamestate.switch(highScoreState)
   elseif x > textStartX and x < textStartX + 205 and y > textStartY  + 90*2 and y < textStartY + 90*3 then
      Gamestate.switch(settingsGameState)
   elseif x > textStartX and x < textStartX + 125 and y > textStartY  + 90*3 and y < textStartY + 90*4 then
      love.event.push('q')
   end
end

function tetrisGameState:draw()
   -- draw the tetris grid
   love.graphics.setColor(0, 255, 255, 255)
   love.graphics.setLineWidth( 1 )
   local initX = 280
   local initY = 50
   local endX = 521
   local endY = 531
   
   local i = 0
   while i <= 10 do
      love.graphics.line(initX + i*unit, initY, 
                           initX + i*unit, endY)
      i = i + 1
   end
   
   i = 0
   while i <= 20 do
      love.graphics.line(initX, initY + i*unit, 
                           endX , initY + i*unit)
      i = i + 1
   end
   
   --draw the boxes
   love.graphics.setColor(255, 255, 255, 255)
   local i = 1
   local j = 1
   while i < xDim do
      while j < yDim do
         drawBlock(i,j,blocks[i][j])
         j = j + 1
      end
      j = 1
      i = i + 1
   end
   
   --draw the current block
   for count = 1, #currBlocks do
      local tempX = currBlocks[count][1]
      local tempY = currBlocks[count][2]
      drawBlock(tempX,tempY,current[2])
   end
   
   --print the score, lines, time, next and swap
   love.graphics.setFont(ASSETS.smallFont)
   
   local tempString = string.format("Score: \n %d", score)
   love.graphics.setColor(255, 5, 5)
   love.graphics.print(tempString, 10, 10)
   
   tempString = string.format("Lines: \n %d", lines)
   love.graphics.setColor(255, 5, 5)
   love.graphics.print(tempString, 10, 70)
   
   tempString = string.format("Time: \n %4.2fs", playTime)
   love.graphics.setColor(255, 5, 5)
   love.graphics.print(tempString, 10, 130)
end

function tetrisGameState:keyreleased(key, unicode)
   -- Quit on escape key
   if key == 'escape' then
      newGame()
      Gamestate.switch(menuGameState)
   end
end

function tetrisGameState:keypressed(key, unicode)
   if key == 'w' or key == 'up' then
      current[3] = current[3] + 1
   end
   if key == 'a' or key == 'left' then
      if canMove(-1,0) then
         move(-1,0)
      end
   end
   if key == 'd' or key == 'right' then
      if canMove(1,0) then
         move(1,0)
      end
   end
   if key == 's' or key == 'down' then
      if not move(0,1) then
         placeBlocks()
         newCurrBlock()
      end
   end
   if key == ' ' then
      while canMove(0,1) do
         move(0,1)
      end
      placeBlocks()
      newCurrBlock()
   end
   checkLineClear()
   setBlocks()
   tetrisGameState:draw()
   
end

local fallTemp = 0

function tetrisGameState:update(dt)
   --calculate the fall delay
   local fallDelay = 5.0
   fallTemp = fallTemp + dt
   
   --if it's time to fall...
   if fallTemp > fallDelay then
      --try to move, 
      if not move(0,1) then
         placeBlocks()
         newCurrBlock()
         checkLineClear()
         --if you can't move in this position, that means you are filled to the top, game over!~~
         if not canMove(0,0) then
            Gamestate.switch(gameOverState)
         end
      end
      fallTemp = 0
   end
   playTime = playTime + dt
end

function gameOverState:keyreleased(key)
   if key == 'escape' then
      love.event.push('q')
   end
end

function gameOverState:draw()
   love.graphics.setColor(224, 27, 99, 200)
   love.graphics.rectangle('fill', 50, 50, SCREEN_WIDTH-100, SCREEN_HEIGHT-100)

   local gameOverString = string.format("Game Over!\nYour score was %0.2f\n\nPress 'h' for high scores.", score)
   love.graphics.setFont(ASSETS.largeFont)
   love.graphics.setColor(5, 255, 5)
   love.graphics.print(gameOverString, SCREEN_WIDTH/2 - gameOverString:len()*4 - 55, SCREEN_HEIGHT/4)
end

function gameOverState:keyreleased(key)
   if key == 'h' then
      Gamestate.switch(highScoreState)
	  -- resetGame()
   end

   if key == 'escape' then
      love.event.push('q')
   end
end

-- Highscore menu
function highScoreState:draw()
   love.graphics.setColor(224, 27, 99, 200)
   love.graphics.rectangle('fill', 50, 50, SCREEN_WIDTH-100, SCREEN_HEIGHT-100)
   love.graphics.setColor(255, 255, 255)
   local line = ""
   love.graphics.setFont(ASSETS.largeFont)
   love.graphics.print("High Scores", 190, 100)

   local backText = {
      "Press 'b' to go back.",
      "The other menus aren't as good.",
      "Come back again soon!"
   }

   love.graphics.setFont(ASSETS.smallFont)
   for i, score, name in highscore() do
      line = string.format("%2d.     %.2f", i, score)
      love.graphics.print(line, 250, (i * 30) + 150)
   end

   love.graphics.setFont(ASSETS.verySmallFont)
   for i, line in pairs(backText) do
      love.graphics.print(line, 485, (i * 15) + 480)
   end
end

function highScoreState:keyreleased(key)
   if key == 'left' or key == 'b' or key == 'a' or key == 'return' then
      Gamestate.switch(menuGameState)
   end
end

-- settingsGameState menu
function settingsGameState:draw()
   love.graphics.setColor(224, 27, 99, 200)
   love.graphics.rectangle('fill', 50, 50, SCREEN_WIDTH-100, SCREEN_HEIGHT-100)
   love.graphics.setColor(255, 255, 255)
   local line = ""
   love.graphics.setFont(ASSETS.largeFont)
   love.graphics.print("Haiku Instructions", 175, 90)

   local text = {
      "lol it's tetris,",
	  "what do you mean how do you play?"
   }
   
   local backText = {
      "Press 'b' to go back."
   }

   love.graphics.setFont(ASSETS.smallFont)
   for i, line in pairs(text) do
      love.graphics.print(line, 145, (i * 30) + 140)
   end
   
   love.graphics.setFont(ASSETS.verySmallFont)
   for i, line in pairs(backText) do
      love.graphics.print(line, 485, (i * 15) + 480)
   end
end

function settingsGameState:keyreleased(key)
   if key == 'left' or key == 'b' or key == 'a' or key == 'return' then
      Gamestate.switch(menuGameState)
   end
end

-- Helper functions

-- draws the main menu, changes color depending on which item is currently selected
function drawMenuItems()
   local offset = 0
   local textStartX = 200
   local textStartY = 200
   
   local x, y = love.mouse.getPosition( )
   if x > textStartX and 
         x < textStartX + 275 and 
         y > textStartY  + 90*0 and 
         y < textStartY + 90*1 then
      selected = 1
   elseif x > textStartX and 
         x < textStartX + 300 and 
         y > textStartY  + 90*1 and 
         y < textStartY + 90*2 then
      selected = 2
   elseif x > textStartX and 
         x < textStartX + 205 and 
         y > textStartY  + 90*2 and 
         y < textStartY + 90*3 then
      selected = 3
   elseif x > textStartX and 
         x < textStartX + 125 and 
         y > textStartY  + 90*3 and 
         y < textStartY + 90*4 then
      selected = 4
   end
   
   love.graphics.setFont(ASSETS.largeFont)
   menuText = {'New Game', 'High Scores', 'Settings', 'Quit'}
   for i, text in pairs(menuText) do
      if i == selected then
         love.graphics.setColor(0, 255, 4)
      else
         love.graphics.setColor(133, 249, 255)
      end
      love.graphics.print(text, textStartX, textStartY + offset, 0, 1, 1)
      offset = offset + 90
   end
end

-- draws a block on screen with x,y and color
function drawBlock(x,y,color)
   if color ~= 0 then
      love.graphics.setColor(colorTable[color][1], colorTable[color][2], colorTable[color][3], colorTable[color][4])
   else
      love.graphics.setColor(0, 0, 0, 0)
   end
   
   --print("filling (%d,%d)",x,y)
   local initTL = {281,51}
   local initTR = {303,51}
   local initBR = {303,73}
   local initBL = {281,73}
   love.graphics.translate(unit*(x-1),unit*(y-1))
   love.graphics.polygon('fill', initTL[1], initTL[2], 
                                 initTR[1], initTR[2],
                                 initBR[1], initBR[2],
                                 initBL[1], initBL[2])
   love.graphics.translate(-unit*(x-1),-unit*(y-1))
end

-- checks to see if the move is legal, returns true if doable, false if not
function canMove(x,y)
   local blockType = current[1]
   
   local move = true
   
   for count = 1, #currBlocks do
      local tempX = currBlocks[count][1]
      local tempY = currBlocks[count][2]
      if tempX+x <= 0 or 
            tempX+x >= xDim or 
            tempY+y <= 0 or 
            tempY+y >= yDim or
            blocks[tempX+x][tempY+y] ~= 0 then
         move = false
         break
      end
   end
   
   return move
end

-- moves the current block to the specified corrdinates,
-- returns true if it succeeded, false if it failed
function move(x,y)
   local blockType = current[1]
   
   if canMove(x,y) then
      current[4] = current[4] + x
      current[5] = current[5] + y
      setBlocks() --update the currBlocks
      return true
   else
      return false
   end
end

-- resets everything and gets the game state ready for a new game
function newGame()
   load_time = love.timer.getTime()
   score = 0
   lines = 0
   playTime = 0
   nextBlock = -1
   swapBlock = -1
   inGame = true
   resetBlock()
   newCurrBlock()
   Gamestate.switch(tetrisGameState)
end

-- Checks to see if it can go down more, then places the current block onto the grid
function placeBlocks()
   --error check, should not be called if it can go down more
   if canMove(0,1) then
      print("Called placeBlocks while canMove(0,1) is true")
      love.quit()
   end
   

   
   for count = 1, #currBlocks do
      local tempX = currBlocks[count][1]
      local tempY = currBlocks[count][2]
      blocks[tempX][tempY] = current[2]
   end

   
end

-- looks at the current value and fills out the currBlocks which 
-- is a pair of x,y coord which indicate which blocks are occupied by the current block
function setBlocks()
   --actually populate it
   currBlocks = {}
   local blockType = current[1]
   local originX = current[4]
   local originY = current[5]
   
   local blockType = current[1]
   print("blockType=" .. blockType)
   
   local tempString = ""
   for count = 2, #blockTable[blockType] do
      tempString = tempString .. "(" .. blockTable[blockType][count][1] .. "," .. blockTable[blockType][count][2] .. ") "
   end
   print(tempString)
   
   local currRotate = current[3]
   print("currRotate=" .. currRotate)
   local maxRotate = blockTable[blockType][1]
   print("maxRotate=" .. maxRotate)
   
   local calculatedRotation = currRotate % maxRotate
   print("calculatedRotation=" .. calculatedRotation)
   
   if calculatedRotation == 0 then
      for count = 2, #blockTable[blockType] do
         local tempX = blockTable[blockType][count][1]
         local tempY = blockTable[blockType][count][2]
         currBlocks[count-1] = {originX+tempX, originY+tempY}
      end
   elseif calculatedRotation == 1 then
      for count = 2, #blockTable[blockType] do
         local tempX = blockTable[blockType][count][2]
         local tempY = blockTable[blockType][count][1]
         currBlocks[count-1] = {originX-tempX, originY+tempY}
      end
   elseif calculatedRotation == 2 then
      for count = 2, #blockTable[blockType] do
         local tempX = blockTable[blockType][count][1]
         local tempY = blockTable[blockType][count][2]
         currBlocks[count-1] = {originX-tempX, originY-tempY}
      end
   elseif calculatedRotation == 3 then
      for count = 2, #blockTable[blockType] do
         local tempX = blockTable[blockType][count][2]
         local tempY = blockTable[blockType][count][1]
         currBlocks[count-1] = {originX+tempX, originY-tempY}
      end
   end
end

--produces a new current block, clearing current and currBlocks value
function newCurrBlock()
   --         type,                       color,                   rotate, x, y
   current = {math.random(1,#blockTable), math.random(1,#colorTable), 0, 6, 1}
   setBlocks()
end

--resets the block array to 0 (empty)
function resetBlock()
   local i = 1
   local j = 1
   while i < xDim do
      blocks[i] = {}
      while j < yDim do
         blocks[i][j] = 0
         j = j + 1
      end
      j = 1
      i = i + 1
   end
end

--checks each row and clears them, then TODO moves the rows down
function checkLineClear()
   local clearedLines = 0
   for j = 1, #blocks[1] do
      local shouldClear = true;
      local stringG = ""
      for i = 1, #blocks do
         stringG = stringG .. blocks[i][j] .. " "
         if blocks[i][j] == 0 then
            shouldClear = false
         end
      end
      if shouldClear then
         print("clearing line #" .. j)
         clearLine(j)
         clearedLines = clearedLines + 1
      end
      --print(j .. "=(" .. stringG .. ")")
   end
   
   score = score + (clearedLines*clearedLines*10)
   lines = lines + clearedLines
end

--clears the specified line and moves the above row down
function clearLine(lineNumber)
   local currLine = lineNumber
   
   --for i = 1, #blocks do
   --   blocks[i][lineNumber] = 0
   --end
   currLine = currLine - 1
   while currLine >= 1 do
      for i = 1, #blocks do
         blocks[i][currLine + 1] = blocks[i][currLine]
      end
      currLine = currLine - 1
   end
   
end


return menuGameState, tetrisGameState, gameOverState, highScoreState
