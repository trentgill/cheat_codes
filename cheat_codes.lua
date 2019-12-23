-- cheat codes
--          a sample playground
--
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
-- need help?
-- please see [?] menu
-- for in-app instruction manual
-- -------------------------------

butts = 0

local pattern_time = require 'pattern_time'
fileselect = require 'fileselect'
help_menus = include 'lib/help_menus'
main_menu = include 'lib/main_menu'
encoder_actions = include 'lib/encoder_actions'
arc_actions = include 'lib/arc_actions'
rightangleslice = include 'lib/zilchmos'
start_up = include 'lib/start_up'
grid_actions = include 'lib/grid_actions'

tau = math.pi * 2
arc_param = {}
for i = 1,3 do
  arc_param[i] = 1
end
arc_control = {}
for i = 1,3 do
  arc_control[i] = i
end

arc_offset = 0 --IMPORTANT TO REVISIT

clip = {}
for i = 1,3 do
  clip[i] = {}
  clip[i].length = 90
  clip[i].sample_length = nil
  clip[i].start_point = nil
  clip[i].end_point = nil
  clip[i].mode = 1
end

help_menu = "welcome"

rec_counter = metro.init(rec_count, 0.01, -1)
rec_time = 0

quantize = 1
quantize_events = {}
for i = 1,3 do
  quantize_events[i] = {}
end
quantizer = {}
for i = 1,3 do
  quantizer[i] = {}
  quantizer[i] = metro.init()
  quantizer[i].time = 0.25
  quantizer[i].count = -1
  quantizer[i].event = function() cheat_q_clock(i) end
  quantizer[i]:start()
end

grid_pat_quantize = 1
grid_pat_quantize_events = {}
for i = 1,3 do
  grid_pat_quantize_events[i] = {}
end
grid_pat_quantizer = {}
for i = 1,3 do
  grid_pat_quantizer[i] = {}
  grid_pat_quantizer[i] = metro.init()
  grid_pat_quantizer[i].time = 0.25
  grid_pat_quantizer[i].count = -1
  grid_pat_quantizer[i].event = function() grid_pat_q_clock(i) end
  grid_pat_quantizer[i]:start()
end

function cheat_q_clock(i)
  if #quantize_events[i] > 0 then
    for k,e in pairs(quantize_events[i]) do
      cheat(i,e)
      grid_p[i] = {}
      grid_p[i].i = i
      grid_p[i].id = selected[i].id
      grid_p[i].x = selected[i].x
      grid_p[i].y = selected[i].y
      grid_pat[i]:watch(grid_p[i])
    end
    quantize_events[i] = {}
  end
end

function grid_pat_q_clock(i)
  if #grid_pat_quantize_events[i] > 0 then
    for k,e in pairs(grid_pat_quantize_events[i]) do
      if grid.alt == 1 then
        grid_pat[i]:rec_stop()
        grid_pat[i]:stop()
        grid_pat[i]:clear()
      elseif grid_pat[i].rec == 1 then
        grid_pat[i]:rec_stop()
        grid_pat[i]:start()
      elseif grid_pat[i].count == 0 then
        grid_pat[i]:rec_start()
      elseif grid_pat[i].play == 1 then
        grid_pat[i]:stop()
      else
        grid_pat[i]:start()
      end
    end
    grid_pat_quantize_events[i] = {}
  end
end

key1_hold = false

clipboard = {}

local beatclock = include "lib/beatclock-crow"
clk = beatclock.new()
clk_midi = midi.connect()
clk_midi.event = function(data) clk:process_midi(data) end

-- DO I NEED THESE?
--t = 0
--dt = 1
grid.alt = 0

local function crow_init()
  for i = 1,4 do
    crow.output[i].action = "{to(5,0),to(0,0.25)}"
    print("output["..i.."] initialized")
  end
end

local lit = {}

