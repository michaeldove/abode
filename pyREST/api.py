from flask import Flask
from flask import abort
from flask.ext.restful import reqparse
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)

zoneConfigs = [ { 'name': 'Grass', 'channel': 0, 'description': 'Lawn' },
	      { 'name': 'Garden', 'channel': 1, 'description': 'Tree and shrubs' },
	      { 'name': 'Patch' , 'channel': 2, 'description': 'Side of house' }
             ]


import valve

def get_zone_config(zone_id):
    return zoneConfigs[zone_id] 
    
def createZone(zoneConfig, on):
    return { 'name': zoneConfig['name'],
             'id': zoneConfig['channel'],
             'on': on,
             'description': zoneConfig['description'] }

def get_zone(zone_id):
    zone_config = get_zone_config(zone_id)
    status = valve.status(zone_config['channel'])
    zone = createZone(zone_config, status)
    return zone

def get_zones():
    zones = []
    for zone_id in range(len(zoneConfigs)):
	zones.append(get_zone(zone_id))
    return zones


def abort_if_zone_doesnt_exist(zone_id):
    if (len(zoneConfigs) -1) < zone_id:
	abort(404)


class ZoneResource(Resource):

    def get(self, zone_id):
	abort_if_zone_doesnt_exist(zone_id)
	return get_zone(zone_id)

    def put(self, zone_id_str):
        zone_id = int(zone_id_str) 
	abort_if_zone_doesnt_exist(zone_id)

	parser = reqparse.RequestParser()
	parser.add_argument('duration', type=int)
	parser.add_argument('on', type=int)
	reqargs = parser.parse_args()
        duration = reqargs['duration']	
	on = reqargs['on']
        zone_config = get_zone_config(zone_id)	
	channel = zone_config['channel']
	if duration:
	    valve.timedOn(channel, duration)
	else:
	    valve.onoff(channel, on)
	zone = get_zone(zone_id)
        return zone, 201
   
class ZoneListResource(Resource):
    
    def get(self):
	return get_zones()
    

api.add_resource(ZoneListResource, '/zones')
api.add_resource(ZoneResource, '/zones/<zone_id_str>')

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=3000)
