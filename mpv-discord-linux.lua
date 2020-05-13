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
  return string.gsub(title, "%[[^%]]+%]", "")
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
    Conn:receive(512)
end

function send_status(state, details, starttime, endtime)
  local f = io.popen("pidof mpv", 'r')
  local pid = f:read('*a')
  local payload_new = '{"cmd":"SET_ACTIVITY","args":{"pid":@pid,"activity":{"state":"@state","details":"@details","timestamps":{"start":@starttime,"end":@endtime},"assets":{"large_image":"mpvlogo","large_text":"mpv Media Player","small_image":"play","small_text":"Playing"}}},"nonce":"647d814a-4cf8-4fbb-948f-898abd24f55b"}'
  payload_new = payload_new:gsub("@pid", pid)
  payload_new = payload_new:gsub("@state", state)
  payload_new = payload_new:gsub("@details", details)
  payload_new = payload_new:gsub("@starttime", starttime)
  payload_new = payload_new:gsub("@endtime", endtime)

  local head_new = write_format(true, "44", 0x1, payload_new:len())

  Conn:send(head_new..payload_new)
  print(Conn:receive(512))
end

----------HANDLERS----------

function on_file_loaded()
  signup()

  Repeat = true
  local title = mp.get_property("filename/no-ext")
  title = clean_title(title)
  local duration = mp.get_property("time-remaining")
  local start_time = os.time()
  local end_time = start_time * 1000 + duration * 1000
  send_status(title, "Now watching:", start_time, end_time)
end

function on_quit()
  Conn:close()
end

----------MAIN----------

require "mp"
mp.register_event("file-loaded", on_file_loaded)
mp.register_event("end-file", on_quit)