function init()
  
  grid_p = {}
  arc_p = {}
  
  rec = {}
  rec.state = 1
  rec.clip = 1
  
  params:add_number("collection", "collection", 1,100,1)
  params:set_action("collection", function (x) selected_coll = x end)
  params:add{type = "trigger", id = "load", name = "load", action = loadstate}
  params:add{type = "trigger", id = "save", name = "save", action = savestate}
  
  params:add_separator()
  
  params:add{type = "trigger", id = "init_crow", name = "initialize crow", action = crow_init}
  
  screen_focus = 1
  
  menu = 1
  
  crow.output[1].action = "{to(5,0),to(0,0.25)}"
  crow.output[2].action = "{to(5,0),to(0,0.25)}"
  crow.output[3].action = "{to(5,0),to(0,0.25)}"
  crow.output[4].action = "{to(5,0),to(0,0.25)}"

  screen.line_width(1)

  clk.on_step = function() update_tempo() end
  clk.on_select_internal = function()
    clk:start()
    crow.input[2].mode("none")
    for i = 1,3 do
      quantizer[i]:start()
      grid_pat_quantizer[i]:start()
    end
  end
  clk.on_select_external = function()
    crow.input[2].mode("none")
    for i = 1,3 do
      quantizer[i]:stop()
      grid_pat_quantizer[i]:stop()
    end
  end
  clk.on_select_crow = function()
    for i = 1,3 do
      quantizer[i]:stop()
      grid_pat_quantizer[i]:stop()
    end
    crow.input[2].mode("change",2,0.1,"rising")
    crow.input[2].change = change
  end
  clk:add_clock_params()
  params:add{type = "number", id = "midi_device", name = "midi device", min = 1, max = 4, default = 1, action = function(value)
    clk_midi.event = nil
    clk_midi = midi.connect(value)
    clk_midi.event = function(data) clk:process_midi(data) end
  end}
  
  --params:set_action("bpm", function() update_tempo() end)
  params:add_option("quantize_pads", "quantize 4x4 pads?", { "no", "yes" })
  params:set_action("quantize_pads", function(x) quantize = x-1 end)
  params:add_option("quantize_pats", "quantize pattern button?", { "no", "yes" })
  params:set_action("quantize_pats", function(x) grid_pat_quantize = x-1 end)
  params:add_number("quant_div", "quantization division", 1, 32, 4)
  params:set_action("quant_div",function() update_tempo() end)

  params:default()

  clk:start()
  
  page = {}
  page.main_sel = 1
  page.loops_sel = 0
  page.levels_sel = 0
  page.panning_sel = 1
  page.filtering_sel = 0
  page.arc_sel = 0
  page.delay_sel = 0
  
  delay_rates = {2,(7/4),(5/3),(3/2),(4/3),(5/4),(1),(4/5),(3/4),(2/3),(3/5),(4/7),(1/2)}
  delay = {}
  for i = 1,2 do
    delay[i] = {}
    delay[i].id = 7
    delay[i].arc_rate_tracker = 7
    delay[i].arc_rate = 7
    delay[i].rate = delay_rates[7]
    delay[i].start_point = 41 + (30*(i-1))
    delay[i].end_point = delay[i].start_point + 0.5
    delay[i].divisor = 1
  end
  
  index = 0
  
  edit = "all"
  
  start_up.init()

  bank = {}
  reset_all_banks()
  
  params:bang()
  
  --GRID
  selected = {}
  fingers = {}
  counter_four = {}
  counter_three = {}
  counter_two = {}
  for i = 1,3 do
    selected[i] = {}
    selected[i].x = 1 + (5*(i-1))
    selected[i].y = 8
    selected[i].id = 1
    for k = 1,4 do
      fingers[k] = {}
      fingers[k].dt = 1
      fingers[k].t1 = 0
      fingers[k].t = 0
      fingers[k][i] = {}
      fingers[k][i].con = {}
    end
    counter_four[i] = {}
    counter_four[i].key_up = metro.init()
    counter_four[i].key_up.time = 0.05
    counter_four[i].key_up.count = 1
    counter_four[i].key_up.event = function()
      zilchmo(4,i)
      zilchmo_p1 = {}
      zilchmo_p1.con = fingers[4][i].con
      zilchmo_p1.row = 4
      zilchmo_p1.bank = i
    end
    counter_four[i].key_up:stop()
    counter_three[i] = {}
    counter_three[i].key_up = metro.init()
    counter_three[i].key_up.time = 0.05
    counter_three[i].key_up.count = 1
    counter_three[i].key_up.event = function()
      zilchmo(3,i)
    end
    counter_three[i].key_up:stop()
    counter_two[i] = {}
    counter_two[i].key_up = metro.init()
    counter_two[i].key_up.time = 0.05
    counter_two[i].key_up.count = 1
    counter_two[i].key_up.event = function()
      zilchmo(2,i)
    end
    counter_two[i].key_up:stop()
  end
  
  grid_pat = {}
  for i = 1,3 do
    grid_pat[i] = pattern_time.new()
    grid_pat[i].process = grid_pattern_execute
  end
  
  arc_pat = {}
  for i = 1,4 do
    arc_pat[i] = pattern_time.new()
    if i ~=4 then
      arc_pat[i].process = arc_pattern_execute
    else
      arc_pat[i].process = arc_delay_pattern_execute
    end
  end
  
  if g then grid_redraw() end
  --/GRID
  for i=1,3 do
    cheat(i,bank[i].id)
  end
  
  gridredrawtimer = metro.init(function() grid_redraw() end, 0.02, -1)
  gridredrawtimer:start()
  
  softcut.poll_start_phase()
  
  filter_types = {"lp", "hp", "bp"}
