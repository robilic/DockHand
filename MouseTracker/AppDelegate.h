//
//  AppDelegate.h
//  MouseTracker
//
//  Created by Robert on 8/5/18.
//  Copyright © 2018 isovega. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    AXUIElementRef  _currentUIElement;
    AXUIElementRef  _systemWideAccessibilityObject;
    AXError         accessibilityErrorCode;
    NSString        *lastTitle;
    NSTimer         *timer;
    NSPoint         mouseLocation, lastMouseLocation;
}

- (NSMutableArray*)getWindowIdsForOwner:(NSString *)owner;

@end

