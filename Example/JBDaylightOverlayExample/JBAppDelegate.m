//
//  JBAppDelegate.m
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

#import "JBAppDelegate.h"
#import "JBMapViewController.h"

@implementation JBAppDelegate

@synthesize window=_window;
@synthesize viewController=_viewController;

- (void)dealloc {
  [_window release];
  [_viewController release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    self.viewController = [[[JBMapViewController alloc] initWithNibName:@"JBMapViewController_iPhone" bundle:nil] autorelease];
  } else {
    self.viewController = [[[JBMapViewController alloc] initWithNibName:@"JBMapViewController_iPad" bundle:nil] autorelease];
  }
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
