//
//  ScanningViewController.m
//  barcode-checkin
//
//  Created by HUGE | Micah Acinapura on 10/31/14.
//  Copyright (c) 2014 JaM. All rights reserved.
//

#import "ScanningViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanningViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
}
@end

@implementation ScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.hidesWhenStopped = YES;
    _spinner.center = self.view.center;
    [_spinner stopAnimating];

    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [self.view addSubview:_spinner];
    
    [_session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            [self.spinner startAnimating];
            [self checkin:detectionString];
            break;
        }
    }
    
    [_session stopRunning];
}

- (void)checkin:(NSString *)detectedNumber {
    NSString *urlString = [NSString stringWithFormat:@"http://bikeracing.com/posttome?licenceNumber=%@",detectedNumber];

//    NSString *urlString = [NSString stringWithFormat:@"http://bikeracing.com/posttome"];

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];


//    req.HTTPMethod = @"POST";
//    NSString *postString = [NSString stringWithFormat:@"licenceNumber=%@",detectedNumber];
//    req.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];

    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:req queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connection errr");
        }  else if (data.length < 1) {
            NSLog(@"data errr");
        } else {
            NSLog(@"checked in racer");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:detectedNumber forKey:@"detectedId"];
            [defaults synchronize];
            [self.spinner stopAnimating];

            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"scanning view gone");
            }];
            
        }
    }];
}

@end
