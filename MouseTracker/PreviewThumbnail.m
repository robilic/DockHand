//
//  PreviewThumbnail.m
//  MouseTracker
//
//  Created by Robert on 9/15/18.
//  Copyright © 2018 isovega. All rights reserved.
//

#import "PreviewThumbnail.h"

@implementation PreviewThumbnail

- (id)initWithFrame:(NSRect)rect
{
    if (![super initWithFrame:rect])
        return nil;
    
    [self prepareAttributes];
    button_color = [NSColor greenColor];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Fill in view
    NSRect bounds = [self bounds];
    NSLog(@"PreviewThumbnail:drawRect");
    CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGRect renderRect = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    CGContextDrawImage(ctx, renderRect, backgroundImage);
    CGImageRelease(backgroundImage);
    
    // Draw preview title
    NSSize strSize = [windowName sizeWithAttributes:attributes];
    NSPoint strOrigin;
    NSRect r = [self bounds];
    strOrigin.x = r.origin.x + (r.size.width - strSize.width) / 2;
    strOrigin.y = r.origin.y + (strSize.height / 2);
    [windowName drawAtPoint:strOrigin withAttributes:attributes];
}

- (void)viewDidMoveToWindow
{
    int options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect;
    NSTrackingArea *ta;
    
    ta = [[NSTrackingArea new] initWithRect:NSZeroRect
                                    options:options
                                      owner:self
                                   userInfo:nil];
    [self addTrackingArea:ta];
}

- (void)prepareAttributes
{
    NSFont *f;
    NSFontManager *fontManager;
    
    f = [NSFont userFontOfSize:14];
    fontManager = [NSFontManager sharedFontManager];
    
    if (YES) {
        f = [fontManager convertFont:f toHaveTrait:NSBoldFontMask];
    }

    attributes = [NSMutableDictionary dictionary];
    [attributes setObject:f
                   forKey:NSFontAttributeName];
    [attributes setObject:[NSColor whiteColor]
                   forKey:NSForegroundColorAttributeName];
}

#pragma mark Events

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    NSLog(@"becomingFirstResponder");
    return YES;
}

- (BOOL)resignFirstResponder {
    NSLog(@"resigningFirstResponder");
    return YES;
}

- (void)mouseEntered:(NSEvent *) event {
    button_color = [NSColor blueColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *) event {
    button_color = [NSColor greenColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"mouseDown: %ld", [event clickCount]);
    NSLog(@"Event %@", event);
}

// getters/setters

- (void)setWindowID:(NSString *)id_string {
    window_id = id_string;
}

- (void)setWindowName:(NSString *)id_string {
    windowName = id_string;
}

- (void)setImage:(CGImageRef)image {
    backgroundImage = image;
}

@end
