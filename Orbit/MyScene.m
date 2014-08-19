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

        //set up _background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        _background.size = CGSizeMake(320, 570);
        //set scale and position for start screen
        [_background setScale:1.5];
        _background.anchorPoint = CGPointZero;
        _background.position = CGPointMake(-80, -10);
        
        
        //set up _backgroundLayer
        _backgroundLayer = [[BackgroundLayer alloc] init];
        //set anchorPoint and position for start screen
        _backgroundLayer.anchorPoint = CGPointZero;
        _backgroundLayer.position = CGPointZero;
        _backgroundLayer.size = CGSizeMake(360, 10000);
        
        //initialize ships
        _mainShip = [[Ship alloc] initWithPosition:CGPointMake(95,120) andColor:nil];
        _yellowShip = [[Ship alloc] initWithPosition:CGPointMake(100,120) andColor:[SKColor yellowColor]];
        _greenShip = [[Ship alloc] initWithPosition:CGPointMake(80,120) andColor:[SKColor greenColor]];
        _redShip = [[Ship alloc] initWithPosition:CGPointMake(60,120) andColor:[SKColor redColor]];
        _blueShip = [[Ship alloc] initWithPosition:CGPointMake(40,120) andColor:[SKColor blueColor]];
        //initialize an array of the ships
        _ships = [NSArray arrayWithObjects:_mainShip, _yellowShip, _greenShip, _redShip, _blueShip, nil];

        
        //set up orbit label
        _orbitLabel = [SKLabelNode labelNodeWithFontNamed:@"Earth Kid"];
        _orbitLabel.text = @"Orbit";
        _orbitLabel.fontSize = 60;
        _orbitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _orbitLabel.position = CGPointMake(160, 400);
        
        
        //set up highscore label
        _highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Heavy"];
        _highScoreLabel.text = [NSString stringWithFormat:@"High Score:\n%i miles",_highScore];
        _highScoreLabel.fontSize = 30;
        _highScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _highScoreLabel.position = CGPointMake(160, 100);
        
        //set up physics world
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        
        //set up instance variables
        _mainShip.zRotation = M_PI_2;
        
        //set up plannets
        [self createPlannetField];

        //add ship nodes to _backgroundLayer
        [_backgroundLayer addChild:_mainShip];
        //        [_backgroundLayer addChild:_yellowShip];
        //        [_backgroundLayer addChild:_greenShip];
        //        [_backgroundLayer addChild:_redShip];
        //        [_backgroundLayer addChild:_blueShip];

        
        //add _background, _backgroundLayer, _orbitLabel, _highscoreLabel nodes to the scene
        [self addChild:_background];
        [self addChild:_backgroundLayer];
        [self addChild:_orbitLabel];
        [self addChild:_highScoreLabel];
        
        //scale the backgroundLayer in
        [_backgroundLayer scaleIn];
        
    }

    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch");
    //if game has not been started
    if(!_gameStarted){
        
        //create action to scale _background out
        SKAction *scaleOut = [SKAction scaleTo:1.0 duration:0.5];
        SKAction *changePos = [SKAction moveTo:CGPointZero duration:0.5];
        SKAction *togetherNow =[SKAction group:@[scaleOut, changePos]];
        togetherNow.timingMode = SKActionTimingEaseOut;
        
        //create actions to fade labels
        SKAction *fadeLabel = [SKAction fadeAlphaTo:0 duration:0.5];
        SKAction *fadeLabel2 = [SKAction fadeAlphaTo:0 duration:0.2];
        
        //run the actions to fade the labels
        [_orbitLabel runAction: fadeLabel];
        [_highScoreLabel runAction:fadeLabel2];
        
        //run the actions to scale _backgroundLayer and _background out
        [_backgroundLayer scaleOut];
        [_background runAction:togetherNow];
        
        //set startgame to true after 0.6 seconds
        SKAction *startGame = [SKAction sequence:@[[SKAction waitForDuration:.6],[SKAction runBlock:^{
            _gameStarted = YES;
        }]]];
        [self runAction:startGame];
        
    //if game is in play and _mainShip has a current plannet
    }else if(_mainShip._currentPlannet){
        
        //remove all actions on the plannets gravzone image and start the pulsing action on it
        [_mainShip._currentPlannet._gravZoneImage removeAllActions];
        [_mainShip._currentPlannet._gravZoneImage runAction:_mainShip._currentPlannet._pulseAction];
        
        //set mainship to have no current plannet
        _mainShip._currentPlannet = nil;
        //set mainship inOrbit property to no
        _mainShip._inOrbit = NO;
        //set mainShip plannetToShipAngle property to 0
        _mainShip._plannetToShipAngle = 0;
        
        //remove all actions on mainShip and run freefly action based on the mainship zRotation property
        [_mainShip removeAllActions];
        SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
        [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
        
    }

}

