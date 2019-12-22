local help_menus = {}

function help_menus.welcome()
  screen.move(0,30)
  screen.level(15)
  screen.text("this is a dynamic help menu.")
  screen.move(0,45)
  screen.text("press a grid key")
  screen.move(0,55)
  screen.text("to learn more.")
end

function help_menus.banks()
  screen.level(15)
  local i = which_bank
  local id = bank[i].id
  screen.move(0,20)
  screen.text("bank: "..i.." | pad: "..id)
  screen.move(0,30)
  screen.text("pads recall parameters:")
  screen.move(0,40)
  screen.text("- rate: "..string.format("%.2f", bank[i][id].rate))
  screen.move(60,40)
  screen.text("- pan: "..string.format("%.2f", bank[i][id].pan))
  screen.move(0,50)
  screen.text("- start: "..string.format("%.2f", bank[i][id].start_point-1))
  screen.move(60,50)
  screen.text("- end: "..string.format("%.2f", bank[i][id].end_point-1))
  screen.move(0,60)
  screen.text("- loop: "..tostring(bank[i][id].loop))
  screen.move(60,60)
  screen.text("etc.")
end

function help_menus.zilchmo4()
  screen.level(15)
  local i = which_bank
  local action = fingers[4][i].con
  screen.move(0,20)
  screen.text("4th row action: ")
  screen.move(70,20)
  screen.text(action)
  if action == "1" then
    screen.move(0,35)
    screen.text("- set pad's start point to 0")
    screen.move(100,60)
    screen.level(3)
    screen.text("try: 2")
  elseif action == "2" then
    screen.move(0,35)
    screen.text("- jump to start of slice")
    screen.move(0,45)
    screen.text("- slices evenly distributed")
    screen.move(100,60)
    screen.level(3)
    screen.text("try: 3")
  elseif action == "3" then
    screen.move(0,35)
    screen.text("- jump to end of slice")
    screen.move(0,45)
    screen.text("- slices evenly distributed")
    screen.move(100,60)
    screen.level(3)
    screen.text("try: 4")
  elseif action == "4" then
    screen.move(0,35)
    screen.text("- set pad's end point to 8")
    screen.move(100,60)
    screen.level(3)
    screen.text("try: 12")
  elseif action == "12" then
    screen.move(0,35)
    screen.text("- randomize pad's start point")
    screen.move(0,45)
    screen.text("- aware of end point")
    screen.move(0,60)
    screen.level(3)
    screen.text("(s): "..bank[i][bank[i].id].start_point)
    screen.move(100,60)
    screen.text("try: 34")
  elseif action == "34" then
    screen.move(0,35)
    screen.text("- randomize pad's end point")
    screen.move(0,45)
    screen.text("- aware of start point")
    screen.move(0,60)
    screen.level(3)
    screen.text("(e): "..bank[i][bank[i].id].end_point)
    screen.move(100,60)
    screen.text("try: 23")
  elseif action == "23" then
    screen.move(0,35)
    screen.text("- randomize pad's window")
    screen.move(0,45)
    screen.text("- (s) + (e) move together")
    screen.move(0,60)
    screen.level(3)
    screen.text("(s): "..bank[i][bank[i].id].start_point)
    screen.move(40,60)
    screen.text("(e): "..bank[i][bank[i].id].end_point)
    screen.move(95,60)
    screen.text("try: 13")
  elseif action == "13" then
    screen.move(0,35)
    screen.text("- double pad's window")
    screen.move(0,45)
    screen.text("- (s) extends, if it can")
    screen.move(0,60)
    screen.level(3)
    screen.text("(s): "..string.format("%.2f",bank[i][bank[i].id].start_point))
    screen.move(40,60)
    screen.text("(e): "..string.format("%.2f",bank[i][bank[i].id].end_point))
    screen.move(95,60)
    screen.text("try: 24")
  elseif action == "24" then
    screen.move(0,35)
    screen.text("- halve pad's window")
    screen.move(0,45)
    screen.text("- (s) + (e) move inward")
    screen.move(0,60)
    screen.level(3)
    screen.text("(s): "..string.format("%.2f",bank[i][bank[i].id].start_point))
    screen.move(40,60)
    screen.text("(e): "..string.format("%.2f",bank[i][bank[i].id].end_point))
    screen.move(95,60)
    screen.text("try: 123")
  elseif action == "123" then
    screen.move(0,35)
    screen.text("- jump window to opp. bank's")
    screen.move(0,45)
    screen.text("- 1 -> 2, 2 -> 3, 3 -> 1")
    screen.move(0,60)
    screen.level(3)
    screen.text("(s): "..string.format("%.2f",bank[i][bank[i].id].start_point))
    screen.move(40,60)
    screen.text("(e): "..string.format("%.2f",bank[i][bank[i].id].end_point))
    screen.move(95,60)
    screen.text("try: 234")
  elseif action == "234" then
    screen.move(0,35)
    screen.text("- jump window to alt. bank's")
    screen.move(0,45)
    screen.text("- 1 -> 3, 2 -> 1, 3 -> 2")
    screen.move(0,60)
    screen.level(3)
    screen.text("(s): "..string.format("%.2f",bank[i][bank[i].id].start_point))
    screen.move(40,60)
    screen.text("(e): "..string.format("%.2f",bank[i][bank[i].id].end_point))
    screen.move(95,60)
    screen.text("try: 124")
  elseif action == "124" then
    screen.move(0,35)
    screen.text("- 2x pad's current rate")
    screen.move(0,45)
    screen.text("- upper limit: 4x")
    screen.move(0,60)
    screen.level(3)
    screen.text("rate: "..bank[i][bank[i].id].rate.."x")
    screen.move(95,60)
    screen.text("try: 134")
  elseif action == "134" then
    screen.move(0,35)
    screen.text("- 0.5x pad's current rate")
    screen.move(0,45)
    screen.text("- lower limit: 0.125x")
    screen.move(0,60)
    screen.level(3)
    screen.text("rate: "..bank[i][bank[i].id].rate.."x")
    screen.move(95,60)
    screen.text("try: 14")
  elseif action == "14" then
    screen.move(0,35)
    screen.text("- reverse pad's current rate")
    screen.move(0,60)
    screen.level(3)
    screen.text("rate: "..bank[i][bank[i].id].rate.."x")
    screen.move(90,60)
    screen.text("try: 1234")
  elseif action == "1234" then
    screen.move(0,35)
    screen.text("- add 7 semitones")
    screen.move(0,60)
    screen.level(3)
    screen.text("rate: "..bank[i][bank[i].id].rate.."x")
    screen.move(85,60)
    screen.text("try: row 3")
  end
