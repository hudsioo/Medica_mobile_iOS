//
//  ConfirmTrakingNoViewController.h
//  MedicaVIVA
//
//  Created by Chakrit on 2/23/2560 BE.
//  Copyright © 2560 qoofhouse. All rights reserved.
//

#import "ViewController.h"

@protocol ConfirmTrackDelegate <NSObject>

- (void)dissMissConfirmTrack;
- (void)addConfirmTrack:(NSString *)productCode;

@end

@interface ConfirmTrakingNoViewController : UIViewController


@property (nonatomic , strong) id<ConfirmTrackDelegate> delegate;

@property (nonatomic , weak) IBOutlet UILabel *titleLabel;
@property (nonatomic , weak) IBOutlet UIView *myView;
@property (nonatomic , weak) IBOutlet UIButton *okButton;
@property (nonatomic , weak) IBOutlet UIButton *closeButton;
@property (nonatomic , weak) IBOutlet UITextView *detailTextView;

@property (nonatomic , copy) NSString *productString;
@property (nonatomic , copy) NSString *emsString;
@property (nonatomic , strong) NSDictionary *orderData;

@end
