//
//  MyScene.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

//regular speed = 100 pixels per second

#import "MyScene.h"
#import "BackgroundLayer.h"
#import "Plannet.h"
#import "Ship.h"
#import "SKTUtils.h"

static const float NORMAL_SHIP_SPEED_PPS = 80;

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKSpriteNode *_background;
    BackgroundLayer *_backgroundLayer;
    Plannet *_earth;
    Ship *_mainShip;      //_mainShips[0]
    Ship *_yellowShip;    //_mainShips[1]
    Ship *_greenShip;     //_mainShips[2]
    Ship *_redShip;       //_mainShips[3]
    Ship *_blueShip;      //_mainShips[4]
    
    NSArray *_ships;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    int _highScore;
    SKLabelNode *_orbitLabel;
    SKLabelNode *_highScoreLabel;
    SKLabelNode *_lastScoreLabel;
    BOOL _gameStarted;
    CGFloat _distance;
    
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {

        //set background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        _background.size = CGSizeMake(320, 570);
        [_background setScale:1.5];
        _background.anchorPoint = CGPointZero;
        _background.position = CGPointMake(-80, -10);
        
        
        //set up _backgroundLayer nodes
        _backgroundLayer = [[BackgroundLayer alloc] init];
        _backgroundLayer.anchorPoint = CGPointMake(80, 0);
        _backgroundLayer.position = CGPointZero;
        _backgroundLayer.size = CGSizeMake(480, 10000);
        
        _mainShip = [[Ship alloc] initWithPosition:CGPointMake(95,120) andColor:nil];
        _yellowShip = [[Ship alloc] initWithPosition:CGPointMake(100,120) andColor:[SKColor yellowColor]];
        _greenShip = [[Ship alloc] initWithPosition:CGPointMake(80,120) andColor:[SKColor greenColor]];
        _redShip = [[Ship alloc] initWithPosition:CGPointMake(60,120) andColor:[SKColor redColor]];
        _blueShip = [[Ship alloc] initWithPosition:CGPointMake(40,120) andColor:[SKColor blueColor]];
        _ships = [NSArray arrayWithObjects:_mainShip, _yellowShip, _greenShip, _redShip, _blueShip, nil];

        
        //setting up orbit label
        _orbitLabel = [SKLabelNode labelNodeWithFontNamed:@"Earth Kid"];
        _orbitLabel.text = @"Orbit";
        _orbitLabel.fontSize = 60;
        _orbitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _orbitLabel.position = CGPointMake(160, 400);
        
        
        //setting up highscore label
        _highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Heavy"];
        _highScoreLabel.text = [NSString stringWithFormat:@"High Score:\n%i miles",_highScore];
        _highScoreLabel.fontSize = 30;
        _highScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _highScoreLabel.position = CGPointMake(160, 100);
        
        //setting up physics world
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        
        //setting up instance variables
        _mainShip.zRotation = M_PI_2;
        
        [self createPlannetField];

        //setting up ship nodes
        [_backgroundLayer addChild:_mainShip];
        //        [_background addChild:_yellowShip];
        //        [_background addChild:_greenShip];
        //        [_background addChild:_redShip];
        //        [_background addChild:_blueShip];

        
        [self addChild:_background];
        [self addChild:_backgroundLayer];
        [self addChild:_orbitLabel];
        [self addChild:_highScoreLabel];
        [_backgroundLayer scaleIn];
        
    }

    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch");
    /* Called when a touch begins */
    if(!_gameStarted){
        
        SKAction *scaleOut = [SKAction scaleTo:1.0 duration:0.5];
        SKAction *changePos = [SKAction moveTo:CGPointZero duration:0.5];
        SKAction *togetherNow =[SKAction group:@[scaleOut, changePos]];
        togetherNow.timingMode = SKActionTimingEaseOut;


        
        SKAction *fadeLabel = [SKAction fadeAlphaTo:0 duration:0.5];
        SKAction *fadeLabel2 = [SKAction fadeAlphaTo:0 duration:0.2];
        [_orbitLabel runAction: fadeLabel];
        [_highScoreLabel runAction:fadeLabel2];
        [_backgroundLayer scaleOut];
        [_background runAction:togetherNow];
        
        SKAction *startGame = [SKAction sequence:@[[SKAction waitForDuration:.6],[SKAction runBlock:^{
            _gameStarted = YES;
        }]]];
        [self runAction:startGame];
        
        
    }else{
        
        _mainShip._lastOrbitPosition = _mainShip.position;
        _mainShip._currentPlannet._gravZoneImage.paused = NO;
        _mainShip._currentPlannet = nil;
        _mainShip._onPlannet = NO;
        _mainShip._plannetToShipAngle = 0;
        [_mainShip removeAllActions];
        SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
        [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
        
    }

}

