grid_actions = {}

function ga.parse_key(x,y,z)
  -- FIXME x & y are swapped (grid is sideways) so correct that here first

  if y == 16 then -- global row
    if x == 8 then -- same in both modes
      ga.meta(z)
    else -- all other bottom row keys
      local global_action = (grid_page == 0) and ga.global or ga.metaglobal
      global_action( x,z )
    end
  else -- banks
    local bank_action = (grid_page == 0) and ga.bank or ga.metabank
    bank_action( math.floor((y-1)/5) + 1, x,y,z )
  end
end

-- top level functions. most of the actual press detection goes here
function ga.bank( bank, x,y,z )
  --TODO
  print('ga.bank ' .. bank .. ' ' .. x .. ' ' .. y .. ' ' .. z)
  if x <= 4 then -- left side
    if y <= 4 then
      ga.pad( bank, x,y,z )
    end -- ignore bottom row
  else -- right side
    if y == 1 then     -- 1 2 3 f
      -- TODO
    elseif y == 2 then -- L C r P
      -- TODO
    elseif y == 3 then
      if x == 5 then
        -- TODO *
      elseif x >= 7 then -- Z Z
        ga.zilchmo( bank, 2, x-6, z )
      end
    elseif y == 4 then
      if x >= 6 then -- Z Z Z
        ga.zilchmo( bank, 3, x-5, z )
      end
    elseif y == 5 then -- Z Z Z Z
      ga.zilchmo( bank, 4, x-4, z )
    end
  end
end

function ga.metabank( bank, x,y,z )
  --TODO
  print('ga.metabank ' .. bank .. ' ' .. x .. ' ' .. y .. ' ' .. z)
end

function ga.global( x,z )
  if x == 1 then
    ga.alt_pp(z)
  elseif x <= 4 then
    ga.buffer_select(x-1,z)
  elseif x <= 7 then
    ga.arc_patterns(x-4,z)
  end
end

function ga.metaglobal( x,z )
  --TODO
  print('ga.metaglobal ' .. x .. ' ' .. z)
end



--[[
When you plug grid into cheat codes, turn it so it’s 16 tall and 8 wide (versus the
standard 8 tall and 16 wide) and this is what you’ll see:
x x x x | 1 2 3 f
x x x x | L C r P
x x x x | * - Z Z
x x x x | - Z Z Z
- - - - | Z Z Z Z
x x x x | 1 2 3 f
x x x x | L C r P
x x x x | * - Z Z
x x x x | - Z Z Z
- - - - | Z Z Z Z
x x x x | 1 2 3 f
x x x x | L C r P
x x x x | * - Z Z
x x x x | - Z Z Z
- - - - | Z Z Z Z
A 1 2 3 | p p p m

cheat codes is broken up into three banks of two main playing surfaces:

banks and pads
x x x x
x x x x
x x x x
x x x x 

zilchmo's right-angle slice
- - - P: pattern recorder
- - Z Z: level + play/pause
- Z Z Z: panning
Z Z Z Z: start/end points, rate, direction

]]


--TODO this should be deprecated and just call parse_key directly
function grid_actions.init(x,y,z)
  if osc_communication then osc_communication = false end

  ga.parse_key(x,y,z)
--  if grid_page == 0 then
--    -- banks
--    ga.focus_hold(x,y,z)
--    ga.pad(x,y,z)
--    ga.zilch(x,y,z)
--    ga.action2(x,y,z)
--    ga.action4(x,y,z)
--    ga.action6(x,y,z)
--    ga.action7(x,y,z)
--    ga.action8(x,y,z)
--    ga.action9(x,y,z)
--    ga.crow_pad_execute(x,y,z)
--    ga.action11(x,y,z)
--    -- bottom row
--    ga.alt_pp(x,y,z)
--    ga.arc_patterns(x,y,z)
--  else
--    if grid.loop_mod == 0 then
--      ga.modaction1(x,y,z)
--      ga.modaction2(x,y,z)
--      ga.modaction3(x,y,z)
--      ga.modaction4(x,y,z)
--      ga.modaction5(x,y,z)
--      ga.modaction6(x,y,z)
--    elseif grid.loop_mod == 1 then
--      ga.modaction7(x,y,z)
--    end
--    ga.modaction8(x,y,z)
--    ga.help(x,y,z)
--  end
--  ga.meta(x,y,z)
end



