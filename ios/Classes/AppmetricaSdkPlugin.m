// Copyright 2019 EM ALL iT Studio. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AppmetricaSdkPlugin.h"
#import <YandexMobileMetrica/YandexMobileMetrica.h>
#import <YandexMobileMetrica/YMMProfileAttribute.h>

@implementation AppmetricaSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"emallstudio.com/appmetrica_sdk"
            binaryMessenger:[registrar messenger]];
  AppmetricaSdkPlugin* instance = [[AppmetricaSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"activate" isEqualToString:call.method]) {
      [self handleActivate:call result:result];
  } else if ([@"reportEvent" isEqualToString:call.method]) {
      [self handleReportEvent:call result:result];
  } else if ([@"reportUserProfileCustomString" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomString:call result:result];
  } else if ([@"reportUserProfileCustomNumber" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomNumber:call result:result];
  } else if ([@"reportUserProfileCustomBoolean" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomBoolean:call result:result];
  } else if ([@"reportUserProfileCustomCounter" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomCounter:call result:result];
  } else if ([@"reportUserProfileUserName" isEqualToString:call.method]) {
      [self handleReportUserProfileUserName:call result:result];
  } else if ([@"reportUserProfileNotificationsEnabled" isEqualToString:call.method]) {
      [self handleReportUserProfileNotificationsEnabled:call result:result];
  } else if ([@"setStatisticsSending" isEqualToString:call.method]) {
      [self handleSetStatisticsSending:call result:result];
  } else if ([@"getLibraryVersion" isEqualToString:call.method]) {
      [self handleGetLibraryVersion:call result:result];
  } else if ([@"setUserProfileID" isEqualToString:call.method]) {
      [self handleSetUserProfileID:call result:result];
  } else if ([@"sendEventsBuffer" isEqualToString:call.method]) {
      [self handleSendEventsBuffer:call result:result];
  } else if ([@"reportReferralUrl" isEqualToString:call.method]) {
      [self handleReportReferralUrl:call result:result];
  } else if ([@"reportEcommerceShowScreen" isEqualToString:call.method]) {
      [self handleReportEcommerceShowScreen:call result:result];
  } else if ([@"reportEcommerceAddCart" isEqualToString:call.method]) {
      [self handleReportEcommerceAddCart:call result:result];
  } else if ([@"showProductDetailsEventWithProduct" isEqualToString:call.method]) {
      [self handleShowProductDetailsEventWithProduct:call result:result];
  } else if ([@"reportEcommerceRemoveCart" isEqualToString:call.method]) {
      [self handleReportEcommerceRemoveCart:call result:result];
  } else if ([@"beginCheckoutEventWithOrder" isEqualToString:call.method]) {
      [self handleBeginCheckoutEventWithOrder:call result:result];
  }  else if ([@"purchaseEventWithOrder" isEqualToString:call.method]) {
      [self handlePurchaseEventWithOrder:call result:result];
  }  else {
      result(FlutterMethodNotImplemented);
  }
}

- (FlutterError* _Nullable)getFlutterError:(NSError*)error {
  if (error == nil) return nil;

  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

- (void)handleActivate:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* apiKey = call.arguments[@"apiKey"];
    NSInteger sessionTimeout = [call.arguments[@"sessionTimeout"] integerValue];
    BOOL locationTracking = [call.arguments[@"locationTracking"] boolValue];
    BOOL statisticsSending = [call.arguments[@"statisticsSending"] boolValue];
    BOOL crashReporting = [call.arguments[@"crashReporting"] boolValue];
    NSInteger maxReportsInDatabaseCount = [call.arguments[@"maxReportsInDatabaseCount"] integerValue];
    // Creating an extended library configuration.
    YMMYandexMetricaConfiguration *configuration = [[YMMYandexMetricaConfiguration alloc] initWithApiKey:apiKey];
    // Setting up the configuration.
    configuration.logs = YES;
    configuration.sessionTimeout = sessionTimeout;
    configuration.locationTracking = locationTracking;
    configuration.statisticsSending = statisticsSending;
    configuration.crashReporting = crashReporting;
    // maxReportsInDatabaseCount is not supported yet. Android only feature.
    //configuration.maxReportsInDatabaseCount = maxReportsInDatabaseCount;
    // Initializing the AppMetrica SDK.
    [YMMYandexMetrica activateWithConfiguration:configuration];
    result(nil);
}

