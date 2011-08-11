//
//  NSBezierPath+MCAdditions.m
//
//  Created by Sean Patrick O'Brien on 4/1/08.
//  Copyright 2008 MolokoCacao. All rights reserved.
//

#import "NSBezierPath+MCAdditions.h"

// remove/comment out this line of you don't want to use undocumented functions
#define MCBEZIER_USE_PRIVATE_FUNCTION

#ifdef MCBEZIER_USE_PRIVATE_FUNCTION
extern CGPathRef CGContextCopyPath(CGContextRef context);
#endif

@implementation NSBezierPath (MCAdditions)

- (void)fillWithInnerShadow:(NSShadow *)shadow
{
  [NSGraphicsContext saveGraphicsState];
  
  NSSize offset = shadow.shadowOffset;
  NSSize originalOffset = offset;
  CGFloat radius = shadow.shadowBlurRadius;
  NSRect bounds = NSInsetRect(self.bounds, -(ABS(offset.width) + radius), -(ABS(offset.height) + radius));
  offset.height += bounds.size.height;
  shadow.shadowOffset = offset;
  NSAffineTransform *transform = [NSAffineTransform transform];
  if ([[NSGraphicsContext currentContext] isFlipped])
    [transform translateXBy:0 yBy:bounds.size.height];
  else
    [transform translateXBy:0 yBy:-bounds.size.height];
  
  NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRect:bounds];
  [drawingPath setWindingRule:NSEvenOddWindingRule];
  [drawingPath appendBezierPath:self];
  [drawingPath transformUsingAffineTransform:transform];
  
  [self addClip];
  [shadow set];
  [[NSColor blackColor] set];
  [drawingPath fill];
  
  shadow.shadowOffset = originalOffset;
  
  [NSGraphicsContext restoreGraphicsState];
}

- (void)drawBlurWithColor:(NSColor *)color radius:(CGFloat)radius
{
  NSRect bounds = NSInsetRect(self.bounds, -radius, -radius);
  NSShadow *shadow = [[NSShadow alloc] init];
  shadow.shadowOffset = NSMakeSize(0, bounds.size.height);
  shadow.shadowBlurRadius = radius;
  shadow.shadowColor = color;
  NSBezierPath *path = [self copy];
  NSAffineTransform *transform = [NSAffineTransform transform];
  if ([[NSGraphicsContext currentContext] isFlipped])
    [transform translateXBy:0 yBy:bounds.size.height];
  else
    [transform translateXBy:0 yBy:-bounds.size.height];
  [path transformUsingAffineTransform:transform];
  
  [NSGraphicsContext saveGraphicsState];
  
  [shadow set];
  [[NSColor blackColor] set];
  NSRectClip(bounds);
  [path fill];
  
  [NSGraphicsContext restoreGraphicsState];
  
}

// Credit for the next two methods goes to Matt Gemmell
- (void)strokeInside
{
    /* Stroke within path using no additional clipping rectangle. */
    [self strokeInsideWithinRect:NSZeroRect];
}

- (void)strokeInsideWithinRect:(NSRect)clipRect
{
    NSGraphicsContext *thisContext = [NSGraphicsContext currentContext];
    float lineWidth = [self lineWidth];
    
    /* Save the current graphics context. */
    [thisContext saveGraphicsState];
    
    /* Double the stroke width, since -stroke centers strokes on paths. */
    [self setLineWidth:(lineWidth * 2.0)];
    
    /* Clip drawing to this path; draw nothing outwith the path. */
    [self setClip];
    
    /* Further clip drawing to clipRect, usually the view's frame. */
    if (clipRect.size.width > 0.0 && clipRect.size.height > 0.0) {
        [NSBezierPath clipRect:clipRect];
    }
    
    /* Stroke the path. */
    [self stroke];
    
    /* Restore the previous graphics context. */
    [thisContext restoreGraphicsState];
    [self setLineWidth:lineWidth];
}

@end
