//
//  OverlayView.m
//  Grab
//
//  Created by Robert on 8/31/12.
//  Copyright (c) 2012 Robert. All rights reserved.
//

#import "OverlayView.h"
#import "PreviewThumbnail.h"
#import <Cocoa/Cocoa.h>

@implementation OverlayView

- (BOOL)isFlipped {
    return NO;
}

- (void)prepareTheView
{
    NSLog(@"prepareTheView");
    // make the overlay view the same size as the overlay window - AKA the whole screen
    NSSize windowSize = [[_window contentView] frame].size;
    NSRect viewRect;
    viewRect.size.width = windowSize.width;
    viewRect.size.height = windowSize.height;
    self.frame = viewRect;
    
    NSScreen *screen = [self.window screen];
    NSRect visibleFrame = [screen visibleFrame];
    NSRect screenFrame = screen.frame;
    
    dockSize = visibleFrame.origin.y + 3;
    
    NSLog(@"visibleFrame origin = %f, height = %f, vf = %f", visibleFrame.origin.y, visibleFrame.size.height, dockSize);
    if (visibleFrame.origin.x > screenFrame.origin.x) {
        NSLog(@"Dock is positioned on the LEFT");
    } else if (visibleFrame.origin.y > screenFrame.origin.y) {
        NSLog(@"Dock is positioned on the BOTTOM");
    } else if (visibleFrame.size.width < screenFrame.size.width) {
        NSLog(@"Dock is positioned on the RIGHT");
    } else {
        NSLog(@"Dock is HIDDEN");
    };
    NSLog(@"Window is %f, %f view is %f, %f", windowSize.width, windowSize.height, viewRect.size.width, viewRect.size.height);
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSLog(@"Overlay view init..");
    }
    return self;
}

- (void)removePreviews {
    NSLog(@"removePreviews");
    // remove any exsiting PreviewThumbnails
    NSArray *subviews = [self.window.contentView subviews];
    NSLog(@"%lu Subviews = %@", (unsigned long)[subviews count], subviews);
    
    if ([subviews count] > (unsigned long)1) {
        //BOOL test = [self isKindOfClass:[SomeClass class]];
        for (int i = [subviews count] - 1; i > 0; i--) {
            id view_element = [subviews objectAtIndex:i];
            if ([view_element isKindOfClass:[PreviewThumbnail class]]) {
                [view_element removeFromSuperview];
                NSLog(@"Removing subview %d", i);
            }
        }
    }
}

