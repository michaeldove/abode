import subprocess

PIN_LEVEL_LOW = "0"
PIN_LEVEL_HIGH = "1"
GPIO_COMMAND = "/usr/local/bin/gpio"
AT_COMMAND = "at"

def gpio_queue(gpio_pin):
    """
    Returns the name of the at queue for a gpio pin.
    """
    queue = '%s%d' % (GPIO_QUEUE, gpio_pin)
    return queue

def turn_on(gpio_pin, duration):
    """
    Turn on for duration minutes.
    """
    subprocess.call([GPIO_COMMAND, "-g", "write",
                         gpio_pin,
                         PIN_LEVEL_LOW])
    subprocess.call([AT_COMMAND, "-q", gpio_queue(gpio_pin),
                         "now",
                         "+",
                         "%d" % duration,
                         "minute"])





def turn_off(gpio_pin):
    """
    Turn off immediately.
    """
    subprocess.call([GPIO_COMMAND, "-g", "write",
                         gpio_pin,
                         PIN_LEVEL_HIGH])




if __name__ == '__main__':
    pass