end

function help_menus.zilchmo3()
  screen.level(15)
  local i = which_bank
  local action = fingers[3][i].con
  screen.move(0,20)
  screen.text("3rd row action: ")
  screen.move(70,20)
  screen.text(action)
  if action == "1" then
    screen.move(0,35)
    screen.text("- set pad's panning to L")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(100,60)
    screen.text("try: 2")
  elseif action == "2" then
    screen.move(0,35)
    screen.text("- set pad's panning to C")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(100,60)
    screen.text("try: 3")
  elseif action == "3" then
    screen.move(0,35)
    screen.text("- set pad's panning to R")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(100,60)
    screen.text("try: 12")
  elseif action == "12" then
    screen.move(0,35)
    screen.text("- nudge pad's panning L")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(100,60)
    screen.text("try: 23")
  elseif action == "23" then
    screen.move(0,35)
    screen.text("- nudge pad's panning R")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(100,60)
    screen.text("try: 13")
  elseif action == "13" then
    screen.move(0,35)
    screen.text("- reverse pad's panning")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(95,60)
    screen.text("try: 123")
  elseif action == "123" then
    screen.move(0,35)
    screen.text("- randomize pad's panning")
    screen.level(3)
    screen.move(0,60)
    screen.text("pan: "..bank[i][bank[i].id].pan)
    screen.move(85,60)
    screen.text("try: row 2")
  end
end

function help_menus.zilchmo2()
  screen.level(15)
  local i = which_bank
  local action = fingers[2][i].con
  screen.move(0,20)
  screen.text("2nd row action: ")
  screen.move(70,20)
  screen.text(action)
  if action == "1" then
    screen.move(0,35)
    screen.text("- reduce pad's level")
    screen.level(3)
    screen.move(0,60)
    screen.text("level: "..bank[i][bank[i].id].level)
    screen.move(100,60)
    screen.text("try: 2")
  elseif action == "2" then
    screen.move(0,35)
    screen.text("- increase pad's level")
    screen.level(3)
    screen.move(0,60)
    screen.text("level: "..bank[i][bank[i].id].level)
    screen.move(100,60)
    screen.text("try: 12")
  elseif action == "12" then
    screen.move(0,35)
    screen.text("- stop/start pad's playback")
    screen.level(3)
    screen.move(0,60)
    screen.text("pause: "..tostring(bank[i][bank[i].id].pause))
    screen.move(85,60)
    screen.text("try: row 1")
  end
end

