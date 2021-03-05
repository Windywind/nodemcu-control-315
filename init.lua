--function printclient()
--  for mac,ip in pairs(wifi.ap.getclient()) do
--  print(mac,ip)
--end

do
wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ ssid = "WEB control LED", pwd = "12345678" })
--wifi.event.register(wifi.eventmon.AP_STACONNECTED,printclient())

gpio.mode(0, gpio.OUTPUT)
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
        print ("k: "..k)
        print ("v: "..v)
      end
    end
    buf = buf .. "<!DOCTYPE html><html><body><h1>Hello, this is NodeMCU.</h1>"
    .. "<form src=\"/\">Turn PIN1 <button name=\"act\" value=\"ON\" onclick=\"form.submit()\"> On"
    .. "<button name=\"act\" value=\"OFF\" onclick=\"form.submit()\"> Off"
    .. "<button name=\"act\" value=\"STOP\" onclick=\"form.submit()\"> STOP!"

    if (_GET.act == "ON") then
      print("turning LED on")
      gpio.write(0, gpio.LOW)
    elseif (_GET.act == "OFF") then
      print("turn LED off")
      gpio.write(0, gpio.HIGH)
    elseif (_GET.act == "STOP") then
      print("blinking LED")
      tmr.create():alarm(1, tmr.ALARM_SINGLE, function()
        gpio.write(0, gpio.LOW)
        tmr.delay(1000000)
        gpio.write(0, gpio.HIGH)
        tmr.delay(1000000)
        gpio.write(0, gpio.LOW)
        tmr.delay(1000000)
        gpio.write(0, gpio.HIGH)
        tmr.delay(1000000)
        gpio.write(0, gpio.LOW)
      end)
    end
    buf = buf .. "</button> </form></body></html>"
    client:send(buf)
  end)
  conn:on("sent", function(c) c:close() end)
end)
end
