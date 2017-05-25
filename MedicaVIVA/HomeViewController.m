//
//  HomeViewController.m
//  MedicaVIVA
//
//  Created by Chakrit on 2/8/2560 BE.
//  Copyright © 2560 qoofhouse. All rights reserved.
//

#import "HomeViewController.h"
#import <RSBarcodes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "OrderViewController.h"

@interface HomeViewController (){
    
    NSString *qrCodeString;
    
}
@property (nonatomic , weak) IBOutlet UIView *previewView;
@property (nonatomic, strong) RSScannerViewController *scanner;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(Logout:)] ;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    

   
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopRunning];
    [super viewWillDisappear:animated];
}

- (void)Logout:(id)sender{
    AFHTTPSessionManager *manager    = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer        = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSString *public_key = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"] objectForKey:@"public_key"];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];

    parameters[@"api_key"]  = API_KEY;
    parameters[@"public_key"] = public_key;
    parameters[@"user_id"] = [UD objectForKey:@"userInfo"][@"id"];
    
    [manager POST:[USERSAPI stringByAppendingString:SIGNOUT] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary * res = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        
        if ([res[@"status"] isEqualToString:@"true"]) {
            
            [UD removeObjectForKey:@"userInfo"];
            [UD synchronize];
            [SVProgressHUD dismiss];
        
            [self dismissViewControllerAnimated:YES completion:nil];
                
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        
    }];
    
}

- (IBAction)showScan:(id)sender{
    
    qrCodeString = @"";
    self.scanner = [[RSScannerViewController alloc] initWithCornerView:YES
                                                      controlView:YES
                                                  barcodesHandler:^(NSArray *barcodeObjects) {
                                                      if (barcodeObjects.count > 0) {
                                                          [barcodeObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  AVMetadataMachineReadableCodeObject *code = obj;
                                                                  
                                                                  
                                                                  
                                                                  qrCodeString = [code stringValue];
                                                                  [self playSound];
                                                                  [self getOrder:qrCodeString];
                                                                  [self.scanner stopRunning];
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [self.scanner dismissViewControllerAnimated:YES completion:nil];
                                                                      
                                                                  });
                                                              });
                                                          }];
                                                      }
                                                      
                                                  }
               
                                          preferredCameraPosition:AVCaptureDevicePositionBack];
    
    [self.scanner setIsButtonBordersVisible:YES];
    [self.scanner setStopOnFirst:YES];
    [self presentViewController:self.scanner animated:true completion:nil];
     
    

}

-(void) playSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}



- (void)getOrder:(NSString *)invoice_no {
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager    = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer        = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    
    NSString *public_key = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"] objectForKey:@"public_key"];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    parameters[@"api_key"]  = API_KEY;
    parameters[@"public_key"] = public_key;
    parameters[@"invoice_no"] = invoice_no;
    NSLog(@"invoice = %@",parameters);
    
    [manager POST:[MOBILEAPI stringByAppendingString:GETORDER] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary * res = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        NSLog(@"success! %@", res);
        
        if ([res[@"status"] isEqualToString:@"true"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            OrderViewController *orderViewController = [storyboard instantiateViewControllerWithIdentifier:@"OrderViewController"];
            orderViewController.data = res[@"data"];
            [self.navigationController pushViewController:orderViewController animated:YES];
        }
        
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        [SVProgressHUD dismiss];
    }];
    
    
    
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