--- actions list


-- bank

-- zilchmos!
-- this table is used to track which fingers in a zilchmo pattern are pressed
  -- 0: not pressed
  -- 1: pressed, but has released
  -- 2: pressed, and still held
-- TODO could put in the banks table?
ga.zmemory = {} -- was fingers
for n=1,3 do
  ga.zmemory[n] = {}
  for r=2,4 do -- should update to use 1,3 (not 2,4)
    ga.zmemory[n][r] = {[1]=0,[2]=0,[3]=0,[4]=0}
  end
end

function ga.zilchmo( bank, row, x,z )
  local zrow = ga.zmemory[bank][row] -- alias

  if z == 1 then -- save press
    zrow[x] = 2 -- active & held
  else -- release
    zrow[x] = 1 -- active & released

    local do_z = true -- test if all released
    for n=1,4 do
      if v == 2 then -- still physically held
        do_z = false
        break
      end
    end

    -- TODO combine with if-released test
    if do_z then -- do action
      local zcon = ''
      for n=1,4 do
        if zrow[n] == 1 then
          zcon = zcon .. tostring(n) -- make concat list
          zrow[n] = 0 -- reset zmemory
        end
      end
      -- TODO call zilchmo
      print('TODO call zilchmo b='..bank..' row='..row..' '..zcon)
      -- selected_zilchmo_bank = i
    end
  end
end



-- global

function ga.meta(x,y,z) -- used by meta as well
  if z == 1 then
    if grid.alt == 0 then
      grid_page = (grid_page + 1)%2
      if menu == 8 then
        if grid_page == 1 then
          help_menu = "meta page"
        elseif grid_page == 0 then
          help_menu = "welcome"
        end
        redraw()
      end
    elseif grid.alt == 1 then
      clk_midi:stop()
      clk:reset()
    end
  end
end

function ga.alt_pp(z)
  if grid.alt_pp == 1 then grid.alt_pp = 0 end
  grid.alt = z

  if menu == 8 then
    if grid.alt == 1 then
      help_menu = "alt"
    else
      help_menu = "welcome"
    end
  end
  redraw()
  grid_redraw()
end

function ga.buffer_select(x,z)
  if z == 1 then
    softcut.level_slew_time(1,0.5)
    softcut.fade_time(1,0.01)

    local old_clip = rec.clip

    for go = 1,2 do
      local old_min = (1+(8*(rec.clip-1)))
      local old_max = (9+(8*(rec.clip-1)))
      local old_range = old_min - old_max
      rec.clip = x
      local new_min = (1+(8*(rec.clip-1)))
      local new_max = (9+(8*(rec.clip-1)))
      local new_range = new_max - new_min
      local current_difference = (rec.end_point - rec.start_point)
      rec.start_point = (((rec.start_point - old_min) * new_range) / old_range) + new_min
      rec.end_point = rec.start_point + current_difference
    end

    if rec.loop == 0 and grid.alt == 0 then
      softcut.position(1,rec.start_point)
      if rec.state == 0 then
        rec.state = 1
        softcut.rec_level(1,1)
        rec_state_watcher:start()
        end
      if rec.clear == 1 then rec.clear = 0 end
    elseif rec.loop == 0 and grid.alt == 1 then
      buff_flush()
    end

    softcut.loop_start(1,rec.start_point)
    softcut.loop_end(1,rec.end_point-0.01)
    if rec.loop == 1 then
      if old_clip ~= rec.clip then rec.state = 0 end
      buff_freeze()
      if rec.clear == 1 then
        rec.clear = 0
      end
    end
    if grid.alt == 1 then
      buff_flush()
    end

    if menu == 8 then
      help_menu = "buffer switch"
    end
  end