- (void)handleReportEvent:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* name = call.arguments[@"name"];

    if (![call.arguments[@"attributes"] isEqual:[NSNull null]]) {
        NSDictionary* attributes = call.arguments[@"attributes"];
        [YMMYandexMetrica reportEvent:name
            parameters:attributes
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }
        ];
    } else {
        [YMMYandexMetrica reportEvent:name
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }
        ];
    }

    result(nil);
}


- (void)handleReportUserProfileCustomString:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"value"] isEqual:[NSNull null]]) {
        NSString* value = call.arguments[@"value"];
        [userProfile apply:[[YMMProfileAttribute customString:key] withValue:value]];
    } else {
        [userProfile apply:[[YMMProfileAttribute customString:key] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileCustomNumber:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"value"] isEqual:[NSNull null]]) {
        double value = [call.arguments[@"value"] doubleValue];
        [userProfile apply:[[YMMProfileAttribute customNumber:key] withValue:value]];
    } else {
        [userProfile apply:[[YMMProfileAttribute customNumber:key] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileCustomBoolean:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"value"] isEqual:[NSNull null]]) {
        BOOL value = [call.arguments[@"value"] boolValue];
        [userProfile apply:[[YMMProfileAttribute customBool:key] withValue:value]];
    } else {
        [userProfile apply:[[YMMProfileAttribute customBool:key] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileCustomCounter:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];
    double value = [call.arguments[@"delta"] doubleValue];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    [userProfile apply:[[YMMProfileAttribute customCounter:key] withDelta:value]];
    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileUserName:(FlutterMethodCall*)call result:(FlutterResult)result {
    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"userName"] isEqual:[NSNull null]]) {
        NSString* userName = call.arguments[@"userName"];
        [userProfile apply:[[YMMProfileAttribute name] withValue:userName]];
    } else {
        [userProfile apply:[[YMMProfileAttribute name] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileNotificationsEnabled:(FlutterMethodCall*)call result:(FlutterResult)result {
    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"notificationsEnabled"] isEqual:[NSNull null]]) {
        BOOL notificationsEnabled = [call.arguments[@"notificationsEnabled"] boolValue];
        [userProfile apply:[[YMMProfileAttribute notificationsEnabled] withValue:notificationsEnabled]];
    } else {
        [userProfile apply:[[YMMProfileAttribute notificationsEnabled] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleSetStatisticsSending:(FlutterMethodCall*)call result:(FlutterResult)result {
    BOOL statisticsSending = [call.arguments[@"statisticsSending"] boolValue];

    [YMMYandexMetrica setStatisticsSending:statisticsSending];

    result(nil);
}

- (void)handleGetLibraryVersion:(FlutterMethodCall*)call result:(FlutterResult)result {
    result([YMMYandexMetrica libraryVersion]);
}

- (void)handleSetUserProfileID:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* userProfileID = call.arguments[@"userProfileID"];

    [YMMYandexMetrica setUserProfileID:userProfileID];

    result(nil);
}

- (void)handleSendEventsBuffer:(FlutterMethodCall*)call result:(FlutterResult)result {
    [YMMYandexMetrica sendEventsBuffer];

    result(nil);
}

- (void)handleReportReferralUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* referral = call.arguments[@"referral"];
    NSURL *url = [[NSURL alloc] initWithString:referral];
    
    [YMMYandexMetrica reportReferralUrl:url];

    result(nil);
}

/// show screen
-(void)handleReportEcommerceShowScreen:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* screenName = call.arguments[@"screenName"];
    YMMECommerceScreen *screen = [[YMMECommerceScreen alloc] initWithName:screenName];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce showScreenEventWithScreen:screen] onFailure:nil];
    
    result(nil);
}

