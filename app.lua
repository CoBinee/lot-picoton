--[[pod_format="raw",created="2024-06-14 22:40:37",modified="2024-07-13 05:59:39",revision=3146]]
-- app.lua : application
--

-- include
include("text.lua")
include("lot.lua")


-- initialize application
function app_init()

	-- setup application
	palt(0x00, false)
	palt(0x3f, true)	
	window {
		width = 256,
		height = 192,
		resizeable = false,
		title = "lot lot lot"
	}

	-- create instance
	if not app then
		app = {
			state = 0, 
			count = 0, 
			frame_interval = 3, 
			frame_count = -1, 
			btn_left = false, 
			btn_right = false, 
			btn_up = false, 
			btn_down = false, 
			btn_o = false, 
			btn_o_last = false, 
		}
	end
	
	-- initialize instance
	
	-- initialize routines
	text_init()
	lot_init()

end
		
-- update
function app_update()

	-- update frame
	app.frame_count = app.frame_count + 1
	if app.frame_count >= app.frame_interval then
		app.frame_count = 0
	end
	
	-- update button
	if app.frame_count == 0 then
		app.btn_left = btn(0)
		app.btn_right = btn(1)
		app.btn_up = btn(2)
		app.btn_down = btn(3)
		app.btn_o = btnp(4) or app.btn_o_last
		app.btn_o_last = false
	else
		if btnp(4) then
			app.btn_o_last = true
		end
	end

	-- control frame
	if app.frame_count == 0 then
	
		-- 0: load game
		if app.state == 0 then
			lot_load()
			lot_update()
			text_print(6, 12, "*** START ***")
			app.count = 90 // app.frame_interval
			app.state = app.state + 1
			
		-- 1: start game
		elseif app.state == 1 then
			app.count = app.count - 1
			if app.count <= 0 then
				app.state = app.state + 1
			end
			
		-- 2: play game
		elseif app.state == 2 then
			lot_update()
			if lot.over > 0 then
				text_print(4, 12, "*** GAME OVER ***")
				if lot.score > lot.hiscore then
					text_print(8, 14, "YOU ARE TOP !")
					lot.hiscore = lot.score
				else
					text_print(6, 14, string.format("  HIGH SCORE % 5d", lot.hiscore))
				end
				app.state = app.state + 1
			end
			
		-- 3: end game
		else
			if app.btn_o then
				app.state = 0
			end
		end
		
		-- update text
		text_update()
	end

	
end
		
-- draw
function app_draw()

	-- control frame
	if app.frame_count == 0 then
		
		-- clear
		-- cls(0x01)
	
		-- draw routines
		local ox = 0
		local oy = 0
		text_draw(ox, oy)
		lot_draw(ox, oy)
		
	end
	
end
	