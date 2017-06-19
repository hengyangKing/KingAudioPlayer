//
//  NSURL+Scheme.m
//  Example
//
//  Created by J on 2017/6/19.
//  Copyright © 2017年 J. All rights reserved.
//

#import "NSURL+Scheme.h"

@implementation NSURL (Scheme)
-(NSURL *)streamingURL
{
    NSURLComponents *components=[NSURLComponents componentsWithString:self.absoluteString];
    components.scheme=@"streaming";
    return components.URL;
}
-(NSURL *)httpURL
{
    NSURLComponents *components=[NSURLComponents componentsWithString:self.absoluteString];
    components.scheme=@"http";
    return components.URL;
}
@end