end

poll_position_new = {}
for i = 1,3 do
  poll_position_new[i] = {}
end

phase = function(n, x)
  poll_position_new[n] = x
  if menu == 2 then
    redraw()
  end
end

local tap = 0
local deltatap = 1

function change()
  local tap1 = util.time()
  deltatap = tap1 - tap
  tap = tap1
  local tap_tempo = 60/deltatap
  for i = 1,2 do
    local delay_rate_to_time = (tap_tempo) * delay[i].rate
    local delay_time = delay_rate_to_time + (41 + (30*(i-1)))
    delay[i].end_point = delay_time
    softcut.loop_end(i+4,delay[i].end_point)
  end
  for i = 1,3 do
    cheat_q_clock(i)
    grid_pat_q_clock(i)
  end
end

function update_tempo()
  if params:get("clock") == 1 then
    --INTERNAL
    bpm = params:get("bpm")
    local t = params:get("bpm")
    local d = params:get("quant_div")
    local interval = (60/t) / d
    for i = 1,3 do
      quantizer[i].time = interval
      grid_pat_quantizer[i].time = interval
    end
  end
end

--[[function update_tempo()
  if params:get("clock") == 1 then
    --INTERNAL
    bpm = params:get("bpm")
    local t = params:get("bpm")
    local d = params:get("quant_div")
    local interval = (60/t) / d
    for i = 1,3 do
      quantizer[i].time = interval
      grid_pat_quantizer[i].time = interval
    end
  elseif params:get("clock") == 3 then
    --CROW
    local tap1 = util.time()
    deltatap = tap1 - tap
    tap = tap1
    bpm = 60/deltatap
    print(bpm.." / "..deltatap)
    for i = 1,3 do
      quantizer[i].time = deltatap
      grid_pat_quantizer[i].time = deltatap
    end
  end
end]]--

function slice()
  --local t = params:get("bpm")
  --local d = params:get("quant_div")
  --local interval = (60/t) / d
  for i = 1,3 do
    for j = 1,16 do
      bank[i][j].start_point = 1+((8/16)*(j-1))
      bank[i][j].end_point = 1+((8/16)*j)
    end
  end
end

function rec_count()
  rec_time = rec_time + 0.01
end

function reset_all_banks()
  for i = 1,3 do
    bank[i] = {}
    bank[i].id = 1
    for k = 1,16 do
      bank[i][k] = {}
      bank[i][k].clip = 1
      bank[i][k].mode = 1
      bank[i][k].start_point = 1+((8/16)*(k-1))
      bank[i][k].end_point = 1+((8/16)*k)
      bank[i][k].sample_end = 8
      bank[i][k].rate = 1.0
      bank[i][k].left_delay_time = 0.5
      bank[i][k].right_delay_time = 0.5
      bank[i][k].pause = false
      bank[i][k].play_mode = "latch"
      bank[i][k].level = 1.0
      bank[i][k].left_delay_level = 1
      bank[i][k].right_delay_level = 1
      bank[i][k].loop = true
      bank[i][k].fifth = false
      bank[i][k].pan = 0.0
      bank[i][k].left_delay_pan = util.linlin(-1,1,0,1,bank[i][k].pan)*bank[i][k].left_delay_level
      bank[i][k].right_delay_pan = util.linlin(-1,1,1,0,bank[i][k].pan)*bank[i][k].left_delay_level
      bank[i][k].fc = 12000
      bank[i][k].q = 2.0
      bank[i][k].lp = 1.0
      bank[i][k].hp = 0.0
      bank[i][k].bp = 0.0
      bank[i][k].fd = 0.0
      bank[i][k].br = 0.0
      bank[i][k].filter_type = 1
    end
    cheat(i,bank[i].id)
  end