-(void)handleReportEcommerceAddCart:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* screenName = call.arguments[@"screenName"];
    YMMECommerceScreen *screen = [[YMMECommerceScreen alloc] initWithName:screenName];
    
    NSString* SKU = call.arguments[@"SKU"];
    NSString* name = call.arguments[@"name"];
    NSString* category = call.arguments[@"category"];
    double price = [call.arguments[@"price"] doubleValue];
    NSString* reffer = call.arguments[@"reffer"];
    
    YMMECommerceAmount *actualFiat =
            [[YMMECommerceAmount alloc] initWithUnit:@"RUB" value:[[NSDecimalNumber alloc] initWithDouble:price]];
    
    YMMECommercePrice *originalPrice = [[YMMECommercePrice alloc] initWithFiat:actualFiat];
    
    YMMECommerceProduct *product = [[YMMECommerceProduct alloc] initWithSKU:SKU
                                                                       name:name
                                                         categoryComponents:@[category]
                                                                    payload:@{}
                                                                actualPrice:originalPrice
                                                              originalPrice:originalPrice
                                                                 promoCodes:@[]];
    
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:reffer
                                                                     identifier:@""
                                                                         screen:screen];
    
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    
    YMMECommerceCartItem *addedItems = [[YMMECommerceCartItem alloc] initWithProduct:product
                                                                        quantity:quantity
                                                                        revenue:originalPrice
                                                                        referrer:referrer];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce addCartItemEventWithItem:addedItems] onFailure:nil];
    
    result(nil);
}

-(void)handleReportEcommerceRemoveCart:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* screenName = call.arguments[@"screenName"];
    YMMECommerceScreen *screen = [[YMMECommerceScreen alloc] initWithName:screenName];
    
    NSString* SKU = call.arguments[@"SKU"];
    NSString* name = call.arguments[@"name"];
    NSString* category = call.arguments[@"category"];
    double price = [call.arguments[@"price"] doubleValue];
    NSString* reffer = call.arguments[@"reffer"];
    
    YMMECommerceAmount *actualFiat =
            [[YMMECommerceAmount alloc] initWithUnit:@"RUB" value:[[NSDecimalNumber alloc] initWithDouble:price]];
    
    YMMECommercePrice *originalPrice = [[YMMECommercePrice alloc] initWithFiat:actualFiat];
    
    YMMECommerceProduct *product = [[YMMECommerceProduct alloc] initWithSKU:SKU
                                                                       name:name
                                                         categoryComponents:@[category]
                                                                    payload:@{}
                                                                actualPrice:originalPrice
                                                              originalPrice:originalPrice
                                                                 promoCodes:@[]];
    
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:reffer
                                                                     identifier:@""
                                                                         screen:screen];
    
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    
    YMMECommerceCartItem *addedItems = [[YMMECommerceCartItem alloc] initWithProduct:product
                                                                        quantity:quantity
                                                                        revenue:originalPrice
                                                                        referrer:referrer];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce removeCartItemEventWithItem:addedItems] onFailure:nil];
    
    result(nil);
}

-(void)handleShowProductDetailsEventWithProduct:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString* screenName = call.arguments[@"screenName"];
    YMMECommerceScreen *screen = [[YMMECommerceScreen alloc] initWithName:screenName];
    
    NSString* SKU = call.arguments[@"SKU"];
    NSString* name = call.arguments[@"name"];
    NSString* category = call.arguments[@"category"];
    double price = [call.arguments[@"price"] doubleValue];
    
    YMMECommerceAmount *actualFiat =
            [[YMMECommerceAmount alloc] initWithUnit:@"RUB" value:[[NSDecimalNumber alloc] initWithDouble:price]];
    
    YMMECommercePrice *originalPrice = [[YMMECommercePrice alloc] initWithFiat:actualFiat];
    
    YMMECommerceProduct *product = [[YMMECommerceProduct alloc] initWithSKU:SKU
                                                                       name:name
                                                         categoryComponents:@[category]
                                                                    payload:@{}
                                                                actualPrice:originalPrice
                                                              originalPrice:originalPrice
                                                                 promoCodes:@[]];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce showProductCardEventWithProduct:product screen:screen] onFailure:nil];
    
    result(nil);
}