-(void)update:(CFTimeInterval)currentTime {

    //_dt is the change in time
    if(_lastUpdateTime){
        _dt = currentTime - _lastUpdateTime;
    }else{
        _dt=0;
    }
    _lastUpdateTime = currentTime;
    
    //accelerate
    if(_gameStarted && _mainShip.speed < 1.5){
        _mainShip.speed += _dt*.1;
    }
    
    //if the ship is being affected by a plannet
    if (!_mainShip._currentPlannet){
        
        //sets ship to reapear on opposite side of the screen
        if ( _mainShip.position.x < 0){
            _mainShip.position = CGPointMake(320, _mainShip.position.y);
        }else if (_mainShip.position.x >320){
            _mainShip.position = CGPointMake(0, _mainShip.position.y);
        }
        
        //if ship is bellow screen
        
        if ( [_backgroundLayer convertPoint:_mainShip.position toNode:self].y < 0){
            //flip ship over line x = 160
            _mainShip.position = CGPointMake(320 - _mainShip.position.x, [self convertPoint:CGPointMake(0,1) toNode:_backgroundLayer].y);
            
            if (_mainShip.zRotation < 1.5 * M_PI)
                _mainShip.zRotation = M_PI - (_mainShip.zRotation - M_PI);
            else if (_mainShip.zRotation > 1.5 * M_PI)
                _mainShip.zRotation = 2 * M_PI - _mainShip.zRotation;
            
            //sets action to move ship
            [_mainShip removeAllActions];
            SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
            [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
        }
        
        //if ship is between y = 210 & y = 240
        if ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y <= 250 && [_backgroundLayer convertPoint:_mainShip.position toNode:self].y > 210){
            //move backgroundlayer
            _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y - 210) / 30 * sin(_mainShip.zRotation)*NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        }
        
    //if ship is on plannet
    }else  if (_gameStarted){
        if ([_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y <= 305 && [_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y > 240){
                _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y -NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y <= 240 && [_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y > 130){
                _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y - 120) / 110 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y <= 130 && [_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y > 120){
                _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y - 1 / 11 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        }
    }
    
    
    
    //if the ship is currently in the orbit loop of a plannet, set z rotation of ship
    if(_mainShip._onPlannet){
       _mainShip._plannetToShipAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlannet.position));
        if(_mainShip._clockwise){ _mainShip.zRotation = _mainShip._plannetToShipAngle - M_PI_2; }
        else { _mainShip.zRotation = _mainShip._plannetToShipAngle + M_PI_2; }
    }
    
}

