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
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isFront = YES;
        scaleFactor = 2.4f;
        // PDF is 1024x768 pt @2x. which is to say
        // 512 * 682.67 scale.
        transY = 512.0f * scaleFactor;
        if (self.isFront) {
            transX = 0;
        } else {
            // screen width 414 @2x, so 207 is a half.
            transX = -341.f * scaleFactor;
        }
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
    NSLog(@"%s scale:%f X:%f Y:%f",__PRETTY_FUNCTION__, scaleFactor, transX, transY);
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
    if (self.isFront) {
        transX = 0;
    } else {
        // screen width 414 @2x, so 207 is a half.
        transX = -207.f * scaleFactor;
    }
    [self setNeedsDisplay];
}

- (void)setScale:(CGFloat)scale {
    scaleFactor = scale;
    transY = 512.0f * scaleFactor;
    [self setNeedsDisplay];
}

- (void)setTranslationX:(CGFloat)x translationY:(CGFloat)y {
    transX = x;
    transY = y;
    [self setNeedsDisplay];
}

- (void)hopOnBicep {
    scaleFactor = 4.0f;
    transX = -scaleFactor * 105.f;
    transY = scaleFactor * 477.f;
    [self setNeedsDisplay];
}

- (void)hopOnTricep {
    transX = scaleFactor * 100.f;
    transY = scaleFactor * 200.f;
    [self setNeedsDisplay];
}

- (void)recognizePanGesture {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)resetView {
    scaleFactor = 2.4f;
    if (self.isFront) {
        transX = 0;
    } else {
        // screen width 414 @2x, so 207 is a half.
        transX = -207.f * scaleFactor;
    }
    transY = 512.f * scaleFactor;
    [self setNeedsDisplay];
}

- (void)dealloc {
    CGPDFDocumentRelease(_pdfDocument);
}

@end
