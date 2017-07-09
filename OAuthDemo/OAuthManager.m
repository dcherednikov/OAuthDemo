//
//  OAuthManager.m
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "OAuthManager.h"
#include "hmac.h"
#include "Base64Transcoder.h"


@interface OAuthManager () {
    
    __block NSString *token;
    __block NSString *tokenSecret;
    NSString *verifier;
    bool connectionInProcess;
}

@end

@implementation OAuthManager

#pragma mark - public

- (void)requestFirstPair {
    
    [self reset];
    _status = OAuthStatusPerformingFirstRequest;
    [self requestWithAutorizationHeaderFor:_requestURL];
}

- (void)requestAccessPair {
    
    _status = OAuthStatusPerformingSecondRequest;
    [self requestWithAutorizationHeaderFor:_accessURL];
}

- (void)requestAccessPairWithVerifier:(NSString *)inVerifier {
    
    verifier = inVerifier;
    [self requestAccessPair];
}

#pragma mark - 

- (void)reset{
    
    token = nil;
    tokenSecret = nil;
    _accessToken = nil;
    _accessTokenSecret = nil;
}

- (NSString *)token {
    
    return token ? token : @"";
}

- (NSString *)tokenSecret {
    
    return tokenSecret ? tokenSecret : @"";
}

#pragma mark - passing OAuth protocol params via Authorization header

- (void)requestWithAutorizationHeaderFor:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        
        [self handleError];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:[self signedHeaderFor:urlString] forHTTPHeaderField:@"Authorization"];
    
    connectionInProcess = YES;
    
    __weak __block typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * data,
                                                                    NSURLResponse *  response,
                                                                    NSError * error) {
    
                                                    OAuthManager *strongSelf = weakSelf;
                                                    if (!strongSelf) {
                                                        
                                                        return;
                                                    }
                                                    connectionInProcess = NO;
                                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                    if (error || httpResponse.statusCode != 200) {
                                                        
                                                        [strongSelf handleError];
                                                    }
                                                    else {
                                                        
                                                        [strongSelf handleResponseData:data];
                                                    }
                                                }];
    [dataTask resume];
}

- (NSString *)signedHeaderFor:(NSString *)urlString {
    
    NSDictionary *params = [self oauthParametersWithoutSignature];
    NSString *csvParamsString = [self csvParametersStringWithoutSignature:params];//string for header
    NSString *urlEncodedParamsString = [self urlEncodedParametersStringWithoutSignature:params];//this string -> base string -> signature
    NSString *baseString = [self baseStringForUrl:urlString withParametersString:urlEncodedParamsString];
    NSString *signature = [self signatureWithBaseString:baseString];
    NSString *escapedSignature = [self escapeEncode:signature];
    
    NSString *lastPair = [NSString stringWithFormat:@", oauth_signature=\"%@\"", escapedSignature];
    csvParamsString = [csvParamsString stringByAppendingString:lastPair];
    NSString *header = [@"OAuth " stringByAppendingString:csvParamsString];
    
    return header;
}

#pragma mark - timestamp and nonce

- (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return uuidStr;
}

- (NSString *)nonce {
    
    NSString *uuid = [self uuid];
    
    return [[uuid substringToIndex:10] stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
}

- (NSString *)timestamp {
    
    NSString *timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]];
    
    return timestamp;
}

#pragma mark - request parameters handling

- (NSDictionary *)oauthParametersWithoutSignature {
    
    NSString *oauth_timestamp = [self timestamp];
    NSString *oauth_nonce = [self nonce];
    NSString *oauth_consumer_key = _consumerKey;
    NSString *oauth_signature_method = @"HMAC-SHA1";
    NSString *oauth_version = @"1.0a";
    NSString *request_token = [self token];

    NSMutableDictionary *params = [@{@"oauth_consumer_key": oauth_consumer_key,
                                     @"oauth_nonce": oauth_nonce,
                                     @"oauth_signature_method": oauth_signature_method,
                                     @"oauth_timestamp": oauth_timestamp,
                                     @"oauth_version": oauth_version,
                                     @"oauth_token": request_token} mutableCopy];
    
    if (_status == OAuthStatusPerformingSecondRequest
        && verifier
        && ![verifier isEqualToString:@""]) {
        
        params[@"oauth_verifier"] = verifier;
    }
    
    return [params copy];
}

- (NSString *)csvParametersStringWithoutSignature:(NSDictionary *)params {
    
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *name in params) {
        
        NSString *aPair = [name stringByAppendingFormat:@"=\"%@\"", [self escapeEncode:params[name]]];
        [parameterPairs addObject:aPair];
    }
    
    NSString *string = [@"" stringByAppendingFormat:@"%@", [parameterPairs componentsJoinedByString:@", "]];
    
    return string;
}

