player = { x = 200, y = 710, speed = 400, img = nil }

canShoot = true
canShootTimerMax = 0.2
canShoot = canShootTimerMax
bulletImg = nil
bullets = {}

createEnemyTimerMax = 0.5
createEnemyTimer = createEnemyTimerMax

enemyImg = nil
bossImg = nil
enemies = {}

isAlive = true
score = 0

function love.load(arg)
  player.img = love.graphics.newImage('assets/aircraft/Aircraft_03.png')
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
      randomNumber = math.random(10, love.graphics.getWidth() - 10 - bossImg:getWidth())
      newEnemy = { x = randomNumber, y = -10, img = bossImg, health = 3, points = 10 }
    else
      randomNumber = math.random(10, love.graphics.getWidth() - 10 - enemyImg:getWidth())
      newEnemy = { x = randomNumber, y = -10, img = enemyImg, health = 2, points = 1 }
    end

    table.insert(enemies, newEnemy)
  end

  for i, enemy in ipairs(enemies) do
    if enemy.y > 850 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end

    enemy.y = enemy.y + (200 * dt)
  end

  if not canShoot then
    canShootTimer = canShootTimer - (1 * dt)
    if canShootTimer < 0 then
      canShoot = true
    end
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (700 * dt)

    if bullet.y < 0 then -- remove bullets when they pass off the screen
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
    player.x = 50
    player.y = 710

    -- reset our game state
    score = 0
    isAlive = true
  end
end

function love.draw(dt)
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y, math.pi, 1, 1, enemy.img:getWidth(), enemy.img:getHeight())
  end

  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
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
    newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  if love.keyboard.isDown('left','a') then
    if player.x > 0 then
      player.x = player.x - (player.speed*dt)
    end
  end

  if love.keyboard.isDown('right','d') then
    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed*dt)
    end
  end

  if love.keyboard.isDown('up','w') then
    if player.y > 0 then
      player.y = player.y - (player.speed*dt)
    end
  end

  if love.keyboard.isDown('down','s') then
    if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
      player.y = player.y + (player.speed*dt)
    end
  end

  if player.x < 0 then
    player.x = 0
  elseif player.x > (love.graphics.getWidth() - player.img:getWidth()) then 
    player.x = (love.graphics.getWidth() - player.img:getWidth())
  end

  if player.y < 0 then
    player.y = 0
  elseif player.y > (love.graphics.getHeight() - player.img:getHeight()) then 
    player.y = (love.graphics.getHeight() - player.img:getHeight())
  end
end

function overlap(objA, objB)
  return  objA.x < objB.x + objB.img:getWidth() and
          objB.x < objA.x + objA.img:getWidth() and
          objA.y < objB.y + objB.img:getHeight() and
          objB.y < objA.y + objA.img:getHeight()
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
        end
      end
    end

    if overlap(enemy, player) and isAlive then
      table.remove(enemies, i)
      isAlive = false
    end
  end
end