function help_menus.grid_pattern()
  screen.level(15)
  local i = which_bank
  local id = bank[i].id
  screen.move(0,20)
  screen.text("bank: "..i.." | pattern recorder")
  screen.move(0,30)
  screen.text("- record 4x4 pad presses")
  screen.move(0,40)
  screen.text("- tap again to start/stop")
  screen.move(0,50)
  screen.text("- quantization in params")
  screen.level(3)
  screen.move(40,60)
  screen.text("try: far bottom-left")
end

function help_menus.alt()
  screen.level(15)
  screen.move(0,20)
  screen.text("alt key (hold!)")
  screen.move(0,30)
  screen.text("- w/pattern button: clear")
  screen.move(0,40)
  screen.text("- w/4x4 pads: copy + paste")
  screen.move(0,50)
  screen.text("- w/rows: global change")
  screen.level(3)
  screen.move(20,60)
  screen.text("try: rows + combos w/alt")
end

function help_menus.loop()
  local i = which_bank
  local id = bank[i].id
  screen.level(15)
  screen.move(0,20)
  screen.text("toggle: loop or 1-shot")
  screen.move(0,30)
  screen.text("- loop: pad will loop")
  screen.move(0,40)
  screen.text("- 1-shot: pad will play once")
  screen.move(0,50)
  screen.text("- per pad | hold alt for bank")
  screen.level(3)
  screen.move(0,60)
  screen.text("loop: "..tostring(bank[i][id].loop))
  screen.move(90,60)
  screen.text("try: ")
end

function help_menus.mode()
  local i = which_bank
  local id = bank[i].id
  screen.level(15)
  screen.move(0,20)
  screen.text("switch: live or clip")
  screen.move(0,30)
  screen.text("- live: audio = live buffer")
  screen.move(0,40)
  screen.text("- clip: audio = sample")
  screen.move(0,50)
  screen.text("- load samples in params")
  screen.level(3)
  screen.move(0,60)
  local modes = {"live","clip"}
  screen.text("now: "..modes[bank[i][id].mode])
  screen.move(50,60)
  local try_next = {"button on R","button on L"}
  screen.text("try: "..try_next[bank[i][id].mode])
end

function help_menus.buffer_jump()
  local i = which_bank
  local id = bank[i].id
  screen.level(15)
  screen.move(0,20)
  screen.text("switch: buffers (3 live, 3 clip)")
  screen.move(0,30)
  screen.text("- change pad's buffer")
  screen.move(0,40)
  screen.text("- use alt to set whole bank")
  screen.move(0,50)
  screen.text("- fun to switch w/ patterns")
  screen.level(3)
  screen.move(0,60)
  screen.text("buffer: "..bank[i][id].clip)
  screen.move(50,60)
  if bank[i][id].clip == 1 then
    screen.text("try: button below")
  else
    screen.text("try: button @ [2,1]")
  end
end

function help_menus.buffer_switch()
  screen.level(15)
  screen.move(0,20)
  screen.text("switch: live buffer switch")
  screen.move(0,30)
  screen.text("- switch b/w 8 sec buffers")
  screen.move(0,40)
  screen.text("- record up to 8*3=24 sec")
  screen.move(0,50)
  screen.text("- use alt to stop rec")
  screen.level(3)
  screen.move(0,60)
  screen.text("live buffer: "..rec.clip)
  screen.move(60,60)
  if rec.clip ~= 3 then
    screen.text("try: button to R")
  end
end

function help_menus.arc_params()
  local i = which_bank
  screen.level(15)
  screen.move(0,20)
  screen.text("arc: change parameter")
  screen.move(0,30)
  screen.text("- switch arc's focus")
  screen.move(0,40)
  screen.text("- record changes in patterns")
  screen.move(0,50)
  local parameters = {"window","start point","end point","filter cutoff"}
  screen.text("current: "..parameters[arc_param[i]])
  screen.move(45,60)
  screen.level(3)
  if arc_param[i] == 4 then
    screen.text("try: button @ [5,1]")
  elseif arc_param[i] == 2 or arc_param[i] == 3 then
    screen.text("try: buttons to L/R")
  else
    screen.text("try: buttons to R")
  end
end

function help_menus.arc_pattern()
  screen.level(15)
  local i = which_bank
  screen.move(0,20)
  screen.text("arc: "..i.." | pattern recorder")
  screen.move(0,30)
  screen.text("- record arc turns")
  screen.move(0,40)
  screen.text("- tap again to start/stop")
  screen.move(0,50)
  screen.text("- hold alt to clear")
  screen.level(3)
  screen.move(45,60)
  if i == 1 then
    screen.text("try: buttons to R")
  elseif i == 2 or i == 3 then
    screen.text("try: buttons to L/R")
  else
    screen.text("try: buttons to L")
  end
end

return help_menus