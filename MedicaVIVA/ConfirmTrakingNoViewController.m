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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"EMS = %@",self.emsString);
    
    NSString *string = [NSString stringWithFormat:@"%@ \n\nกับ \n\n%@",self.productString,self.emsString];
    self.detailTextView.text = string;
    
}




- (IBAction)cancelButtonTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate dissMissConfirmTrack];
    
}



- (IBAction)okButtonTapped:(id)sender{
    
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager    = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //[manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    
    NSString *public_key = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"] objectForKey:@"public_key"];

    NSMutableDictionary *order_data = [[NSMutableDictionary alloc] init];
    
    [order_data setValue:self.orderData[@"id"] forKey:@"id"];
    [order_data setValue:self.emsString forKey:@"ship_tracking"];
    [order_data setValue:self.orderData[@"status"] forKey:@"status"];
    [order_data setValue:self.orderData[@"status"] forKey:@"old_status"];
    [order_data setValue:self.orderData[@"invoice_no"] forKey:@"invoice_no"];
    [order_data setValue:self.orderData[@"employee_id"] forKey:@"employee_id"];
    
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    parameters[@"api_key"]  = API_KEY;
    parameters[@"public_key"] = public_key;
    parameters[@"user_id"] = [UD objectForKey:@"userInfo"][@"id"];
    parameters[@"order_data"] = order_data;
    
    [manager POST:[MOBILEAPI stringByAppendingString:UPDATESHIP] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"success! %@", responseObject);
        //if ([res[@"status"] isEqualToString:@"true"]) {
            
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.delegate addConfirmTrack:self.orderData[@"invoice_no"]];
            
        //}
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        
    }];
   
    
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event //here enable the touch
{
    // get touch event
    
    
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
