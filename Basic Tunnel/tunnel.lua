function dig(side)
  if side == "f" then
    turtle.dig()
  elseif side == "u" then
    turtle.digUp()
  elseif side == "d" then
    turtle.digDown()
  end
end

function go(side)
  if side == "f" then
    gravel()
    turtle.forward()
  elseif side == "u" then
    turtle.up()
  elseif side == "d" then
    turtle.down()
  elseif side == "b" then
    turtle.back()
  end
end

function turn(side)
  if side == "r" then
    turtle.turnRight()
  elseif side == "l" then
    turtle.turnLeft()
  elseif side == "b" then
    turtle.turnLeft()
    turtle.turnLeft()
  end
end

function checkFull()
  local count = turtle.getItemCount(13)
  if count == 0 then
    return false
  else
    return true
  end
end

function place(item)
  if item == "e" then
    turtle.select(16)
    turtle.placeDown()
  elseif item == "l" then
    turtle.select(15)
    turtle.placeDown()
  end
  turtle.select(1)
end

function take(item)
  if item == "e" then
    turtle.select(16)
    turtle.digDown()
  elseif item == "l" then
    turtle.select(15)
    turtle.digDown()
  end
  turtle.select(1)
end

function gravel()
  local noGravel = false
  while not noGravel do
    local success, data = turtle.inspect()
    local successUp, dataUp = turtle.inspectUp()
    local name = data.name
    local nameUp = dataUp.name
    if name == "minecraft:gravel" or name == "minecraft:sand" then
      turtle.dig()
    else
      noGravel = true
    end
    if nameUp == "minecraft:gravel" or name == "minecraft:sand" then
      turtle.digUp()
    else
      noGravel = true
    end
  end
end

function digForward()
  if finish then
    os.shutdown()
  end
  gravel()
  turtle.dig()
  turtle.forward()
  turtle.digUp()
  turtle.digDown()
  gravel()
end

function digLeft()
  turn("l")
  digForward()
  turn("l")
end

function digRight()
  turn("r")
  digForward()
  turn("r")
end

function digCurrent()
  turtle.digUp()
  turtle.digDown()
  gravel()
end

function offload()
  local slot = 1
  while slot < 14 do
    turtle.select(slot)
    turtle.dropDown()
    slot = slot + 1
  end
  turtle.select(1)
end

function tryOffload()
  if checkFull() then
    offload()
  end
end

function checkFuel() -- Returns true if there is adequate fuel, false if not
  local level = turtle.getFuelLevel()
  local limit = turtle.getFuelLimit()
  --For standard turtles, the limit is 20,000
  --1% fuel is 200 blocks of movement
  if (level / limit) * 100 < 1 then
    return false
  end
  return true
end

function refuel()
  turtle.select(14)
  turtle.refuel()
  turtle.select(1)
end

function tryRefuel()
  if not checkFuel() then
    refuel()
  end
end

function digSmart()
  digForward()
  tryOffload()
  digForward()
  tryOffload()
  digForward()
  tryOffload()
end

function move(number)
  for block=1, number do
    go("f")
  end
end

function loader()
  place("l")
  if not firstLoader then
    turn("b")
    move(4)
    take("l")
    turn("b")
    move(4)
  end
  firstLoader = false
end

refuel()
dig("u")
gravel()
go("u")
digForward()

firstLoader = true

finish = false
while not finish do
  tryRefuel()
  loader()
  turn("l")
  digSmart()
  digRight()
  digSmart()
  digLeft()
  digSmart()
  digRight()
  digSmart()
  turn("l")
  digForward()
end