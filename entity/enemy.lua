module('entity.enemy', package.seeall)

require 'entity.powerup'

function createSpawner(game)
  local spawner = game.ecs:newEntity('enemySpawner')
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

        if math.random(1, 30) <= 1 then
          entity.enemy.createPowerupEnemy(game)
        else
          entity.enemy.createEnemy(game)
        end
      end
    end
  })
end

function enemyUpdater(opts)
  local opts = opts or {}
  return function(self, game, dt)
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
            local bulletDamage = util.getSingleComponent(bullet, 'damage', {amount=1})

            self.stats.health = self.stats.health - bulletDamage.amount

            if self.stats.health <= 0 then
              if opts.deathFn then
                opts.deathFn(self, game, dt)
              end
              game.ecs:removeEntity(self.entity)
              game.score = game.score + self.stats.points
            end
            return
          end
        end
      end
    end
  end
end

function createEnemy(game)
  local enemy = game.ecs:newEntity('basicEnemy')
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
  enemy:addComponent('clear-on-reset')
  enemy:addComponent('render', util.renderImage(game, origin, {
    img = img,
    r = math.pi,
    ox = img:getWidth(),
    oy = img:getHeight(),
  }))

  enemy:addComponent('hitbox', newBBox(0, game:scale(50), game:scale(img:getWidth()), game:scale(20)))
  enemy:addComponent('hitbox', newBBox(game:scale(img:getWidth()) / 2 - 7, 0, 14, game:scale(img:getHeight() - 5)))
  local stats = enemy:addComponent('stats', {health = 6, points = 1, collisionDamage = 1})

  enemy:addComponent('update', {
    speed = 200,
    origin = origin,
    bounds = bounds,
    entity = enemy,
    stats = stats,
    update = enemyUpdater()
  })
end

function createPowerupEnemy(game)
  local enemy = game.ecs:newEntity('powerupEnemy')
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
  enemy:addComponent('clear-on-reset')
  enemy:addComponent('render', util.renderImage(game, origin, {
    img = img,
    r = math.pi,
    ox = img:getWidth(),
    oy = img:getHeight(),
  }))
  enemy:addComponent('hitbox', newBBox(0, game:scale(40), game:scale(img:getWidth()), game:scale(20)))
  enemy:addComponent('hitbox', newBBox(game:scale(img:getWidth()) / 2 - 7, 0, 14, game:scale(img:getHeight() - 5)))
  local stats = enemy:addComponent('stats', {health = 10, points = 10, collisionDamage = 2})
  enemy:addComponent('update', {
    speed = 200,
    origin = origin,
    bounds = bounds,
    entity = enemy,
    stats = stats,
    update = enemyUpdater({ deathFn = function(self, game, dt)
      entity.powerup.createPowerup(game, enemy)
    end})
  })
end
