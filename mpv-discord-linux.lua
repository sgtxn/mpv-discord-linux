----------HELPERS----------

function write_format(little_endian, format, ...)
    local res = ''
    local values = {...}
    for i=1,#format do
      local size = tonumber(format:sub(i,i))
      local value = values[i]
      local str = ""
      for j=1,size do
        str = str .. string.char(value % 256)
        value = math.floor(value / 256)
      end
      if not little_endian then
        str = string.reverse(str)
      end
      res = res .. str
    end
    return res
  end

function clean_title(title)
  local new_title = string.gsub(title, "%[[^%]]+%]", "") -- Removes [Coalgirls] and other stuff in square brackets
  new_title = new_title:gsub("%([^%)]+%)", "") -- Removes (1920x1080 Bluray FLAC) and other stuff in parentheses
  new_title = new_title:gsub("_", " ") -- Replaces underscores with spaces to fix titles like Strike_Witches_The_Movie
  new_title = new_title:gsub("%.", " ") -- Replaces dots with spaces to fix titles like Strike.Witches.The.Movie
  new_title = new_title:gsub("^%s*(.-)%s*$", "%1") -- Trim
  if new_title == ""  then return title end
  return new_title
end

function random_uuid()
  math.randomseed(os.time())
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function (c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

----------DISCORD INTERACTION----------

function signup()
    local path = '/run/user/1000/discord-ipc-0'
    unix = require "socket.unix"
    Conn = unix()
    assert(Conn:connect(path))
    Conn:settimeout(2)
    local payload = '{"v":"1","client_id":"470185467959050261"}'
    local head = write_format(true, "44", 0x0, payload:len())

    Conn:send(head..payload)
    local time = os.time()
    local data = ""
    repeat
      local res = Conn:receive(100)
      if res ~= nil then data = data .. res end
    until res == nil and #data > 0 or time + 1 < os.time()
end

function send_status(state, details, starttime, endtime)
  local f = io.popen("pidof mpv", 'r')
  local pid = f:read('*a')
  local payload_new = '{"cmd":"SET_ACTIVITY","args":{"pid":@pid,"activity":{"state":"@state","details":"@details","timestamps":{"start":@starttime,"end":@endtime},"assets":{"large_image":"mpvlogo","large_text":"mpv Media Player","small_image":"play","small_text":"Playing"}}},"nonce":"@nonce"}'
  payload_new = payload_new:gsub("@pid", pid)
  payload_new = payload_new:gsub("@state", state)
  payload_new = payload_new:gsub("@details", details)
  payload_new = payload_new:gsub("@starttime", starttime)
  payload_new = payload_new:gsub("@endtime", endtime)
  payload_new = payload_new:gsub("@nonce", random_uuid())

  local head_new = write_format(true, "44", 0x1, payload_new:len())

  Conn:send(head_new..payload_new)
  local time = os.time()
	local data = ""
	repeat
    local res = Conn:receive(100)
    if res ~= nil then data = data .. res end
	until res == nil and #data > 0 or time + 1 < os.time()
	if data:find("code", 1, true) then
		error("discord: bad RPC reply, " .. data:sub(8) .. "\n")
	end
end

----------HANDLERS----------

function on_file_loaded()
  signup()

  local title = mp.get_property("filename/no-ext")
  title = clean_title(title)
  local duration = mp.get_property("time-remaining")
  local start_time = os.time()
  local end_time = math.floor(start_time + duration)
  send_status(title, "Now watching:", start_time, end_time)
end

function on_exit()
  Conn:close()
end

----------MAIN----------

require "mp"
mp.register_event("file-loaded", on_file_loaded)
mp.register_event("end-file", on_exit)
