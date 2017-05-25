//
//  ViewController.m
//  MedicaVIVA
//
//  Created by hudsioo on 2/8/2560 BE.
//  Copyright © 2560 qoofhouse. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"userInfo"] != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navigationViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self presentViewController:navigationViewController animated:YES completion:nil];
    }
    
}

- (IBAction)loginAction:(id)sender {
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager    = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer        = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    parameters[@"api_key"]  = API_KEY;
    parameters[@"username"] = self.usernameTF.text;
    parameters[@"password"] = self.passwordTF.text;
    parameters[@"push_key"] = @"";
    
    [manager POST:[MOBILEAPI stringByAppendingString:SIGNIN] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary * res = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        NSLog(@"success! %@", res);
        if ([res[@"status"] isEqualToString:@"true"]) {
            
            [UD setObject:res[@"data"] forKey:@"userInfo"];
            [UD synchronize];
            [SVProgressHUD dismiss];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navigationViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [self presentViewController:navigationViewController animated:YES completion:nil];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        
    }];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
