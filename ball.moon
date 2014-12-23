drystal = require 'drystal'
timer = require 'hump.timer'
Entity = require 'entity'

class Ball extends Entity
	@sprite: {x: 0, y: 0, w: 64, h: 64}
	alive: true

	new: (@good) =>
		super math.random(WIDTH - 40) + 20, math.random(HEIGHT - 40) + 20
		@dx = if math.random(2) == 1 then -1 else 1
		@dy = if math.random(2) == 1 then -1 else 1
		@radius = math.random(5, 20)
		@speed = math.random()*70 + 30
		@w = @radius * 2
		@h = @radius * 2
		@color = if good then {100, 100, 100} else {50, 50, 50}

	update: (dt) =>
		return unless @alive
		@x += @dx * @speed * dt
		@y += @dy * @speed * dt
		local collidex
		local collidey
		if @x - @radius < 0
			@dx *= -1
			@x = @radius
			collidex = true
		elseif @x + @radius > WIDTH
			@dx *= -1
			@x = WIDTH-@radius
			collidex = true
		if @y-@radius < 0
			@dy *= -1
			@y = @radius
			collidey = true
		elseif @y + @radius > HEIGHT
			@dy *= -1
			@y = HEIGHT - @radius
			collidey = true
		if collidex
			@h = @radius*3
			timer.tween .6, @, {h: @radius*2}, 'in-bounce'
		if collidey
			@w = @radius*3
			timer.tween .6, @, {w: @radius*2}, 'in-bounce'

	draw: =>
		drystal.set_color @color
		drystal.draw_sprite_resized @@sprite, @x - @w/2, @y - @h/2, @w, @h

