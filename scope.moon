import abs from math

drystal = require 'drystal'
timer = require 'hump.timer'
Entity = require 'entity'
Ball = require 'ball'

pop = drystal.load_sound('pop.wav')

class Scope extends Entity

	radius: 10
	color: drystal.colors.red
	score: 0

	default_alpha: 100
	alpha: 100
	alpha_handle: nil

	target: nil
	since: nil
	time: 0

	swifth: 0
	swiftw: 0
	swift_handle: nil

	new: =>
		super WIDTH / 2, HEIGHT / 2

	update: (dt, targets) =>
		@time += dt
		hit = (t) ->
			abs(@x - t.x) < t.radius*2 and abs(@y - t.y) < t.radius*2
		if not @target
			for t in *targets
				continue unless t.alive
				if hit t
					@target = t
					@since = @time
					timer.cancel(@alpha_handle) if @alpha_handle
					@alpha_handle = timer.tween @target.radius/10, @, {alpha: 255}, 'expo'
					break
		if @target and not hit @target
			@target = nil
			@reset_alpha!
		if @target
			if @time - @since > @target.radius/10
				s = @target.radius * 100 * (1 + math.random!)
				s *= if @target.good then 1 else -1
				@score = math.floor s

				pop\play!
				the_target = @target
				the_target.alive = false
				timer.tween 2, the_target, w: 1, 'bounce'
				timer.tween 2, the_target, h: 1, 'bounce'
				timer.add 2, ->
					remove_target the_target

				@target = nil
				@reset_alpha!

	draw: =>
		drystal.set_color(@color)
		drystal.set_alpha(@alpha)
		x, y = @x - @radius, @y - @radius
		drystal.draw_sprite_resized Ball.sprite, x, y, @radius*2 + @swiftw, @radius*2 + @swifth

	on_mouse_motion: (@x, @y, dx, dy) =>
		@swiftw = abs dx
		@swifth = abs dy
		timer.cancel @swift_handle if @swift_handle
		@swift_handle = timer.tween 0.3, @, {swiftw: 0, swifth: 0}, 'in-bounce'

	reset_alpha: =>
		timer.cancel @alpha_handle if @alpha_handle
		@alpha_handle = timer.tween 1, @, {alpha: @default_alpha}, 'quad'

