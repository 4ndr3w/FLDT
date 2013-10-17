var child_process = require("child_process"),
	process = undefined;

function getStatus()
{
	return process != undefined;
}

function start(image)
{
	if ( image == "" || process != undefined )
		return false;
	process = child_process.exec("/bin/sh sendMulticastImage.sh "+image);
	console.log("/bin/sh sendMulticastImage.sh "+image);
	process.on("exit", function()
	{
		process = undefined;
	});
	return true;
}

function stop()
{
	if ( process == undefined )
		return false;
	process.kill();
	child_process.exec("killall udp-sender");
	return true;
}

function getPID()
{
	if ( process == undefined)
		return 0;
	return process.pid;
}

exports.start = start;
exports.stop = stop;
exports.getPID = getPID;
exports.getStatus = getStatus;
