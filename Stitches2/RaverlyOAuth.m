//
//  RaverlyOAuth.m
//  Stitches2
//
//  Created by Nicole Yarroch on 1/28/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

#import "RaverlyOAuth.h"
#import "AFOAuth1Client.h"
#import "AFJSONRequestOperation.h"

@interface RaverlyOAuth()
@property (strong, nonatomic) NSUserDefaults *storage;

@end

@implementation RaverlyOAuth

static RaverlyOAuth *_sharedInstance;
#define TOKEN_KEY "RavelryToken"
#define TOKEN_SAVED "RavelryTokenSaved"
#define USER_NAME_SAVED "RavelryUserNameSaved"

-(NSUserDefaults *)storage {
    if (!_storage) _storage = [NSUserDefaults standardUserDefaults];
    return _storage;
}

- (id) init
{
    if (self = [super init])
    {
       
        /* Check to see if token was saved */
        bool ravelryEnabled = [self.storage boolForKey:@TOKEN_SAVED];
        
        /* If the token was saved, set the access token for the client */
        if (ravelryEnabled) {
            
            /* Initialize the client */
            self.ravelryClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.ravelry.com"] key:@"95B5A3A459B890ED7F11" secret:@"8UpGjPflOWJFXSWJee+zttlz45Aw/dUUNA/7t7UN"];
            
            /* Set the token with the saved token */
            AFOAuth1Token *savedToken = [AFOAuth1Token retrieveCredentialWithIdentifier:@TOKEN_KEY];
            [self.ravelryClient setAccessToken:savedToken];
            
            /* Get the saved username */
            self.userName = [self.storage stringForKey:@USER_NAME_SAVED];
            
            /* Make a request */
            [self.ravelryClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
            [self.ravelryClient getPath:@"https://api.ravelry.com/color_families.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                /* TEST PRINT yarn colors */
//                NSLog(@"%@", operation.responseString);
            
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
                /* OAuth tokens are long-lived but they can expire after a period of inactivity 
                 * or if the user revoke access. Your application should handle HTTP 401 
                 * Unauthorized responses by re-authenticating the user. */
                if (operation.response.statusCode == 401) {
                    /* reauthorize client */
                    /* Initialize the client */
                    self.ravelryClient = [[AFOAuth1Client alloc]
                                          initWithBaseURL:[NSURL URLWithString:@"https://www.ravelry.com"]
                                          key:@"95B5A3A459B890ED7F11"
                                          secret:@"8UpGjPflOWJFXSWJee+zttlz45Aw/dUUNA/7t7UN"];
                    
                    /* Request token */
                    [self.ravelryClient authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                                          userAuthorizationPath:@"/oauth/authorize"
                                                                    callbackURL:[NSURL URLWithString:@"stitches2npy://success"]
                                                                accessTokenPath:@"/oauth/access_token"
                                                                   accessMethod:@"POST"
                                                                          scope:nil
                                                                        success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                                            /* Get username */
                                                                            [self.ravelryClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
                                                                            [self.ravelryClient getPath:@"https://api.ravelry.com/color_families.json"
                                                                                             parameters:nil
                                                                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                    NSLog(@"Success");
                                                                                                    
                                                                                                    /* Get current user */
                                                                                                    [self.ravelryClient getPath:@"https://api.ravelry.com/current_user.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                        
                                                                                                        NSDictionary *response = (NSDictionary *)responseObject;
                                                                                                        
                                                                                                        // Get the username
                                                                                                        self.userName = [[response objectForKey:@"user"] valueForKey:@"username"];
                                                                                                        
                                                                                                        /* Save the token and username */
                                                                                                        [AFOAuth1Token storeCredential:accessToken withIdentifier:@TOKEN_KEY];
                                                                                                        [self.storage setBool:YES forKey:@TOKEN_SAVED];
                                                                                                        [self.storage setObject:self.userName forKey:@USER_NAME_SAVED];
                                                                                                        
                                                                                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                        NSLog(@"failure getting username");
                                                                                                    }];
                                                                                                    
                                                                                                    
                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                    NSLog(@"Error: %@", error);
                                                                                                }];
                                                                        } failure:^(NSError *error) {
                                                                            NSLog(@"Error: %@", error);
                                                                        }];
                }
            }];

        }

        /* If the token was not saved, get a token from Ravelry */
        else {
            
            /* Initialize the client */
            self.ravelryClient = [[AFOAuth1Client alloc]
                                  initWithBaseURL:[NSURL URLWithString:@"https://www.ravelry.com"]
                                  key:@"95B5A3A459B890ED7F11"
                                  secret:@"8UpGjPflOWJFXSWJee+zttlz45Aw/dUUNA/7t7UN"];
            
            /* Request token */
            [self.ravelryClient authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                                  userAuthorizationPath:@"/oauth/authorize"
                                                            callbackURL:[NSURL URLWithString:@"stitches2npy://success"]
                                                        accessTokenPath:@"/oauth/access_token"
                                                           accessMethod:@"POST"
                                                                  scope:nil
                                                                success:^(AFOAuth1Token *accessToken, id responseObject) {
                 /* Get username */
                [self.ravelryClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
                [self.ravelryClient getPath:@"https://api.ravelry.com/color_families.json"
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSLog(@"Success");
                                        
                                        /* Get current user */
                                        [self.ravelryClient getPath:@"https://api.ravelry.com/current_user.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            
                                            NSDictionary *response = (NSDictionary *)responseObject;
                                            
                                            // Get the username
                                            self.userName = [[response objectForKey:@"user"] valueForKey:@"username"];
                                            
                                            /* Save the token and username */
                                            [AFOAuth1Token storeCredential:accessToken withIdentifier:@TOKEN_KEY];
                                            [self.storage setBool:YES forKey:@TOKEN_SAVED];
                                            [self.storage setObject:self.userName forKey:@USER_NAME_SAVED];

                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"failure getting username");
                                        }];

                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error: %@", error);
                                    }];
                                                                } failure:^(NSError *error) {
                                                                    NSLog(@"Error: %@", error);
                                                                }];
        }
    }
    return self;
}

+ (RaverlyOAuth *) sharedInstance
{
    if (!_sharedInstance)
    {
        _sharedInstance = [[RaverlyOAuth alloc] init];
    }
    
    return _sharedInstance;
}


@end
