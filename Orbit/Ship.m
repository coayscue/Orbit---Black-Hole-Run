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
@synthesize _currentPlannet;
@synthesize _oldPlannetToShipAngle;
@synthesize _plannetToShipAngle;
@synthesize _clockwise;
@synthesize _onPlannet;
@synthesize _lastOrbitPosition;

-(instancetype) initWithPosition:(CGPoint)position andColor:(SKColor *)color
{
    if(self = [super initWithImageNamed:@"rocketship"])
    {
        self.position = position;
        if(color){
            self.color = color;
            self.colorBlendFactor = 0.7;
        }
        self.size = CGSizeMake(20, 20);
        [self configurePhysicsBody];
        
    }
    return self;
}

-(void)configurePhysicsBody
{
    CGMutablePathRef trianglePath = CGPathCreateMutable();
    
    CGPathMoveToPoint(trianglePath, nil, -self.size.width/4, self.size.height/4);
    CGPathAddLineToPoint(trianglePath, nil, self.size.width/2, 0);
    CGPathAddLineToPoint(trianglePath, nil, -self.size.width/4, -self.size.height/4);
    CGPathAddLineToPoint(trianglePath, nil, -self.size.width/4, self.size.height/4);
    
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:trianglePath];
    self.physicsBody.linearDamping = 0;
    self.physicsBody.angularDamping = 0;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryShip;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = CNPhysicsCategoryGravityZone | CNPhysicsCategoryPlannetBody;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.usesPreciseCollisionDetection = YES;
}
@end
