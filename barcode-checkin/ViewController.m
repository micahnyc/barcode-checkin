//
//  ViewController.m
//  barcode-checkin
//
//  Created by HUGE | Micah Acinapura on 10/31/14.
//  Copyright (c) 2014 JaM. All rights reserved.
//

#import "ViewController.h"
#import "ScanningViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"detectedId"];
    [defaults synchronize];

}


- (IBAction)showScanView:(id)sender {
    ScanningViewController * svc = [[ScanningViewController alloc] init];
    [self presentViewController:svc animated:YES completion:^{
        NSLog(@"show ing scanner view");
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *detectedId = [defaults valueForKey:@"detectedId"];
    if (detectedId) {
        self.licenceNumber.text = detectedId;
    } else {
        self.licenceNumber.text = @"No licence number detected";
    }
}

@end
