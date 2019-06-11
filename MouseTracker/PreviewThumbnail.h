//
//  PreviewThumbnail.h
//  MouseTracker
//
//  Created by Robert on 9/15/18.
//  Copyright © 2018 isovega. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreviewThumbnail : NSView {
    NSColor             *button_color;
    NSMutableDictionary *attributes;
    NSString            *window_id;
    NSString            *windowName;
    int                 button_id;
    CGImageRef          backgroundImage;
}

- (void)setWindowID:(NSString*)id_string;
- (void)setWindowName:(NSString*)id_string;
- (void)setImage:(CGImageRef)image;

@end
