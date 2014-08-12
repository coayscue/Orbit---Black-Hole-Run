//
//  Background.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "Background.h"

@implementation Background

-(instancetype)init
{
    if (self = [super initWithImageNamed:@"background.jpg"]){
        self.size = CGSizeMake(390, 568);
        self.anchorPoint = CGPointZero;
        self.position = CGPointZero;
    }
    return self;
}

-(void) scaleIn
{
    SKAction *scaleIn = [SKAction scaleTo:2.0 duration:0];
    [self runAction:scaleIn];
    self.position = CGPointMake(-160, 0);
}

-(void) scaleOut
{
    SKAction *scaleOut = [SKAction scaleTo:1.0 duration:0.5];
    
    SKAction *changePos = [SKAction moveTo:CGPointZero duration:0.5];
    SKAction *togetherNow =[SKAction group:@[scaleOut, changePos]];
    togetherNow.timingMode = SKActionTimingEaseOut;
    
    [self runAction:togetherNow];
}
@end