end

function cheat(b,i)
  softcut.level_slew_time(b+1,0.0)
  softcut.level(b+1,bank[b][i].level)
  softcut.loop_start(b+1,bank[b][i].start_point)
  softcut.loop_end(b+1,bank[b][i].end_point)
  softcut.buffer(b+1,bank[b][i].mode)
  if bank[b][i].pause == false then
    softcut.rate(b+1,bank[b][i].rate*offset)
  else
    softcut.rate(b+1,0)
  end
  if bank[b][i].loop == false then
    softcut.loop(b+1,0)
  else
    softcut.loop(b+1,1)
  end
  --softcut.fade_time(b+1,0.1)
  softcut.fade_time(b+1,0.01)
  if bank[b][i].rate > 0 then
      softcut.position(b+1,bank[b][i].start_point+0.05)
  elseif bank[b][i].rate < 0 then
      softcut.position(b+1,bank[b][i].end_point-0.05)
  end
  --
  softcut.post_filter_fc(b+1,bank[b][i].fc)
  softcut.post_filter_rq(b+1,bank[b][i].q)
  local filter_type = bank[b][i].filter_type
  if bank[b][i].filter_type == 1 then
    params:set("filter "..math.floor(tonumber(b)).." lp",1)
    params:set("filter "..math.floor(tonumber(b)).." hp",0)
    params:set("filter "..math.floor(tonumber(b)).." bp",0)
  elseif bank[b][i].filter_type == 2 then
    params:set("filter "..math.floor(tonumber(b)).." lp",0)
    params:set("filter "..math.floor(tonumber(b)).." hp",1)
    params:set("filter "..math.floor(tonumber(b)).." bp",0)
  elseif bank[b][i].filter_type == 3 then
    params:set("filter "..math.floor(tonumber(b)).." lp",0)
    params:set("filter "..math.floor(tonumber(b)).." hp",0)
    params:set("filter "..math.floor(tonumber(b)).." bp",1)
  end
  softcut.post_filter_dry(b+1,bank[b][i].fd)
  softcut.pan(b+1,bank[b][i].pan)
  softcut.level_cut_cut(b+1,5,util.linlin(-1,1,0,1,bank[b][i].pan)*bank[b][i].left_delay_level)
  softcut.level_cut_cut(b+1,6,util.linlin(-1,1,1,0,bank[b][i].pan)*bank[b][i].right_delay_level)
  softcut.level_slew_time(b+1,1.0)
  update_delays()
end

function freeze()
  rec.state = (rec.state + 1)%2
  softcut.rec(1,rec.state)
end

function update_delays()
  for i = 1,2 do
    local delay_rate_to_time = (60/bpm) * delay[i].rate
    local delay_time = delay_rate_to_time + (41 + (30*(i-1)))
    delay[i].end_point = delay_time
    softcut.loop_end(i+4,delay[i].end_point)
  end
end

function load_sample(file,sample)
  if file ~= "-" then
    local ch, len = audio.file_info(file)
    if len/48000 <=90 then
      --clip[sample].sample_length = len/48000
      if len/48000 > 8 then
        clip[sample].sample_length = 8
      else
        clip[sample].sample_length = len/48000
      end
    else
      --clip[sample].sample_length = 90
      clip[sample].sample_length = 8
    end
    print(len/48000)
    softcut.buffer_read_mono(file, 0, 1+(8 * (sample-1)), (9+(8 * (sample-1)))-0.1, 1, 2)
  end
end

function save_sample(i)
  local name = "cc_"..os.date("%y%m%d_%X-buff")..i..".wav"
  local save_pos = i - 1
  softcut.buffer_write_mono(_path.dust.."/audio/"..name,1+(8*save_pos),8,1)
end

