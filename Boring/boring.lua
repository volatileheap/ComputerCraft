--Config
local boreWidth = 4 --Tunnel width in 4-block areas
local autoRefuelOnOffload = true

--Turtle API function list
--[[
global turtle: {
  back: function,
  dig: function,
  digDown: function,
  digUp: function,
  down: function,
  dropDown: function,
  forward: function,
  getFuelLevel: function,
  getFuelLimit: function,
  getItemCount: function,
  getItemDetail: function,
  inspect: function,
  inspectUp: function,
  placeDown: function,
  refuel: function,
  select: function,
  suckDown: function,
  transferTo: function,
  turnLeft: function,
  turnRight: function,
  up: function,
}
--]]

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

--Define orientation constants
local forward = "forward"
local up = "up"
local down = "down"
local left = "left"
local right = "right"
local back = "back"

local facing = forward

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

--Cached orientation manager
local function face(side)
  if facing == forward then
    if side == right then
      facing = right
      turn(right)
    elseif side == left then
      facing = left
      turn(left)
    elseif side == back then
      facing = back
      turn(back)
    end
  elseif facing == right then
    if side == right then
      facing = back
      turn(right)
    elseif side == left then
      facing = forward
      turn(left)
    elseif side == back then
      facing = left
      turn(back)
    end
  elseif facing == left then
    if side == right then
      facing = forward
      turn(right)
    elseif side == left then
      facing = back
      turn(left)
    elseif side == back then
      facing = right
      turn(back)
    end
  elseif facing == back then
    if side == right then
      facing = left
      turn(right)
    elseif side == left then
      facing = right
      turn(left)
    elseif side == back then
      facing = forward
      turn(back)
    end
  end
end

local blockNotSteady, fallingBlockState = true
local blockSuccess, blockData, blockFront = true
local blockSuccessUp, blockDataUp, blockUp = true
local blockDetect, blockDetectUp, blockDetectDown = false

--TODO block position sleep optimization (if applicable: dig front and up, then sleep)
--TODO block-item name assign
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
    if blockFront == "minecraft:gravel" or blockFront == "minecraft:sand" then
      fallingBlockState = 1
      turtleDig()
    end
    if blockUp == "minecraft:gravel" or blockUp == "minecraft:sand" then
      fallingBlockState = 2
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
local isInventoryFull = false

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

