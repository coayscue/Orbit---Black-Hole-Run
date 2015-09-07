//
//  Ship.h
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Planet.h"

@interface Ship : SKSpriteNode

@property CGFloat _speed;
@property CGPoint _direction;
@property CGFloat _miles;
@property Planet* _currentPlanet;
@property CGFloat _oldPlanetToShipAngle;
@property float _planetToShipAngle;
@property BOOL _clockwise;
@property BOOL _inOrbit;
@property int _place;
@property BOOL _dead;
@property float _entrancePathLength;
@property CGPoint _newPos;
@property CGPoint _oldPos;
@property float _releaseAngle;
@property int _clockwiseInt;
@property float _accuracyAngle;
@property BOOL _inGravZone;
@property BOOL _hasEntered;
@property SKSpriteNode *_glow;

-(instancetype) initWithPosition:(CGPoint) position andSize:(CGSize)size andImage:(NSString *)imageName;


@end