function key(n,z)
if screen_focus == 1 then
  if n == 3 and z == 1 then
    if menu == 1 then
      for i = 1,6 do
        if page.main_sel == i then
          menu = i+1
        end
      end
    elseif menu == 2 then
      local loop_nav = (page.loops_sel + 1)%3
      page.loops_sel = loop_nav
    elseif menu == 3 then
      local level_nav = (page.levels_sel + 1)%3
      page.levels_sel = level_nav
    elseif menu == 5 then
      local filter_nav = (page.filtering_sel + 1)%3
      page.filtering_sel = filter_nav
    elseif menu == 6 then
      local delay_nav = (page.delay_sel+1)%5
      page.delay_sel = delay_nav
    end
  elseif n == 2 and z == 1 then
    if menu == 7 then
      help_menu = "welcome"
    end
    menu = 1
  end
  if n == 1 and z == 1 then
    key1_hold = true
  elseif n == 1 and z == 0 then
    key1_hold = false
  end
  redraw()
end
end

function enc(n,d)
  encoder_actions.init(n,d)
end

function redraw()
if screen_focus == 1 then
	screen.clear()
	screen.level(15)
	screen.font_size(8)
	main_menu.init()
  screen.update()
end
end

--GRID
g = grid.connect()

g.key = function(x,y,z)
  grid_actions.init(x,y,z)
end

function clip_jump(i,s,y,z)
  for go = 1,2 do
    local old_min = (1+(8*(bank[i][s].clip-1)))
    local old_max = (9+(8*(bank[i][s].clip-1)))
    local old_range = old_min - old_max
    bank[i][s].clip = math.abs(y-5)
    local new_min = (1+(8*(bank[i][s].clip-1)))
    local new_max = (9+(8*(bank[i][s].clip-1)))
    local new_range = new_max - new_min
    local current_difference = (bank[i][s].end_point - bank[i][s].start_point)
    bank[i][s].start_point = (((bank[i][s].start_point - old_min) * new_range) / old_range) + new_min
    bank[i][s].end_point = bank[i][s].start_point + current_difference
    if menu == 7 then
      which_bank = i
      help_menu = "buffer jump"
    end
  end
end

function grid_entry(e)
  if e.state > 0 then
    lit[e.id] = {}
    lit[e.id].x = e.x
    lit[e.id].y = e.y
  else
    if lit[e.id] ~= nil then
      lit[e.id] = nil
    end
  end
  grid_redraw()
end

function grid_redraw()
  g:all(0)
  
  for j = 0,2 do
    for k = 1,4 do
      k = k+(5*j)
      for i = 8,5,-1 do
        g:led(k,i,3)
      end
    end
  end
  
  for j = 0,2 do
    for k = (5-j),(15-j),5 do
      for i = (4-j),1,-1 do
        g:led(k,i,3)
      end
    end
  end
  
  for i = 1,3 do
    if grid_pat[i].rec == 1 then
      g:led(2+(5*(i-1)),1,(15*1))
    elseif grid_pat[i].play == 1 then
      g:led(2+(5*(i-1)),1,9)
    elseif grid_pat[i].count > 0 then
      g:led(2+(5*(i-1)),1,5)
    else
      g:led(2+(5*(i-1)),1,3)
    end
  end
  
  for i = 1,4 do
    if arc_pat[i].rec == 1 then
      g:led(16,5-i,15)
    elseif arc_pat[i].play == 1 then
      g:led(16,5-i,9)
    elseif arc_pat[i].count > 0 then
      g:led(16,5-i,5)
    else
      g:led(16,5-i,0)
    end
  end
  
  for i = 1,3 do
    g:led(selected[i].x, selected[i].y, 15)
    if bank[i][bank[i].id].pause == true then
     g:led(3+(5*(i-1)),1,15)
     g:led(3+(5*(i-1)),2,15)
    else
      g:led(3+(5*(i-1)),1,3)
      g:led(3+(5*(i-1)),2,3)
    end
  end
  
  for i,e in pairs(lit) do
    g:led(e.x, e.y,15)
  end
  
  g:led(16,8,(grid.alt*12)+3)
  
  g:led(1,math.abs(bank[1][bank[1].id].clip-5),8)
  g:led(6,math.abs(bank[2][bank[2].id].clip-5),8)
  g:led(11,math.abs(bank[3][bank[3].id].clip-5),8)
  
  g:led(2,math.abs(bank[1][bank[1].id].mode-5),6)
  g:led(7,math.abs(bank[2][bank[2].id].mode-5),6)
  g:led(12,math.abs(bank[3][bank[3].id].mode-5),6)
  
  for i = 1,3 do
    if bank[i][bank[i].id].loop == false then
      g:led(3+(5*(i-1)),4,2)
    elseif bank[i][bank[i].id].loop == true then
      g:led(3+(5*(i-1)),4,4)
    end
  end
  
  g:led(16,8-rec.clip,(5*rec.state)+5)
  
  g:refresh()
