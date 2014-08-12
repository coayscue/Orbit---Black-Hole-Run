//
//  Plannet.h
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Plannet : SKNode

@property CGSize _size;
@property SKSpriteNode *_gravZone;
@property SKSpriteNode *_gravZoneImage;
@property UIBezierPath *_gravPath;
@property CGFloat _radius;
@property UIBezierPath *_entrancePath;

-(instancetype) initWithSize:(CGSize) size andPosition:(CGPoint) position andImage:(NSString *) plannetName;

@end
