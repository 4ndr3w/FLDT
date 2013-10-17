var fs = require("fs"),
    hostDB = new Array(),
	redis = require("redis").createClient();

function loadCSV(path)
{
	fs.readFile(path, function(err, data) 
	{
		if ( !err )
		{
			lines = data.toString().split("\n");
			for ( var i = 0; i < lines.length; i++ )
			{
				d = lines[i].toString().split(",");
				addHost(d[0], d[3]);
			}
		}
	});
}


function addHost(hostname, mac)
{
	if ( hostname == undefined || mac == undefined )
		return false;
	redis.set("host"+hostname, mac);
	redis.set("mac"+mac, hostname);
}

function resetHosts()
{
	redis.flushdb();
}

function getNumHosts(callback)
{
	redis.keys("host*", function(err, res) {
		callback(res.length);
	})
}

function getHosts(callback)
{
	redis.keys("host*", function(err, res) {
		callback(res);
	})
}

function getHostnameByMAC(mac, callback)
{
	redis.get("mac"+mac, function(err, data)
	{
		callback(data);
	});
}

exports.loadCSV = loadCSV;
exports.hosts = hostDB;
exports.addHost = addHost;
exports.resetHosts = resetHosts;
exports.getNumHosts = getNumHosts;
exports.getHosts = getHosts;
exports.getHostnameByMAC = getHostnameByMAC;
