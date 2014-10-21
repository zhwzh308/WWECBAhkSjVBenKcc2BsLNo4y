//
//  ViewController.m
//  pdfViewExp
//
//  Created by Wenzhong Zhang on 2014-10-20.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import "ViewController.h"
#import "PDFView.h"
#import "NumberPadDoneBtn.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet PDFView *myPDFView;
@property (weak, nonatomic) IBOutlet UISlider *scaleFactor;
@property (weak, nonatomic) IBOutlet UITextField *boxX;
@property (weak, nonatomic) IBOutlet UITextField *boxY;
@property (weak, nonatomic) IBOutlet UITextField *scaleFactorText;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;
@property (weak, nonatomic) IBOutlet UIButton *bicepButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panScreenGesture;

@end

@implementation ViewController {
    UITextField *currentField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _boxX.delegate = _boxY.delegate = self;
    
    UIToolbar *numberPadToolBar= [[UIToolbar alloc]
                                  initWithFrame:CGRectMake(0, 0, 320.f, 44.f)];
    numberPadToolBar.items = [NSArray arrayWithObjects:
                              [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(numberPadDone)], nil];
    self.boxX.inputAccessoryView = numberPadToolBar;
    
    self.scaleFactorText.inputAccessoryView = [[NumberPadDoneBtn alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    currentField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    currentField = textField;
    [textField resignFirstResponder];
    return YES;
}

- (void)cancelNumberPad {
    [currentField resignFirstResponder];
}

- (void)numberPadDone {
    [currentField resignFirstResponder];
}

- (void)updateBoxes {
    // update all UI elements
    self.scaleFactorText.text = [NSString stringWithFormat:@"%f", self.myPDFView->scaleFactor];
    self.boxX.text = [NSString stringWithFormat:@"%f", self.myPDFView->transX];
    self.boxY.text = [NSString stringWithFormat:@"%f", self.myPDFView->transY];
    self.scaleFactor.value = self.myPDFView->scaleFactor / 10.f;
}

- (IBAction)scalePDF:(UISlider *)sender {
    [self.myPDFView setScale:(sender.value * 10.f)];
    self.scaleFactorText.text = [NSString stringWithFormat:@"%f", self.myPDFView->scaleFactor];
    self.boxX.text = [NSString stringWithFormat:@"%f", self.myPDFView->transX];
    self.boxY.text = [NSString stringWithFormat:@"%f", self.myPDFView->transY];
}

- (IBAction)updateX:(UITextField *)sender {
    [self.myPDFView setTranslationX:[self.boxX.text floatValue] translationY:self.myPDFView->transY];
    self.scaleFactorText.text = [NSString stringWithFormat:@"%f", self.myPDFView->scaleFactor];
    self.boxY.text = [NSString stringWithFormat:@"%f", self.myPDFView->transY];
    self.scaleFactor.value = self.myPDFView->scaleFactor / 10.f;
}

- (IBAction)updateY:(UITextField *)sender {
    [self.myPDFView setTranslationX:self.myPDFView->transX translationY:[self.boxY.text floatValue]];
    self.scaleFactorText.text = [NSString stringWithFormat:@"%f", self.myPDFView->scaleFactor];
    self.boxX.text = [NSString stringWithFormat:@"%f", self.myPDFView->transX];
    self.scaleFactor.value = self.myPDFView->scaleFactor / 10.f;
}

- (IBAction)updateScaling:(UITextField *)sender {
    [self.myPDFView setScale:([sender.text floatValue])];
    self.boxX.text = [NSString stringWithFormat:@"%f", self.myPDFView->transX];
    self.boxY.text = [NSString stringWithFormat:@"%f", self.myPDFView->transY];
    self.scaleFactor.value = self.myPDFView->scaleFactor / 10.f;
}

- (IBAction)flipSide:(UIButton *)sender {
    [self.myPDFView flipFrontBack];
}

- (IBAction)hopOnBicep:(UIButton *)sender {
    [self.myPDFView hopOnBicep];
}

- (IBAction)panGestureAction:(UIPanGestureRecognizer *)sender {
    [self.myPDFView recognizePanGesture];
}

- (IBAction)resetPDFView:(id)sender {
    [self.myPDFView resetView];
    [self updateBoxes];
}

- (IBAction)refreshUIElements:(UIButton *)sender {
    [self updateBoxes];
}

@end
