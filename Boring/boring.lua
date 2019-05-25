--Config
local boreWidth = 4 --Tunnel width in 4-block areas

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

--Localize Turtle API
local turtleSuckDown = turtle.suckDown()
local turtleTransferTo = turtle.transferTo()
local turtleTurnLeft = turtle.turnLeft()
local turtleTurnRight = turtle.turnRight()
local turtleUp = turtle.up()

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
    turtle.turnRight()
  elseif orientation == back then
    turtle.turnLeft()
    turtle.turnLeft()
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

--Variable assign-lookup optimization
local blockNotSteady, fallingBLockState = true
local blockSuccess, blockData, blockFront = true
local blockSuccessUp, blockDataUp, blockUp = true

local function fallingBlock()
  blockNotSteady = true
  while blockNotSteady do
    blockSuccess, blockData = turtle.inspect()
    blockSuccessUp, blockDataUp = turtle.inspectUp()
    blockFront = blockData.name
    blockUp = blockDataUp.name
    fallingBLockState = 0
    if blockFront == "minecraft:gravel" or blockFront == "minecraft:sand" then
      fallingBLockState = 1
      turtle.dig()
    end
    if blockUp == "minecraft:gravel" or blockUp == "minecraft:sand" then
      fallingBLockState = 2
      turtle.digUp()
    end
    if fallingBLockState ~= 0 then
      os.sleep(fallingBlockSettleTime)
    else
      blockNotSteady = false
      break
    end
  end
end

local function dig(orientation)
  if orientation == forward then
    turtle.dig()
  end
end