-(void)handleBeginCheckoutEventWithOrder:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString* screenName = call.arguments[@"screenName"];
    YMMECommerceScreen *screen = [[YMMECommerceScreen alloc] initWithName:screenName];
    
    NSArray* productItems = call.arguments[@"products"];
    NSMutableArray<YMMECommerceCartItem *>* products = [[NSMutableArray alloc] init];
    
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    
    NSString* orderId = call.arguments[@"orderId"];
    
    for (NSDictionary* item in productItems) {
        NSString* SKU = item[@"SKU"];
        NSString* name = item[@"name"];
        NSString* category = item[@"category"];
        double price = [item[@"price"] doubleValue];
        NSString* reffer = item[@"reffer"];
        
        YMMECommerceAmount *actualFiat =
                [[YMMECommerceAmount alloc] initWithUnit:@"RUB" value:[[NSDecimalNumber alloc] initWithDouble:price]];
        
        YMMECommercePrice *originalPrice = [[YMMECommercePrice alloc] initWithFiat:actualFiat];
        
        YMMECommerceProduct *product = [[YMMECommerceProduct alloc] initWithSKU:SKU
                                                                           name:name
                                                             categoryComponents:@[category]
                                                                        payload:@{}
                                                                    actualPrice:originalPrice
                                                                  originalPrice:originalPrice
                                                                     promoCodes:@[]];
        
        YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:reffer
                                                                         identifier:@""
                                                                             screen:screen];
        
        YMMECommerceCartItem *addedItem = [[YMMECommerceCartItem alloc] initWithProduct:product
                                                                            quantity:quantity
                                                                            revenue:originalPrice
                                                                            referrer:referrer];
        
        [products addObject:addedItem];
    }
    
    
    YMMECommerceOrder *order = [[YMMECommerceOrder alloc] initWithIdentifier:orderId
                                                                   cartItems:products
                                                                     payload:@{}];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce beginCheckoutEventWithOrder:order] onFailure:nil];
    
    result(nil);
}

-(void)handlePurchaseEventWithOrder::(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString* screenName = call.arguments[@"screenName"];
    YMMECommerceScreen *screen = [[YMMECommerceScreen alloc] initWithName:screenName];
    
    NSArray* productItems = call.arguments[@"products"];
    NSMutableArray<YMMECommerceCartItem *>* products = [[NSMutableArray alloc] init];
    
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    
    NSString* orderId = call.arguments[@"orderId"];
    
    for (NSDictionary* item in productItems) {
        NSString* SKU = item[@"SKU"];
        NSString* name = item[@"name"];
        NSString* category = item[@"category"];
        double price = [item[@"price"] doubleValue];
        NSString* reffer = item[@"reffer"];
        
        YMMECommerceAmount *actualFiat =
                [[YMMECommerceAmount alloc] initWithUnit:@"RUB" value:[[NSDecimalNumber alloc] initWithDouble:price]];
        
        YMMECommercePrice *originalPrice = [[YMMECommercePrice alloc] initWithFiat:actualFiat];
        
        YMMECommerceProduct *product = [[YMMECommerceProduct alloc] initWithSKU:SKU
                                                                           name:name
                                                             categoryComponents:@[category]
                                                                        payload:@{}
                                                                    actualPrice:originalPrice
                                                                  originalPrice:originalPrice
                                                                     promoCodes:@[]];
        
        YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:reffer
                                                                         identifier:@""
                                                                             screen:screen];
        
        YMMECommerceCartItem *addedItem = [[YMMECommerceCartItem alloc] initWithProduct:product
                                                                            quantity:quantity
                                                                            revenue:originalPrice
                                                                            referrer:referrer];
        
        [products addObject:addedItem];
    }
    
    
    YMMECommerceOrder *order = [[YMMECommerceOrder alloc] initWithIdentifier:orderId
                                                                   cartItems:products
                                                                     payload:@{}];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce purchaseEventWithOrder:order] onFailure:nil];
    
    result(nil);
}

@end
