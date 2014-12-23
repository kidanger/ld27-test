require 'mooner'
local drystal = require 'drystal'
local timer = require 'hump.timer'
WIDTH, HEIGHT = 600, 600
local Ball = require 'ball'
local Scope = require 'scope'

math.randomseed(os.time())

local RUN = {
	x=0, y=0,
}
local END = {
	x=0, y=-20,
	tx=WIDTH/2, ty=HEIGHT/2,
}
local gamestate

local font, image

local scope = Scope()
local targets = {}

function remove_target(target)
	for i, t in ipairs(targets) do
		if t == target then table.remove(targets, i) end
	end
end

function drystal.init()
	drystal.show_cursor(false)
	drystal.resize(WIDTH, HEIGHT)

	font = assert(drystal.load_font('coldnightforalligators.ttf', 40))

	image = drystal.load_surface('ball.png')
	image:draw_from()

	reload()
end

function reload()
	targets = {}
	for i = 0, 5 do
		table.insert(targets, Ball(true))
		table.insert(targets, Ball(false))
	end
	gamestate = RUN
	scope.score = 0
end

function drystal.draw()
	drystal.set_alpha(255)
	drystal.set_color(0, 0, 0)
	drystal.draw_background()

	for i, t in ipairs(targets) do
		t:draw()
	end
	scope:draw()

	drystal.set_alpha(255)
	if gamestate == END then
		local text = "Score: " .. scope.score
		local w, h = font:sizeof(text)
		font:draw(text, gamestate.x - w / 2, gamestate.y - h/2)
	end
end

function drystal.update(dt)
	if gamestate == RUN then
		scope:update(dt, targets)

		local goods = 0
		for i, t in ipairs(targets) do
			t:update(dt)
			if t.alive and t.good then goods = goods + 1 end
		end

		if goods == 0 and gamestate == RUN then
			gamestate = END
			timer.tween(2.7, gamestate, {x=gamestate.tx})
			timer.tween(3, gamestate, {y=gamestate.ty}, 'in-bounce')
		end
	end

	timer.update(dt)
end

function drystal.mouse_motion(x, y, dx, dy)
	scope:on_mouse_motion(x, y, dx, dy)
end

function drystal.key_press(k)
	if k == 'a' then
		drystal.stop()
	end
	if k == 'return' and gamestate == END then
		reload()
	end
end