end

function ga.arc_patterns(i,z)
  if z == 0 then
    if grid.alt == 1 then
      arc_pat[i]:rec_stop()
      arc_pat[i]:stop()
      arc_pat[i]:clear()
    elseif arc_pat[i].rec == 1 then
      arc_pat[i]:rec_stop()
      arc_pat[i]:start()
    elseif arc_pat[i].count == 0 then
      arc_pat[i]:rec_start()
    elseif arc_pat[i].play == 1 then
      arc_pat[i]:stop()
    else
      arc_pat[i]:start()
    end
    if menu == 8 then
      help_menu = "arc patterns"
      which_bank = i
    end
  end
end


-- metabank

-- metaglobal







--- uncategorized



-- lower level actions
function ga.focus_hold(x,y,z)
  for i = 1,3 do
    if grid.alt == 1 then
      if x == 1+(5*(i-1)) and y == 1 and z == 1 then
        bank[i].focus_hold = not bank[i].focus_hold
      end
    end
  end
end

function ga.pad( bank, x,y,z )
  for i = 1,3 do
    if z == 1 and x > 0 + (5*(i-1)) and x <= 4 + (5*(i-1)) and y >=5 then
      if bank[i].focus_hold == false then
        if grid.alt == 0 then
          selected[i].x = x
          selected[i].y = y
          selected[i].id = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
          bank[i].id = selected[i].id
          which_bank = i
          if menu == 8 then
            help_menu = "banks"
          end
          pad_clipboard = nil
          if bank[i].quantize_press == 0 then
            cheat(i, bank[i].id)
            grid_p[i] = {}
            grid_p[i].action = "pads"
            grid_p[i].i = i
            grid_p[i].id = selected[i].id
            grid_p[i].x = selected[i].x
            grid_p[i].y = selected[i].y
            grid_p[i].rate = bank[i][bank[i].id].rate
            grid_p[i].start_point = bank[i][bank[i].id].start_point
            grid_p[i].end_point = bank[i][bank[i].id].end_point
            grid_p[i].rate_adjusted = false
            grid_p[i].loop = bank[i][bank[i].id].loop
            grid_p[i].pause = bank[i][bank[i].id].pause
            grid_p[i].mode = bank[i][bank[i].id].mode
            grid_p[i].clip = bank[i][bank[i].id].clip
            grid_pat[i]:watch(grid_p[i])
          else
            table.insert(quantize_events[i],selected[i].id)
          end
        end
      else
        if grid.alt == 0 then
          bank[i].focus_pad = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
        elseif grid.alt == 1 then
          if not pad_clipboard then
            pad_clipboard = {}
            bank[i].focus_pad = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
            pad_copy(pad_clipboard, bank[i][bank[i].focus_pad])
          else
            bank[i].focus_pad = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
            pad_copy(bank[i][bank[i].focus_pad], pad_clipboard)
            pad_clipboard = nil
          end
        end
      end
      redraw()
    elseif z == 0 and x > 0 + (5*(i-1)) and x <= 4 + (5*(i-1)) and y >=5 then
      if bank[i][bank[i].id].play_mode == "momentary" then
        softcut.rate(i+1,0)
      end
    end
  end
end

