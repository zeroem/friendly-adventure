require 'ecs'
require 'entity.enemy'
require 'entity.gun'
require 'entity.player'
require 'util'

game = {
  ecs = ecs.new(),
  playArea = nil,
  score = 0,
  resources = {
    playerImg = 'assets/aircraft/Aircraft_03.png',
    bulletImg = 'assets/aircraft/bullet_2_orange.png',
    enemyImg = 'assets/aircraft/Aircraft_01.png',
    powerupEnemyImg = 'assets/aircraft/Aircraft_02.png',
    powerupImg = 'assets/aircraft/bullet_purple0001.png'
  },
  isAlive = true,
  config = {
    drawHitboxes = false,
    scale = 0.75
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
    self.ecs:removeEntity(game.player)
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

  for k, path in pairs(game.resources) do
    game.resources[k] = love.graphics.newImage(path)
  end

  game.player = entity.player.createPlayer(game)
  entity.gun.createGun(game)
  entity.enemy.createSpawner(game)
end

function love.update(dt)
  processInput(dt)

  for c in game.ecs:getComponentsByType('update') do
    c:update(game, dt)
  end

  if not game.isAlive and love.keyboard.isDown('r') then
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

  love.graphics.print(string.format("Score: %d", game.score), 5, 5)

  for render, entity in game.ecs:getComponentsByType('render') do
    local origin = util.getOrigin(entity)
    love.graphics.draw(
      render.img,
      origin.x,
      origin.y,
      render.r,
      render.sx or game:scale(),
      render.sy or game:scale(),
      render.ox,
      render.oy,
      render.kx,
      render.ky
    )
  end

  if game.config.drawHitboxes then
    for hitbox in game.ecs:getComponentsByType('hitbox') do
      drawBoundingBox(util.getOrigin(hitbox._owner), hitbox)
    end
  end
end

function processInput(dt)
  game.keysPressed = {}

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
