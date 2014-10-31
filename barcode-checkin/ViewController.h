//
//  ViewController.h
//  barcode-checkin
//
//  Created by HUGE | Micah Acinapura on 10/31/14.
//  Copyright (c) 2014 JaM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *checkinButton;
@property (nonatomic, weak) IBOutlet UILabel *licenceNumber;

- (IBAction)showScanView:(id)sender;

@end

