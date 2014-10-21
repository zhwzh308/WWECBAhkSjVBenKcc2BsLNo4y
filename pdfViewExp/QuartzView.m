//
//  QuartzView.m
//  pdfViewExp
//
//  Created by Wenzhong Zhang on 2014-10-20.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import "QuartzView.h"

@implementation QuartzView

- (void)drawRect:(CGRect)rect {
    [self drawInContext:UIGraphicsGetCurrentContext()];
}


- (void)drawInContext:(CGContextRef)context {
    // Let's do nothing
}

@end
