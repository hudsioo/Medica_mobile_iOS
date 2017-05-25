//
//  OrderViewController.m
//  MedicaVIVA
//
//  Created by Chakrit on 2/13/2560 BE.
//  Copyright © 2560 qoofhouse. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderTableViewCell.h"
#import "ConfirmTrakingNoViewController.h"
#import "ProfileViewController.h"
#import <RSBarcodes.h>

@interface OrderViewController () <UITableViewDelegate , UITableViewDelegate , ConfirmTrackDelegate , BEMCheckBoxDelegate>{
    __weak UIView *_staticView;
    
    UIView* backView;
    
    NSInteger checkSum;
    NSString *qrCodeString;
    NSString *emsCodeString;
}


@property (nonatomic , weak) IBOutlet UITableView *tableView;
@property (nonatomic , weak) IBOutlet UIButton *confirmButtom;
@property (nonatomic, strong) RSScannerViewController *scanner;


@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"รายละเอียด";
    
    UIView *staticView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.bounds.size.height-40, self.tableView.bounds.size.width, 40)];
    staticView.backgroundColor = [UIColor greenColor];
    //[self.tableView addSubview:staticView];
    _staticView = staticView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    
    backView = [[UIView alloc] initWithFrame:self.view.frame];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    UIImage *image = [[UIImage imageNamed:@"barcode-1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonTapped)];
    self.navigationItem.rightBarButtonItem = button;
    
    checkSum = 0;
   
}

- (void)menuButtonTapped{
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
            self.data = res[@"data"];
            [self.tableView reloadData];
        }
        
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        [SVProgressHUD dismiss];
    }];
    
    
    
}

- (void)dissMissConfirmTrack{
    [backView removeFromSuperview];
}
- (void)addConfirmTrack:(NSString *)productCode{
    [self getOrder:productCode];
    [backView removeFromSuperview];
}