-(void)update:(CFTimeInterval)currentTime {

    //_dt is the change in time since the last frame
    if(_lastUpdateTime){
        _dt = currentTime - _lastUpdateTime;
    }else{
        _dt=0;
    }
    _lastUpdateTime = currentTime;
    
    //if game is started and mainship speed property is less than 1.5
    if(_gameStarted && _mainShip.speed < 1.5){
        //increment speed by .1
        _mainShip.speed = 1;
    }
    
    //if the ship is being affected by a plannet
    if (!_mainShip._currentPlannet && !_mainShip._dead){
        
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
            
            //set z rotation of ship so that it aims away at the same angle it pointed to the baseline with before
            if (_mainShip.zRotation < 1.5 * M_PI)
                _mainShip.zRotation = M_PI - (_mainShip.zRotation - M_PI);
            else if (_mainShip.zRotation > 1.5 * M_PI)
                _mainShip.zRotation = 2 * M_PI - _mainShip.zRotation;
            
            //remove all actions on ship and run freefly action based on the ships zRotation property
            [_mainShip removeAllActions];
            SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
            [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
        }
        
        //if ship is between y = 210 & y = 240
        if ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y > 210){
            //move backgroundlayer at speed relative to ships position and ships dy velocity
            _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y - 210) / 30 * sin(_mainShip.zRotation)*NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        }
        
    //if ship is on plannet and game is started
    }else  if (_gameStarted && !_mainShip._dead){
        //if plannet is greater than y = 240
        if ([_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y > 240){
            //move background layer down at ship speed
                _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y -NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        //if plannet is between y = 130 and y = 240 in scene coords
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y <= 240 && [_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y > 130){
            //move backgroundLayer down at a fraction of mainship's speed relative to the plannets position
                _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y - 120) / 110 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        //if plannet is between y = 120 and y = 130
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y <= 130 && [_backgroundLayer convertPoint:_mainShip._currentPlannet.position toNode:self].y > 120){
            //move backgroundLayer down at small fraction of the ship speed
                _backgroundLayer.position = CGPointMake(0, _backgroundLayer.position.y - 1 / 11 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        }
    }
    
    //if the ship is currently in the orbit loop of a plannet
    if(_mainShip._inOrbit){
       _mainShip._plannetToShipAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlannet.position));
        //set z rotation of ship perpendicular to ships plannet to ship angle
        if(_mainShip._clockwise){ _mainShip.zRotation = _mainShip._plannetToShipAngle - M_PI_2; }
        else { _mainShip.zRotation = _mainShip._plannetToShipAngle + M_PI_2; }
    }
    
}

-(void)didSimulatePhysics{
    
}

