//
//  ViewController.m
//  dubdub iOS Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import "FirstViewController.h"
#import "Challenge-Swift.h"

#define IMAGE_URL_STRING @"http://www.arch2o.com/wp-content/uploads/2015/03/Arch2O-Portraits-Sergio-Lopez-04-750x400.jpg"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize imageView;
@synthesize imageLoader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageLoader = [[ImageLoader alloc] init];
}

- (IBAction)showImage:(id)sender {
    [(UIButton *)sender setEnabled:NO];
    // NSLog(@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    [imageLoader loadImageDataWithUrlString:IMAGE_URL_STRING completion:^(NSData * _Nullable data, NSURLResponse * _Nullable urlResponse, NSError * _Nullable error) {
        if (error) {
            // ensure to run in main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [(UIButton *)sender setEnabled:YES];
                }];
                [alertController addAction:defaultAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            // NSLog(@"%@", [error localizedDescription]);
        } else {
            // no heavy tasks on the main queue, e.g., image manipulations.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [[UIImage alloc] initWithData:data];
                // any image manipulations, or anything...
                dispatch_async(dispatch_get_main_queue(), ^{
                    // ensure UI operations on main the thread
                    [imageView setImage:image];
                    [(UIButton *)sender setEnabled:YES];
                });
            });
        }
    }];
}

@end
