--[[pod_format="raw",created="2024-07-11 11:52:56",modified="2024-07-13 05:58:24",revision=314]]
-- text.lua : text screen
--

-- include
include("font.lua")


-- initialize text screen
function text_init()

	-- create instance
	if not text then
		text = {
			vram = nil, 
			font = nil, 
		}
	end
	
	-- initialize instance
	text.vram = userdata('u8', 32, 24)
	text_clear()
	text.font = userdata('u8', 128, 128)
	for i = 0, 255, 1 do
		local cx = (i % 16) * 8
		local cy = (i // 16) * 8
		for py = 0, 7, 1 do
			local p = font_pattern[i * 8 + py + 1]
			for px = 0, 7, 1 do
				local c = 0x00
				if (p & (1 << (7 - px))) ~= 0 then
					c = 0x07
				end
				text.font:set(cx + px, cy + py, c)
			end
		end
	end

end

-- update text screen
function text_update()

end

-- draw text screen
function text_draw(ox, oy)

	-- draw vram
	for cy = 0, 23, 1 do
		for cx = 0, 31, 1 do
			local c = text.vram:get(cx, cy)
			local fx = (c % 16) * 8
			local fy = (c // 16) * 8
			sspr(text.font, fx, fy, 8, 8, ox + cx * 8, oy + cy * 8)
		end
	end

end

-- clear text screen
function text_clear()
	for y = 0, 23, 1 do
		for x = 0, 31, 1 do
			text.vram:set(x, y, 0x20)
		end
	end
end

-- print text screen
function text_print(x, y, s)
	for i = 1, #s, 1 do
		text.vram:set(x + i - 1, y, string.byte(s, i))
	end
end

