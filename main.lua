require 'drystal'

function init()
	resize(600, 480)
end

function draw()
end

function update(dt)
end

function key_press(k)
	if k == 'a' then
		print('stop')
		engine_stop()
	end
end
