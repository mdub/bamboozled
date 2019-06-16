Bamboozled
==========

"[CCMenu](http://ccmenu.sourceforge.net/)" is a OS X menubar widget that displays the status of continuous integration builds.

"[Bamboo](http://www.atlassian.com/software/bamboo/)" is a continuous integration server, made by the fine folks at Atlassian.  It does a bunch of good things, but unfortunately does not publish it's results in a manner usable by CCMenu.

"Bamboozled" is a small Rack app that presents the status of Bamboo projects, in "cc.xml" format, as required by CCMenu.  It scrapes the Bamboo "Wallboard" page

    http://bamboo.yourco.com/telemetry.action

Usage
-----

Start the Bamboozled app using "rackup" (or some other method of your choice).

    rackup -p 3456

Check out the root page. It's almost entirely useless.

    curl http://localhost:3456/

The fun starts when you point it towards a Bamboo server of your choice, e.g.

    curl http://localhost:3456/bamboo.yourco.com/cc.xml

Enter that URL in your CCMenu preferences, and you should see results!
