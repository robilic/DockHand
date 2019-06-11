//
//  AppDelegate.m
//  MouseTracker
//
//  Created by Robert on 8/5/18.
//  Copyright © 2018 isovega. All rights reserved.
//

#import <stdlib.h>
#import <Cocoa/Cocoa.h>
// #import </System/Library/Frameworks/ApplicationServices.framework/Frameworks/CoreGraphics.framework/Headers/CGWindow.h>
#import <AppKit/NSAccessibility.h>

#import "AppDelegate.h"
#import "OverlayView.h"
#import "UIElementUtilities.h"

// these are private
@interface AppDelegate () {

}

@property (weak) IBOutlet OverlayView *overlay;
@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // this will make the window the size of the whole screen
    [_window
     setFrame:[_window frameRectForContentRect:[[_window screen] frame]]
     display:YES
     animate:YES];
    // scale the view 
    [_overlay prepareTheView];
    [_overlay prepareTextAttributes];
    
    if (AXIsProcessTrustedWithOptions(NULL)) {
        NSLog(@"Trusted I guess");
    }
    if (!AXAPIEnabled()) {
        NSLog(@"Accessibility API is not enabled, go to System Preferences");
    }
    
    NSLog(@"Creating system wide accessibility object");
    _systemWideAccessibilityObject = AXUIElementCreateSystemWide();
    
    NSLog(@"%@", CFCopyDescription(_systemWideAccessibilityObject));

    _currentUIElement = NULL;
    lastTitle = @"X0FFF";
    // if (timer == nil) ...
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(checkMouse:)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)dealloc {
    [timer invalidate];
    timer = nil;
    
    if (_systemWideAccessibilityObject)
        CFRelease(_systemWideAccessibilityObject);
    if (_currentUIElement)
        CFRelease (_currentUIElement);
    [super dealloc];
}

- (void)checkMouse:(NSTimer *)theTimer
{
    mouseLocation = [NSEvent mouseLocation];
    
    // check to see if the mouse even moved
    if (!NSEqualPoints(mouseLocation, lastMouseLocation)) {        
        CGPoint carbonPoint = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:mouseLocation];
        CGPoint *axPosition = nil;
        AXUIElementRef elementUnderCursor = NULL;
        AXError e;
        NSSize *axSize = nil;
        NSArray *attrArray = nil;
        NSString *axTitle = nil;
        NSString *axSubrole = nil;
        NSString *axURL;
        NSNumber *axIsApplicationRunning;
        pid_t axPID;

        // grab what is under the current mouse location
        accessibilityErrorCode = AXUIElementCopyElementAtPosition(_systemWideAccessibilityObject, carbonPoint.x, carbonPoint.y, &elementUnderCursor);

        AXUIElementCopyAttributeNames(elementUnderCursor, (CFArrayRef *)&attrArray);

        if (accessibilityErrorCode == kAXErrorSuccess) {
            if (AXUIElementCopyAttributeValue(elementUnderCursor, kAXSubroleAttribute, (CFTypeRef *)&axSubrole) == kAXErrorSuccess) {
                AXUIElementCopyAttributeValue(elementUnderCursor, kAXTitleAttribute, (CFTypeRef *)&axTitle);
                AXUIElementCopyAttributeValue(elementUnderCursor, kAXSizeAttribute, (CFTypeRef *)&axSize);
                AXUIElementCopyAttributeValue(elementUnderCursor, kAXPositionAttribute, (CFTypeRef *)&axPosition);
                AXUIElementCopyAttributeValue(elementUnderCursor, kAXURLAttribute, (CFTypeRef *)&axURL);

                if ([axSubrole isEqualToString:@"AXApplicationDockItem"]) {
                    AXUIElementCopyAttributeValue(elementUnderCursor, kAXIsApplicationRunningAttribute, (CFTypeRef *)&axIsApplicationRunning);
                    e = AXUIElementGetPid(elementUnderCursor, &axPID);
                    if ([axTitle isEqualToString:lastTitle]) {
                        NSLog(@"Still on the same icon");
                    }
                    if ([axIsApplicationRunning boolValue] == YES && ![axTitle isEqualToString:lastTitle]) {
                        [_overlay removePreviews];
                        [_overlay setWindowIds:[self getWindowIdsForOwner:axTitle]];
                        [_overlay createPreviews];
                        [_overlay setTitleText:axTitle];
                        [_overlay setNeedsDisplay:YES];
                        lastTitle = axTitle;;
                    }
                } else {
                    // check here to see if the mouse is inside the preview window at all, if so keep it visibile
                    NSLog(@"else : axSubrole isEqualToString:@'AXApplicationDockItem'");
                    [_overlay removePreviews];
                    [_overlay setWindowIds:nil];
                    [_overlay setNeedsDisplay:YES];
                    lastTitle = @"X0FFFF";
                }
            }
        } else {
            // we borked
            
            NSLog(@"Accessibility Error Code: %d", accessibilityErrorCode);
            NSLog(@"Description: %@", CFCopyDescription(elementUnderCursor));
        }
    
        lastMouseLocation = mouseLocation;
    }
}

- (NSMutableArray*)getWindowIdsForOwner:(NSString *)owner {
    NSLog(@"Searching for windows belonging to %@", owner);
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSString *searchString = owner;
    CFIndex count = CFArrayGetCount(windowList);
    NSMutableArray *windowNumberList = [NSMutableArray new];
    
    for (int i=0; i<count; i++) {
        NSDictionary *dict = CFArrayGetValueAtIndex(windowList, i);
        if ([searchString isEqualTo:[dict objectForKey:@"kCGWindowOwnerName"]]) {
            //NSLog(@"kCGWindowNumber = %@, Owner = %@", [dict objectForKey:@"kCGWindowNumber"], [dict objectForKey:@"kCGWindowOwnerName"]);
            [windowNumberList addObject:[dict objectForKey:@"kCGWindowNumber"]];
        }
    }
    return windowNumberList;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