function ga.action2(x,y,z)
  for k = 1,1 do
    for i = 1,3 do
      if z == 0 and x == (k+1)+(5*(i-1)) and y<=k then
        if grid_pat[i].quantize == 0 then -- still relevant
          if grid.alt == 1 then -- still relevant
            grid_pat[i]:rec_stop()
            grid_pat[i]:stop()
            --grid_pat[i].external_start = 0
            grid_pat[i].tightened_start = 0
            grid_pat[i]:clear()
            pattern_saver[i].load_slot = 0
          elseif grid_pat[i].rec == 1 then -- still relevant
            grid_pat[i]:rec_stop()
            midi_clock_linearize(i)
            if grid_pat[i].auto_snap == 1 then
              print("auto-snap")
              snap_to_bars(i,how_many_bars(i))
            end
            grid_pat[i]:start()
            grid_pat[i].loop = 1
          elseif grid_pat[i].count == 0 then
            grid_pat[i]:rec_start()
          elseif grid_pat[i].play == 1 then
            grid_pat[i]:stop()
          else
            grid_pat[i]:start()
          end
        else
          if grid.alt == 1 then
            grid_pat[i]:rec_stop()
            grid_pat[i]:stop()
            grid_pat[i].tightened_start = 0
            grid_pat[i]:clear()
            pattern_saver[i].load_slot = 0
          else
            --table.insert(grid_pat_quantize_events[i],i)
            better_grid_pat_q_clock(i)
          end
        end
        if menu == 8 then
          help_menu = "grid patterns"
          which_bank = i
        end
      end
    end
  end
end


function ga.action4(x,y,z)
  for i = 1,3 do
    if x == (3)+(5*(i-1)) and y == 4 and z == 1 then
      which_bank = i
      local which_pad = nil
      if bank[i].focus_hold == false then
        which_pad = bank[i].id
      else
        which_pad = bank[i].focus_pad
      end
      if bank[i][which_pad].loop == true then
        if grid.alt == 0 then
          bank[i][which_pad].loop = false
        else
          for j = 1,16 do
            bank[i][j].loop = false
          end
        end
        if bank[i].focus_hold == false then
          softcut.loop(i+1,0)
        end
      else
        if grid.alt == 0 then
          bank[i][which_pad].loop = true
        else
          for j = 1,16 do
            bank[i][j].loop = true
          end
        end
        if bank[i].focus_hold == false then
          softcut.loop(i+1,1)
        end
      end
      if menu == 8 then
        help_menu = "loop"
      end
    end
    redraw()
  end
end

function ga.action6(x,y,z)
  if y == 4 or y == 3 or y == 2 then
    if x == 1 or x == 6 or x == 11 then
      local which_pad = nil
      local current = math.sqrt(math.abs(x-2))
      if grid.alt == 0 then
        if bank[current].focus_hold == false then
          clip_jump(current, bank[current].id, y, z)
        else
          clip_jump(current, bank[current].focus_pad, y, z)
        end
      else
        for j = 1,16 do
          clip_jump(current, j, y, z)
        end
      end
      if z == 0 then
        redraw()
        if bank[current].focus_hold == false then
          cheat(current,bank[current].id)
        end
      end
    end
  end
end

function ga.action7(x,y,z)
  for i = 4,3,-1 do
    for j = 2,12,5 do
      if x == j and y == i and z == 1 then
        local which_pad = nil
        if grid.alt == 0 then
          local current = math.sqrt(math.abs(x-3))
          if bank[current].focus_hold == false then
            bank[current][bank[current].id].mode = math.abs(i-5)
          else
            bank[current][bank[current].focus_pad].mode = math.abs(i-5)
          end
        else
          for k = 1,16 do
            local current = math.sqrt(math.abs(x-3))
            bank[current][k].mode = math.abs(i-5)
          end
        end
        local current = math.sqrt(math.abs(x-3))
        if bank[current].focus_hold == false then
          which_pad = bank[current].id
        else
          which_pad = bank[current].focus_pad
        end
        if bank[current][which_pad].mode == 1 then
          bank[current][which_pad].sample_end = 8
        else
          bank[current][which_pad].sample_end = clip[bank[current][which_pad].clip].sample_length
        end
        if bank[current].focus_hold == false then
          local current = math.sqrt(math.abs(x-3))
          cheat(current,bank[current].id)
        end
        if menu == 8 then
          which_bank = current
          help_menu = "mode"
        end
      end
    end
  end
end