-(void)didSimulatePhysics{
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"Contact");
    
    uint32_t collision = (contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask);
    
    if(collision == (CNPhysicsCategoryShip | CNPhysicsCategoryGravityZone)){
        
        if(contact.bodyA.categoryBitMask == CNPhysicsCategoryGravityZone){
//
//            //Ship *currentShip = (Ship*)contact.bodyB.node;
//            _mainShip._currentPlannet = (Plannet *)contact.bodyA.node.parent;
//            _mainShip._currentPlannet._gravZoneImage.paused = YES;
//            
//            
//            //sets the angle from the plannet to the last orbit position
//            CGFloat plannetToLastOrbitPositionAngle = CGPointToAngle(CGPointSubtract( _mainShip._lastOrbitPosition, _mainShip._currentPlannet.position));
//            while (plannetToLastOrbitPositionAngle > 2*M_PI) { plannetToLastOrbitPositionAngle -= (2*M_PI); }
//            while (plannetToLastOrbitPositionAngle < 0) { plannetToLastOrbitPositionAngle += (2*M_PI); }
//            
//            //sets the angle from the plannet to the ship
//            _mainShip._plannetToShipAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlannet.position));
//            while (_mainShip._plannetToShipAngle > 2*M_PI){ _mainShip._plannetToShipAngle -= 2*M_PI; }
//            while (_mainShip._plannetToShipAngle < 0) { _mainShip._plannetToShipAngle += (2*M_PI);}
//            
//            //finds the angle between the plannet to ship and plannet to last orbit position angle
//            float accuracyAngle = (180/M_PI*(_mainShip._plannetToShipAngle - plannetToLastOrbitPositionAngle));
//            
//            NSLog(@"plannetToShipAngle: %f", _mainShip._plannetToShipAngle);
//            NSLog(@"plannetToLastOrbitPositionAngle: %f", plannetToLastOrbitPositionAngle);
//            NSLog(@"accuracy angle: %f", accuracyAngle);
//            
//            //sets the clockwise property depending on which side of the plannet the ship hit with respect to where it last left orbit
//            if(accuracyAngle >= 0){ _mainShip._clockwise = NO; } else { _mainShip._clockwise = YES; }
//            
//            CGPoint newPosition;
//            
//            //sets the curved path that the ship will take to go to the start of the orbit path
//            if(_mainShip._clockwise){
//                UIBezierPath *entrancePath = [UIBezierPath bezierPath];
//                [entrancePath moveToPoint:_mainShip.position];
//                CGFloat newAngle = _mainShip._plannetToShipAngle - (0.3 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed/ (_mainShip._currentPlannet._radius * 1.3));
//                newPosition = CGPointMake(_mainShip._currentPlannet.position.x + cos(newAngle)*_mainShip._currentPlannet._radius*1.3, _mainShip._currentPlannet.position.y + sin(newAngle)*_mainShip._currentPlannet._radius*1.3);
//                //makes a curve that goes from ship position to the desired position
//                [entrancePath
//                 addQuadCurveToPoint: newPosition
//                 controlPoint:CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlannet._radius*0.3*cos(_mainShip.zRotation), _mainShip._currentPlannet._radius*0.3*sin(_mainShip.zRotation)))];
//                _mainShip._currentPlannet._entrancePath = entrancePath;
//            }else{
//                UIBezierPath *entrancePath = [UIBezierPath bezierPath];
//                [entrancePath moveToPoint:_mainShip.position];
//                CGFloat newAngle = _mainShip._plannetToShipAngle + ((0.3 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed) / (_mainShip._currentPlannet._radius * 1.3));
//                newPosition = CGPointMake(_mainShip._currentPlannet.position.x + cos(newAngle)*_mainShip._currentPlannet._radius*1.3, _mainShip._currentPlannet.position.y + sin(newAngle)*_mainShip._currentPlannet._radius*1.3);
//                //makes a curve that goes from ship position to the desired position
//                [entrancePath
//                 addQuadCurveToPoint: newPosition
//                 controlPoint:CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlannet._radius*0.3*cos(_mainShip.zRotation), _mainShip._currentPlannet._radius*0.3*sin(_mainShip.zRotation)))];
//                _mainShip._currentPlannet._entrancePath = entrancePath;
//
//            }
//            
//            //sets the path that the ship will follow, starting and ending with its current position
//            //issue with clockwise - seems flipped for some reason here
//
//            CGFloat theNewAngle;
//            
//            if(_mainShip._clockwise){
//                theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, _mainShip._currentPlannet.position));
//                _mainShip._currentPlannet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlannet.position radius: _mainShip._currentPlannet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle - 2*M_PI + 0.0001 clockwise: !_mainShip._clockwise];
//                theNewAngle -= M_PI_2;
//            }else{
//                theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, _mainShip._currentPlannet.position));
//                _mainShip._currentPlannet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlannet.position radius: _mainShip._currentPlannet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle + 2*M_PI - 0.0001 clockwise: !_mainShip._clockwise];
//                theNewAngle += M_PI_2;
//            }
//
//
//            SKAction *followPath = [SKAction repeatActionForever: [SKAction followPath: _mainShip._currentPlannet._gravPath.CGPath asOffset: NO orientToPath: NO duration:((2*M_PI) *_mainShip._currentPlannet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS]];
//            
//            //runs the actions that enter the ship into orbit, set _onPlannet to true, and run laps around the plannet
//            [_mainShip runAction: [SKAction sequence:@[[SKAction group:@[[SKAction rotateToAngle:theNewAngle duration:0.3 shortestUnitArc:YES], [SKAction followPath:_mainShip._currentPlannet._entrancePath.CGPath asOffset:NO orientToPath:NO duration:0.4]]], [SKAction runBlock:^{ _mainShip._onPlannet = YES; }], followPath]]];
//            
//            
//            
//            if ( accuracyAngle > 4){
//                
//                accuracyAngle = abs(accuracyAngle);
//                
//                if(accuracyAngle <= 100 && accuracyAngle > 30){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 1.3 duration:0.3]];
//                }else if(accuracyAngle <= 30 && accuracyAngle > 20){
//                    //no change in speed
//                }else if(accuracyAngle <= 20 && accuracyAngle > 15){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.9 duration:0.3]];
//                }else if(accuracyAngle <= 15 && accuracyAngle > 12){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.75 duration:0.3]];
//                }else if(accuracyAngle <= 12 && accuracyAngle > 10){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.6 duration:0.3]];
//                }else if(accuracyAngle <= 10 && accuracyAngle > 8){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.5 duration:0.3]];
//                }else if(accuracyAngle <= 8 && accuracyAngle > 6){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.4 duration:0.3]];
//                }else if(accuracyAngle <= 6 && accuracyAngle > 4){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.25 duration:0.3]];
//                }
//                
//            }else if(accuracyAngle < -4){
//                
//                accuracyAngle = abs(accuracyAngle);
//                
//                if(accuracyAngle <= 100 && accuracyAngle > 30){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 1.3 duration:0.3]];
//                }else if(accuracyAngle <= 30 && accuracyAngle > 20){
//                    //no change in speed
//                }else if(accuracyAngle <= 20 && accuracyAngle > 15){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.9 duration:0.3]];
//                }else if(accuracyAngle <= 15 && accuracyAngle > 12){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.75 duration:0.3]];
//                }else if(accuracyAngle <= 12 && accuracyAngle > 10){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.6 duration:0.3]];
//                }else if(accuracyAngle <= 10 && accuracyAngle > 8){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.5 duration:0.3]];
//                }else if(accuracyAngle <= 8 && accuracyAngle > 6){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.4 duration:0.3]];
//                }else if(accuracyAngle <= 6 && accuracyAngle > 4){
//                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.25 duration:0.3]];
//                }
//                
//            }else if(accuracyAngle > -4 && accuracyAngle < 4){ NSLog(@"ship dead");}
//

            
        }else if(contact.bodyB.categoryBitMask == CNPhysicsCategoryGravityZone){
            
            //Ship *_currentShip = (Ship*)contact.bodyA.node;
            _mainShip._currentPlannet = (Plannet *)contact.bodyB.node.parent;
            [_mainShip._currentPlannet._gravZoneImage setScale: 1.03];
            _mainShip._currentPlannet._gravZoneImage.paused = YES;
            
            
            
            //sets the angle from the plannet to the ship

            _mainShip._plannetToShipAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlannet.position));
            while (_mainShip._plannetToShipAngle > 2*M_PI){ _mainShip._plannetToShipAngle -= 2*M_PI; }
            while (_mainShip._plannetToShipAngle < 0) { _mainShip._plannetToShipAngle += (2*M_PI);}
            
            //sets the angle from the ship to the plannet
            float shipToPlannetAngle = _mainShip._plannetToShipAngle - M_PI;
            while (shipToPlannetAngle > 2*M_PI){ shipToPlannetAngle -= 2*M_PI; }
            while (shipToPlannetAngle < 0) { shipToPlannetAngle += (2*M_PI);}
            
            //
            
            //finds the angle between the ship to plannet and plannet to last orbit position angle
            float accuracyAngle = ((float)180/M_PI*(shipToPlannetAngle - _mainShip.zRotation));
            
            NSLog(@"z rotation: %f", _mainShip.zRotation);
            NSLog(@"shipToPlannetAngle: %f", shipToPlannetAngle);
            NSLog(@"accuracy angle: %f", accuracyAngle);
            
            //sets the clockwise property depending on which side of the plannet the ship hit with respect to where it last left orbit
            if(accuracyAngle >= 0){ _mainShip._clockwise = NO; } else { _mainShip._clockwise = YES; }
            
            if (accuracyAngle > -4 && accuracyAngle < 4){
                _mainShip._dead = YES;
                [self killShip:_mainShip];
            }
            
            if(!_mainShip._dead){
                
                CGPoint newPosition;
                
                //sets the curved path that the ship will take to go to the start of the orbit path
                if(_mainShip._clockwise){
                    UIBezierPath *entrancePath = [UIBezierPath bezierPath];
                    [entrancePath moveToPoint:_mainShip.position];
                    CGFloat newAngle = _mainShip._plannetToShipAngle - M_PI_2*.3;
                    newPosition = CGPointMake(_mainShip._currentPlannet.position.x + cos(newAngle)*_mainShip._currentPlannet._radius*1.3, _mainShip._currentPlannet.position.y + sin(newAngle)*_mainShip._currentPlannet._radius*1.3);
                    //makes a curve that goes from ship position to the desired position
                    [entrancePath
                     addQuadCurveToPoint: newPosition
                     controlPoint:CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlannet._radius*0.3*cos(_mainShip.zRotation), _mainShip._currentPlannet._radius*0.3*sin(_mainShip.zRotation)))];
                    _mainShip._currentPlannet._entrancePath = entrancePath;
                }else{
                    UIBezierPath *entrancePath = [UIBezierPath bezierPath];
                    [entrancePath moveToPoint:_mainShip.position];
                    CGFloat newAngle = _mainShip._plannetToShipAngle + M_PI_2*.3;
                    newPosition = CGPointMake(_mainShip._currentPlannet.position.x + cos(newAngle)*_mainShip._currentPlannet._radius*1.3, _mainShip._currentPlannet.position.y + sin(newAngle)*_mainShip._currentPlannet._radius*1.3);
                    //makes a curve that goes from ship position to the desired position
                    [entrancePath
                     addQuadCurveToPoint: newPosition
                     controlPoint:CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlannet._radius*0.3*cos(_mainShip.zRotation), _mainShip._currentPlannet._radius*0.3*sin(_mainShip.zRotation)))];
                    _mainShip._currentPlannet._entrancePath = entrancePath;
                    
                }
                
                //sets the path that the ship will follow, starting and ending with its current position
                //issue with clockwise - seems flipped for some reason here
                
                
                CGFloat theNewAngle;
                
                if(_mainShip._clockwise){
                    theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, _mainShip._currentPlannet.position));
                    _mainShip._currentPlannet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlannet.position radius: _mainShip._currentPlannet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle - (2*M_PI - 0.0001) clockwise: !_mainShip._clockwise];
                    theNewAngle -= M_PI_2;
                }else{
                    theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, _mainShip._currentPlannet.position));
                    _mainShip._currentPlannet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlannet.position radius: _mainShip._currentPlannet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle + (2*M_PI - 0.0001) clockwise: !_mainShip._clockwise];
                    theNewAngle += M_PI_2;
                }
                
                
                SKAction *followPath = [SKAction repeatActionForever: [SKAction followPath: _mainShip._currentPlannet._gravPath.CGPath asOffset: NO orientToPath: NO duration:((2*M_PI) *_mainShip._currentPlannet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS]];
                
                //runs the actions that enter the ship into orbit, set _onPlannet to true, and run laps around the plannet
                [_mainShip runAction: [SKAction sequence:@[[SKAction group:@[[SKAction rotateToAngle:theNewAngle duration:0.3 shortestUnitArc:YES], [SKAction followPath:_mainShip._currentPlannet._entrancePath.CGPath asOffset:NO orientToPath:NO duration:(M_PI_2*.3*_mainShip._currentPlannet._radius)/NORMAL_SHIP_SPEED_PPS]]], [SKAction runBlock:^{ _mainShip._onPlannet = YES; }], followPath]]];
                
            }
            
            if ( accuracyAngle > 4){
                
                accuracyAngle = abs(accuracyAngle);
                
                if(accuracyAngle <= 100 && accuracyAngle > 30){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 1.3 duration:0.2]];
                }else if(accuracyAngle <= 30 && accuracyAngle > 20){
                    //no change in speed
                }else if(accuracyAngle <= 20 && accuracyAngle > 15){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.9 duration:0.2]];
                }else if(accuracyAngle <= 15 && accuracyAngle > 12){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.75 duration:0.2]];
                }else if(accuracyAngle <= 12 && accuracyAngle > 10){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.6 duration:0.2]];
                }else if(accuracyAngle <= 10 && accuracyAngle > 8){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.5 duration:0.2]];
                }else if(accuracyAngle <= 8 && accuracyAngle > 6){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.4 duration:0.2]];
                }else if(accuracyAngle <= 6 && accuracyAngle > 4){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.25 duration:0.2]];
                }
                
            }else if(accuracyAngle < -4){
                
                accuracyAngle = abs(accuracyAngle);
                
                if(accuracyAngle <= 100 && accuracyAngle > 30){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 1.3 duration:0.2]];
                }else if(accuracyAngle <= 30 && accuracyAngle > 20){
                    //no change in speed
                }else if(accuracyAngle <= 20 && accuracyAngle > 15){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.9 duration:0.2]];
                }else if(accuracyAngle <= 15 && accuracyAngle > 12){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.75 duration:0.2]];
                }else if(accuracyAngle <= 12 && accuracyAngle > 10){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.6 duration:0.2]];
                }else if(accuracyAngle <= 10 && accuracyAngle > 8){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.5 duration:0.2]];
                }else if(accuracyAngle <= 8 && accuracyAngle > 6){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.4 duration:0.2]];
                }else if(accuracyAngle <= 6 && accuracyAngle > 4){
                    [_mainShip runAction:[SKAction speedTo: _mainShip.speed * 0.25 duration:0.2]];
                }
                
            }

        }
        
    }
    
    
}