- (void)createPreviews {
    NSLog(@"createPreviews");
    CGImageRef      thumbref;
    CGImageRef      thumbRetrieve;
    CGRect          nullImageBounds = CGRectNull;
    NSArray         *windowInfo;
    NSMutableArray  *previewThumbnails = [NSMutableArray array];
    NSUInteger      previewWindowCount = [windowIds count];
    
    float start = screenMidpoint - ((totalPreviewWidth * previewWindowCount) / 2);
    float x = (start + previewBorder / 2);
    //NSLog(@"Start = %g", start);
    NSLog(@"There are %lu windowIds", previewWindowCount);

    // grab all the preview images
    if (previewWindowCount > 0U) {
        for (unsigned long i = 0; i < previewWindowCount; i++) {
            // grab the image
            thumbref = CGWindowListCreateImage(nullImageBounds, kCGWindowListOptionIncludingWindow, [[windowIds objectAtIndex:i] intValue], kCGWindowImageNominalResolution || kCGWindowImageBoundsIgnoreFraming);
            // encode it, add to array
            NSValue *cgImageValue = [NSValue valueWithBytes:&thumbref objCType:@encode(CGImageRef)];
            [previewThumbnails addObject:cgImageValue];
            
            windowInfo = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow, [[windowIds objectAtIndex:i] intValue]));
            //NSLog(@"createPreviews\nwindowInfo (%lu) = %@", i, windowInfo);
            NSRect thumbnailFrame = NSMakeRect(x, dockSize+previewBorder, previewWidth, previewHeight);
            PreviewThumbnail *thumbnailView;
            thumbnailView = [[PreviewThumbnail new] initWithFrame:thumbnailFrame];
            [thumbnailView setImage:thumbref];
            [thumbnailView setWindowName:[windowInfo[0] objectForKey:@"kCGWindowName"]];
            [self.window.contentView addSubview:thumbnailView];
            x = x + totalPreviewWidth;
        }
    }
    // We need         kCGWindowName = robert;
    //
    // Don't draw:
    //   kCGWindowName = statusBarItem;
    //   kCGWindowLayer = "-2147483603";
    //   kCGWindowOwnerPID = our PID

    NSImage *thumb = [[NSImage new] initWithCGImage:thumbref size:NSZeroSize];
    
    for (unsigned long i = 0; i < previewWindowCount; i++) {
        [[previewThumbnails objectAtIndex:i] getValue:&thumbRetrieve];
         NSImage *thumb = [[NSImage new] initWithCGImage:thumbRetrieve size:NSZeroSize];
         //NSLog(@"thumbref = %zu x %zu, thumb = %g x %g", CGImageGetWidth(thumbref), CGImageGetWidth(thumbref), 0.0, 0.0);
         [thumb setSize:NSMakeSize(previewWidth, previewHeight)];
         [thumb drawAtPoint:NSMakePoint(x, 100.0+previewBorder)
                   fromRect:NSZeroRect
                  operation:NSCompositingOperationCopy
                   fraction:1.0];
        
         //TODO: draw text to label this window
         // NSGR something
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([windowIds count] == 0) {
        NSLog(@"No windowIds set, exiting drawRect");
        return;
    }
    
    // Returns the screen object containing the window with the keyboard focus.
    NSRect      theMainScreen = [[NSScreen mainScreen] frame];
    NSRect      backdrop;
    NSColor     *borderColor, *fillColor;
    borderColor = [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:0.8f];
    fillColor = [NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.2f alpha:0.8f];

    previewWidth = 320.0;
    previewHeight = 200.0;  // TODO: some % of screen height? 1/3rd? Or whatever will fit in width
    previewBorder = 20.0;
    totalPreviewWidth = previewWidth + previewBorder; // window plus borders
    screenWidth = theMainScreen.size.width;
    screenMidpoint = screenWidth / 2;
    // NSLog(@"The mainScreen is %g, %g", theMainScreen.size.width, theMainScreen.size.height);

//    [NSGraphicsContext saveGraphicsState];

    NSUInteger      previewWindowCount = [windowIds count];

    // TODO: use screen width to figure out how many we can draw full size
    if (previewWindowCount > (unsigned long)4 ) {
        NSLog(@"%lu is too many preview windows to draw!", previewWindowCount);
    } else {
        previewGroupWidth = previewWindowCount * totalPreviewWidth + 20; // add all the preview windows and their borders together
        backdrop.size.width = previewGroupWidth;
        backdrop.size.height = previewHeight + previewBorder + 40; // 40 pixels is the padding for the preview title
        backdrop.origin.x = (screenWidth - previewGroupWidth) / 2;
        backdrop.origin.y = dockSize; // dummy value for now, 100 px from bottom edge of screen
        NSLog(@"Going to draw %lu windows, previewGroupWidth = %g, totalPreviewWidth = %g", previewWindowCount, previewGroupWidth, totalPreviewWidth);
        
        // draw the backdrop
        NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:backdrop
                                                               xRadius:5 yRadius:5];
        [fillColor setFill];
        [border fill];
        [borderColor setStroke];
        [border setLineWidth:3];
        [border stroke];
    }

    // draw the text labels
    NSSize strSize = [previewTitleString sizeWithAttributes:titleTextAttributes];
    NSPoint strOrigin;
    strOrigin.x = screenMidpoint - (strSize.width / 2);
    strOrigin.y = dockSize + previewHeight + strSize.height + 10;
    [previewTitleString drawAtPoint:strOrigin withAttributes:titleTextAttributes];

//    [NSGraphicsContext restoreGraphicsState];
}

- (void)setWindowIds:(NSArray*)ids {
    windowIds = [NSArray arrayWithArray:ids];
//    NSLog(@"Setting window ids to %@", windowIds);
}

- (void)prepareTextAttributes {
    NSFont *f;
    NSFontManager *fontManager;
    
    f = [NSFont userFontOfSize:16];
    fontManager = [NSFontManager sharedFontManager];
    f = [fontManager convertFont:f toHaveTrait:NSBoldFontMask];
    
    titleTextAttributes = [NSMutableDictionary dictionary];
    [titleTextAttributes setObject:f
                   forKey:NSFontAttributeName];
    [titleTextAttributes setObject:[NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.0f]
                   forKey:NSForegroundColorAttributeName];
}

- (void)setTitleText:(NSString*)title {
    previewTitleString = title;
}

#pragma mark Events

@end
