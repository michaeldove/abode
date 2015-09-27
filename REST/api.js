var http = require('http');
var express = require('express');
var bodyParser = require('body-parser');
var valve = require('./valve');

var app = express()
var jsonParser = bodyParser.json()

var zoneConfigs = [ { name: 'Grass', channel: 0, description: 'Lawn' },
	      { name: 'Garden', channel: 1, description: 'Tree and shrubs' },
	      { name: 'Patch' , channel: 2, description: 'Side of house' }
             ]

app.use(express['static'](__dirname ));

var createZone = function(zoneConfig, on) {
  console.log(on);
  return { name : zoneConfig.name,
           id : zoneConfig.channel,
           on : on,
           description: zoneConfig.description };
}


app.get('/zones', function(req, res) {
 var zones = [];
 for (var i=0, size=zoneConfigs.length; i < size; i++) {
  var zoneConfig = zoneConfigs[i];
  var status = valve.status(zoneConfig.channel);
  var zone = createZone(zoneConfig, status);
  zones.push(zone);
 }
 res.setHeader('Content-Type', 'application/json');
 res.end(JSON.stringify(zones));
});

app.get('/zones/:id', function(req, res) {
 var zoneConfig = zoneConfigs[req.params.id];
 var status = valve.status(zoneConfig.channel);
 var zone = createZone(zoneConfig, status);
 res.setHeader('Content-Type', 'application/json');
 res.end(JSON.stringify(zone));
});

app.put('/zones/:id', jsonParser, function(req, res) {
 var zone = zoneConfigs[req.params.id];
 if (req.body.duration && req.body.on) {
  valve.timedOn(zone.channel, req.body.duration);
 } else {
  valve.onoff(zone.channel, req.body.on); 
 }
 res.status(200).send();
});

app.get('*', function(req, res) {
 res.status(404).send('Unrecognised call');
});

app.use(function(err, req, res, next) {
 if (req.xhr) {
  res.status(500).send('Oops, something went wrong!');
 } else {
  next(err);
 }
});

app.listen(3000);
console.log('App server running at port 3000');