-(void) killShip:(Ship *)ship
{
    CGPoint deathPoint = CGPointAdd(ship._currentPlannet.position, CGPointMultiplyScalar(CGPointMake(cos(ship._plannetToShipAngle), sin(ship._plannetToShipAngle)), ship._currentPlannet._radius*1.1));
    CGPoint particleEmitterPosition = CGPointAdd(ship._currentPlannet.position, CGPointMultiplyScalar(CGPointMake(cos(ship._plannetToShipAngle), sin(ship._plannetToShipAngle)), ship._currentPlannet._radius));
    
    SKAction *flyToDeath = [SKAction moveTo:deathPoint duration:(ship._currentPlannet._radius*0.5)/NORMAL_SHIP_SPEED_PPS];
    
    [ship runAction: flyToDeath completion:^{
        
        [ship removeFromParent];
        
        //sets up the explosion effect
        SKEmitterNode *fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"]];
        SKEmitterNode *explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"]];
        
        [_backgroundLayer addChild:explosionEmitter];
        explosionEmitter.position = particleEmitterPosition;
        [explosionEmitter runAction:[SKAction sequence:@[[SKAction waitForDuration:2],[SKAction removeFromParent]]]];
        
        [ship._currentPlannet addChild:fireEmitter];
        fireEmitter.position = [_backgroundLayer convertPoint:particleEmitterPosition toNode:ship._currentPlannet];
        [fireEmitter setScale: 0];
        fireEmitter.emissionAngle = ship._plannetToShipAngle;
        
        [fireEmitter runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5],[SKAction scaleTo:0 duration:2],[SKAction removeFromParent]]]];
        
        SKAction *screenShake1 = [SKAction moveBy:CGVectorMake(10*cos(ship._plannetToShipAngle + M_PI_2), 10*sin(ship._plannetToShipAngle + M_PI_2)) duration:0.025];
        SKAction *screenShake2 = [screenShake1 reversedAction];
        SKAction *sequence = [SKAction sequence:@[screenShake1, screenShake2, screenShake2,screenShake1]];
        
        //lighter shake
        SKAction *finalShake1 = [SKAction moveBy:CGVectorMake(5*cos(ship._plannetToShipAngle + M_PI_2), 5*sin(ship._plannetToShipAngle + M_PI_2)) duration:0.025];
        SKAction *finalShake2 = [finalShake1 reversedAction];
        SKAction *sequence2 = [SKAction sequence:@[finalShake1, finalShake2, finalShake2, finalShake1]];
                                                   
        SKAction *fullShake = [SKAction sequence:@[sequence,sequence,sequence,sequence,sequence,sequence2,sequence2]];
        fullShake.timingMode = SKActionTimingEaseOut;
        [_background runAction: fullShake];
        [_backgroundLayer runAction:fullShake];
    }];
}

