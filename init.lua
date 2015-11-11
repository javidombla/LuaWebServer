
-- WiFi Connection Verification --
wifi.setmode(wifi.STATION)
wifi.sta.config("Usuario","password")
wifi.sta.connect()
-- Poner IP manual
wifi.sta.setip({ip="192.168.10.40",netmask="255.255.255.0",gateway="192.168.10.1"})
print(wifi.sta.getip())

-- Global Variables --
led1 = 3
led2 = 4
blink_open = "http://dominio.dnsalias.com/On.png"
blink_close = "http://dominio.dnsalias.com/Off.png"
site_image = blink_op

-- GPIO Setup --
print("Setting Up GPIO...")
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
-- Web Server --
print("Starting Web Server...")
-- Create a server object with 30 second timeout
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local buf2 = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        
        local _, _, auth = string.find(request, "%cAuthorization: Basic ([%w=\+\/]+)");--Authorization:
          if (auth == nil or auth ~= "amF2aTpqYXZpZXI=")then --user:pass
               client:send("HTTP/1.0 401 Authorization Required\r\nWWW-Authenticate: Basic realm=\"ESP8266 Web Server\"\r\n\r\n<h1>Unauthorized Access</h1>");
               client:close();
               return;
          end
          
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

        -- Seleccion de imagen
        if gpio.read(led1) == 1 then
           site_image = blink_open
           print("PULSADOR ESTA A UNO")  
        else 
           site_image = blink_close
           print("PULSADOR ESTA A CERO")   
        end          
                               
        buf = buf.."<html><head>";           
        buf = buf.."<meta charset=\"utf-8\">";
        buf = buf.."<meta http-equiv=\"refresh\" content=\"5\">";
        buf = buf.."<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">";
        buf = buf.."<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">";
        buf = buf.."<title>Controlador</title>";
        buf = buf.."<style type=\"text/css\">";
        buf = buf.."body {";
        buf = buf.."background-color: #515151;";
        buf = buf.."color: #ffffff;";
        buf = buf.."}";
        buf = buf.."h1 {";
        buf = buf.."margin-left: 20px;";
        buf = buf.."}";
        buf = buf.."h2 {";
        buf = buf.."margin-left: 20px;";
        buf = buf.."}";
        buf = buf..".btn {";
        buf = buf.."position:relative;";
        buf = buf.."background: #FF6600;";
        buf = buf.."-webkit-border-radius: 14;";
        buf = buf.."-moz-border-radius: 14;";
        buf = buf.."border-radius: 14px;";
        buf = buf.."font-family: Arial;";
        buf = buf.."color: #ffffff;";
        buf = buf.."font-size: 20px;";
        buf = buf.."padding: 20px;";
        buf = buf.."}";
        buf = buf..".btn:hover {";
        buf = buf.."background: #AA6600;";
        buf = buf.."color: #ffffff;";
        buf = buf.."text-decoration: none;";
        buf = buf.."}";
        buf = buf..".btn:active {";
        buf = buf.."position:relative;";
        buf = buf.."color: #ffffff;";
        buf = buf.."top:3px;";
        buf = buf.."left:3px;";
        buf = buf.."}";
        buf = buf.."#menu {";
        buf = buf.."margin:20px;" ;   
        buf = buf.."}";
        buf = buf.."#menu2 {";
        buf = buf.."margin:20px;";  
        buf = buf.."}";
        buf = buf.."#boton {";
        bu2 = buf.."width:100%;";
        buf = buf.."}";
        bu2 = buf.."#boton2 {";
        buf = buf.."width:100%;";
        buf = buf.."}";
        buf = buf.."</style>";
        buf = buf.."</head>";
        buf = buf.."<body><h1>Web Server</h1>";
        buf = buf..('<IMG SRC="'..site_image..'" WIDTH="130" HEIGHT="90" BORDER="0"><br><br>\n');
        buf = buf.."<h2>Accion</h2>";
        buf = buf.."<div id=\"menu\">";      
        buf = buf.."<a href=\"?pin=ON1\"><input id=\"boton\" class=btn type=\"button\" value=\"ON1\" /></a></div>";
        buf = buf.."<div id=\"menu2\">";      
        buf = buf.."<a href=\"?pin=OFF1\"><input id=\"boton2\" class=btn type=\"button\" value=\"OFF1\" /></a></div>";
        buf = buf.."</body></html>";
        
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(led1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
              gpio.write(led1, gpio.LOW);
        elseif(_GET.pin == "ON2")then
              gpio.write(led2, gpio.HIGH);
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