function ga.action9(x,y,z)
  for i = 8,6,-1 do
      if x == 5 or x == 10 or x == 15 then
        if y == i then
          if z == 1 then
            arc_switcher[x/5] = arc_switcher[x/5] + 1
            if grid.alt == 0 and arc_switcher[x/5] == 1 then
              arc_param[x/5] = 9-y
              if menu == 8 then
                which_bank = x/5
                help_menu = "arc params"
              end
              redraw()
            elseif grid.alt == 0 and arc_switcher[x/5] == 3 then
               arc_param[x/5] = 4
            end
          elseif z == 0 then
            arc_switcher[x/5] = arc_switcher[x/5] - 1
          end
        end
      end
  end
end

function ga.crow_pad_execute(x,y,z)
  if y == 5 and z == 1 then
    for i = 1,3 do
      if bank[i].focus_hold == true then
        if x == i*5 then
          bank[i][bank[i].focus_pad].crow_pad_execute = (bank[i][bank[i].focus_pad].crow_pad_execute + 1)%2
          if grid.alt == 1 then
            for j = 1,16 do
              bank[i][j].crow_pad_execute = bank[i][bank[i].focus_pad].crow_pad_execute
            end
          end
        end
      end
    end
  end
end

function ga.action11(x,y,z)
  --- new page focus
  for k = 4,1,-1 do
    for i = 1,3 do
      if z == 1 and x == k+(5*(i-1)) and y == k then
        if grid.alt == 0 then
          menu = 6-y
          if key1_hold == true then key1_hold = false end
          if menu == 2 then
            page.loops_sel = math.floor((x/4)-1)
          elseif menu == 5 then
            page.filtering_sel = math.floor((x/4))
          end
          redraw()
        else
          if y == 2 then
            random_grid_pat(math.ceil(x/4),3)
          end
          if y == 4 then
            local current = math.floor(x/5)+1
            bank[current][bank[current].id].rate = 1
            softcut.rate(current+1,1*bank[current][bank[current].id].offset)
            if bank[current][bank[current].id].fifth == true then
              bank[current][bank[current].id].fifth = false
            end
          end
        end
      end
    end
  end
end

function ga.modaction1(x,y,z)
      for i = 1,11,5 do
        for j = 1,8 do
          if x == i and y == j then
            local current = math.floor(x/5)+1
            if z == 1 then
              saved_already = pattern_saver[current].saved[9-y]
              if step_seq[current].held == 0 then
                pattern_saver[current].source = math.floor(x/5)+1
                pattern_saver[current].save_slot = 9-y
                pattern_saver[current]:start()
              else
                --if there's a pattern saved there...
                if pattern_saver[current].saved[9-y] == 1 then
                  if grid.alt_pp == 0 then
                    step_seq[current][step_seq[current].held].assigned_to = 9-y
                  end
                end
              end
            elseif z == 0 then
              if step_seq[current].held == 0 then
                pattern_saver[math.floor(x/5)+1]:stop()
                if grid.alt_pp == 0 and saved_already == 1 then
                  if pattern_saver[current].saved[9-y] == 1 then
                    pattern_saver[current].load_slot = 9-y
                    test_load((9-y)+(8*(current-1)),current)
                  end
                end
              end
            end
          end
        end
      end
 
end


function ga.modaction2(x,y,z)
     
      for i = 2,12,5 do
        for j = 1,8 do
          if z == 1 and x == i and y == j then
            local current = math.floor(x/5)+1
            step_seq[current].meta_duration = 9-y
          end
        end
      end
 
end

function ga.modaction3(x,y,z)
      
      for i = 3,13,5 do
        for j = 1,8 do
          if z == 1 and x == i and y == j then
            local current = math.floor(x/5)+1
            step_seq[current].held = 9-y
            if grid.alt_pp == 1 then
              step_seq[current][step_seq[current].held].assigned_to = 0
            end
          elseif z == 0 and x == i and y == j then
            local current = math.floor(x/5)+1
            step_seq[current].held = 0
          elseif z == 1 and x == i+1 and y == j then
            local current = math.floor(x/5)+1
            step_seq[current].held = (9-y)+8
            if grid.alt_pp == 1 then
              step_seq[current][step_seq[current].held].assigned_to = 0
            end
          elseif z == 0 and x == i+1 and y == j then
            local current = math.floor(x/5)+1
            step_seq[current].held = 0
          end
        end
      end
 