-(void)createPlannetField
{

    _earth = [[Plannet alloc] initWithSize:CGSizeMake(90,90) andPosition:CGPointMake(160, 120) andImage:@"Earth"];
    [_backgroundLayer addChild:_earth];
    CGRect earthRect = CGRectMake(160-45*1.6, 120-45*1.6, 90*1.6, 90*1.6);
    
    Plannet *stopLightPlannet1 = [[Plannet alloc] initWithSize:CGSizeMake(50,50) andPosition:CGPointMake(40, 120) andImage:@"plannet"];
    [_backgroundLayer addChild:stopLightPlannet1];
    CGRect stop1rect = CGRectMake(0, 80, 50*1.6, 50*1.6);
    
    Plannet *stopLightPlannet2 = [[Plannet alloc] initWithSize:CGSizeMake(50,50) andPosition:CGPointMake(280, 120) andImage:@"plannet"];
    [_backgroundLayer addChild:stopLightPlannet2];
    CGRect stop2rect = CGRectMake(240, 80, 50*1.6, 50*1.6);
    
    
    CGRect nilRect = CGRectMake(-20, -20, 0, 0);
    NSMutableArray *plannetRectArray = [NSMutableArray arrayWithObjects:[NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:stop1rect], [NSValue valueWithCGRect:earthRect], [NSValue valueWithCGRect:stop2rect], nil];
    
    for(int y = 0; y < 20; y++){
        for (int x = 0; x < 3; x++) {
            
            int xMin, xMax, yMin, yMax;
            
            if (x == 0){
                xMin = 10;
                xMax = 100;
            }else if (x == 1){
                xMin = 120;
                xMax = 200;
            }else if (x == 2){
                xMin = 220;
                xMax = 310;
            }
            
            yMin = 210+y*180+10;
            yMax = 210+(y+1)*180-10;
            
            
            
            int size;
            CGPoint position = CGPointMake(0, 0);
            CGRect plannetRect = CGRectMake(0, 0, 0, 0);
            CGRect plannetRect2 = CGRectMake(0, 0, 0, 0);
            
            int tries = 0;
            do{
                tries++;
                
                size = arc4random_uniform(50) + 30;
                
                position = CGPointMake(arc4random_uniform(xMax - xMin) + xMin, arc4random_uniform(yMax - yMin) + yMin);
                
                
                plannetRect = CGRectMake(position.x - .5*size*1.6, position.y - .5*size*1.6, size*1.6, size*1.6);
                
                if(plannetRect.origin.x < 0){
                    plannetRect2 = CGRectMake(plannetRect.origin.x + 320, plannetRect.origin.y, size*1.6, size*1.6);
                }else if(plannetRect.origin.x + size*1.6 > 320){
                    plannetRect2 = CGRectMake(plannetRect.origin.x - 320, plannetRect.origin.y, size*1.6, size*1.6);
                }
                
                
            }while( (CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:5] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:6] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:7] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:8] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:9] CGRectValue])||CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:1] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:2] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:3] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:4] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:5] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:6] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:7] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:8] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:9] CGRectValue])) && (tries < 20));
            
            if ((CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:5] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:6] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:7] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:8] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:9] CGRectValue])||CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:1] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:2] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:3] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:4] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:5] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:6] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:7] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:8] CGRectValue])||
                CGRectIntersectsRect(plannetRect2, [[plannetRectArray objectAtIndex:9] CGRectValue]))){
            }else{
                
                //sets the image
                int imageNum = arc4random_uniform(10);
                NSString *imageName;
                
                if (size <= 55){
                    switch (imageNum) {
                        case 0:
                            imageName = @"red_gray_cloudy";
                            break;
                        case 1:
                            imageName = @"dark_blue_green_wavy";
                            break;
                        case 2:
                            imageName = @"blue_green_speckelled";
                            break;
                        case 3:
                            imageName = @"blue_green_wavy";
                            break;
                        case 4:
                            imageName = @"blue_white_speckelled";
                            break;
                        case 5:
                            imageName = @"dark_sun";
                            break;
                        case 6:
                            imageName = @"green_black_cloudy";
                            break;
                        case 7:
                            imageName = @"green_brown_speckelled";
                            break;
                        case 8:
                            imageName = @"green_gray_wavy";
                            break;
                        case 9:
                            imageName = @"orange_yellow_wavy";
                            break;
                        default:
                            imageName = @"blank_plannet";
                            break;
                    }
                }else{
                    switch (imageNum) {
                        case 0:
                            imageName = @"thanos";
                            break;
                        case 1:
                            imageName = @"earth";
                            break;
                        case 2:
                            imageName = @"jupiter";
                            break;
                        case 3:
                            imageName = @"mars";
                            break;
                        case 4:
                            imageName = @"mercury";
                            break;
                        case 5:
                            imageName = @"moon";
                            break;
                        case 6:
                            imageName = @"venus";
                            break;
                        case 7:
                            imageName = @"neptune";
                            break;
                        case 8:
                            imageName = @"pluto";
                            break;
                        case 9:
                            imageName = @"sun";
                            break;
                        default:
                            imageName = @"blank_plannet";
                            break;
                    }
                }

                
                Plannet *plannet1 = [[Plannet alloc] initWithSize:CGSizeMake(size, size) andPosition:CGPointMake(position.x, position.y) andImage:imageName];
                [_backgroundLayer addChild:plannet1];
                
                [plannetRectArray removeObjectAtIndex:0];
                [plannetRectArray addObject:[NSValue valueWithCGRect:plannetRect]];
                
                if(plannetRect2.origin.y != 0 && plannetRect2.size.width != 0){
                    Plannet *plannet2 = [[Plannet alloc] initWithSize:CGSizeMake(size, size) andPosition:CGPointMake(plannetRect2.origin.x + .5*size*1.6, plannetRect2.origin.y + .5*size*1.6) andImage:imageName];
                    [_backgroundLayer addChild:plannet2];
                    
                    [plannetRectArray removeObjectAtIndex:0];
                    [plannetRectArray addObject:[NSValue valueWithCGRect:plannetRect2]];
                }
                
                
                
            }
            
        }
    }
}


@end
