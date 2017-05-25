//
//  OpenWeatherInfoLoader.h
//  Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//
//  API: http://openweathermap.org/current
//  OpenWeatherInfoLoader acts as model in MVC – Comprises all logic of preparing data

#import <Foundation/Foundation.h>

@protocol OpenWeatherInfoLoaderDelegate;

@interface OpenWeatherInfoLoader : NSObject {
    NSDictionary *weatherData;
    __weak id <OpenWeatherInfoLoaderDelegate> delegate;
}
@property (nonatomic) NSDictionary *weatherData;
@property (weak, nonatomic) id <OpenWeatherInfoLoaderDelegate> delegate;

- (void)startDownloadWeatherInfoByLatitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void)startDownloadWeatherInfoByCityName:(NSString *)cityName;
- (void)startDownloadWeatherInfoByCityID:(NSString *)cityID;
- (void)startDownloadWeatherInfoByZIPCode:(NSString *)zipCode;

@end

@protocol OpenWeatherInfoLoaderDelegate <NSObject>

- (void)weatherInfoDidLoadWithWeatherInfo:(NSDictionary *)weatherInfo;
- (void)loadWeatherInfoDidFailWithError:(NSError *)error;

@end
