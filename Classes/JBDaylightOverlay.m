//
//  JBDaylightOverlay.m
//  Maptivity
//
//  Created by John Boiles on 2/2/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "JBDaylightOverlay.h"

BOOL MKMapXInRect(double x, MKMapRect rect);

BOOL MKMapXInRect(double x, MKMapRect rect) {
  if (x >= rect.origin.x && x <= (rect.origin.x + rect.size.width)) {
    return YES;
  }
  return NO;
}

@implementation JBDaylightOverlay

- (void)dealloc {
  [_refreshTimer invalidate];
  [super dealloc];
}

- (void)startUpdating {
  if (_refreshTimer) return;
  _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
}

- (void)stopUpdating {
  [_refreshTimer invalidate];
  _refreshTimer = nil;
}

- (void)fillMapRect:(MKMapRect)mapRect context:(CGContextRef)context {
  CGMutablePathRef path = CGPathCreateMutable();
  CGRect rect = [self rectForMapRect:mapRect];
  CGPathMoveToPoint(path, nil, rect.origin.x, rect.origin.y);
  CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y);
  CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
  CGPathAddLineToPoint(path, nil, rect.origin.x, rect.origin.y + rect.size.height);
  CGPathCloseSubpath(path);
  CGContextAddPath(context, path);
  UIColor *overlayColor = [UIColor colorWithWhite:0.0 alpha:0.2];
  CGContextSetFillColorWithColor(context, overlayColor.CGColor);
  CGContextDrawPath(context, kCGPathFillStroke);
  CGPathRelease(path);
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
  // Get the longitude of the sun (based on the current time of day)
  NSCalendar *calendar = [NSCalendar currentCalendar];
  [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
  // Sun's offset as a fraction of a day. This is zero when the sun is over the prime meridian
  double sunOffset = ((double)(components.hour * 3600 + components.minute * 60 + components.second)) / (double)(24 * 60 * 60) + 0.5;
  if (sunOffset > 1) sunOffset -= 1;
  MKMapPoint primeMeridianMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(0, 0));
  double sunMapPointX = primeMeridianMapPoint.x - sunOffset * MKMapSizeWorld.width;
  // Wrap the sun's offset around the map
  if (sunMapPointX < 0) sunMapPointX += MKMapSizeWorld.width;

  // Calculate solar declination (latitude of the sun)
  NSUInteger dayOfYear = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
  // This is an estimation, the real equation was more complex and I couldn't get it to work
  // See http://en.wikipedia.org/wiki/Declination
  double solarDeclination = -23.44 * cos(360 * (dayOfYear + 10) *2 * M_PI / (365 * 360));

  // MKZoomScale is the number of pixels in a map point. Let's get the number of map points per pixel.
  NSInteger mapYInterval = 1 / zoomScale;
  // Iterate through all ~1px strips in the map tile, drawing the appropriate fill for the daylight overlay
  for (double mapPointY = mapRect.origin.y; mapPointY <= (mapRect.origin.y + mapRect.size.height); mapPointY += mapYInterval) {
    // Rectangle for which we will calculate the daylight.
    // This strip of the map that should be roughly 1px tall at the current zoom level
    MKMapRect mapStripRect;
    mapStripRect.origin = MKMapPointMake(mapRect.origin.x, mapPointY);
    mapStripRect.size = MKMapSizeMake(mapRect.size.width, mapYInterval);

    // Let's be more precise and look at the longitude halfway down mapStripRect
    CLLocationDegrees latitude = MKCoordinateForMapPoint(MKMapPointMake(mapStripRect.origin.x, (mapStripRect.origin.y + mapStripRect.size.height / 2))).latitude;

    // Fill in the top or bottom areas based on the solar declination
    // North pole is always dark
    if (solarDeclination < 0) {
      if (latitude > (solarDeclination + 90)) {
        [self fillMapRect:mapStripRect context:context];
        continue;
      }
    // South pole is always dark
    } else {
      if (latitude < (solarDeclination - 90)) {
        [self fillMapRect:mapStripRect context:context];
        continue;
      }
    }

    // Length of daylight (as a fraction of a full 24 hour day)
    // This equation came from the Xplanet source code (Map.cpp:907-917)
    // Xplanet took it from Chapter 42 of Astronomical Formulae for Calculators by Meeus.
    double lengthOfDay = (1 - (acos(tan(latitude * 2 * M_PI / 360) * tan(solarDeclination * 2 * M_PI / 360)) / M_PI));

    // X point at which sunrise happens on the map
    double sunriseMapPointX = sunMapPointX - lengthOfDay * MKMapSizeWorld.width / 2;
    if (sunriseMapPointX < 0) sunriseMapPointX += MKMapSizeWorld.width;

    // X point at which sunset happens on the map
    double sunsetMapPointX = sunMapPointX + lengthOfDay * MKMapSizeWorld.width / 2;
    if (sunsetMapPointX > MKMapSizeWorld.width) sunsetMapPointX -= MKMapSizeWorld.width;

    // If everything on this strip of tile is dark
    if ((sunsetMapPointX < mapRect.origin.x && (sunriseMapPointX > (mapRect.origin.x + mapRect.size.width))) // Surrounded by darkness
        || ((sunsetMapPointX > sunriseMapPointX) && (sunriseMapPointX > (mapRect.origin.x + mapRect.size.width))) // Left of map
        || ((sunsetMapPointX > sunriseMapPointX) && (sunsetMapPointX < mapRect.origin.x))) { // Right of map
      [self fillMapRect:mapStripRect context:context];
    // Both sunrise and sunset are in this mapRect, draw something (rare)
    } else if (MKMapXInRect(sunsetMapPointX, mapRect) && MKMapXInRect(sunriseMapPointX, mapRect)) {
      // Day, then night, then day
      if (sunsetMapPointX < sunriseMapPointX) {
        [self fillMapRect:MKMapRectMake(sunsetMapPointX, mapStripRect.origin.y, sunriseMapPointX - sunsetMapPointX, mapStripRect.size.height) context:context];
      // Night, then day, then night
      } else if (sunriseMapPointX < sunsetMapPointX) {
        [self fillMapRect:MKMapRectMake(mapRect.origin.x, mapStripRect.origin.y, sunriseMapPointX - mapRect.origin.x, mapStripRect.size.height) context:context];
        [self fillMapRect:MKMapRectMake(sunsetMapPointX, mapStripRect.origin.y, mapRect.origin.x + mapRect.size.width - sunsetMapPointX, mapStripRect.size.height) context:context];
      }      
    // The map tile shows day, then night
    } else if (MKMapXInRect(sunsetMapPointX, mapRect)) {
      MKMapRect rightNight = MKMapRectMake(sunsetMapPointX, mapStripRect.origin.y, (mapRect.origin.x + mapRect.size.width) - sunsetMapPointX, mapStripRect.size.height);
      [self fillMapRect:rightNight context:context];
    // The map tile shows night, then day
    } else if (MKMapXInRect(sunriseMapPointX, mapRect)) {
      MKMapRect night = MKMapRectMake(mapRect.origin.x, mapStripRect.origin.y, sunriseMapPointX - mapRect.origin.x, mapStripRect.size.height);
      [self fillMapRect:night context:context];
    }
  }
}

#pragma mark - MKOverlay

- (CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake(0, 0);
}

- (MKMapRect)boundingMapRect {
  return MKMapRectWorld;
}

@end
