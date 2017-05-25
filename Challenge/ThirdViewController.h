//
//  ThirdViewController.h
//  dubdub iOS Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OpenWeatherInfoLoader.h"

@interface ThirdViewController : UIViewController  <CLLocationManagerDelegate, OpenWeatherInfoLoaderDelegate> {
    OpenWeatherInfoLoader *weatherInfoLoader;
    CLLocationManager *locationManager;
    __weak UITextField *cityNameTextField;
    __weak UITextField *temperatureTextField;
    __weak UIButton *showWeatherInfoButton;
}
@property (nonatomic) OpenWeatherInfoLoader *weatherInfoLoader;
@property (nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *cityNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *temperatureTextField;
@property (weak, nonatomic) IBOutlet UIButton *showWeatherInfoButton;

- (IBAction)showWeatherInfo:(id)sender;

- (void)weatherInfoDidLoadWithWeatherInfo:(NSDictionary *)weatherInfo;
- (void)loadWeatherInfoDidFailWithError:(NSError *)error;

@end
