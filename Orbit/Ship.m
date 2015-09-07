//
//  Ship.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "Ship.h"

@implementation Ship{
    CGPoint _position;
}

@synthesize _speed;
@synthesize _direction;
@synthesize _miles;
@synthesize _currentPlanet;
@synthesize _oldPlanetToShipAngle;
@synthesize _planetToShipAngle;
@synthesize _clockwise;
@synthesize _inOrbit;
@synthesize _place;
@synthesize _dead;
@synthesize _entrancePathLength;
@synthesize _newPos;
@synthesize _oldPos;
@synthesize _releaseAngle;
@synthesize _clockwiseInt;
@synthesize _inGravZone;
@synthesize _hasEntered;
@synthesize _glow;

-(instancetype) initWithPosition:(CGPoint)position andSize:(CGSize)size andImage:(NSString*)imageName
{
    if(self = [super initWithImageNamed:imageName])
    {
        
        self.position = position;
        self.anchorPoint = CGPointMake(0.615, 0.5);
        self.size = size;
        [self configurePhysicsBody];
        
        _glow = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ship_glow"] size:CGSizeMake(self.size.width*1.1943, self.size.height*1.755)];
        _glow.alpha = 0;
        
        [self addChild:_glow];
        
    }
    return self;
}

-(void)configurePhysicsBody
{
    CGMutablePathRef bodyPath = CGPathCreateMutable();
    CGPathMoveToPoint(bodyPath, nil, -self.size.width/4, self.size.height/2);
    CGPathAddLineToPoint(bodyPath, nil, self.size.width/2, 0);
    CGPathAddLineToPoint(bodyPath, nil, -self.size.width/4, -self.size.height/2);
    CGPathCloseSubpath(bodyPath);
    
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:bodyPath];
    self.physicsBody.linearDamping = 0;
    self.physicsBody.angularDamping = 0;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryAsteroid | CNPhysicsCategoryPlanetBody;
    self.physicsBody.usesPreciseCollisionDetection = YES;

}

@end
