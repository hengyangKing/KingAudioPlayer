//
//  NSURL+streaming.m
//  Example
//
//  Created by J on 2017/6/18.
//  Copyright © 2017年 J. All rights reserved.
//

#import "NSURL+streaming.h"

@implementation NSURL (streaming)
-(NSURL *)streamingURL
{
    NSURLComponents *components=[NSURLComponents componentsWithString:self.absoluteString];
    components.scheme=@"streaming";
    return components.URL;
}
@end
