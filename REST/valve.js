var hardware;
try {
 hardware = require("./valve-rpi")
} catch (e) {
 hardware = { onoff: function(channel, on) {
              console.log('OnOff - channel: ' + channel + ' on: ' + on);
              },
              status: function(channel) {
               console.log('Status - channel: ' + channel);
              }
            }
}

var timers = {};
module.exports = {
 onoff: function(channel, on) {
  clearTimeout(timers[channel]);
  delete timers[channel];
  hardware.onoff(channel, on);
 },
 timedOn: function(channel, duration) {
  var timeOut = function() {
   delete timers[channel];
   hardware.onoff(channel, 0);
  };
  hardware.onoff(channel, 1);
  clearTimeout(timers[channel]);
  timers[channel] = setTimeout(timeOut, duration);
 },
 status: function(channel) {
  return hardware.status(channel);
 }
};