end
--/GRID

function grid_pattern_execute(entry)
  local i = entry.i
  selected[i].id = entry.id
  selected[i].x = entry.x
  selected[i].y = entry.y
  bank[i].id = selected[i].id
  cheat(i,bank[i].id)
  grid_redraw()
  redraw()
end

function arc_pattern_execute(entry)
  local i = entry.i
  local id = arc_control[i]
  local param = entry.param
  arc_param[i] = param
  bank[id][bank[id].id].start_point = (entry.start_point + (8*(bank[id][bank[id].id].clip-1)) + arc_offset)
  bank[id][bank[id].id].end_point = (entry.end_point + (8*(bank[id][bank[id].id].clip-1)) + arc_offset)
  softcut.loop_start(id+1, (entry.start_point + (8*(bank[id][bank[id].id].clip-1))) + arc_offset)
  softcut.loop_end(id+1, (entry.end_point + (8*(bank[id][bank[id].id].clip-1))) + arc_offset)
  bank[id][bank[id].id].fc = entry.fc
  softcut.post_filter_fc(id+1,entry.fc)
  redraw()
end

function arc_delay_pattern_execute(entry)
  local i = entry.i
  local side = entry.delay_focus
  arc_p[4].delay_focus = side
  if side == "L" then
    arc_p[4].left_delay_value = entry.left_delay_value
    params:set("delay L: rate",entry.left_delay_value)
  else
    arc_p[4].right_delay_value = entry.right_delay_value
    params:set("delay R: rate",entry.right_delay_value)
  end
  redraw()
end

function zilchmo(k,i)
  rightangleslice.init(k,i)
  lit = {}
  grid_redraw()
  redraw()
end

function clipboard_copy(a,b,c,d,e,f,g,h,i,j,k,l)
  for k,v in pairs({a,b,c,d,e,f,g,h,i,j,k,l}) do
    clipboard[k] = v
  end
end

function clipboard_paste(i)
  local d = bank[i].id
  bank[i][d].start_point = clipboard[1]
  bank[i][d].end_point = clipboard[2]
  bank[i][d].rate = clipboard[3]
  bank[i][d].level = clipboard[4]
  bank[i][d].pan = clipboard[5]
  bank[i][d].clip = clipboard[6]
  bank[i][d].mode = clipboard[7]
  bank[i][d].loop = clipboard[8]
  bank[i][d].filter_type = clipboard[9]
  bank[i][d].fc = clipboard[10]
  bank[i][d].q = clipboard[11]
  bank[i][d].fifth = clipboard[12]
  redraw()
  if bank[i][d].loop == true then
    cheat(i,d)
  end
end

re = metro.init()
re.time = 0.03
re.event = function()
  arc_redraw()
end
re:start()

a = arc.connect()
arc_d = {}
for i = 1,3 do
  arc_d[i] = {}
end

a.delta = function(n,d)
  arc_d[n] = d
  arc_actions.init(n,arc_d[n])
end

