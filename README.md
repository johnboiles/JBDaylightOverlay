JBDaylightOverlay
=================
http://github.com/johnboiles/JBDaylightOverlay

An overlay for MapKit that shows daylight for the current date and time.

![JBDaylightOverlayScreenshot](https://johnboiles.s3.amazonaws.com/JBDaylightOverlayScreenshot.png)

To Use
------
1.   Instantiate an MKMapView

2.   Instantiate a JBDaylightOverlay

3.   Call [mapView addOverlay:daylightOverlay]

4.   Call [daylightOverlay startUpdating]

5.   Implement MKMapViewDelegate's mapView:viewForOverlay: delegate method to return daylightOverlay

License
-------
JBDaylightOverlay includes a [New/Modified BSD license](http://en.wikipedia.org/wiki/BSD_licenses#3-clause_license_.28.22New_BSD_License.22_or_.22Modified_BSD_License.22.29 "New/Modified BSD license"). This means you can use it modified or unmodified for your commerical products. However, you must include a credit mentioning John Boiles as the original author. Where you put it is up to you, but preferrably somewhere in the software itself. Perhaps something like:

Includes “JBDaylightOverlay” code by John Boiles.

You're under no obligation to share any modified / improved code, but I would appreciate it if you shared improvements via a pull request!
