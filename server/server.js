process.chdir(__dirname);

var fs = require("fs"),
	express = require("express"),
	app = express(),
	hostDB = require("./Host.js"),
	multicastManager = require("./MulticastManager.js"),
	redis = require("redis").createClient();

var hosts = new Array();

app.use(express.bodyParser({uploadDir:"/tmp"}));
app.engine('jshtml', require('jshtml-express'));
app.set('view engine', 'jshtml');

images = fs.readdirSync("/images");

selectedImage = 0;
redis.get("selectedImage", function(err, res)
{
	if ( res )
		selectedImage = parseInt(res);
})

app.get("/api/currentImage", function(req,res)
{
	newParam = req.param("set");
	console.log(newParam);
	if ( newParam != undefined && newParam > 0 && newParam < images.length )
	{
		selectedImage = newParam;
		redis.set("selectedImage", newParam);
	}	
	res.send(images[selectedImage]);
});

app.get("/api/images", function(req,res)
{
	res.json(images);
});

app.get("/api/hostname", function (req,res)
{
	mac = req.param("mac");
	hostDB.getHostnameByMAC(mac, function(host)
	{
		if ( host )
			res.send(host);	
		else
			res.send("unknown");
	});
});

app.get("/api/multicastStatus", function(req,res)
{
	if ( multicastManager.getStatus() )
		res.send("running");
	else
		res.send("stopped");
});

app.get("/", function (req,res)
{
	res.redirect("/images");
})

app.get("/images", function(req,res) { 
	res.locals({
		"images": images,
		"selectedImage": selectedImage
	});
	
	res.render("images");
});


app.post("/hosts", function(req,res) {
	hostDB.loadCSV(req.files.file.path);
	res.redirect("/hosts");
});

app.get("/hosts", function(req,res) { 
	if ( req.param("reset") )
	{
		hostDB.resetHosts();
		res.redirect("/hosts");
	}
	else
	{	
		hostDB.getHosts(function(hosts)
		{
			redis.mget(hosts, function(err, macAddrs)
			{
				res.locals({
					hosts: hosts,
					macAddrs: macAddrs,
					"nHosts": hosts.length
				});
				res.render("hosts");
			});
		});
	}
});


app.get("/multicast", function(req,res) { 
	res.locals({
		inProgress: multicastManager.getStatus(),
		pid: multicastManager.getPID(),
		currentImage: images[selectedImage]
	});
	
	if ( req.param("start") )
	{
		multicastManager.start(images[selectedImage]);
		res.redirect("/multicast");
	}
	else if ( req.param("stop") )
	{
		multicastManager.stop();
		res.redirect("/multicast");
	}
	else
		res.render("multicast");
});


app.use("/static", express.static("static"));
app.listen(80);
