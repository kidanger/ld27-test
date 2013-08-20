require 'drystal'

function init()
	resize(600, 480)
end

function draw()
	set_color(255, 255, 255)
	draw_background()

	flip()
end

function update(dt)
end

function key_press(k)
	if k == 'a' then
		print('stop')
		engine_stop()
	end
end
