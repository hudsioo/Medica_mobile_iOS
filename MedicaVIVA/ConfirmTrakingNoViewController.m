//
//  ConfirmTrakingNoViewController.m
//  MedicaVIVA
//
//  Created by Chakrit on 2/23/2560 BE.
//  Copyright © 2560 qoofhouse. All rights reserved.
//

#import "ConfirmTrakingNoViewController.h"

@interface ConfirmTrakingNoViewController ()

@end

@implementation ConfirmTrakingNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)cancelButtonTapped:(id)sender{
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.delegate dissMissConfirmTrack];
    
}



- (IBAction)okButtonTapped:(id)sender{
    

   
    
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event //here enable the touch
{
    // get touch event
    
    /*
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint touchLocation = [touch locationInView:self.view];
    if (CGRectContainsPoint(self.myView.frame, touchLocation))
    {
        NSLog(@"touched");
        [self.view endEditing:YES];
    }else{
        NSLog(@"outside");
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate dissMissConfirmTrack];
    }
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
