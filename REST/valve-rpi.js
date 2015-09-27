var config = require("./config");
var Gpio = require("onoff").Gpio;

var gpios = [];
for (var i=0, size=config.gpios.length; i < size; i++) {
 var gpioConfig = config.gpios[i];
 var gpio = new Gpio(gpioConfig.gpio, 'out');
 gpio.write(1); // Turn off as the setup will turn it on.
 gpios.push(gpio);
}

module.exports = { 
 onoff: function(channel, on) {
  gpio = gpios[channel];
  gpio_value = ((on == 0) ? 1 : 0);
  gpio.writeSync(gpio_value);
 },
 status: function(channel) {
  gpio = gpios[channel];
  gpio_value = gpio.readSync();
  on = ((gpio_value == 0) ? 1 : 0);
  return on;
 }
};
