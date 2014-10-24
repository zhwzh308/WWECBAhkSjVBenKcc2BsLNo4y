//
//  PDFView.h
//  pdfViewExp
//
//  Created by Wenzhong Zhang on 2014-10-20.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzView.h"

@interface PDFView : QuartzView {
    @public
    CGFloat scaleFactor, transX, transY, bicepX, bicepY, pageWidth, pageHeight, aspectRatio;
}
@property BOOL isFront;

- (void)respondToUserTouchEvents:(CGPoint) location;
- (void)flipFrontBack;
- (void)setScale:(CGFloat)scale;
- (void)setTranslationX:(CGFloat)x translationY:(CGFloat)y;
- (void)hopOnBicep;
- (void)recognizePanGesture;
- (void)resetView;
- (void)restoreScale;

@end