- (NSString *)urlEncodedParametersStringWithoutSignature:(NSDictionary *)params {
    
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *name in params) {
        
        NSString *aPair = [name stringByAppendingFormat:@"=%@", [self escapeEncode:params[name]]];
        [parameterPairs addObject:aPair];
    }
    NSArray *sortedArray = [parameterPairs sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSString *string = [@"" stringByAppendingFormat:@"%@", [sortedArray componentsJoinedByString:@"&"]];
    
    return string;
}

- (NSString *)baseStringForUrl:(NSString *)urlString withParametersString:(NSString *)paramsString {
    
    NSString *baseString = [NSString stringWithFormat:@"POST&%@&%@", [self escapeEncode:urlString], [self escapeEncode:paramsString]];
    
    return baseString;
}

#pragma mark - encoding and signing

- (NSString *)escapeEncode:(NSString *)string {
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
    characterSet = [characterSet invertedSet];
    
    return [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

- (NSString *)signatureWithBaseString:(NSString *)baseString {
    
    NSString *consumerSecretPart = [self escapeEncode:_consumerSecret];
    NSString *tokenSecretPart = [self escapeEncode:[self tokenSecret]];
    NSString *secretString = [consumerSecretPart stringByAppendingFormat:@"&%@", tokenSecretPart];
    NSData *secretData = [secretString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *textData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[20];
    hmac_sha1((unsigned char *)[textData bytes],
              [textData length],
              (unsigned char *)[secretData bytes],
              [secretData length],
              result);
    
    //Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result,
                     20,
                     base64Result,
                     &theResultLength);
    
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    return [NSString.alloc initWithData:theData encoding:NSUTF8StringEncoding];
}

#pragma mark - responses handling

- (void)handleError {
    
    if (_status == OAuthStatusPerformingFirstRequest) {
        
        _status = OAuthStatusFirstRequestFailed;
        [_delegate firstRequestFailed];
    }
    else if (_status == OAuthStatusPerformingSecondRequest) {
        
        _status = OAuthStatusSecondRequestFailed;
        [_delegate secondRequestFailed];
    }
    [self reset];
}

- (void)handleResponseData:(NSData *)data {
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"response string %@", responseString);
    NSDictionary *responsePair = [self parseString:responseString];
    if (_status == OAuthStatusPerformingFirstRequest) {
        
        [self firstRequestCompletedWithResponsePair:responsePair];
    }
    else if (_status == OAuthStatusPerformingSecondRequest) {
        
        [self secondRequestCompletedWithResponsePair:responsePair];
    }
    
}

- (void)firstRequestCompletedWithResponsePair:(NSDictionary *)responsePair {
    
    token = responsePair[@"oauth_token"];
    tokenSecret = responsePair[@"oauth_token_secret"];
    
    if (token && ![token isEqualToString:@""] && tokenSecret && ![tokenSecret isEqualToString:@""]) {
        
        _status = OAuthStatusFirstRequestSucceeded;
        _encodedAuthorizationURL = [_authorizationURL stringByAppendingString:[NSString stringWithFormat:@"?oauth_token=%@", [self token]]];
        [_delegate firstRequestSucceeded];
    }
    else {
        
        _status = OAuthStatusFirstRequestFailed;
        [_delegate firstRequestFailed];
    }
}

- (void)secondRequestCompletedWithResponsePair:(NSDictionary *)responsePair {
    
    _accessToken = responsePair[@"oauth_token"];
    _accessTokenSecret = responsePair[@"oauth_token_secret"];
    
    if (_accessToken && ![_accessToken isEqualToString:@""] && _accessTokenSecret && ![_accessTokenSecret isEqualToString:@""]) {
        
        _status = OAuthStatusSecondRequestSucceeded;
        [_delegate secondRequestSucceeded];
    }
    else {
        
        _status = OAuthStatusSecondRequestFailed;
        [_delegate secondRequestFailed];
    }
}

#pragma mark - utility methods

- (NSDictionary *)parseString:(NSString *)string {
    
    NSUInteger i = 0;
    NSMutableString *name = [[NSMutableString alloc] init];
    NSMutableString *value = [[NSMutableString alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    bool writingName = YES; //otherwise writing value
    while (i < [string length]) {
        
        if ([string characterAtIndex:i] == '=') {
            
            writingName = NO;
        }
        else if ([string characterAtIndex:i] == '&') {
            
            [dictionary setObject:[value copy] forKey:name];
            [name setString:@""];
            [value setString:@""];
            writingName = YES;
        }
        else if (writingName) {
            
            [name appendFormat:@"%c", [string characterAtIndex:i]];
        }
        else if (!writingName) { //writing value
            
            [value appendFormat:@"%c", [string characterAtIndex:i]];
        }
        i++;
    }
    [dictionary setObject:[value copy] forKey:name];
    
    return dictionary;
}

@end

