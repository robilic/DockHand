/*
     File: UIElementUtilities.h 
 Abstract: Utility methods to manage AXUIElementRef instances.
  
 
 */

#import <Cocoa/Cocoa.h>

extern NSString *const UIElementUtilitiesNoDescription;

@interface UIElementUtilities : NSObject {}

#pragma mark -
#pragma mark AXUIElementRef cover methods
/* These methods cover the bulk of the AXUIElementRef API found in <HIServices/AXUIElement.h> */

// Attribute values
+ (NSArray *)attributeNamesOfUIElement:(AXUIElementRef)element;
+ (id)valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;
+ (BOOL)canSetAttribute:(NSString *)attributeName ofUIElement:(AXUIElementRef)element;

// Takes a string value, converts the string to numbers, ranges, points, sizes, rects, if required
+ (void)setStringValue:(NSString *)stringValue forAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;

// Actions
+ (NSArray *)actionNamesOfUIElement:(AXUIElementRef)element;
+ (NSString *)descriptionOfAction:(NSString *)actionName ofUIElement:(AXUIElementRef)element;
+ (void)performAction:(NSString *)actionName ofUIElement:(AXUIElementRef)element;

// Returns 0 if process identifier could not be retrieved.  Process 0 never has valid UI elements
+ (pid_t)processIdentifierOfUIElement:(AXUIElementRef)element;


#pragma mark -
#pragma mark Convenience Methods
/* Convenience methods to return commonly requested attributes of a UI element */

// Returns the frame of the UI element in Cocoa screen coordinates
+ (NSRect)frameOfUIElement:(AXUIElementRef)element;

+ (AXUIElementRef)parentOfUIElement:(AXUIElementRef)element;
+ (NSString *)roleOfUIElement:(AXUIElementRef)element;
+ (NSString *)titleOfUIElement:(AXUIElementRef)element;

+ (BOOL)isApplicationUIElement:(AXUIElementRef)element;

#pragma mark -
// Screen geometry conversions
+ (CGPoint)carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint;
+ (CGPoint)cocoaScreenPointFromCarbonScreenPoint:(NSPoint)carbonPoint;

#pragma mark -
#pragma mark String Descriptions
/* Methods to return the various strings displayed in the interface */
+ (NSString *)stringDescriptionOfUIElement:(AXUIElementRef)inElement; // Note this is NOT nec. the AXDescription of the UIElement
+ (NSString *)descriptionForUIElement:(AXUIElementRef)uiElement attribute:(NSString *)name beingVerbose:(BOOL)beVerbose;


+ (NSString *)descriptionOfAXDescriptionOfUIElement:(AXUIElementRef)element;

@end
