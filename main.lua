--
-- TODO: use a spritesheet with circle
--
require 'drystal'
local tt = require 'truetype'

local width, height = 600, 480
local time = 0

local score = 0

local scope = {
	x=0,
	y=0,
	size=10,
	color={255, 0, 0},
	alpha=255,
	range=10,

	target=nil,
	since=nil,
}

local targets = {}

function scope:draw()
	set_color(self.color)
	set_alpha(self.alpha)
	draw_circle(self.x, self.y, self.size)
end

function scope:update(dt)
	local abs = math.abs
	if not self.target then
		for i, t in ipairs(targets) do
			if abs(self.x - t.x) < t.size then
				if abs(self.y - t.y) < t.size then
					self.target = t
					self.since = time
					break
				end
			end
		end
	end
	if self.target then
		if abs(self.x - self.target.x) > self.target.size
		or abs(self.y - self.target.y) > self.target.size then
			self.target = nil
		end
	end
	if self.target then
		self.alpha = (math.sin((time - self.since)*5)+1)/2*200+50
		if time - self.since > self.target.size/10 then
			for i, t in ipairs(targets) do
				if t == self.target then table.remove(targets, i) end
			end
			score = (self.target.good and 1 or -1) * self.target.size
			self.target = nil
		end
	else
		self.alpha = 255
	end
end

local font

function init()
	show_cursor(false)
	resize(width, height)
	font = tt.load('arial.ttf', 30)
	tt.use(font)

	for i=0, 5 do
		add_target(false)
		add_target(true)
	end
end

function draw()
	set_alpha(255)
	set_color(0, 0, 0)
	draw_background()

	for i, t in ipairs(targets) do
		set_color(t.color)
		draw_circle(t.x, t.y, t.size)
	end

	scope:draw()

	tt.draw("Score: " .. score, 0, 0)

	flip()
end

function update(dt)
	dt = dt / 1000
	time = time + dt

	scope:update(dt)

	for i, t in ipairs(targets) do
		t.x = t.x + t.dx * t.speed * dt
		t.y = t.y + t.dy * t.speed * dt
		if t.x-t.size < 0 then
			t.dx = t.dx * -1
			t.x = t.size
		elseif t.x+t.size > width then
			t.dx = t.dx * -1
			t.x = width-t.size
		end
		if t.y-t.size < 0 then
			t.dy = t.dy * -1
			t.y = t.size
		elseif t.y+t.size > height then
			t.dy = t.dy * -1
			t.y = height-t.size
		end
	end
end

function add_target(good)
	local t = {
		x=math.random(width),
		y=math.random(height),
		speed=math.random()*70 + 30,
		dx=math.random(2)==1 and -1 or 1,
		dy=math.random(2)==1 and -1 or 1,
		size=math.random(5, 20),
		good=good
	}
	if good then
		t.color = {200, 200, 200}
	else
		t.color = {100, 100, 100}
	end
	table.insert(targets, t)
end


function mouse_motion(x, y)
	scope.x, scope.y = x, y
end

function key_press(k)
	if k == 'a' then
		print('stop')
		engine_stop()
	end
end
