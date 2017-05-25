//
//  OpenWeatherInfoLoader.m
//  Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//

#import "OpenWeatherInfoLoader.h"

#define APP_ID @"d9ab1c71d78050145cc51dc33cfcf27f"
#define WEATHER_API @"http://api.openweathermap.org/data/2.5/weather"
#define UNIT @"metric"

@implementation OpenWeatherInfoLoader

@synthesize weatherData; // could implement some cache mechanism, or create a structure for weather data
@synthesize delegate;

- (void)startDownloadWeatherInfoByLatitude:(NSString *)latitude longitude:(NSString *)longitude {
    if (latitude == nil || [latitude isEqualToString:@""] || longitude == nil || [longitude isEqualToString:@""]) {
        // could do more to ensure about the latitude and longitude format. E.g., must be valid number and be in certain range...
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Invalid Latitude and Longitude Values.", NSLocalizedDescriptionKey, nil];
        NSError *error = [[NSError alloc] initWithDomain: @"Challenge.WeatherLoadingError" code:1 userInfo:userInfo];
        [delegate loadWeatherInfoDidFailWithError:error];
    } else {
        NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithString:WEATHER_API];
        if (!urlComponents) {
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Invalid URL.", NSLocalizedDescriptionKey, nil];
            NSError *error = [[NSError alloc] initWithDomain: @"Challenge.WeatherLoadingError" code:2 userInfo:userInfo];
            [delegate loadWeatherInfoDidFailWithError:error];
        } else {
            // @{@"lat" : latitude, @"lon" : longitude, @"units", UNIT, @"appid" : APP_ID};
            NSDictionary *parametersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:latitude, @"lat", longitude, @"lon", UNIT, @"units", APP_ID, @"appid", nil];
            NSMutableArray<NSURLQueryItem *> *queryItems = [[NSMutableArray alloc] initWithCapacity:[parametersDictionary count]];
            for (NSString *key in parametersDictionary) {
                NSURLQueryItem *urlQueryItem = [[NSURLQueryItem alloc] initWithName:key value:[parametersDictionary valueForKey:key]];
                [queryItems addObject:urlQueryItem];
            }
            [urlComponents setQueryItems:queryItems];
            NSURL *url = [urlComponents URL];
            // url should be valid, since urlComponents is valid
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
                if ([httpURLResponse statusCode] != 200) {
                    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Response Failure.", NSLocalizedDescriptionKey, nil];
                    NSError *error = [[NSError alloc] initWithDomain: @"Challenge.WeatherLoadingError" code:3 userInfo:userInfo];
                    [delegate loadWeatherInfoDidFailWithError:error];
                } else if (![[[response MIMEType] lowercaseString] isEqualToString:@"application/json"]) {
                    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Weather Data in Wrong Format.", NSLocalizedDescriptionKey, nil];
                    NSError *error = [[NSError alloc] initWithDomain: @"Challenge.WeatherLoadingError" code:4 userInfo:userInfo];
                    [delegate loadWeatherInfoDidFailWithError:error];
                } else {
                    NSError * jsonError = nil;
                    NSDictionary *json = nil;
                    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                    if ([object isKindOfClass:[NSDictionary class]] && !error) {
                        json = (NSDictionary *)object;
                    }
                    if (!json) {
                        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Can Not Parse Weather Data.", NSLocalizedDescriptionKey, nil];
                        NSError *error = [[NSError alloc] initWithDomain: @"Challenge.WeatherLoadingError" code:5 userInfo:userInfo];
                        [delegate loadWeatherInfoDidFailWithError:error];
                    } else {
                        [self setWeatherData:json];
                        // NSLog(@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
                        // it is not called in the main thread
                        [delegate weatherInfoDidLoadWithWeatherInfo:json];
                    }
                }
            }];
            [task resume];
        }
    }
}

- (void)startDownloadWeatherInfoByCityName:(NSString *)cityName {
    // to be implemented
}

- (void)startDownloadWeatherInfoByCityID:(NSString *)cityID {
    // to be implemented
}

- (void)startDownloadWeatherInfoByZIPCode:(NSString *)zipCode {
    // to be implemented
}

@end
