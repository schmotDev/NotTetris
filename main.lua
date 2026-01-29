-- print() are displayed in realtime in the console - easier for debugging
io.stdout:setvbuf('no')

-- avoid filtering on image frames, when redimensionned
love.graphics.setDefaultFilter("nearest")

-- for step-by-step debugging
if arg[#arg] == "-debug" then require("mobdebug").start() end


local Tetros = {}

Tetros[1] = {}
Tetros[1].color = {255 / 255, 0, 0}
Tetros[1].shape = {{
    {0,0,0,0},
    {0,0,0,0},
    {1,1,1,1},
    {0,0,0,0}
  },
  {
    {0,0,1,0},
    {0,0,1,0},
    {0,0,1,0},
    {0,0,1,0}
  }}


Tetros[2] = {}
Tetros[2].color = {0, 71 / 255, 222 / 255}
Tetros[2].shape = {{
    {0,0,0,0},
    {0,1,1,0},
    {0,1,1,0},
    {0,0,0,0}
  }}


Tetros[3] = {}
Tetros[3].color = {222 / 255, 184 / 255, 0}
Tetros[3].shape = {{
    {0,0,0},
    {1,1,1},
    {0,0,1},
  },
  {
    {0,1,0},
    {0,1,0},
    {1,1,0},
  },
  {
    {1,0,0},
    {1,1,1},
    {0,0,0},
  },
  {
    {0,1,1},
    {0,1,0},
    {0,1,0},
  }}


Tetros[4] = {}
Tetros[4].color = {222 / 255, 0, 222 / 255}
Tetros[4].shape = {{
    {0,0,0},
    {1,1,1},
    {1,0,0},
  },
  {
    {1,1,0},
    {0,1,0},
    {0,1,0},
  },
  {
    {0,0,1},
    {1,1,1},
    {0,0,0},
  },
  {
    {0,1,0},
    {0,1,0},
    {0,1,1},
  }}


Tetros[5] = {}
Tetros[5].color = {255 / 255, 151 / 255, 0}
Tetros[5].shape = {{
    {0,0,0},
    {0,1,1},
    {1,1,0},
  },
  {
    {0,1,0},
    {0,1,1},
    {0,0,1},
  },
  {
    {0,0,0},
    {0,1,1},
    {1,1,0},
  },
  {
    {0,1,0},
    {0,1,1},
    {0,0,1},
  }}


Tetros[6] = {}
Tetros[6].color = {71 / 255, 184 / 255, 0}
Tetros[6].shape = {{
    {0,0,0},
    {1,1,1},
    {0,1,0},
  },
  {
    {0,1,0},
    {1,1,0},
    {0,1,0},
  },
  {
    {0,1,0},
    {1,1,1},
    {0,0,0},
  },
  {
    {0,1,0},
    {0,1,1},
    {0,1,0},
  }}


Tetros[7] = {}
Tetros[7].color = {0, 184 / 255, 151 / 255}
Tetros[7].shape = {{
    {0,0,0},
    {1,1,0},
    {0,1,1},
  },
  {
    {0,0,1},
    {0,1,1},
    {0,1,0},
  },
  {
    {0,0,0},
    {1,1,0},
    {0,1,1},
  },
  {
    {0,0,1},
    {0,1,1},
    {0,1,0},
  }}


local currentTetros = {}
currentTetros.shapeid = 1
currentTetros.rotation = 1
currentTetros.position = {x=1, y=1}

local nextTetros = {}
nextTetros.shapeid = 1

local Grid = {}
Grid.height = 20
Grid.width = 10
Grid.cellSize = 0
Grid.cells = {}

local dropSpeed = 1
local timerDrop = 0

local pauseForceDrop = false

local sndMusicMenu
local sndMusicGame
local sndMusicGameover
local sndLevel
local sndLine
local sndVolume = 0.2
local gameState = ""

local fontMenu
local fontGameover
local fontScore
local fontOptions
local showOptions = 0

local menuSin = 0

local score = 0
local level = 0
local lines = 0
local highscore = 0
local save = false

local bag = {}
local selectedBag = {}
local firstBag = true

function StartGame()
  gameState = "play"
  dropSpeed = 1
  sndMusicMenu:stop()
  sndMusicGame:play()
  SetVolume()
  initGrid()
  InitBag()
  firstBag = true
  SpawnTetros()
  
  score = 0
  level = 1
  lines = 0

end


function StartMenu()
  gameState = "menu"
  sndMusicGame:stop()
  sndMusicGameover:stop()
  sndMusicMenu:play()
  SetVolume()

end



function StartGameover()
  gameState = "gameover"
  sndMusicGame:stop()
  sndMusicGameover:play()
  SetVolume()
  print("gameover. score="..score.."high="..highscore)
  if save == true then
    WriteSave()
  end
end

function initGrid()
  local h = screen_height / Grid.height
  Grid.cellSize = h
  Grid.offsetX = (screen_width / 2) - (h*Grid.width) / 2
  Grid.offsetY = 0
  
  Grid.cells = {}
  for l=1, Grid.height do
    Grid.cells[l] = {}
    for c=1, Grid.width do
      Grid.cells[l][c] = 0
    end
  end

end


function DrawNextTetros(pShape, pColor)
  local h = Grid.cellSize
  local x_base = screen_width - ((Grid.offsetX / 2) + (4 * h) / 2)
  local y_base = screen_height / 2
  love.graphics.setColor(pColor[1], pColor[2], pColor[3])
  for l=1, #pShape do
    for c=1,#pShape[l] do
      local x_next = (c-1) * Grid.cellSize
      local y_next = (l-1) * Grid.cellSize
      x_next = x_next + x_base
      y_next = y_next + y_base
      if pShape[l][c] == 1 then
        love.graphics.rectangle("fill", x_next, y_next, Grid.cellSize-1, Grid.cellSize-1)
      end
    end
  end
  
  love.graphics.setFont(fontScore)
  love.graphics.setColor(0.6,1,1)
  local sNext = "Next: "
  local w = fontMenu:getWidth(sNext)
  local h = fontMenu:getHeight(sNext)
  love.graphics.print(sNext, x_base, y_base - h/2)

end

function DrawGrid()
  local h = Grid.cellSize
  local w = h
  local x, y
  
  for l=1,Grid.height do
    for c=1,Grid.width do
      x = (c-1)*w
      y = (l-1)*h
      x = x + Grid.offsetX
      y = y + Grid.offsetY
      id = Grid.cells[l][c]
      if id == 0 then
        love.graphics.setColor(1,1,1,0.2)
        love.graphics.rectangle("fill", x, y, w, h)
      else
        local Color = Tetros[id].color
        love.graphics.setColor(Color[1], Color[2], Color[3])
        love.graphics.rectangle("fill", x, y, w-1, h-1)
      end

      --love.graphics.rectangle("fill", x, y, w-1, h-1)
      --love.graphics.rectangle("fill", x, y, w, h)
    end
  end
end




function DrawHighscore()
  local c = Grid.cellSize
  local x_base = screen_width - ((Grid.offsetX / 2) + (4 * c) / 2)
  local y_base = 0
  
  love.graphics.setFont(fontScore)
  love.graphics.setColor(0.6,1,1)
  local sHigh = "Highest: "
  local w = fontMenu:getWidth(sHigh)
  local h = fontMenu:getHeight(sHigh)
  love.graphics.print(sHigh, x_base, y_base + h)
  
  
  love.graphics.setFont(fontScore)
  love.graphics.setColor(1,1,1)
  local sHighcore = highscore
  w = fontMenu:getWidth(sHighcore)
  h = fontMenu:getHeight(sHighcore)
  love.graphics.print(sHighcore, x_base, y_base + 2*h)
  
  
end


function InitBag()
  bag = {}
  for n=1,#Tetros do
    table.insert(bag,n)
    table.insert(bag,n)
    table.insert(bag,n)
    table.insert(bag,n)
  end
end



function LoadSave()
  if love.filesystem.getInfo("save.json") then
    local contents = love.filesystem.read("save.json")
    local value = contents:match('"highscore"%s*:%s*(%d+)')
    highscore = tonumber(value) or 0
  else
    highscore = 0
  end
end



function WriteSave()
  local json = string.format('{ "highscore": %d }', score)
  love.filesystem.write("save.json", json)

end

function PickBag()
  local nBag = math.random(1, #bag) 
  local new = bag[nBag]
  table.remove(bag, nBag)
  if #bag == 0 then
    InitBag()
  end
  return new
end


function SpawnTetros()
  if firstBag == true then
    selectedBag["new"] = PickBag()
    selectedBag["next"] = PickBag()
    firstBag = false
  else
    selectedBag["new"] = selectedBag["next"]
    selectedBag["next"] = PickBag()
  end
  
  currentTetros.shapeid = selectedBag["new"]
  currentTetros.rotation = 1
  local tetrosWidth = #Tetros[currentTetros.shapeid].shape[currentTetros.rotation][1]
  currentTetros.position.x = (math.floor((Grid.width - tetrosWidth) / 2)) + 1
  currentTetros.position.y = 1
  timerDrop = dropSpeed
  pauseForceDrop = true
  
  if Collide() then
    StartGameover()
  end
  
  nextTetros.shapeid = selectedBag["next"]
  nextTetros.rotation = 1

end

function DrawShape(pShape, pColor, pColumn, pLine)
  love.graphics.setColor(pColor[1], pColor[2], pColor[3])
  for l=1, #pShape do
    for c=1,#pShape[l] do
      local x = (c-1) * Grid.cellSize
      local y = (l-1) * Grid.cellSize
      x = x + (pColumn-1) * Grid.cellSize
      y = y + (pLine-1) * Grid.cellSize
      x = x + Grid.offsetX
      y = y + Grid.offsetY
      if pShape[l][c] == 1 then
        love.graphics.rectangle("fill", x, y, Grid.cellSize-1, Grid.cellSize-1)
      end
    end
  end

end

function Collide()
  local Shape = Tetros[currentTetros.shapeid].shape[currentTetros.rotation]
  for l=1,#Shape do
    for c=1,#Shape[l] do
      local cInGrid = (c-1) + currentTetros.position.x
      local lInGrid = (l-1) + currentTetros.position.y
      if Shape[l][c] == 1 then
        if cInGrid <= 0 or cInGrid > Grid.width then
          return true
        end
        if lInGrid > Grid.height then
          return true
        end
        if Grid.cells[lInGrid][cInGrid] ~= 0 then
          return true
        end
      end
    end
  end

  return false

end


function Transfer()
  local Shape = Tetros[currentTetros.shapeid].shape[currentTetros.rotation]
  for l=1,#Shape do
    for c=1,#Shape[l] do
      local cInGrid = (c-1) + currentTetros.position.x
      local lInGrid = (l-1) + currentTetros.position.y
      if Shape[l][c] ~= 0 then
        Grid.cells[lInGrid][cInGrid] = currentTetros.shapeid
      end
    end
  end
end


function SetVolume()
  sndMusicMenu:setVolume(sndVolume)
  sndMusicGame:setVolume(sndVolume)
  sndMusicGameover:setVolume(sndVolume)
  sndLevel:setVolume(sndVolume)
  sndLine:setVolume(sndVolume)


end


function ManageLevel()
  local newLevel = math.floor(lines / 10) + 1
  if newLevel <= 20 then
    if newLevel ~= level then
      sndLevel:play()
      level = newLevel
      dropSpeed = dropSpeed - 0.08
    end
  end
end

function RemoveLineGrid(pLine)
  -- Remonte à l'envers depuis la ligne à supprimer
  for l=pLine,2,-1 do
    for c=1,Grid.width do
      Grid.cells[l][c] = Grid.cells[l-1][c]
    end
  end
end



function UpdateMenu(dt)
    menuSin = menuSin + 5*60*dt
end

function UpdatePlay(dt)
  if love.keyboard.isDown("down") == false then
    pauseForceDrop = false
  end

  -- Next drop
  timerDrop = timerDrop - dt
  if timerDrop <= 0 then
    currentTetros.position.y = currentTetros.position.y + 1
    timerDrop = dropSpeed
  end
  
  if Collide() then
    currentTetros.position.y = currentTetros.position.y - 1
    Transfer()
    SpawnTetros()
  end
  
  local lineComplete
  local nbLines = 0
  for l=1,Grid.height do
    lineComplete = true
    for c=1,Grid.width do
      if Grid.cells[l][c] == 0 then
        lineComplete = false
      end
    end
    if lineComplete == true then
      nbLines = nbLines + 1
      sndLine:play()
      RemoveLineGrid(l)
    end
  end
  lines = lines + nbLines
  if nbLines == 1 then
    score = score + (100*level)
  elseif nbLines == 2 then
    score = score + (300*level)
  elseif nbLines == 3 then
    score = score + (400*level)
  elseif nbLines == 4 then
    score = score + (800*level)
  end
  if score > highscore then
    highscore = score
    save = true
  end
  ManageLevel()

end

function UpdateGameover(dt)

end


function love.load()
  
  math.randomseed(os.time())
  
  love.window.setTitle("Absolutely not Tetris")
  
  sndMusicMenu = love.audio.newSource("tetris-gameboy-01.mp3", "stream")
  sndMusicMenu:setLooping(true)
  sndMusicGame = love.audio.newSource("tetris-gameboy-02.mp3", "stream")
  sndMusicGame:setLooping(true)
  sndMusicGameover = love.audio.newSource("tetris-gameboy-04.mp3", "stream")
  sndMusicGameover:setLooping(true)
  
  sndLevel = love.audio.newSource("levelup.wav", "stream")
  sndLine = love.audio.newSource("line.wav", "stream")

  SetVolume()
  
  fontMenu = love.graphics.newFont("blocked.ttf", 50)  
  fontGameover = love.graphics.newFont("blocked.ttf", 50)
  fontOptions = love.graphics.newFont("blocked.ttf", 25)
  fontScore = love.graphics.newFont("blocked.ttf", 30)

  love.keyboard.setKeyRepeat(true)
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  
  LoadSave()
  initGrid()
  StartMenu()
  

end

function love.update(dt)
  SetVolume()
  if showOptions == true then
    PrintOptions()
    --showOptions = false
  end
  if gameState == "play" then
    UpdatePlay(dt)
  elseif gameState == "menu" then
    UpdateMenu(dt)
  elseif gameState == "gameover" then
    UpdateGameover(dt)
  end
end


function DrawMenu()
  love.graphics.setFont(fontMenu)
  local sMessage = "THIS IS NOT TETRIS"
  local w = fontMenu:getWidth(sMessage)
  local h = fontMenu:getHeight(sMessage)
  local x = (screen_width - w)/2
  local y = 0
  for c=1,sMessage:len() do
    love.graphics.setColor(1, 0, 0)
    local char = string.sub(sMessage,c,c)
    y = math.sin((x+menuSin)/50)*30
    love.graphics.print(char, x, y + (screen_height - h)/2.5)
    x = x + fontMenu:getWidth(char)
  end
  love.graphics.setColor(0, 184 / 255, 151 / 255)
  sMessage = "PRESS ENTER"
  local w = fontMenu:getWidth(sMessage)
  local h = fontMenu:getHeight(sMessage)
  love.graphics.print(sMessage, (screen_width - w)/2, (screen_height - h)/1.5)
  
  PrintOptions()
end


function DrawPlay()
  local Shape = Tetros[currentTetros.shapeid].shape[currentTetros.rotation]
  local Color = Tetros[currentTetros.shapeid].color
  DrawShape(Shape, Color, currentTetros.position.x, currentTetros.position.y)
  
  local nShape = Tetros[nextTetros.shapeid].shape[nextTetros.rotation]
  local nColor = Tetros[nextTetros.shapeid].color
  DrawNextTetros(nShape, nColor)
  
  love.graphics.setFont(fontScore)
  local y = 100
  local h = fontScore:getHeight("X")
  love.graphics.setColor(1,1,1)
  love.graphics.print("SCORE", 50, y)
  y = y + h
  love.graphics.print(tostring(score), 50, y)
  y = y + h
  y = y + h
  love.graphics.setColor(1,1,1)
  love.graphics.print("LEVEL", 50, y)
  y = y + h
  love.graphics.print(tostring(level), 50, y)
  y = y + h
  y = y + h
  love.graphics.setColor(1,1,1)
  love.graphics.print("LINES", 50, y)
  y = y + h
  love.graphics.print(tostring(lines), 50, y)
  
  DrawHighscore()

  PrintOptions()

end


function DrawGameover()
  love.graphics.setFont(fontGameover)
  love.graphics.setColor(1,1,1)
  local sMessage = "GAME OVER :("
  local w = fontGameover:getWidth(sMessage)
  local h = fontGameover:getHeight(sMessage)
  love.graphics.print(sMessage, (screen_width - w)/2, (screen_height - h)/2)
  
  PrintOptions()
end


function PrintOptions()
  if showOptions > 0 then
    love.graphics.setFont(fontOptions)
    love.graphics.setColor(0.6,0.6,0)
    local sOptions = "Volume: "..sndVolume*100
    local w = fontMenu:getWidth(sOptions)
    local h = fontMenu:getHeight(sOptions)
    love.graphics.print(sOptions, 20, 20)
    showOptions = showOptions - 1
  end
    
end


function love.draw()
  
  DrawGrid()
  
  if gameState == "play" then
    DrawPlay(dt)
  elseif gameState == "menu" then
    DrawMenu(dt)
  elseif gameState == "gameover" then
    DrawGameover(dt)
  end
  
  
end


function InputMenu(key)
  if key == "return" then
    StartGame()
  end
end


function InputGameover(key)
  if key == "return" then
    StartMenu()
  end
end


function InputPlay(key)
	local oldX = currentTetros.position.x
  local oldY = currentTetros.position.y
  local oldRotation = currentTetros.rotation

    -- Tetros mouvement latéral
  if key == "right" then
    currentTetros.position.x = currentTetros.position.x + 1
  end
  if key == "left" then
    currentTetros.position.x = currentTetros.position.x - 1
  end

  if key == "up" then
    currentTetros.rotation = currentTetros.rotation + 1
    if currentTetros.rotation > #Tetros[currentTetros.shapeid].shape then
      currentTetros.rotation = 1
    end
  end
  
  if Collide() then
    currentTetros.position.x = oldX
    currentTetros.position.y = oldY
    currentTetros.rotation = oldRotation
  end
  
    -- Tetros mouvement vertical
  if pauseForceDrop == false then
    if key == "down" then
      currentTetros.position.y = currentTetros.position.y + 1
    end
    -- Vérifie si le Tétros de "pose"
    if Collide() then
      currentTetros.position.y = oldY
      Transfer()
      SpawnTetros()
    end
  end
end



function love.keypressed(key)
  
  if key == "+" or key == "kp+" then
    sndVolume = sndVolume + 0.01
    showOptions = 40
  end
  if key == "-"  or key == "kp-" then
    sndVolume = sndVolume - 0.01
    showOptions = 40
  end
  
  if gameState == "menu" then
    InputMenu(key)
  elseif gameState == "play" then
    InputPlay(key)
  elseif gameState == "gameover" then
    InputGameover(key)
  end

end