arc_redraw = function()
  a:all(0)
  for i = 1,3 do
    if arc_param[i] == 1 then
      local start_to_led = (bank[arc_control[i]][bank[arc_control[i]].id].start_point-1)-(8*(bank[arc_control[i]][bank[arc_control[i]].id].clip-1))
      local end_to_led = (bank[arc_control[i]][bank[arc_control[i]].id].end_point-1)-(8*(bank[arc_control[i]][bank[arc_control[i]].id].clip-1))
      if start_to_led <= end_to_led then
        a:segment(i, util.linlin(0, 8, tau*(1/4), tau*1.23, start_to_led), util.linlin(0, 8, (tau*(1/4))+0.1, tau*1.249999, end_to_led), 15)
      else
        a:segment(i, util.linlin(0, 8, (tau*(1/4))+0.1, tau*1.23, end_to_led), util.linlin(0, 8, tau*(1/4), tau*1.249999, start_to_led), 15)
      end
    end
    if arc_param[i] == 2 then
      local start_to_led = (bank[arc_control[i]][bank[arc_control[i]].id].start_point-1)-(8*(bank[arc_control[i]][bank[arc_control[i]].id].clip-1))
      local end_to_led = (bank[arc_control[i]][bank[arc_control[i]].id].end_point-1)-(8*(bank[arc_control[i]][bank[arc_control[i]].id].clip-1))
      local playhead_to_led = util.linlin(1,9,1,64,(poll_position_new[i+1] - (8*(bank[i][bank[i].id].clip-1))))
      a:led(i,(math.floor(playhead_to_led))+16,5)
      a:led(i,(math.floor(util.linlin(0,8,1,64,start_to_led)))+16,15)
      a:led(i,(math.floor(util.linlin(0,8,1,64,end_to_led)))+17,8)
    end
    if arc_param[i] == 3 then
      local start_to_led = (bank[arc_control[i]][bank[arc_control[i]].id].start_point-1)-(8*(bank[arc_control[i]][bank[arc_control[i]].id].clip-1))
      local end_to_led = (bank[arc_control[i]][bank[arc_control[i]].id].end_point-1)-(8*(bank[arc_control[i]][bank[arc_control[i]].id].clip-1))
      local playhead_to_led = util.linlin(1,9,1,64,(poll_position_new[i+1] - (8*(bank[i][bank[i].id].clip-1))))
      a:led(i,(math.floor(playhead_to_led))+16,5)
      a:led(i,(math.floor(util.linlin(0,8,1,64,end_to_led)))+17,15)
      a:led(i,(math.floor(util.linlin(0,8,1,64,start_to_led)))+16,8)
    end
    if arc_param[i] == 4 then
      local fc_to_led = bank[arc_control[i]][bank[arc_control[i]].id].fc
      if bank[arc_control[i]][bank[arc_control[i]].id].filter_type == 1 then
        a:segment(i, tau*(1/4), util.linlin(1, 12000, (tau*(1/4))+0.1, tau*1.249999, fc_to_led), 15)
      elseif bank[arc_control[i]][bank[arc_control[i]].id].filter_type == 2 then
        a:segment(i, util.linlin(1, 12000, (tau*(1/4)), tau*1.24, fc_to_led), tau*(1/4), 15)
      elseif bank[arc_control[i]][bank[arc_control[i]].id].filter_type == 3 then
        a:segment(i, util.linlin(10, 12000, (tau*(1/4)), tau*1.20, fc_to_led), util.linlin(10, 12000, (tau*(1/4))+0.3, tau*1.249999, fc_to_led), 15)
      end
    end
  end
  
  for i = 1,13 do
    local arc_left_delay_level = (params:get("delay L: rate") == i and 15 or 5)
    local arc_right_delay_level = (params:get("delay R: rate") == i and 15 or 5)
    if grid.alt == 0 then
      a:led(4,(41+((i-1)*4)-16),arc_left_delay_level)
    else
      a:led(4,(41+((i-1)*4)-16),arc_right_delay_level)
    end
  end
  a:refresh()
end

--file loading

function savestate()
  local file = io.open(_path.data .. "cheat_codes/collections"..selected_coll..".data", "w+")
  io.output(file)
  io.write("PERMANENCE".."\n")
  for i = 1,3 do
    for k = 1,16 do 
      io.write(bank[i].id .. "\n")
      io.write(selected[i].x .. "\n")
      io.write(selected[i].y .. "\n")
      io.write(bank[i][k].clip .. "\n")
      io.write(bank[i][k].mode .. "\n")
      io.write(bank[i][k].start_point .. "\n")
      io.write(bank[i][k].end_point .. "\n")
      io.write(bank[i][k].rate .. "\n")
      io.write(tostring(bank[i][k].pause) .. "\n")
      io.write(tostring(bank[i][k].play_mode) .. "\n")
      io.write(bank[i][k].level .. "\n")
      io.write(tostring(bank[i][k].loop) .. "\n")
      io.write(tostring(bank[i][k].fifth) .. "\n")
      io.write(bank[i][k].pan .. "\n")
      io.write(bank[i][k].fc .. "\n")
      io.write(bank[i][k].q .. "\n")
      io.write(bank[i][k].lp .. "\n")
      io.write(bank[i][k].hp .. "\n")
      io.write(bank[i][k].bp .. "\n")
      io.write(bank[i][k].fd .. "\n")
      io.write(bank[i][k].br .. "\n")
      io.write(bank[i][k].filter_type .. "\n")
      io.write(arc_control[i] .. "\n")
      io.write(arc_param[i] .. "\n")
    end
    io.write(params:get("rate slew time ".. i) .. "\n")
    io.write(tostring(params:get("clip "..i.." sample") .. "\n"))
    local sides = {"delay L: ", "delay R: "}
    for k = 1,2 do
      io.write(params:get(sides[k].."rate") .. "\n")
      io.write(params:get(sides[k].."global level") .. "\n")
      io.write(params:get(sides[k].."feedback") .. "\n")
      io.write(params:get(sides[k].."(a) send") .. "\n")
      io.write(params:get(sides[k].."(b) send") .. "\n")
      io.write(params:get(sides[k].."(c) send") .. "\n")
      io.write(params:get(sides[k].."filter cut") .. "\n")
      io.write(params:get(sides[k].."filter q") .. "\n")
      io.write(params:get(sides[k].."filter lp") .. "\n")
      io.write(params:get(sides[k].."filter hp") .. "\n")
      io.write(params:get(sides[k].."filter bp") .. "\n")
      io.write(params:get(sides[k].."filter dry") .. "\n")
    end
  end
  io.write(params:get("offset").."\n")
  io.close(file)
