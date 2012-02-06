//
//  JBMapViewController.m
//  JBDaylightOverlayExample
//
//  Created by John Boiles on 2/6/12.
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

#import "JBMapViewController.h"
#import "JBDaylightOverlay.h"

@implementation JBMapViewController

- (void)viewDidLoad {
  _mapView.delegate = self;
  JBDaylightOverlay *daylightOverlay = [[JBDaylightOverlay alloc] init];
  [_mapView addOverlay:daylightOverlay];
  [daylightOverlay startUpdating];
  [daylightOverlay autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  if ([overlay isKindOfClass:[JBDaylightOverlay class]]) {
    return (JBDaylightOverlay *)overlay;
  }
  return nil;
}

@end
