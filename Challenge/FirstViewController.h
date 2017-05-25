//
//  ViewController.h
//  dubdub iOS Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageLoader;

@interface FirstViewController : UIViewController {
    ImageLoader *imageLoader;
    __weak UIImageView *imageView;
}
@property (nonatomic) ImageLoader *imageLoader;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)showImage:(id)sender;

@end

