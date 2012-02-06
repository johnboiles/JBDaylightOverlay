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
