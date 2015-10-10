import RPi.GPIO as GPIO

class Valves:
    
    def onoff(channel, on):
	GPIO.output(channel, on)

    def status(channel):
	return GPIO.input(channel)
	

#GPIO.setup(17, GPIO.OUT)
#GPIO.output(17, False)

#GPIO.setup(22, GPIO.OUT)
#GPIO.output(22, False)

#GPIO.setup(22, GPIO.OUT)
#GPIO.output(22, False)
