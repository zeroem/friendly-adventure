player = { origin = { x = 200, y = 710 }, speed = 400, img = nil, bbox = nil}
scale = 0.5
debug = {
  bb = false
}

canShoot = true
canShootTimerMax = 0.2
canShoot = canShootTimerMax
bulletImg = nil
bullets = {}

createEnemyTimerMax = 0.3
createEnemyTimer = createEnemyTimerMax

enemyImg = nil
bossImg = nil
enemies = {}

isAlive = true
score = 0

function love.load(arg)
  player.img = love.graphics.newImage('assets/aircraft/Aircraft_03.png')
  player.bbox = newBBox(0, 0, player.img:getWidth() * scale, player.img:getHeight() * scale)
  bulletImg = love.graphics.newImage('assets/aircraft/bullet_2_blue.png')
  enemyImg = love.graphics.newImage('assets/aircraft/Aircraft_01.png')
  bossImg = love.graphics.newImage('assets/aircraft/Aircraft_02.png')
end

function love.update(dt)
  local newEnemy = nil
  local randomeNumber = nil

  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax

    -- Create an enemy
    if math.random(1, 10) <= 1 then
      newEnemy = { img = bossImg, health = 3, points = 10 }
    else
      newEnemy = { img = enemyImg, health = 2, points = 1 }
    end

    randomNumber = math.random(10, love.graphics.getWidth() - 10 - newEnemy.img:getWidth() * scale)
    newEnemy.origin = {x = randomNumber, y = -10}

    newEnemy.bbox = newBBox(0, 0, newEnemy.img:getWidth() * scale, newEnemy.img:getHeight() * scale)

    table.insert(enemies, newEnemy)
  end

  for i, enemy in ipairs(enemies) do
    if enemy.origin.y > love.graphics.getHeight() + (enemy.img:getHeight() * scale) then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end

    enemy.origin.y = enemy.origin.y + (200 * dt)
  end

  if not canShoot then
    canShootTimer = canShootTimer - (1 * dt)
    if canShootTimer < 0 then
      canShoot = true
    end
  end

  for i, bullet in ipairs(bullets) do
    bullet.origin.y = bullet.origin.y - (700 * dt)

    if bullet.origin.y < 0 then -- remove bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end

  processInput(dt)
  checkCollisions()

  if not isAlive and love.keyboard.isDown('r') then
    -- remove all our bullets and enemies from screen
    bullets = {}
    enemies = {}

    -- reset timers
    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    -- move player back to default position
    player.origin.x = 50
    player.origin.y = 710

    -- reset our game state
    score = 0
    isAlive = true
  end
end

function love.draw(dt)
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.origin.x, bullet.origin.y, 0)

    if debug.bb  then
      drawBoundingBox(bullet)
    end
  end

  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.origin.x, enemy.origin.y, math.pi, scale, scale, enemy.img:getWidth(), enemy.img:getHeight())

    if debug.bb  then
      drawBoundingBox(enemy)
    end
  end

  if isAlive then
    love.graphics.draw(player.img, player.origin.x, player.origin.y, 0, scale, scale)

    if debug.bb  then
      drawBoundingBox(player)
    end
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end

  love.graphics.print(string.format("Score: %d", score), 5, 5)
end

function processInput(dt)
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('space', ' ', 'rctrl', 'lctrl', 'ctrl') and canShoot and isAlive then
    -- Create some bullets
    newBullet = { origin = {x = player.origin.x + (player.bbox.dx/2) + 15, y = player.origin.y}, img = bulletImg, bbox = newBBox( 0, 0, bulletImg:getWidth(), bulletImg:getHeight())}
    table.insert(bullets, newBullet)

    newBullet = { origin = {x = player.origin.x + (player.bbox.dx/2) - 15, y = player.origin.y}, img = bulletImg, bbox = newBBox( 0, 0, bulletImg:getWidth(), bulletImg:getHeight())}
    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  if love.keyboard.isDown('left','a') then
    if player.origin.x > 0 then
      player.origin.x = player.origin.x - (player.speed*dt)
    end
  end

  if love.keyboard.isDown('right','d') then
    if player.origin.x < (love.graphics.getWidth() - player.img:getWidth() * scale) then
      player.origin.x = player.origin.x + (player.speed*dt)
    end
  end

  if love.keyboard.isDown('up','w') then
    if player.origin.y > 0 then
      player.origin.y = player.origin.y - (player.speed*dt)
    end
  end

  if love.keyboard.isDown('down','s') then
    if player.origin.y < (love.graphics.getHeight() - player.img:getHeight() * scale) then
      player.origin.y = player.origin.y + (player.speed*dt)
    end
  end

  if player.origin.x < 0 then
    player.origin.x = 0
  elseif player.origin.x > (love.graphics.getWidth() - player.img:getWidth() * scale) then
    player.origin.x = (love.graphics.getWidth() - player.img:getWidth() * scale)
  end

  if player.origin.y < 0 then
    player.origin.y = 0
  elseif player.origin.y > (love.graphics.getHeight() - player.img:getHeight() * scale) then
    player.origin.y = (love.graphics.getHeight() - player.img:getHeight() * scale)
  end
end

function overlap(objA, objB)
  return  objA.origin.x < objB.origin.x + objB.bbox.ox + objB.bbox.dx and
          objB.origin.x < objA.origin.x + objA.bbox.ox + objA.bbox.dx and
          objA.origin.y < objB.origin.y + objB.bbox.oy + objB.bbox.dy and
          objB.origin.y < objA.origin.y + objA.bbox.oy + objA.bbox.dy
end

function checkCollisions()
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if overlap(enemy, bullet) then
        table.remove(bullets, j)
        enemy.health = enemy.health - 1

        if enemy.health <= 0 then
          table.remove(enemies, i)
          score = score + enemy.points

          -- Stop consuming bullets if the enemy is dead
          break
        end
      end
    end

    if overlap(enemy, player) and isAlive then
      table.remove(enemies, i)
      isAlive = false
    end
  end
end

function drawBoundingBox(obj)
  love.graphics.rectangle(
    'line',
    obj.origin.x + obj.bbox.ox,
    obj.origin.y + obj.bbox.oy,
    obj.bbox.dx,
    obj.bbox.dy
  )
end

function newBBox(ox, oy, dx, dy)
  return {ox = ox, oy = oy, dx = dx, dy = dy}
end
