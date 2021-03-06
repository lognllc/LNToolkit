//
//  RSBubbleView.m
//
//  Created by Rex Sheng on 4/28/12.
//

#import "RSBubbleView.h"

@implementation RSBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		_cornerRadius = 10.5f;
		_arrowSize = CGRectMake(30, 0, 14, 9);
    }
    return self;
}

- (void)setArrowType:(RSBubbleType)arrowType
{
	_arrowType = arrowType;
	[self setNeedsDisplay];
}

- (void)setColors:(NSArray *)colors
{
	_colors = colors;
	[self setNeedsDisplay];
}

- (void)setLocations:(NSArray *)locations
{
	_locations = locations;
	[self setNeedsDisplay];
}

- (void)setArrowSize:(CGRect)arrowSize
{
	_arrowSize = arrowSize;
	[self setNeedsDisplay];
}

- (UIBezierPath *)bubblePathInset:(CGFloat)inset
{
	//	CGFloat delta = inset * M_SQRT1_2;
	//	creating the path
	CGMutablePathRef path = CGPathCreateMutable();
	//topleft
	CGFloat radius = _cornerRadius - inset * M_SQRT1_2;
	CGRect rect = CGRectInset(self.bounds, inset, inset);
	BOOL _left = (_arrowType & (RSBubbleTopLeft | RSBubbleBottomLeft)) != 0;
	BOOL _right = (_arrowType & (RSBubbleTopRight | RSBubbleBottomRight)) != 0;
	BOOL _top = (_arrowType & (RSBubbleTopLeft | RSBubbleTopRight)) != 0;
	BOOL _bottom = (_arrowType & (RSBubbleBottomLeft | RSBubbleBottomRight)) != 0;
	BOOL middle = (_arrowType & RSBubbleMiddle) != 0;
	
	BOOL left = _left && _arrowSize.origin.y != 0;
	BOOL right = _right && _arrowSize.origin.y != 0;
	BOOL top = _top && _arrowSize.origin.x != 0;
	BOOL bottom = _bottom && _arrowSize.origin.x != 0;
	
	CGFloat minX = CGRectGetMinX(rect) + left * _arrowSize.size.width;
	CGFloat maxX = CGRectGetMaxX(rect) - right * _arrowSize.size.width;
	CGFloat minY = CGRectGetMinY(rect) + top * _arrowSize.size.height;
	CGFloat maxY = CGRectGetMaxY(rect) - bottom * _arrowSize.size.height;
	//top left
	CGFloat x = minX, y = minY;
	CGPathMoveToPoint(path, NULL, x, y + radius);
	CGPathAddCurveToPoint(path, NULL, x, y, x, y, x + radius, y);
	CGFloat awidth = _arrowSize.size.width - 2 * inset;
	CGFloat ahwidth = awidth / (middle ? 2 : 1);
	CGFloat aheight = _arrowSize.size.height - 2 * inset;
	CGFloat ahheight = aheight / (middle ? 2 : 1);
	if (top) {
		//top arrow
		x += CGRectGetMinX(_arrowSize);
		CGPathAddLineToPoint(path, NULL, x, y);
		CGPathAddLineToPoint(path, NULL, x + _right * ahwidth, y - _arrowSize.size.height + inset);
		CGPathAddLineToPoint(path, NULL, x + awidth, y);
	}
	x = maxX;
	//top right
	CGPathAddLineToPoint(path, NULL, x - radius, y);
	CGPathAddCurveToPoint(path, NULL, x, y, x, y, x, y + radius);
	if (right) {
		//right arrow
		y += CGRectGetMinY(_arrowSize);
		CGPathAddLineToPoint(path, NULL, x, y);
		CGPathAddLineToPoint(path, NULL, x + _arrowSize.size.width - inset, y + _bottom * ahheight);
		CGPathAddLineToPoint(path, NULL, x, y + aheight);
	}
	//bottom right
	y = maxY;
	CGPathAddLineToPoint(path, NULL, x, y - radius);
	CGPathAddCurveToPoint(path, NULL, x, y, x, y, x - radius, y);
	x = minX;
	if (bottom) {
		x += CGRectGetMaxX(_arrowSize) - 2 * inset;
		CGPathAddLineToPoint(path, NULL, x, y);
		CGPathAddLineToPoint(path, NULL, x - _left * ahwidth, y + _arrowSize.size.height - inset);
		CGPathAddLineToPoint(path, NULL, x - awidth, y);
	}
	//bottom left
	x = minX;
	CGPathAddLineToPoint(path, NULL, x + radius, y);
	CGPathAddCurveToPoint(path, NULL, x, y, x, y, x, y - radius);
	y = minY;
	if (left) {
		y += CGRectGetMaxY(_arrowSize) - 2 * inset;
		CGPathAddLineToPoint(path, NULL, x, y);
		CGPathAddLineToPoint(path, NULL, x - _arrowSize.size.width + inset, y - _top * ahheight);
		CGPathAddLineToPoint(path, NULL, x, y - aheight);
	}
	CGPathCloseSubpath(path);
	UIBezierPath *bpath = [UIBezierPath bezierPathWithCGPath:path];
	CGPathRelease(path);
	return bpath;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat inset = 0;
	if (_bubbleBorderWidth) {
		CGContextSaveGState(context);
		CGContextSetLineJoin(context, kCGLineJoinBevel);
		CGPathRef path = [self bubblePathInset:inset].CGPath;
		CGContextAddPath(context, path);
		CGContextSetFillColorWithColor(context, _bubbleBorderColor.CGColor);
		CGContextDrawPath(context, kCGPathFill);
		CGContextRestoreGState(context);
		inset += _bubbleBorderWidth - .5f;
	}
	
	inset += _whiteInset;
	if (inset) {
		CGContextSaveGState(context);
		CGPathRef path = [self bubblePathInset:inset].CGPath;
		CGContextAddPath(context, path);
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextDrawPath(context, kCGPathFill);
		CGContextRestoreGState(context);
		inset += 1;
	}
	
	CGContextSaveGState(context);
	CGPathRef path = [self bubblePathInset:inset].CGPath;
	CGContextAddPath(context, path);
	CGContextClip(context);
	
	if (_colors && _locations) {
		CGFloat locations[_locations.count];
		for (int i = 0; i < _locations.count; i++) {
			locations[i] = [_locations[i] floatValue];
		}
		NSMutableArray *colors = [NSMutableArray array];
		for (int i = 0; i < _colors.count; i++) {
			colors[i] = (__bridge id)[_colors[i] CGColor];
		}
		CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0, CGRectGetMinY(rect)), CGPointMake(0, CGRectGetMaxY(rect)), 0);
		CGGradientRelease(gradient);
	}
	CGContextRestoreGState(context);
	[super drawRect:rect];
}

@end
