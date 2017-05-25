//
//  SecondViewController.m
//  dubdub iOS Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize inputTextField;
@synthesize outputTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)sortArrayAndRemoveDuplicates:(id)sender {
    // 1. eliminate non-numeric characters, leading commas, trailing commas and white spaces
    NSString *inputString0 = [[inputTextField text] stringByReplacingOccurrencesOfString:@"\\s|[^\\d,]|\\A,+|,+\\Z" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [[inputTextField text] length])];
    // 2. eliminate extra commas
    NSString *inputString1 = [inputString0 stringByReplacingOccurrencesOfString:@",+" withString:@"," options:NSRegularExpressionSearch range:NSMakeRange(0, [inputString0 length])];
    // 3. construct an array with input as instructed
    NSArray *inputArray = [inputString1 componentsSeparatedByString:@","];
    // 4. eliminate duplicates
    NSSet *outputSet = [[NSSet alloc] initWithArray:inputArray];
    NSArray *outputArray0 = [outputSet allObjects];
    // 5. sort array
    NSArray *outputArray1 = [outputArray0 sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    // NSLog(@"%@", outputArray1);
    // 6. construct output
    [outputTextField setText: [outputArray1 componentsJoinedByString:@", "]];
}

@end
