//
//  OrderTableViewCell.h
//  MedicaVIVA
//
//  Created by Chakrit on 2/22/2560 BE.
//  Copyright © 2560 qoofhouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface OrderTableViewCell : UITableViewCell

@property (nonatomic , weak) IBOutlet UILabel  *invoiceNoLabel;
@property (nonatomic , weak) IBOutlet UILabel  *trackNoLabel;
@property (nonatomic , weak) IBOutlet UIButton *addTrackingNumberButton;
@property (nonatomic , weak) IBOutlet UIButton *statusButton;

@property (nonatomic , weak) IBOutlet UILabel *productLabel;
@property (nonatomic , weak) IBOutlet UILabel *amountLabel;
@property (nonatomic , weak) IBOutlet BEMCheckBox *checkBox;

@property (nonatomic , weak) IBOutlet UILabel *addressTextView;

@property (nonatomic , weak) IBOutlet UITextView *noteTextView;



@end
