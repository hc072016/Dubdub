//
//  SecondViewController.h
//  dubdub iOS Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextField *outputTextField;

- (IBAction)sortArrayAndRemoveDuplicates:(id)sender;

@end
