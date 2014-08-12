//
//  Ship.h
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Plannet.h"

@interface Ship : SKSpriteNode

@property CGFloat _speed;
@property CGPoint _direction;
@property CGFloat _miles;
@property Plannet* _currentPlannet;
@property CGFloat _oldPlannetToShipAngle;
@property float _plannetToShipAngle;
@property CGPoint _lastOrbitPosition;
@property BOOL _clockwise;
@property BOOL _onPlannet;
@property BOOL _dead;

-(instancetype) initWithPosition:(CGPoint) position andColor:(SKColor *) color;

@end