- (IBAction)addtrackingNoButtonTapped:(id)sender{
    
    emsCodeString = @"";
    self.scanner = [[RSScannerViewController alloc] initWithCornerView:YES
                                                           controlView:YES
                                                       barcodesHandler:^(NSArray *barcodeObjects) {
                                                           if (barcodeObjects.count > 0) {
                                                               [barcodeObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       AVMetadataMachineReadableCodeObject *code = obj;
                                                                       
                                                                       
                                                                       
                                                                       emsCodeString = [code stringValue];
                                                                       [self playSound];
                                                                       [self.scanner stopRunning];
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self.scanner dismissViewControllerAnimated:YES completion:^{
                                                                               [self confirmEMS:emsCodeString];
                                                                           }];
                                                                           
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

- (void)confirmEMS:(NSString *)emsString{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConfirmTrakingNoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmTrakingNoViewController"];
    vc.delegate = self;
    vc.emsString = emsString;
    vc.productString = self.data[@"invoice_no"];
    vc.orderData = self.data;
    
    self.modalPresentationStyle = UIModalPresentationPopover;
    [self.navigationController.view insertSubview:backView atIndex:2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        
    });

    
}



- (IBAction)confirmButtonTapped:(id)sender{
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager    = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //[manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    
    NSString *public_key = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"] objectForKey:@"public_key"];
    
    NSMutableDictionary *order_data = [[NSMutableDictionary alloc] init];
    
    [order_data setValue:self.data[@"id"] forKey:@"id"];
    [order_data setValue:self.data forKey:@"ship_tracking"];
    [order_data setValue:@"3" forKey:@"status"];
    [order_data setValue:self.data[@"status"] forKey:@"old_status"];
    [order_data setValue:self.data[@"invoice_no"] forKey:@"invoice_no"];
    [order_data setValue:self.data[@"employee_id"] forKey:@"employee_id"];
    
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    parameters[@"api_key"]  = API_KEY;
    parameters[@"public_key"] = public_key;
    parameters[@"user_id"] = [UD objectForKey:@"userInfo"][@"id"];
    parameters[@"order_data"] = order_data;
    
    [manager POST:[MOBILEAPI stringByAppendingString:UPDATESHIP] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"success! %@", responseObject);
    
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _staticView.transform = CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this is needed to prevent cells from being displayed above our static view
   // [self.tableView bringSubviewToFront:_staticView];
}


#pragma mark - Table DataSource & Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 1) {
        return [self.data[@"products_used"] count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return 30.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 170.0f;
    }else if (indexPath.section == 3){
        return 160.0f;
    }
        
        
    return 80.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //put your values, this is part of my code
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80.0f)];
    
   
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    label.backgroundColor = [UIColor colorWithRed:0.93 green:0.67 blue:0.27 alpha:1.0];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    
    
    
    if (section == 0) {
        label.text = @"    1.ข้อมูลคำสั่งซื้อ  ";
    }else if(section == 1){
        label.text = @"    2.สินค้า  ";
    }else if(section == 2){
        label.text = @"    3.ข้อมูลที่อยู่จัดส่ง  ";
    }else if(section == 3){
        label.text = @"    4.ข้อมูลอื่น ๆ  ";
    }else{
        
    }
    
    CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    CGFloat strikeWidth = textSize.width;
    CGRect frame = label.frame;
    frame.size.width = strikeWidth;
    
    if (section == 0) {
        frame.origin.y = 10;
        label.frame = frame;
        [self drawRibbonAfterLabel:label moveYPosition:10];
    }else{
        label.frame = frame;
        [self drawRibbonAfterLabel:label moveYPosition:0];
    }
    
    
    
   

    
    
    return view;
}
- (void)drawRibbonAfterLabel:(UILabel *)label moveYPosition:(NSInteger) y{
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0f, 0.0f);
    CGPathAddLineToPoint(path, NULL, label.frame.size.width, label.frame.origin.y - y);
    CGPathAddLineToPoint(path, NULL, label.frame.size.width + 20, label.frame.origin.y - y);
    CGPathAddLineToPoint(path, NULL, label.frame.size.width, label.frame.size.height/2);
    CGPathAddLineToPoint(path, NULL, label.frame.size.width + 20, label.frame.size.height);
    CGPathAddLineToPoint(path, NULL, 0.0f, label.frame.size.height);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:[[UIColor colorWithRed:0.93 green:0.67 blue:0.27 alpha:1.0] CGColor]];
    [shapeLayer setBounds:CGRectMake(0.0f, 0.0f, 160.0f, 480)];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [[label layer] addSublayer:shapeLayer];
    
    CGPathRelease(path);
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10.0f)];
    //view.backgroundColor = [UIColor grayColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.50f)];
    line.backgroundColor = [UIColor grayColor];
    [view addSubview:line];
    

    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderTableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"section1"];
        if (cell == nil) {
            cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section1"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        cell.invoiceNoLabel.text = self.data[@"invoice_no"];
        cell.trackNoLabel.text = self.data[@"ship_tracking"];
        
        if ([self.data[@"status"] isEqualToString:@"1"]) {
            [cell.statusButton setTitle:@"เตรียมสินค้า" forState:UIControlStateNormal];
            [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.73 green:0.49 blue:0.84 alpha:1.0]]; // ม่วง
        }else if ([self.data[@"status"] isEqualToString:@"2"]) {
            [cell.statusButton setTitle:@"รอจัดส่ง" forState:UIControlStateNormal];
            [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.94 green:0.68 blue:0.31 alpha:1.0]]; // ส้ม
        }
        else if ([self.data[@"status"] isEqualToString:@"3"]) {
            [cell.statusButton setTitle:@"ส่งสินค้าแล้ว" forState:UIControlStateNormal];
            [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.38 green:0.77 blue:0.38 alpha:1.0]]; // เขียว
        }
        
        //[cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1.0]]; // เทา
        
        
        
        
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"section2"];
        if (cell == nil) {
            cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section2"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        cell.productLabel.text = self.data[@"products_used"][indexPath.row][@"product_name"];
        cell.amountLabel.text = [NSString stringWithFormat:@"%@ %@",self.data[@"products_used"][indexPath.row][@"cut_stock_amount"],self.data[@"products_used"][indexPath.row][@"product_unit_name"]];
        //[cell.checkBox addTarget:self action:@selector(checkProduct:) forControlEvents:UIControlEventTouchUpInside];
        cell.checkBox.delegate = self;
    }
    else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"section3"];
        if (cell == nil) {
            cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section3"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        NSError *jsonError;
        NSData *objectData = [self.data[@"ship_customer"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        NSData *addressData = [json[@"address"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *addressJson = [NSJSONSerialization JSONObjectWithData:addressData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        
        NSString *showString = [NSString stringWithFormat:@"%@ \r%@ \rเบอร์ติดต่อ : %@",json[@"name"],addressJson[@"address"],json[@"phone"]];
        cell.addressTextView.text = showString;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"section4"];
        if (cell == nil) {
            cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section4"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        [cell.noteTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
        [cell.noteTextView.layer setBorderWidth:2.0];
        cell.noteTextView.layer.cornerRadius = 5;
        cell.noteTextView.clipsToBounds = YES;
        
        cell.noteTextView.text = self.data[@"note"];
    }

    
    return cell;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox{
    
    if (checkBox.on) {
        checkSum++;
    }else{
        checkSum--;
    }
    
    if (checkSum == [self.data[@"products_used"] count]) {
        self.confirmButtom.enabled = YES;
    }else{
        self.confirmButtom.enabled = NO;
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
