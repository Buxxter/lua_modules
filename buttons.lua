do
local function setnew (pin)
    return {}
end
local M = {}
M.set = function(pin, short, med, long)
    gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
    local o = setnew ()
    o.buttonPin = pin
    o.cicle = 0
    o.startcount = false
    o.gotpress = false
    o.doshort = short
    o.domedium = med or o.doshort
    o.doendcile = long or o.domedium
    o.startpin = function(self)
        gpio.trig(self.buttonPin, "down")
        gpio.trig(self.buttonPin, "down",function (level)
            if self.gotpress == false then
                self.gotpress = true
                local endflag = false
                local function exitnow(buf)
                    tmr.stop(buf); tmr.unregister( buf)
                    if not endflag then
                        if self.cicle < 20 then self.doshort()
                        else self.domedium() end
                    end
                    self.cicle, self.gotpress, self.startcount = 0, false, false
                end
                local buf = tmr.create()
                buf:alarm(50, 1, function()
                    if gpio.read(self.buttonPin) == 0 then
                        self.cicle = self.cicle + 1
                    else
                        if not self.startcount then
                            self.cicle = self.cicle - 1
                            if self.cicle < 0 then exitnow(buf) end
                        else
                            exitnow(buf)
                        end
                    end
                    if self.cicle > 3 then self.startcount = true end
                    if self.cicle > 50 and not endflag then
                        endflag = true; self.doendcile()
                    end
                end)
            end
        end)
    end
    return o:startpin()
end
return M
end