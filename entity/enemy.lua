module('entity.enemy', package.seeall)

function createSpawner(game)
  local spawner = game.ecs:newEntity()
  spawner:addComponent('update', {
    lastSpawnTime = nil,
    delay = 0.3,
    canSpawn = function(self)
      if not self.lastSpawnTime then
        return true
      else
        local currentTime = love.timer.getTime()
        if (currentTime - self.lastSpawnTime) > self.delay then
          return true
        end
      end

      return false
    end,

    update = function(self, game, dt)
      if self:canSpawn() then
        self.lastSpawnTime = love.timer.getTime()

        if math.random(1, 10) <= 1 then
          entity.enemy.createPowerupEnemy(game)
        else
          entity.enemy.createEnemy(game)
        end
      end
    end
  })
end

function enemyUpdate(self, game, dt)
  self.origin.y = self.origin.y + (self.speed * dt)

  if not util.overlap(self.origin,
                      self.bounds, 
                      util.getOrigin(game.gameArea),
                      util.getBounds(game.gameArea)) then
    game.ecs:removeEntity(self.entity)
  end

  for _, bullet in game.ecs:getComponentsByType('bullet') do
    local bulletOrigin = util.getOrigin(bullet)

    for enemyHitbox in self.entity:getComponentsByType('hitbox') do
      for bulletHitbox in bullet:getComponentsByType('hitbox') do
        if util.overlap(self.origin, enemyHitbox, bulletOrigin, bulletHitbox) then
          game.ecs:removeEntity(bullet)

          self.stats.health = self.stats.health - 1

          if self.stats.health <= 0 then
            game.ecs:removeEntity(self.entity)
            game.score = game.score + self.stats.points
          end
          return
        end
      end
    end
  end
end

function createEnemy(game)
  local enemy = game.ecs:newEntity()
  local velocity = enemy:addComponent('velocity', {speed = 200})
  local img = game.resources.enemyImg
  local origin = enemy:addComponent('origin', {
    x = math.random(10, love.graphics.getWidth() - 10 - game:scale(img:getWidth())),
    y = -0.9 * game:scale(img:getHeight())
  })

  local bounds = enemy:addComponent(
    'bounds',
    { dx = game:scale(img:getWidth()), dy = game:scale(img:getHeight())}
  )

  enemy:addComponent('enemy')
  enemy:addComponent('render', {
    img = img,
    r = math.pi,
    ox = img:getWidth(),
    oy = img:getHeight(),
  })

  enemy:addComponent('hitbox', newBBox(0, game:scale(50), game:scale(img:getWidth()), game:scale(20)))
  enemy:addComponent('hitbox', newBBox(game:scale(img:getWidth()) / 2 - 7, 0, 14, game:scale(img:getHeight() - 5)))
  enemy:addComponent('update', {
    speed = 200,
    origin = origin,
    bounds = bounds,
    entity = enemy,
    stats = {health = 2, points = 1},
    update = enemyUpdate
  })
end

function createPowerupEnemy(game)
    local enemy = game.ecs:newEntity()
    local velocity = enemy:addComponent('velocity', { speed = 200 })
    local img = game.resources.powerupEnemyImg
    local origin = enemy:addComponent('origin', {
      x = math.random(10, love.graphics.getWidth() - 10 - game:scale(img:getWidth())),
      y = -0.9 * game:scale(img:getHeight())
    })
    local bounds = enemy:addComponent(
      'bounds',
      { dx = game:scale(img:getWidth()), dy = game:scale(img:getHeight())}
    )

    enemy:addComponent('enemy')
    enemy:addComponent('render', {
      img = img,
      r = math.pi,
      ox = img:getWidth(),
      oy = img:getHeight(),
    })
    enemy:addComponent('hitbox', newBBox(0, game:scale(40), game:scale(img:getWidth()), game:scale(20)))
    enemy:addComponent('hitbox', newBBox(game:scale(img:getWidth()) / 2 - 7, 0, 14, game:scale(img:getHeight() - 5)))
    enemy:addComponent('update', {
      speed = 200,
      origin = origin,
      bounds = bounds,
      entity = enemy,
      stats = {health = 5, points = 10},
      update = enemyUpdate
    })
  end
