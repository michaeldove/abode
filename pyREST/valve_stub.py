class Valves:

    _status = {}

    def onoff(self, channel, on):
	self._status.setdefault(channel, on)
        print "Channel: %d, on: %d" % (channel, on)

    def status(self, channel):
        if self._status.has_key(channel):
	    return self._status[channel]
	return 0