end

function loadstate()
  local file = io.open(_path.data .. "cheat_codes/collections"..selected_coll..".data", "r")
  if file then
    io.input(file)
    if io.read() == "PERMANENCE" then
      for i = 1,3 do
        for k = 1,16 do
          bank[i].id = tonumber(io.read())
          selected[i].x = tonumber(io.read())
          selected[i].y = tonumber(io.read())
          bank[i][k].clip = tonumber(io.read())
          bank[i][k].mode = tonumber(io.read())
          bank[i][k].start_point = tonumber(io.read())
          bank[i][k].end_point = tonumber(io.read())
          bank[i][k].rate = tonumber(io.read())
          local pause_to_boolean = io.read()
          if pause_to_boolean == "true" then
            bank[i][k].pause = true
          else
            bank[i][k].pause = false
          end
          bank[i][k].play_mode = io.read()
          bank[i][k].level = tonumber(io.read())
          local loop_to_boolean = io.read()
          if loop_to_boolean == "true" then
            bank[i][k].loop = true
          else
            bank[i][k].loop = false
          end
          local fifth_to_boolean = io.read()
          if fifth_to_boolean == "true" then
            bank[i][k].fifth = true
          else
            bank[i][k].fifth = false
          end
          bank[i][k].pan = tonumber(io.read())
          bank[i][k].fc = tonumber(io.read())
          bank[i][k].q = tonumber(io.read())
          bank[i][k].lp = tonumber(io.read())
          bank[i][k].hp = tonumber(io.read())
          bank[i][k].bp = tonumber(io.read())
          bank[i][k].fd = tonumber(io.read())
          bank[i][k].br = tonumber(io.read())
          bank[i][k].filter_type = tonumber(io.read())
          arc_control[i] = tonumber(io.read())
          arc_param[i] = tonumber(io.read())
        end
      params:set("rate slew time ".. i,tonumber(io.read()))
      local string_to_sample = io.read()
      params:set("clip "..i.." sample", string_to_sample)
      local sides = {"delay L: ", "delay R: "}
      for k = 1,2 do
        params:set(sides[k].."rate",tonumber(io.read()))
        params:set(sides[k].."global level",tonumber(io.read()))
        params:set(sides[k].."feedback",tonumber(io.read()))
        params:set(sides[k].."(a) send",tonumber(io.read()))
        params:set(sides[k].."(b) send",tonumber(io.read()))
        params:set(sides[k].."(c) send",tonumber(io.read()))
        params:set(sides[k].."filter cut",tonumber(io.read()))
        params:set(sides[k].."filter q",tonumber(io.read()))
        params:set(sides[k].."filter lp",tonumber(io.read()))
        params:set(sides[k].."filter hp",tonumber(io.read()))
        params:set(sides[k].."filter bp",tonumber(io.read()))
        params:set(sides[k].."filter dry",tonumber(io.read()))
      end
    end
    params:set("offset",tonumber(io.read()))
    else
      print("invalid data file")
    end
    io.close(file)
    for i = 1,3 do
      if bank[i][bank[i].id].loop == true then
        cheat(i,bank[i].id)
      else
        softcut.loop(i+1, 0)
        softcut.position(i+1,bank[i][bank[i].id].start_point+(8*(bank[i][bank[i].id].clip-1)))
      end
    end
  end
end