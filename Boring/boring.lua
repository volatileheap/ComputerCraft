--Config
local boreWidth = 4 --Tunnel width in 4-block areas
local autoRefuelOnOffload = true
local paranoid = true --Extra conditional checks

--Localize APIs
local turtleBack = turtle.back()
local turtleDig = turtle.dig()
local turtleDigDown = turtle.digDown()
local turtleDigUp = turtle.digUp()
local turtleDown = turtle.down()
local turtleDropDown = turtle.dropDown()
local turtleForward = turtle.forward()
local turtleGetFuelLevel = turtle.getFuelLevel()
local turtleGetFuelLimit = turtle.getFuelLimit()
local turtleGetItemCount = turtle.getItemCount()
local turtleGetItemDetail = turtle.getItemDetail()
local turtleInspect = turtle.inspect()
local turtleInspectUp = turtle.inspectUp()
local turtleInspectDown = turtle.inspectDown()
local turtleDetect = turtle.detect()
local turtleDetectUp = turtle.detectUp()
local turtleDetectDown = turtle.detectDown()
local turtlePlaceDown = turtle.placeDown()
local turtleRefuel = turtle.refuel()
local turtleSelect = turtle.select()
local turtleTransferTo = turtle.transferTo()
local turtleTurnLeft = turtle.turnLeft()
local turtleTurnRight = turtle.turnRight()
local turtleUp = turtle.up()
local osSleep = os.sleep()

local fallingBlockSettleTime = 0.3 --Minimum 0.25 for 1 block fall settle
local operational = true

--Define orientation constants
local forward = "forward"
local up = "up"
local down = "down"
local left = "left"
local right = "right"
local back = "back"

--Define block constants
local gravel = "minecraft:gravel"
local sand = "minecraft:sand"

--Define algorithm constants
local baseRight = "base:right"
local interRight = "inter:right"
local finalRight = "final:right"
local baseLeft = "base:left"
local interLeft = "inter:left"
local finalLeft = "final:left"

--Orientation-based turtle turn wrapper
local function turn(orientation)
  if orientation == left then
    turtleTurnLeft()
  elseif orientation == right then
    turtleTurnRight()
  elseif orientation == back then
    turtleTurnLeft()
    turtleTurnLeft()
  end
end

local blockNotSteady, fallingBlockState = true
local blockSuccess, blockData, blockFront = true
local blockSuccessUp, blockDataUp, blockUp = true
local blockDetect, blockDetectUp, blockDetectDown = false

local function fallingBlock()
  blockNotSteady = true
  blockDetect = turtleDetect()
  blockDetectUp = turtleDetectUp()
  if not blockDetect and not blockDetectUp then
    blockNotSteady = false
  end
  while blockNotSteady do
    blockSuccess, blockData = turtleInspect()
    blockSuccessUp, blockDataUp = turtleInspectUp()
    blockFront = blockData.name
    blockUp = blockDataUp.name
    fallingBlockState = 0
    if blockFront == gravel or blockFront == sand then
      if blockUp == gravel or blockUp == sand then
        fallingBlockState = 1
      else
        fallingBlockState = 2
      end
    elseif blockUp == gravel or blockUp == sand then
      fallingBlockState = 3
    end
    if fallingBlockState == 1 then
      turtleDig()
      turtleDigUp()
    elseif fallingBlockState == 2 then
      turtleDig()
    elseif fallingBlockState == 3 then
      turtleDigUp()
    end
    if fallingBlockState ~= 0 then
      osSleep(fallingBlockSettleTime)
    else
      blockNotSteady = false
      break
    end
  end
end

local function dig(orientation)
  if orientation == forward then
    fallingBlock()
    turtleDig()
  elseif orientation == up then
    fallingBlock()
    turtleDigUp()
  elseif orientation == down then
    turtleDigDown()
  end
end

local inventorySlotItemCount = true

local function checkInventoryFull()
  inventorySlotItemCount = turtleGetItemCount(13)
  if inventorySlotItemCount == 0 then
    return false
  else
    return true
  end
end

local function digCurrent()
  dig(up)
  dig(down)
end

local function digForward()
  dig(forward)
  turtleForward()
  digCurrent()
end

local fuelLevel = true
local fuelLimit = true
local function checkFuel()
  fuelLevel = turtleGetFuelLevel()
  fuelLimit = turtleGetFuelLimit()
  if (fuelLevel / fuelLimit) * 100 < 1 then --Less than 1% fuel remaining
    operational = false
    return false
  else
    return true
  end
end

local selectedSlot = 1

local function refuel(coalOnly, exposedSlot, slot)
  if coalOnly then
    turtleSelect(14)
    turtleRefuel()
  else
    if exposedSlot and selectedSlot ~= nil then
      turtleSelect(slot)
      turtleRefuel()
    else
      while selectedSlot < 15 do --Include coal slot
        turtleSelect(selectedSlot)
        turtleRefuel()
        selectedSlot = selectedSlot + 1
      end
    end
  end
  turtleSelect(1)
  selectedSlot = 1
end

local function offload()
  selectedSlot = 1
  if not autoRefuelOnOffload then
    while selectedSlot < 14 do
      turtleSelect(selectedSlot)
      turtleDropDown()
      selectedSlot = selectedSlot + 1
    end
  else
    while selectedSlot < 15 do --Include coal slot
      refuel(false, true, selectedSlot)
      turtleDropDown()
      selectedSlot = selectedSlot + 1
    end
  end
  turtleSelect(1)
end

local function tryOffload()
  if checkInventoryFull() then
    turtleSelect(16)
    turtlePlaceDown()
    offload()
    turtleSelect(16)
    turtleDigDown()
    turtleSelect(1)
  end
end

local function move(blocks)
  if not paranoid then
    for block=1, blocks do
      turtleForward()
    end
  else
    for block=1, blocks do
      blockDetect = turtleDetect()
      if not blockDetect then
        turtleForward()
      else
        operational = false
      end
    end
  end
end

local function digRow()
  digForward()
  digForward()
  digForward()
end

local function digChunk(algorithm)
end