//
//  RaverlyOAuth.h
//  Stitches2
//
//  Created by Nicole Yarroch on 1/28/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFOAuth1Client/AFOAuth1Client.h>


@interface RaverlyOAuth : NSObject

@property (strong, nonatomic) AFOAuth1Client *ravelryClient;
@property (strong, nonatomic) NSString *userName;

+ (RaverlyOAuth *) sharedInstance;
- (void) getFavorites:(NSNumber *)pageCount;
- (void)searchFavorites:(NSString *)searchKeyword;

@end
