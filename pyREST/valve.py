from threading import Timer

try:
    from valve_rpi import Valves
except ImportError:
    from valve_stub import Valves

hardware = Valves()
timers = {}


def clearTimeout(channel):
    if channel in timers.keys():
	t = timers[channel]
        t.cancel()
	del timers[channel]
    
def onoff(channel, on):
    clearTimeout(timers[channel])
    hardware.onoff(channel, on)

def timedOn(channel, duration):
    def timeout():
	clearTimeout(timers[channel])
	hardware.onoff(channel, 0)
    hardware.onoff(channel, 1)
    clearTimeout(channel)
    t = Timer(duration, timeout)
    t.start()
    timers[channel] = t

def status(channel):
    return hardware.status(channel)
