//
//  PDFView.m
//  pdfViewExp
//
//  Created by Wenzhong Zhang on 2014-10-20.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import "PDFView.h"

static void op_MP (CGPDFScannerRef s, void *info) {
    const char *name;
    if (!CGPDFScannerPopName(s, &name))
        return;
    printf("MP /%s\n", name);
}

@implementation PDFView {
    CGPDFDocumentRef _pdfDocument;
    CGPDFPageRef page;
    CGAffineTransform pdfTransform;
    CGContextRef currentContext;
    CGRect pageRect;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isFront = YES;
        scaleFactor = 2.f;
        [self updateFrontBack];
    }
    return self;
}

-(void)drawInContext:(CGContextRef)context {
    CGContextTranslateCTM(context, transX, transY);
    // PDF page drawing expects a Lower-Left coordinate system, so we flip the coordinate system
    CGContextScaleCTM(context, scaleFactor, -scaleFactor);
    page = CGPDFDocumentGetPage(self.pdfDocument, 1);
    // We're about to modify the context CTM to draw the PDF page
    // where we want it, so save the graphics state in case we
    // want to do more drawing
    CGContextSaveGState(context);
    // CGPDFPageGetDrawingTransform provides an easy way to get the transform for a PDF page. It will scale down to fit, including any
    // base rotations necessary to display the PDF page correctly.
    pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.bounds, 0, true);
    // And apply the transform.
    CGContextConcatCTM(context, pdfTransform);
    // Finally, we draw the page and restore the graphics state for further manipulations!
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    aspectRatio = pageRect.size.height / pageRect.size.width;
    pageWidth = self.frame.size.width;
    pageHeight = pageWidth * aspectRatio;
    NSLog(@"%s\nx:%f y:%f w:%f h:%f\nscale:%f PDFw:%f h:%f", __PRETTY_FUNCTION__, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, scaleFactor, pageWidth, pageHeight);
}

- (BOOL)containsPoint:(CGPoint)point onPath:(UIBezierPath *)path inFillArea:(BOOL)inFill {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef cgPath = path.CGPath;
    BOOL isHit = NO;
    NSLog(@"In hit detection");
    // Determine the drawing mode to use. Default to
    // detecting hits on the stroked portion of the path.
    CGPathDrawingMode mode = kCGPathStroke;
    if (inFill)
    {
        // Look for hits in the fill area of the path instead.
        if (path.usesEvenOddFillRule)
            mode = kCGPathEOFill;
        else
            mode = kCGPathFill;
    }
    
    // Save the graphics state so that the path can be
    // removed later.
    CGContextSaveGState(context);
    CGContextAddPath(context, cgPath);
    
    // Do the hit detection.
    isHit = CGContextPathContainsPoint(context, point, mode);
    
    CGContextRestoreGState(context);
    
    return isHit;
}

- (CGPDFDocumentRef)pdfDocument {
    if (_pdfDocument == NULL)
    {
        CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("NewBody2.ai"), NULL, NULL);
        _pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
        CFRelease(pdfURL);
    }
    return _pdfDocument;
}

- (void)doWork {
    CGPDFOperatorTableRef myTable = CGPDFOperatorTableCreate();
    CGPDFOperatorTableSetCallback (myTable, "MP", &op_MP);
    //CGPDFOperatorTableSetCallback (myTable, "DP", &op_DP);
    //CGPDFOperatorTableSetCallback (myTable, "BMC", &op_BMC);
    //CGPDFOperatorTableSetCallback (myTable, "BDC", &op_BDC);
    //CGPDFOperatorTableSetCallback (myTable, "EMC", &op_EMC);
    size_t k;
    //CGPDFPageRef myPage;
    CGPDFScannerRef myScanner;
    CGPDFContentStreamRef myContentStream;
    
    size_t numOfPages = CGPDFDocumentGetNumberOfPages (_pdfDocument);// 1
    for (k = 0; k < numOfPages; k++) {
        //myPage = CGPDFDocumentGetPage (_pdfDocument, k + 1 );// 2
        myContentStream = CGPDFContentStreamCreateWithPage (page);// 3
        myScanner = CGPDFScannerCreate (myContentStream, myTable, NULL);// 4
        CGPDFScannerScan (myScanner);// 5
        CGPDFPageRelease (page);// 6
        CGPDFScannerRelease (myScanner);// 7
        CGPDFContentStreamRelease (myContentStream);// 8
    }
    CGPDFOperatorTableRelease(myTable);
}

- (void)respondToUserTouchEvents:(CGPoint) location {
    NSLog(@"location %f, %f", location.x, location.y);
}

- (void)flipFrontBack {
    self.isFront = !self.isFront;
    NSString *aString = self.isFront? @"showing front body" : @"showing back body";
    NSString *bString = [NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, aString];
    NSLog(@"%@", bString);
    [self updateFrontBack];
}

- (void)updateFrontBack {
    transY = 0.5f * (self.frame.size.height + pageHeight) * scaleFactor;
    if (self.isFront) {
        transX = 0;
    } else {
        transX = -scaleFactor * self.frame.size.width * 0.5f;
    }
    [self setNeedsDisplay];
}

- (void)setScale:(CGFloat)scale {
    scaleFactor = scale;
    [self setNeedsDisplay];
}

- (void)setTranslationX:(CGFloat)x translationY:(CGFloat)y {
    transX = x;
    transY = y;
    [self setNeedsDisplay];
}

- (void)hopOnBicep {
    // Entire area (512 384) for (1024 768)
    // disp area: (xywh in pt: 129 70 80 162.5)
    // 129 / 512 * 414 (for iPhone 6+, 375 for iPhone 6)
    // click area: (162.5 112 11 36)
    // scaleFactor = 4.5f;
    bicepX = 258.f / pageRect.size.width * self.frame.size.width;
    bicepY = 140.f / pageRect.size.height * self.frame.size.height;
    NSLog(@"bicepY:%f", bicepY);
    transX = -(scaleFactor * bicepX);
    transY = (0.5f * (self.frame.size.height + pageHeight) - bicepY) * scaleFactor;
    [self setNeedsDisplay];
}

- (void)hopOnTricep {
    transX = scaleFactor * 100.f;
    transY = scaleFactor * 200.f;
    [self setNeedsDisplay];
}

- (void)recognizePanGesture {
    // NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)resetView {
    scaleFactor = 2.f;
    [self updateFrontBack];
    NSString *statusString = [NSString stringWithFormat:@"%s x:%f y:%f w:%f h:%f", __PRETTY_FUNCTION__, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height];
    NSLog(@"Status: %@", statusString);
    [self setNeedsDisplay];
}

-(void)restoreScale {
    // Called on orientation change.
    // We need to zoom out and basically reset the scrollview to look right in two-page spline view.
    CGFloat yScale = self.frame.size.height/pageRect.size.height;
    CGFloat xScale = self.frame.size.width/pageRect.size.width;
    scaleFactor = MIN( xScale, yScale );
    NSLog(@"%s xScale:%f, yScale:%f, scaleFactor:%f.", __PRETTY_FUNCTION__, xScale, yScale,scaleFactor);
    [self setNeedsDisplay];
}

- (void)dealloc {
    CGPDFDocumentRelease(_pdfDocument);
}

@end