end


function ga.modaction4(x,y,z)
     
      for i = 5,15,5 do
        for j = 1,8 do
          if z == 1 and x == i and y == j then
            local current = x/5
            if step_seq[current].held == 0 then
              step_seq[current][step_seq[current].current_step].meta_meta_duration = 9-y
            else
              step_seq[current][step_seq[current].held].meta_meta_duration = 9-y
            end
            if grid.alt_pp == 1 then
              for k = 1,16 do
                step_seq[current][k].meta_meta_duration = 9-y
              end
            end
          end
        end
      end
 
end

function ga.modaction5(x,y,z)
     
      for i = 7,5,-1 do
        if x == 16 and y == i and z == 1 then
          if step_seq[8-i].held == 0 then
            if grid.alt_pp == 1 then
              step_seq[8-i].current_step = step_seq[8-i].start_point
              step_seq[8-i].meta_step = 1
              step_seq[8-i].meta_meta_step = 1
              if step_seq[8-i].active == 1 and step_seq[8-i][step_seq[8-i].current_step].assigned_to ~= 0 then
                test_load(step_seq[8-i][step_seq[8-i].current_step].assigned_to+(((8-i)-1)*8),8-i)
              end
            else
              step_seq[8-i].active = (step_seq[8-i].active + 1)%2
            end
          else
            step_seq[8-i][step_seq[8-i].held].loop_pattern = (step_seq[8-i][step_seq[8-i].held].loop_pattern + 1)%2
          end
        end
      end
      
 
end


function ga.modaction6(x,y,z)
     
      if x == 16 and y == 8 then
        grid.alt_pp = z
        redraw()
        grid_redraw()
      end
 
end

function ga.modaction7(x,y,z)
      for i = 3,13,5 do
        if x == i or x == i+1 then
          local current = math.floor(x/5)+1
          if z == 1 then
            step_seq[current].loop_held = step_seq[current].loop_held + 1
            if step_seq[current].loop_held == 1 then
              if x == i then
                step_seq[current].start_point = 9-y
              elseif x == i+1 then
                step_seq[current].start_point = 17-y
              end
              if step_seq[current].start_point > step_seq[current].current_step then
                step_seq[current].current_step = step_seq[current].start_point
              end
            elseif step_seq[current].loop_held == 2 then
              if x == i then
                step_seq[current].end_point = 9-y
              elseif x == i+1 then
                step_seq[current].end_point = 17-y
              end
            end
          elseif z == 0 then
            step_seq[current].loop_held = step_seq[current].loop_held - 1
          end
        end
      end

end

function ga.modaction8(x,y,z)
    
    if x == 16 and y == 2 then
      grid.loop_mod = z
      redraw()
      grid_redraw()
    end
 
end

function ga.help(x,y,z)
  if menu == 8 then
    if x == 1 or x == 6 or x == 11 then
      help_menu = "meta: slots"
    elseif x == 2 or x == 7 or x == 12 then
      help_menu = "meta: clock"
    elseif x == 3 or x == 4 or x == 8 or x == 9 or x == 13 or x == 14 then
      if grid.loop_mod == 0 then
        help_menu = "meta: step"
      end
    elseif x == 5 or x == 10 or x == 15 then
      help_menu = "meta: duration"
    elseif x == 16 then
      if y == 8 then
        if z == 1 then
          help_menu = "meta: alt"
        elseif z == 0 then
          help_menu = "welcome"
        end
      elseif y == 7 or y == 6 or y == 5 then
        help_menu = "meta: toggle"
      elseif y == 2 then
        if z == 1 then
          help_menu = "meta: loop mod"
        elseif z == 0 then
          help_menu = "welcome"
        end
      end
    end
    redraw()
  end
end

return grid_actions
