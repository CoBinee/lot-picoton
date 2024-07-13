--[[pod_format="raw",created="2024-07-11 13:18:54",modified="2024-07-13 05:58:24",revision=355]]
-- lot.lua : lotlotlot
--

-- include


-- initialize lotlotlot
function lot_init()

	-- create instance
	if not lot then
		lot = {
			field = nil,				-- D000..D2FF
			vwall_block = 0,			-- D300
			vwall_position = 0,		-- D301 
			hwall_block = 0,			-- D302
			hwall_position = 0, 	-- D303
			cursor_position = nil, 	-- D310..D373
			cursor_sprite = {
				nil, 
				nil, 
			}, 
			over = 0, 				-- D37C
			score = 0, 				-- D37D..D37E
			hiscore = 0, 
			keyedge = 0, 			-- D37F
			
		}
	end
	
	-- initialize instance
	lot.field = userdata('u8', 0x0300)
	lot.cursor_position = userdata('u8', 0x64)
	lot.cursor_sprite[1] = userdata('u8', 16, 16)
	lot.cursor_sprite[2] = userdata('u8', 16, 16)
		
	-- create cursor sprite
	do
		local pattern = 
			"30381C0F07090E37395E66791D0B0100" ..
			"00040C0C9CFC7CBCBC7CFCF8F8F0E000"
		for i = 1, #pattern, 2 do
			local p = tonumber('0x' .. string.sub(pattern, i, i + 1))
			local x = (((i - 1) // 2) // 16) * 8
			local y = ((i - 1) // 2) % 16
			for j = 0, 7, 1 do
				local c1 = 0x3f
				local c2 = 0x3f
				if (p & (1 << (7 - j))) ~= 0 then
					c1 = 0x1e
					c2 = 0x10
				end
				lot.cursor_sprite[1]:set(x + j, y, c1)
				lot.cursor_sprite[2]:set(x + j, y, c2)
			end
		end
	end
	
	-- create block character
	do 
		local pattern = {
			"DFDF00FDFDFD00DF", 
			"D7DF00DDE8BD00DA", 
			"55DE00DD60BD005A",
			"448A00D50089004A", 
			"4482000100810002", 
			"0000000000000000", 
		}
		for i = 1, #pattern, 1 do
			local x0 = (i - 1) * 8
			local x1 = (16 - i) * 8
			local y0 = 0x09 * 8
			local y1 = 0x0a * 8
			for j = 1, #pattern[i], 2 do
				local p = tonumber('0x' .. string.sub(pattern[i], j, j + 1))
				for k = 0, 7, 1 do
					local c = 0x00
					if (p & (1 << (7 - k))) ~= 0 then
						c = 0x0a
					end
					text.font:set(x0 + k, y0 + (j - 1) // 2, c)
					text.font:set(x1 + k, y1 + (j - 1) // 2, c)
				end
			end
		end
		for i = 0, 7, 1 do
			for j = 0, 7, 1 do
				local x = 0x05 * 8 + j
				local y = 0x08 * 8 + i
				local c = text.font:get(x, y)
				if c ~= 0 then
					text.font:set(x, y, 0x1c)
				end
			end
		end
	end
end

-- load lotlotlot
function lot_load()
	for i = 0, 0x02ff, 1 do
		lot.field:set(i, 0x20)
	end
	for i = 0, 4, 1 do
		for j = 2, 23, 1 do
			lot.field:set(i * 0x06 + j * 0x20, 0xaf)
		end
	end
	for i = 0, 4, 1 do
		for j = 0, 24, 1 do
			lot.field:set(i * 0xa0 + j + 0x40, 0xaf)
		end
	end
	lot.field:set(0x00, 0xaf)
	lot.field:set(0x18, 0xaf)
	lot.field:set(0x20, 0xaf)
	lot.field:set(0x38, 0xaf)
	for i = 0x00, 0x62, 1 do
		lot.cursor_position:set(i, 0x18)
	end
	lot.vwall_block = 0xaf
	lot.vwall_position = 0x00
	lot.hwall_block = 0x9f
	lot.hwall_position = 0x00
	lot.over = 0
	lot.score = 0
end

-- update lotlotlot
function lot_update()

	-- new ball
	lot.field:set(0x0001, 0x85)
	
	-- clear bottom line
	for i = 0x02e1, 0x02e5, 1 do
		lot.field:set(i, 0x20)
	end
	for i = 0x02e7, 0x02eb, 1 do
		lot.field:set(i, 0x20)
	end	
	for i = 0x02ed, 0x02f1, 1 do
		lot.field:set(i, 0x20)
	end	
	for i = 0x02f3, 0x02f7, 1 do
		lot.field:set(i, 0x20)
	end	
	for i = 0x02f9, 0x02ff, 1 do
		lot.field:set(i, 0x20)
	end	

	-- update vertical wall
	do
		local pos = {
			0x0066, 0x006c, 0x0072, 0x0078, 
			0x0106, 0x010c, 0x0112, 0x0118, 
			0x01a6, 0x01ac, 0x01b2, 0x01b8, 
			0x0246, 0x024c, 0x0252, 0x0258, 
		}
		if lot.vwall_block >= 0xaa or lot.vwall_block <= 0x95 then
			local p = pos[lot.vwall_position + 1]
			for i = 0, 3, 1 do
				lot.field:set(p + i * 0x20, lot.vwall_block)
			end
		end
		lot.vwall_block = lot.vwall_block + 1
		if lot.vwall_block >= 0xb0 then
			lot.vwall_block = 0x90
			lot.vwall_position = math.floor(rnd(16))
		end
	end

	-- update horizon wall
	do
		local pos = {
			0x0041, 0x0047, 0x004d, 0x0053, 
			0x00e1, 0x00e7, 0x00ed, 0x00f3, 
			0x0181, 0x0187, 0x018d, 0x0193, 
			0x0221, 0x0227, 0x022d, 0x0233, 
			0x02c1, 0x02c7, 0x02cd, 0x02d3, 
		}
		if lot.hwall_block >= 0xaa or lot.hwall_block <= 0x95 then
			local p = pos[lot.hwall_position + 1]
			for i = 0, 4, 1 do
				lot.field:set(p + i, lot.hwall_block)
			end
		end
		lot.hwall_block = lot.hwall_block + 1
		if lot.hwall_block >= 0xb0 then
			lot.hwall_block = 0x90
			lot.hwall_position = math.floor(rnd(20))
		end		
	end
	
	-- hole random wall
	do
		local h = ((lot.score * 2) >> 8) & 0xff
		local r = math.floor(rnd(128))
		if r < h then
			local p = ((lot.score & 0xff) ~ r) * 2 + 0x0040
			lot.field:set(p, 0x20)
			for i = 0, 23, 1 do
				lot.field:set(i * 0x0020, 0xaf)
			end
		end
	end
	
	-- move ball
	for i = 0x02df, 0x0001, -1 do
		local c = lot.field:get(i)
		if c == 0x95 then
			lot.field:set(i, 0x20)
		elseif c == 0x85 then
			if lot.field:get(i + 0x0020) == 0x20 then
				lot.field:set(i + 0x0000, 0x20)
				lot.field:set(i + 0x0020, 0x85)
			else
				local cl = lot.field:get(i - 1)
				local cr = lot.field:get(i + 1)
				local m = 0
				if cl == 0x20 then
					if cr == 0x20 then
						m = math.floor(rnd(2)) * 2 - 1
					else
						m = -1
					end
				elseif cr == 0x20 then
					m = 1
				end
				if m ~= 0 then
					lot.field:set(i + 0, 0x20)
					lot.field:set(i + m, 0x85)
				end
			end
		end
	end
	
	-- count score
	for i = 0x02f9, 0x02ff, 1 do
		if lot.field:get(i) == 0x85 then
			lot.score = lot.score + 2
			-- call 0xCAE0
		end
	end
	for i = 0x02f3, 0x02f7, 1 do
		if lot.field:get(i) == 0x85 then
			lot.score = lot.score + 1
			-- call 0xCAF7
		end
	end
	--[[
	for i = 0x02ed, 0x02f1, 1 do
		if lot.field:get(i) == 0x85 then
			lot.score = lot.score + 0
		end
	end
	]]
	for i = 0x02e7, 0x02eb, 1 do
		if lot.field:get(i) == 0x85 then
			lot.score = lot.score - 3
			-- call 0xCB0E
		end
	end
	for i = 0x02e1, 0x02e5, 1 do
		if lot.field:get(i) == 0x85 then
			lot.over = lot.over + 1
		end
	end
	lot.score = min(65535, max(0, lot.score))
	
	-- move cursor
	for i = 0x61, 0x00, -1 do
		local c = lot.cursor_position:get(i + 0x00)
		lot.cursor_position:set(i + 0x02, c)
	end
	do
		local x = lot.cursor_position:get(0x02)
		local y = lot.cursor_position:get(0x03)
		if app.btn_left then
			x = max(0x08, x - 3)
		elseif app.btn_right then
			x = min(0xc0, x + 3)
		end
		if app.btn_up then
			y = max(0x18, y - 3)
		elseif app.btn_down then
			y = min(0xb0, y + 3)
		end
		lot.cursor_position:set(0x00, x)
		lot.cursor_position:set(0x01, y)
		-- sound
	end
	
	-- swap ball
	if app.btn_o then
		local x0 = lot.cursor_position:get(0x62)
		local y0 = lot.cursor_position:get(0x63)
		local p0 = lot_get_field_point(x0, y0)
		local x1 = lot.cursor_position:get(0x00)
		local y1 = lot.cursor_position:get(0x01)
		local p1 = lot_get_field_point(x1, y1)
		for i = 0, 3, 1 do
			for j = 0, 4, 1 do
				local c0 = lot.field:get(p0)
				local c1 = lot.field:get(p1)
				lot.field:set(p0, c1)
				lot.field:set(p1, c0)
				p0 = p0 + 1
				p1 = p1 + 1
			end
			p0 = p0 + 0x001b
			p1 = p1 + 0x001b
		end
	end
	
	-- print field
	for y = 0, 23, 1 do
		for x = 0, 31, 1 do
			local c = lot.field:get(y * 0x0020 + x)
			text.vram:set(x, y, c)
		end
	end
	
	-- print score
	do
		text_print(25, 0, "SCORE")
		text_print(25, 1, string.format("% 6d", lot.score))
	end
	
	-- print bottom info
	do
		local s = " OVER   - 3         + 1   + 2   "
		for i = 1, #s, 1 do
			local c = string.byte(s, i)
			if c ~= 0x20 then
				text.vram:set(i - 1, 23, c)
			end
		end
	end
	
end

function lot_get_field_point(x, y)
	local p = 0xffbb	
	x = x - 0x04
	repeat
		p = p + 0x0006
		x = x - 0x30
	until x < 0
	y = y - 0x14
	repeat
		p = p + 0x00a0
		y = y - 0x28
	until y < 0
	return p & 0xffff
end
--[[        
MDLCAA4:                                ;CAA4:
        LD      IX,0CFBBH               ;CAA4: DD21BBCF
        LD      A,D                     ;CAA8: 7A
        SUB     004H                    ;CAA9: D604
        LD      BC,0006H                ;CAAB: 010600
LBLCAAE:                                ;CAAE:
        ADD     IX,BC                   ;CAAE: DD09
        SUB     030H                    ;CAB0: D630
        JR      NC,LBLCAAE              ;CAB2: 30FA
        LD      A,E                     ;CAB4: 7B
        SUB     014H                    ;CAB5: D614
        LD      C,0A0H                  ;CAB7: 0EA0
LBLCAB9:                                ;CAB9:
        ADD     IX,BC                   ;CAB9: DD09
        SUB     028H                    ;CABB: D628
        JR      NC,LBLCAB9              ;CABD: 30FA
        RET                             ;CABF: C9
]]

-- draw lotlotlot
function lot_draw(ox, oy)

	-- draw cursor
	do
		local x = lot.cursor_position:get(0x62)
		local y = lot.cursor_position:get(0x63)
		spr(lot.cursor_sprite[2], ox + x, oy + y)
	end
	do
		local x = lot.cursor_position:get(0x00)
		local y = lot.cursor_position:get(0x01)
		spr(lot.cursor_sprite[1], ox + x, oy + y)
	end

end