//when ship touches a plannets gravity field
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"Contact");
    
    //gets collision bitmask based on two bodies
    uint32_t collision = (contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask);
    
    //if collision is between ship and gravzone
    if(collision == (CNPhysicsCategoryShip | CNPhysicsCategoryGravityZone)){
        
        //if body A of the contact is a gravity zone
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
//            //runs the actions that enter the ship into orbit, set _inOrbit to true, and run laps around the plannet
//            [_mainShip runAction: [SKAction sequence:@[[SKAction group:@[[SKAction rotateToAngle:theNewAngle duration:0.3 shortestUnitArc:YES], [SKAction followPath:_mainShip._currentPlannet._entrancePath.CGPath asOffset:NO orientToPath:NO duration:0.4]]], [SKAction runBlock:^{ _mainShip._inOrbit = YES; }], followPath]]];
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

        //if body B of contact is a gravZone
        }else if(contact.bodyB.categoryBitMask == CNPhysicsCategoryGravityZone){
            
            //Ship *_currentShip = (Ship*)contact.bodyA.node;
            //set ships current plannet as the parent of the body's node
            _mainShip._currentPlannet = (Plannet *)contact.bodyB.node.parent;
            //removes actions on current plannet's gravZone image
            [_mainShip._currentPlannet._gravZoneImage removeAllActions];
            //scale gravzone image to 1.03
            [_mainShip._currentPlannet._gravZoneImage runAction:[SKAction scaleTo:1.03 duration:0.2]];
            
            //remove all actions from mainship
            [_mainShip removeAllActions];
            
            //set the plannet to ship angle to a number between 0 and 2PI
            _mainShip._plannetToShipAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlannet.position));
            while (_mainShip._plannetToShipAngle > M_PI){ _mainShip._plannetToShipAngle -= M_PI; }
            while (_mainShip._plannetToShipAngle < -M_PI) { _mainShip._plannetToShipAngle += M_PI;}
            
            //set the angle from the ship to the plannet to a number between -M_PI and M_PI
            float shipToPlannetAngle = CGPointToAngle(CGPointSubtract(_mainShip._currentPlannet.position, _mainShip.position));
            while (shipToPlannetAngle > M_PI){ shipToPlannetAngle -= M_PI; }
            while (shipToPlannetAngle < -M_PI) { shipToPlannetAngle += M_PI;}
            
            //set the accuracy angle to the angle between the ship to plannet angle and the zRotation (directional angle) of the ship
            //set accuracy angle to a number between 0 and 2PI
            float accuracyAngle = ((float)180/M_PI*(_mainShip.zRotation - shipToPlannetAngle));
            
            NSLog(@"z rotation: %f", _mainShip.zRotation);
            NSLog(@"shipToPlannetAngle: %f", shipToPlannetAngle);
            NSLog(@"accuracy angle: %f", accuracyAngle);
            
            //sets the clockwise property depending on which side of the plannet the ship hit with respect to where it last left orbit
            if(accuracyAngle >= 0){ _mainShip._clockwise = YES; } else { _mainShip._clockwise = NO; }
            
            //if accuracy angle is between -4 and 4
            if (accuracyAngle > -4 && accuracyAngle < 4){
                //set mainships dead property to yes
                _mainShip._dead = YES;
                //run killShip method with mainship as a parameter
                [self killShip:_mainShip];
            }
            
            //if mainship is not dead
            if(!_mainShip._dead){
                
                CGPoint newPosition;
                
                //if ship should rotate clockwise
                if(_mainShip._clockwise){
                    //create the curved path that the ship will take to go to the start of the orbit path
                    UIBezierPath *entrancePath = [UIBezierPath bezierPath];
                    //set the angle the ship shoul go to
                    CGFloat newAngle = _mainShip._plannetToShipAngle - M_PI_4;
                    //set the end position with the new angle and the position and radius of the current plannet
                    newPosition = CGPointMake(_mainShip._currentPlannet.position.x + cos(newAngle)*_mainShip._currentPlannet._radius*1.3, _mainShip._currentPlannet.position.y + sin(newAngle)*_mainShip._currentPlannet._radius*1.3);
                    //make a control point for the curve that is 0.3 times the radius of the current plannet infront of the mainship
                    CGPoint controlPoint = CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlannet._radius*0.4*cos(_mainShip.zRotation), _mainShip._currentPlannet._radius*0.4*sin(_mainShip.zRotation)));
                    //make a curve that goes from ship position to the desired position
                    [entrancePath moveToPoint:_mainShip.position];
                    [entrancePath addQuadCurveToPoint: newPosition controlPoint:controlPoint];
                    _mainShip._currentPlannet._entrancePath = entrancePath;
                    //set the entrancePathLength based on the entrancePath specifications
                    _mainShip._entrancePathLength = [self bezierCurveLengthFromStartPoint:_mainShip.position toEndPoint:newPosition withControlPoint:controlPoint];
                }else{
                    //create the curved path that the ship will take to go to the start of the orbit path
                    UIBezierPath *entrancePath = [UIBezierPath bezierPath];
                    //set the angle the ship shoul go to
                    CGFloat newAngle = _mainShip._plannetToShipAngle + M_PI_4;
                    //set the end position with the new angle and the position and radius of the current plannet
                    newPosition = CGPointMake(_mainShip._currentPlannet.position.x + cos(newAngle)*_mainShip._currentPlannet._radius*1.3, _mainShip._currentPlannet.position.y + sin(newAngle)*_mainShip._currentPlannet._radius*1.3);
                    //make a control point for the curve that is 0.3 times the radius of the current plannet infront of the mainship
                    CGPoint controlPoint = CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlannet._radius*0.4*cos(_mainShip.zRotation), _mainShip._currentPlannet._radius*0.4*sin(_mainShip.zRotation)));
                    //make a curve that goes from ship position to the desired position
                    [entrancePath moveToPoint:_mainShip.position];
                    [entrancePath addQuadCurveToPoint: newPosition controlPoint:controlPoint];
                    _mainShip._currentPlannet._entrancePath = entrancePath;
                    //set the entrancePathLength based on the entrancePath specifications
                    _mainShip._entrancePathLength = [self bezierCurveLengthFromStartPoint:_mainShip.position toEndPoint:newPosition withControlPoint:controlPoint];                }
                
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
                
                //run the actions that enter the ship into orbit, set _inOrbit to true, and run the ship laps around the plannet
                [_mainShip runAction: [SKAction sequence:@[[SKAction group:@[[SKAction rotateToAngle:theNewAngle duration:_mainShip._entrancePathLength/NORMAL_SHIP_SPEED_PPS*_mainShip.speed shortestUnitArc:YES], [SKAction followPath:_mainShip._currentPlannet._entrancePath.CGPath asOffset:NO orientToPath:NO duration:_mainShip._entrancePathLength/NORMAL_SHIP_SPEED_PPS*_mainShip.speed]]], [SKAction runBlock:^{ _mainShip._inOrbit = YES; }], followPath]]];
                
            }
            
            if ( accuracyAngle > 4){
                
                accuracyAngle = abs(accuracyAngle);
                
                if(accuracyAngle <= 100 && accuracyAngle > 30){
                    if (_mainShip.speed < 1.5)
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

    _earth = [[Plannet alloc] initWithSize:CGSizeMake(90,90) andPosition:CGPointMake(160, 120) andImage:@"clear_earth"];
    [_backgroundLayer addChild:_earth];
    CGRect earthRect = CGRectMake(160-45*1.6, 120-45*1.6, 90*1.6, 90*1.6);
    
    Plannet *stopLightPlannet1 = [[Plannet alloc] initWithSize:CGSizeMake(50,50) andPosition:CGPointMake(40, 120) andImage:@"blank_plannet"];
    [_backgroundLayer addChild:stopLightPlannet1];
    CGRect stop1rect = CGRectMake(0, 80, 50*1.6, 50*1.6);
    
    Plannet *stopLightPlannet2 = [[Plannet alloc] initWithSize:CGSizeMake(50,50) andPosition:CGPointMake(280, 120) andImage:@"blank_plannet"];
    [_backgroundLayer addChild:stopLightPlannet2];
    CGRect stop2rect = CGRectMake(240, 80, 50*1.6, 50*1.6);
    
    
    CGRect nilRect = CGRectMake(-20, -20, 0, 0);
    NSMutableArray *plannetRectArray = [NSMutableArray arrayWithObjects: [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:stop1rect], [NSValue valueWithCGRect:earthRect], [NSValue valueWithCGRect:stop2rect], nil];
    
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
            
            int tries = 0;
            do{
                tries++;
                
                size = arc4random_uniform(50) + 30;
                
                position = CGPointMake(arc4random_uniform(xMax - xMin) + xMin, arc4random_uniform(yMax - yMin) + yMin);
                
                
                plannetRect = CGRectMake(position.x - .5*size*1.6, position.y - .5*size*1.6, size*1.6, size*1.6);
                
                
            }while( (CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:5] CGRectValue])|| (plannetRect.origin.x < 0) || (plannetRect.origin.x + plannetRect.size.width > 320)) && (tries < 20));
            
            if (CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(plannetRect, [[plannetRectArray objectAtIndex:5] CGRectValue])){
            }else{
                
                //sets the image
                int imageNum = arc4random_uniform(10);
                NSString *imageName;
                
                if (size <= 48){
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
                            imageName = @"bumpyEarth";
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
                
            }
            
        }
    }
    
    
}

- (float) bezierCurveLengthFromStartPoint: (CGPoint) start toEndPoint: (CGPoint) end withControlPoint: (CGPoint) control
{
    const int kSubdivisions = 50;
    const float step = 1.0f/(float)kSubdivisions;
    
    float totalLength = 0.0f;
    CGPoint prevPoint = start;
    
    // starting from i = 1, since for i = 0 calulated point is equal to start point
    for (int i = 1; i <= kSubdivisions; i++)
    {
        float t = i*step;
        
        float x = (1.0 - t)*(1.0 - t)*start.x + 2.0*(1.0 - t)*t*control.x + t*t*end.x;
        float y = (1.0 - t)*(1.0 - t)*start.y + 2.0*(1.0 - t)*t*control.y + t*t*end.y;
        
        CGPoint diff = CGPointMake(x - prevPoint.x, y - prevPoint.y);
        
        totalLength += sqrtf(diff.x*diff.x + diff.y*diff.y); // Pythagorean
        
        prevPoint = CGPointMake(x, y);
    }
    
    return totalLength;
}


@end
