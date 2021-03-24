do
  wifi.setmode(wifi.SOFTAP)
  wifi.ap.config({ ssid = "WEB-Pin", pwd = "12345678" })

  onpin = 4
  offpin = 8
  stoppin = 9
  idlepin = 3
  powerpin = 10

  function initpin(pin)
    gpio.mode(pin,gpio.OUTPUT)
    gpio.write(pin,gpio.LOW)
  end

  for pin = 3,10,1 do
    initpin(pin)
  end

  function sendpin (datapin, powerpin)
      gpio.mode(datapin, gpio.OUTPUT)
      gpio.mode(powerpin, gpio.OUTPUT)
      tmr.create():alarm(1, tmr.ALARM_SINGLE, function()
          gpio.write(powerpin, gpio.HIGH)
          print("read powerpin: "..gpio.read(powerpin))
          gpio.write(datapin, gpio.HIGH)
          print("read datapin: "..gpio.read(datapin))
          tmr.delay(300000)
          gpio.write(powerpin, gpio.LOW)
          print("read powerpin: "..gpio.read(powerpin))
          gpio.write(datapin, gpio.LOW)
          print("read datapin: "..gpio.read(datapin))
      end)
  end
  
  local srv = net.createServer(net.TCP)
  srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
      local buf = ""
      local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")  -- luacheck: no unused
      if (method == nil) then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")  -- luacheck: no unused
      end
      local _GET = {}
      if (vars ~= nil) then
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
          _GET[k] = v
        end
      end
      buf = buf .. "<!DOCTYPE html><html><body><h1>Hello, this is NodeMCU.</h1>"
      .. "<form src=\"/\">Turn PIN1" 
      .. "<br><br>"
      .."<button name=\"act\" value=\"ON\" onclick=\"form.submit()\"> &nbsp;On&nbsp; </button>"
      .. "<br><br>"
      .. "<button name=\"act\" value=\"OFF\" onclick=\"form.submit()\"> &nbsp;Off&nbsp; </button>"
      .. "<br><br>"
      .. "<button name=\"act\" value=\"STOP\" onclick=\"form.submit()\" style=\"width:100px;height:60px\"> &nbsp;STOP!&nbsp; </button>"
      if (_GET.act == "ON") then
        sendpin (onpin,powerpin)
      elseif (_GET.act == "OFF") then
        sendpin (offpin,powerpin)
      elseif (_GET.act == "STOP") then
        sendpin (stoppin,powerpin)
      end
      buf = buf .. "</button> </form></body></html>"
      client:send(buf)
    end)
    conn:on("sent", function(c) c:close() end)
  end)
end
