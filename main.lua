require 'drystal'
local tt = require 'truetype'

local width, height = 600, 480
local time = 0

local scope = {
	x=0,
	y=0,
	size=20,
	color={255, 0, 0},
	alpha=255,
}

local targets = {}

function scope:draw()
	set_color(self.color)
	set_alpha(self.alpha)
	draw_circle(self.x, self.y, self.size)
end

function scope:update(dt)
	self.alpha = (math.sin(time*5)+1)/2*200+50
end


function init()
	show_cursor(false)
	resize(width, height)

	for i=0, 10 do
		add_target(math.random(2)==1)
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
		speed=math.random()*50 + 40,
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
