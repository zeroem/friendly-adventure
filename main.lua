require 'ecs'
require 'entity.enemy'
require 'entity.gun'
require 'entity.player'
require 'util'

shine = require 'deps/shine'

local game = {
  ecs = ecs.new(),
  playArea = nil,
  score = 0,
  resources = {
    playerImg = 'assets/aircraft/Aircraft_03.png',
    bulletImg = 'assets/aircraft/bullet_2_orange.png',
    waveImg = 'assets/aircraft/bullet_2_blue.png',
    enemyImg = 'assets/aircraft/Aircraft_01.png',
    powerupEnemyImg = 'assets/aircraft/Aircraft_02.png',
    powerupImg = 'assets/aircraft/bullet_purple0001.png',
    rocketImg = 'assets/aircraft/rocket_purple.png'
  },
  spriteBatches = {},
  isAlive = true,
  config = {
    drawHitboxes = false,
    drawBoundingBoxes = false,
    drawOrigins = false,
    scale = 0.5
  },
  keysPressed = {},

  scale = function(self, n)
    if n ~= nil then
      return n * self.config.scale
    else
      return self.config.scale
    end
  end,

  playerDeath = function(self)
    self.isAlive = false
    self.ecs:removeEntity(self.player)
    self.player = nil
  end,

  initGameArea = function(self)
    local gameArea = self.ecs:newEntity()
    gameArea:addComponent(
      'bounds',
      newBBox(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    )

    gameArea:addComponent('origin', { x = 0, y = 0 })

    self.gameArea = gameArea
  end,
}

function love.load(arg)
  game:initGameArea()
  glow = shine.glowsimple()
  glow:set("sigma", 1)
  glow:set("min_luma", 0)

  scanlines = shine.scanlines()
  scanlines:set("pixel_size", 5)

  for k, path in pairs(game.resources) do
    game.resources[k] = love.graphics.newImage(path)
  end

  game.spriteBatches.bullet = love.graphics.newSpriteBatch(game.resources.bulletImg, 25)
  game.spriteBatches.wave = love.graphics.newSpriteBatch(game.resources.waveImg, 50)
  game.spriteBatches.rocket = love.graphics.newSpriteBatch(game.resources.rocketImg, 10)

  game.player = entity.player.createPlayer(game)
  entity.gun.createGun(game)
  entity.enemy.createSpawner(game)
end

function love.update(dt)
  processInput(dt)

  for c in game.ecs:getComponentsByType('update') do
    c:update(game, dt)
  end

  if love.keyboard.isDown('r') then
    -- remove all our bullets and enemies from screen
    for _, e in game.ecs:getComponentsByType('clear-on-reset') do
      game.ecs:removeEntity(e)
    end

    game.player = entity.player.createPlayer(game)

    -- reset our game state
    game.score = 0
    game.isAlive = true
  end
end

function love.draw(dt)
  if not game.isAlive then
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  local pr, pg, pb, pa = love.graphics.getColor()

  love.graphics.print(string.format("Score: %d", game.score), 5, 5)

  scanlines:draw(function()
    glow:draw(function()
      for render in game.ecs:getComponentsByType('render-0') do
        render:render()
        love.graphics.setColor(pr, pg, pb, pa)
      end
    end)

    for render in game.ecs:getComponentsByType('render') do
      render:render()
      love.graphics.setColor(pr, pg, pb, pa)
    end
  end)

  if game.config.drawHitboxes then
    love.graphics.setColor(255,0,0,200)
    for hitbox, owner in game.ecs:getComponentsByType('hitbox') do
      drawBoundingBox(util.getOrigin(owner), hitbox)
    end
  end

  if game.config.drawBoundingBoxes then
    love.graphics.setColor(0,0,255,200)
    for hitbox, owner in game.ecs:getComponentsByType('bounds') do
      drawBoundingBox(util.getOrigin(owner), hitbox)
    end
  end

  if game.config.drawOrigins then
    love.graphics.setColor(255,0,255)
    love.graphics.setPointSize(5)
    for origin in game.ecs:getComponentsByType('origin') do
      love.graphics.points(origin.x, origin.y)
    end
  end

  love.graphics.setColor(pr, pg, pb, pa)
end

function processInput(dt)
  game.keysPressed = {
    up    = false,
    down  = false,
    left  = false,
    right = false,
    quit  = false,
  }

  if love.keyboard.isDown('escape') then
    game.keysPressed.quit = true
    love.event.quit()
  end

  if love.keyboard.isDown('left','a') then
    game.keysPressed.left = true
  end

  if love.keyboard.isDown('right','d') then
    game.keysPressed.right = true
  end

  if love.keyboard.isDown('up','w') then
    game.keysPressed.up = true
  end

  if love.keyboard.isDown('down','s') then
    game.keysPressed.down = true
  end
end

function drawBoundingBox(origin, bbox)
  love.graphics.rectangle(
    'line',
    origin.x + (bbox.ox or 0),
    origin.y + (bbox.oy or 0),
    bbox.dx,
    bbox.dy
  )
end

function newBBox(ox, oy, dx, dy)
  return {ox = ox, oy = oy, dx = dx, dy = dy}
end
