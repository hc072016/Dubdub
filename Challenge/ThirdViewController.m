//
//  ThirdViewController.m
//  dubdub iOS Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import "ThirdViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

@synthesize weatherInfoLoader;
@synthesize locationManager;
@synthesize cityNameTextField;
@synthesize temperatureTextField;
@synthesize showWeatherInfoButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)showWeatherInfo:(id)sender {
    [showWeatherInfoButton setEnabled:NO];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Permission Required" message:@"Requires permission to determine current location." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [(UIButton *)sender setEnabled:YES];
        }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        if (!locationManager) {
            [self setLocationManager:[[CLLocationManager alloc] init]];
            [locationManager setDelegate:self];
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }
        if (![CLLocationManager locationServicesEnabled]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Turn On Location Services in Settigns to  Determine Your Location" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [(UIButton *)sender setEnabled:YES];
            }];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            // To cancel a pending request
            [locationManager stopUpdatingLocation];
            // Calling this method while location services are already running does nothing
            [locationManager requestLocation];
        }
    }
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [locationManager stopUpdatingLocation];
    // Because it can take several seconds to return an initial location, the location manager typically delivers the previously cached location data immediately and then delivers more up-to-date location data as it becomes available. Therefore it is always a good idea to check the timestamp of any location object before taking any actions.
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = [location timestamp];
    NSTimeInterval timeInterval = [eventDate timeIntervalSinceNow];
    // 15 seconds are good enough for this app
    if (-timeInterval < 15.0) {
        // NSLog(@"latitude: %f, longitude: %f", location.coordinate.latitude, location.coordinate.longitude);
        if (!weatherInfoLoader) {
            [self setWeatherInfoLoader:[[OpenWeatherInfoLoader alloc] init]];
            [weatherInfoLoader setDelegate:self];
        }
        NSString *latitudeString = [[NSString alloc] initWithFormat:@"%f", location.coordinate.latitude];
        NSString *longitudeString = [[NSString alloc] initWithFormat:@"%f", location.coordinate.longitude];
        [weatherInfoLoader startDownloadWeatherInfoByLatitude:latitudeString longitude:longitudeString];
        
    } else {
        NSLog(@"Cached Location Data is being thrown away.");
        [showWeatherInfoButton setEnabled:YES];
        // [locationManager requestLocation];
        // or prompt the users to try again, or some other handling
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [locationManager stopUpdatingLocation];
    // NSLog(@"%@", [error localizedDescription]);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [showWeatherInfoButton setEnabled:YES];
    }];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - OpenWeatherInfoLoaderDelegate methods
- (void)weatherInfoDidLoadWithWeatherInfo:(NSDictionary *)weatherInfo {
    // NSLog(@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    NSString *cityName = nil;
    NSString *temperature = nil;
    id object;
    object = [weatherInfo valueForKey:@"name"];
    if ([object isKindOfClass:[NSString class]]) {
        cityName = (NSString *)object;
    }
    object = [weatherInfo valueForKeyPath:@"main.temp"];
    if ([object isKindOfClass:[NSNumber class]]) {
        temperature = [(NSNumber *)object stringValue];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cityName == nil || [cityName isEqualToString:@""] || temperature == nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Weather information does not contain particular information." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [showWeatherInfoButton setEnabled:YES];
            }];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [cityNameTextField setText:cityName];
            [temperatureTextField setText:temperature];
            [showWeatherInfoButton setEnabled:YES];
        }
    });
}

- (void)loadWeatherInfoDidFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [showWeatherInfoButton setEnabled:YES];
        }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
