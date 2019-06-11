//
//  OverlayView.h
//  Grab
//
//  Created by Robert on 8/31/12.
//  Copyright (c) 2012 Robert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OverlayView : NSView {
    NSArray *windowIds;
    NSString *previewTitleString;
    NSMutableDictionary *titleTextAttributes;

    float dockSize;
    float screenWidth, screenMidpoint;
    float previewWidth, previewHeight, previewBorder;
    float totalPreviewWidth, previewGroupWidth;
}

- (void)setWindowIds:(NSArray*)ids;
- (void)prepareTheView;
- (void)prepareTextAttributes;
- (void)setTitleText:(NSString*)title;
- (void)createPreviews;
- (void)removePreviews;

@end
