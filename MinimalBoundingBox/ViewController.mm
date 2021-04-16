//
//  ViewController.m
//  MinimalBoundingBox
//
//  Created by Alexander Kormanovsky on 16.04.2021.
//

#import "ViewController.h"
#import "DrawingView.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet DrawingView *drawingView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.drawingView calculateMinimalBoundingBox];
}

- (IBAction)minimalBoundingBoxButtonTouchUpInside:(UIButton *)sender
{
    [self.drawingView calculateMinimalBoundingBox];
}

@end
