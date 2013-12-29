local drystal = require 'drystal'
local tt = require 'truetype'
local timer = require 'hump.timer'

math.randomseed(os.time())

local width, height = 600, 600
local time = 0

local RUN = {
	x=0, y=0,
}
local END = {
	x=0, y=-20,
	tx=width/2, ty=height/2,
}
local gamestate

local font, image
local ball_sprite = {x=0, y=0, w=64, h=64}
local pop = drystal.load_sound('pop.wav')

local score = 0

local scope = {
	x=width/2,
	y=height/2,
	radius=10,

	color={255, 0, 0},
	default_alpha=100,
	alpha=100,
	alpha_handle=nil,

	target=nil,
	since=nil,

	swiftw=0,
	swifth=0,
	swift_handle=nil,
}

local targets = {}

function remove_target(target)
	for i, t in ipairs(targets) do
		if t == target then table.remove(targets, i) end
	end
end


function scope:update(dt)
	local abs = math.abs
	if not self.target then
		for i, t in ipairs(targets) do
			if t.alive and abs(self.x - t.x) < t.radius*2 then
				if abs(self.y - t.y) < t.radius*2 then
					self.target = t
					self.since = time
					if self.alpha_handle then
						timer.cancel(self.alpha_handle)
					end
					self.alpha_handle = timer.tween(self.target.radius/10,
													self, {alpha=255}, 'expo')
					break
				end
			end
		end
	end
	if self.target then
		if abs(self.x - self.target.x) > self.target.radius*2
		or abs(self.y - self.target.y) > self.target.radius*2 then
			self.target = nil
			self:reset_alpha()
		end
	end
	if self.target then
		if time - self.since > self.target.radius/10 then
			score = (self.target.good and 1 or -1) * self.target.radius * 100 * (1 + math.random())
			score = math.floor(score)

			pop:play()
			local the_target = self.target
			the_target.alive = false
			timer.tween(2, the_target, {w=1}, 'bounce')
			timer.tween(2, the_target, {h=1}, 'bounce')
			timer.add(2, function() remove_target(the_target) end)

			self.target = nil
			self:reset_alpha()
		end
	end
end

function scope:reset_alpha()
	if self.alpha_handle then
		timer.cancel(self.alpha_handle)
	end
	self.alpha_handle = timer.tween(1, self, {alpha=self.default_alpha}, 'quad')
end

function init()
	drystal.show_cursor(false)
	drystal.resize(width, height)

	font = tt.load('coldnightforalligators.ttf', 40)
	tt.use(font)

	image = drystal.load_surface('ball.png')
	drystal.draw_from(image)

	reload()
end

function reload()
	targets = {}
	for i=0, 5 do
		add_target(false)
		add_target(true)
	end
	gamestate = RUN
end

function draw()
	drystal.set_alpha(255)
	drystal.set_color(0, 0, 0)
	drystal.draw_background()

	for i, t in ipairs(targets) do
		drystal.set_color(t.color)
		drystal.draw_sprite_resized(ball_sprite, t.x - t.w/2, t.y - t.h/2,
							t.w, t.h)
	end

	drystal.set_color(scope.color)
	drystal.set_alpha(scope.alpha)
	local x, y = scope.x - scope.radius, scope.y - scope.radius
	drystal.draw_sprite_resized(ball_sprite, x, y, scope.radius*2 + scope.swiftw, scope.radius*2 + scope.swifth)

	drystal.set_alpha(255)
	if gamestate == END then
		local text = "Score: " .. score
		local w, h = tt.sizeof(text)
		tt.draw(text, gamestate.x - w / 2, gamestate.y - h/2)
	end
end

function update(dt)
	dt = dt / 1000
	time = time + dt

	if gamestate == RUN then
		scope:update(dt)

		local goods = 0
		for i, t in ipairs(targets) do
			if t.alive then
				if t.good then goods = goods + 1 end
				t.x = t.x + t.dx * t.speed * dt
				t.y = t.y + t.dy * t.speed * dt
				local collidex
				local collidey
				if t.x-t.radius < 0 then
					t.dx = t.dx * -1
					t.x = t.radius
					collidex = true
				elseif t.x+t.radius > width then
					t.dx = t.dx * -1
					t.x = width-t.radius
					collidex = true
				end
				if t.y-t.radius < 0 then
					t.dy = t.dy * -1
					t.y = t.radius
					collidey = true
				elseif t.y+t.radius > height then
					t.dy = t.dy * -1
					t.y = height-t.radius
					collidey = true
				end
				if collidex then
					t.h = t.radius*3
					timer.tween(.6, t, {h=t.radius*2}, 'in-bounce')
				end
				if collidey then
					t.w = t.radius*3
					timer.tween(.6, t, {w=t.radius*2}, 'in-bounce')
				end
			end
		end

		if goods == 0 and gamestate == RUN then
			gamestate = END
			timer.tween(2.7, gamestate, {x=gamestate.tx})
			timer.tween(3, gamestate, {y=gamestate.ty}, 'in-bounce')
		end
	end

	timer.update(dt)
end

function add_target(good)
	local t = {
		x=math.random(width-40) + 20,
		y=math.random(height-40) + 20,
		speed=math.random()*70 + 30,
		dx=math.random(2)==1 and -1 or 1,
		dy=math.random(2)==1 and -1 or 1,
		radius=math.random(5, 20),
		good=good,
		alive=true,
	}
	t.w = t.radius * 2
	t.h = t.radius * 2
	if good then
		t.color = {100, 100, 100}
	else
		t.color = {50, 50, 50}
	end
	table.insert(targets, t)
end


function mouse_motion(x, y, dx, dy)
	scope.swiftw = math.abs(dx)
	scope.swifth = math.abs(dy)
	if scope.swift_handle then
		timer.cancel(scope.swift_handle)
	end
	scope.swift_handle = timer.tween(0.3, scope, {swiftw=0, swifth=0}, 'in-bounce')
	scope.x, scope.y = x, y
end

function key_press(k)
	if k == 'a' then
		drystal.stop()
	end
	if k == 'return' and gamestate == END then
		reload()
	end
end
