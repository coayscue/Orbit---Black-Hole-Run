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
#import "Planet.h"
#import "Ship.h"
#import "ProgressBar.h"
#import "SKTUtils.h"
#import "ViewController.h"

static const float NORMAL_SHIP_SPEED_PPS = 60;

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKSpriteNode *_background;
    BackgroundLayer *_backgroundLayer;
    Planet *_earth;
    Ship *_mainShip;      //_ships[0]
    Ship *_yellowShip;    //_ships[1]
    Ship *_greenShip;     //_ships[2]
    Ship *_redShip;       //_ships[3]
    Ship *_blueShip;      //_ships[4]
    
    Planet *_stopLightPlanet1;
    Planet *_stopLightPlanet2;
    
    NSArray *_ships;
    NSMutableArray *_planets;
    int _plannetCounter;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    int _highScore;
    SKLabelNode *_orbitLabel;
    SKLabelNode *_recordLabel;
    SKLabelNode *_recordNumLabel;
    SKLabelNode *_lastScoreLabel;
    SKLabelNode *_yourScore;
    BOOL _gameStarted;
    int _miles;
    BOOL _newHighScore;
    SKLabelNode *_mileNumLabel;
    SKLabelNode *_milesLabel;

    int _nextMileDistance;
    SKAction *_popMileNum;
    ProgressBar *_progressBar;
    CGFloat _checkPoint1;
    CGFloat _checkPoint2;
    CGFloat _checkPoint3;
    CGFloat _checkPoint4;
    CGFloat _nextCheckP;
    BOOL _noMoreProgressBarUpdates;
    BOOL _paused;
    SKSpriteNode *_pauseMenu;
    SKSpriteNode *_deadMenu;
    SKSpriteNode *_resumeButton;
    SKSpriteNode *_mainMenuButton;
    SKSpriteNode *_deadShips;
    SKSpriteNode *_aliveShips;
    SKSpriteNode *_randSprite;
    SKSpriteNode *_pauseButton;
}

@synthesize theViewController;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
                
        //set up _background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        _background.size = CGSizeMake(self.size.width, self.size.height);
        //set scale and position for start screen
        [_background setScale:1.5];
        _background.anchorPoint = CGPointZero;
        _background.position = CGPointMake(-80, -10);
        
        //set up _backgroundLayer
        _backgroundLayer = [[BackgroundLayer alloc] init];
        //set anchorPoint and position for start screen
        _backgroundLayer.anchorPoint = CGPointZero;
        _backgroundLayer.size = CGSizeMake((self.size.width - 32), 100000);
        
        //initialize ships
        _mainShip = [[Ship alloc] initWithPosition:CGPointMake(_backgroundLayer.size.width*0.5 - 60, 120) andImage:@"main_ship"];
        _mainShip.name = @"main ship";
        _yellowShip = [[Ship alloc] initWithPosition:CGPointMake(5,120) andImage:@"yellow_ship"];
        _yellowShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone;
        _yellowShip.name = @"yellow ship";
        _greenShip = [[Ship alloc] initWithPosition:CGPointMake(65,120) andImage:@"green_ship"];
        _greenShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone;
        _greenShip.name = @"green ship";
        _redShip = [[Ship alloc] initWithPosition:CGPointMake(_backgroundLayer.size.width-5,120) andImage:@"red_ship"];
        _redShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone;
        _redShip.name = @"red ship";
        _blueShip = [[Ship alloc] initWithPosition:CGPointMake(_backgroundLayer.size.width-65,120) andImage:@"blue_ship"];
        _blueShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone;
        _blueShip.name = @"blue ship";
        //initialize an array of the ships
        _ships = [NSArray arrayWithObjects:_mainShip, _yellowShip, _redShip, _greenShip, _blueShip, nil];
        
        
        //set up orbit label
        _orbitLabel = [SKLabelNode labelNodeWithFontNamed:@"Earth Kid"];
        _orbitLabel.text = @"Orbit";
        _orbitLabel.fontSize = 60;
        _orbitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _orbitLabel.position = CGPointMake(self.size.width*0.5, 0.85*self.size.height);
        
        
        //set up record label
        _recordLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
        _recordLabel.text = @"Record: ";
        _recordLabel.fontSize = 30;
        _recordLabel.position = CGPointMake(self.size.width*0.5, 0.2*self.size.width);
        _recordNumLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
        _recordNumLabel.text = [NSString stringWithFormat:@"%i miles",_highScore];
        _recordNumLabel.fontSize = 30;
        _recordNumLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _recordNumLabel.position = CGPointMake(_recordLabel.position.x, _recordLabel.position.y - 10);
        
        //set up physics world
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        
        //set up pause button node
        _pauseButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"pause_button"] size:CGSizeMake(30, 35)];
        _pauseButton.anchorPoint = CGPointMake(0, 1);
        _pauseButton.position = CGPointMake(2, size.height-2);
        _pauseButton.alpha = 0;
        
        
        //set up miles counter
        //get font with outline
        _miles = 0;
        _mileNumLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
        _mileNumLabel.text = [NSString stringWithFormat:@"%i", _miles];
        _mileNumLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _mileNumLabel.fontSize = 35;
        _mileNumLabel.position = CGPointMake(self.size.width*0.5, self.size.height-17.5);
        _mileNumLabel.alpha = 0;
        _milesLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
        _milesLabel.text = @"MILES";
        _milesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _milesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        _milesLabel.fontSize = 15;
        _milesLabel.position = CGPointMake(self.size.width-5, _mileNumLabel.position.y);
        _milesLabel.alpha = 0;
        
        
        _popMileNum = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:0.1],[SKAction scaleTo:1.0 duration:0.1]]];
        _nextMileDistance = 400;
        
        
        //set up progress bar
        _progressBar = [[ProgressBar alloc] initWithScreenSize:self.size];
        _progressBar.alpha = 0;
        //set up checkpoints and progressbar variables
        _checkPoint1 = 400 + 300*2;
        _checkPoint2 = _checkPoint1 + 300*2;
        _checkPoint3 = _checkPoint2 + 300*5;
        _checkPoint4 = _checkPoint3 + 300*5;
        _progressBar._beforeLastCheckpointPos = 0;
        _progressBar._lastCheckpointPos = 0;
        _progressBar._nextCheckpointPos = _checkPoint1;
        _nextCheckP = _checkPoint2;
        _noMoreProgressBarUpdates = NO;

        
        //set up other variables
        _mainShip.zRotation = M_PI_2;
        _yellowShip.zRotation = M_PI_2;
        _greenShip.zRotation = -M_PI_2;
        _redShip.zRotation = -M_PI_2;
        _blueShip.zRotation = M_PI_2;
        _mainShip._newPos = _mainShip.position;
        _yellowShip._newPos = _yellowShip.position;
        _redShip._newPos = _redShip.position;
        _greenShip._newPos = _greenShip.position;
        _blueShip._newPos = _blueShip.position;
        
        _randSprite = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeZero];
        
        //sets ships running
        for (Ship* ship in _ships) {
            SKAction *freeFly = [SKAction moveByX:cos(ship.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(ship.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
            [ship runAction:[SKAction repeatActionForever:freeFly]];
        }
        
        //set up planets
        [self createPlanetField];
        
        //add ship nodes to _backgroundLayer
        [_backgroundLayer addChild:_mainShip];
        [_backgroundLayer addChild:_yellowShip];
        [_backgroundLayer addChild:_greenShip];
        [_backgroundLayer addChild:_redShip];
        [_backgroundLayer addChild:_blueShip];
        
        
        //add _background, _backgroundLayer, _orbitLabel, _recordLabel nodes to the scene
        [self addChild:_background];
        [self addChild:_backgroundLayer];
        [self addChild:_orbitLabel];
        [self addChild:_recordLabel];
        [self addChild:_recordNumLabel];
        [self addChild:_mileNumLabel];
        [self addChild:_milesLabel];
        [self addChild:_progressBar];
        [self addChild:_pauseButton];
        
        //scale the backgroundLayer in
        [_backgroundLayer scaleIn];
        
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch");
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    
    //if touch is on pause button
    if (!_paused && CGRectContainsPoint(CGRectMake(0, self.size.height-35, 30, 35), location)) {
        NSLog(@"paused!");
        _paused = YES;
        _pauseButton.texture = [SKTexture textureWithImageNamed:@"pause_button_pressed"];
        _mainShip.paused = YES;
        _yellowShip.paused = YES;
        _redShip.paused = YES;
        _greenShip.paused = YES;
        _blueShip.paused = YES;
        for (int i = _plannetCounter + 15; i >= _plannetCounter; i--){
            Planet *planet = [_planets objectAtIndex:i];
            planet.paused = YES;
        }
        [self openPausedMenu];
    //if resume button is pressed
    }else if (_paused && (CGRectContainsPoint(CGRectMake([_pauseMenu convertPoint:_resumeButton.position toNode:self].x - 0.5*_resumeButton.size.width, [_pauseMenu convertPoint:_resumeButton.position toNode:self].y - 0.5*_resumeButton.size.height, _resumeButton.size.width, _resumeButton.size.height), location)))
    {
        _resumeButton.texture = [SKTexture textureWithImageNamed:@"resume_button_pressed"];
        [_pauseMenu runAction:[SKAction scaleTo:0 duration:0.4] completion:^{
            _paused = NO;
            _pauseButton.texture = [SKTexture textureWithImageNamed:@"pause_button"];
            _mainShip.paused = NO;
            _yellowShip.paused = NO;
            _redShip.paused = NO;
            _greenShip.paused = NO;
            _blueShip.paused = NO;
            for (int i = _plannetCounter + 15; i >= _plannetCounter; i--){
                Planet *planet = [_planets objectAtIndex:i];
                planet.paused = NO;
            }
        }];
        
    }else if (_paused && (CGRectContainsPoint(CGRectMake([_pauseMenu convertPoint:_mainMenuButton.position toNode:self].x - 0.5*_mainMenuButton.size.width, [_pauseMenu convertPoint:_mainMenuButton.position toNode:self].y - 0.5*_mainMenuButton.size.height, _mainMenuButton.size.width, _mainMenuButton.size.height), location)))
    {
        _mainMenuButton.texture = [SKTexture textureWithImageNamed:@"main_menu_button_pressed"];
        MyScene *newScene = [MyScene sceneWithSize:self.size];
        newScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene: newScene transition:[SKTransition crossFadeWithDuration:2]];
        
    }else if (_mainShip._dead && (CGRectContainsPoint(CGRectMake([_deadMenu convertPoint:_mainMenuButton.position toNode:self].x - 0.5*_mainMenuButton.size.width, [_deadMenu convertPoint:_mainMenuButton.position toNode:self].y - 0.5*_mainMenuButton.size.height, _mainMenuButton.size.width, _mainMenuButton.size.height), location)))
    {
        _mainMenuButton.texture = [SKTexture textureWithImageNamed:@"main_menu_button_pressed"];
        MyScene *newScene = [MyScene sceneWithSize:self.size];
        newScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene: newScene transition:[SKTransition crossFadeWithDuration:2]];
        
        //if game has not been started
    }else if(!_gameStarted){
        
        [self zoomOut];
        
        //set startgame to true after 3.5 and changes the stoplight color every 1 second
        SKAction *startGame = [SKAction sequence:@[[SKAction waitForDuration:0.5],[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1 duration:1], [SKAction colorizeWithColor:[SKColor yellowColor] colorBlendFactor:1 duration:1], [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1 duration:1], [SKAction runBlock:^{
            _gameStarted = YES;
        }]]];
        [_stopLightPlanet1 runAction:startGame];
        [_stopLightPlanet1 runAction:startGame];
        
        //if game is in play and _mainShip has a current planet
    }else if(CGRectContainsPoint(CGRectMake(32, 0, _backgroundLayer.size.width, self.size.height - 35), location) && _mainShip._currentPlanet){
        
        //remove all actions on the planets gravzone image and start the pulsing action on it
        [_mainShip._currentPlanet._gravZoneImage removeAllActions];
        [_mainShip._currentPlanet._gravZoneImage runAction:_mainShip._currentPlanet._pulseAction];
        [_mainShip._currentPlanet popPlanet];
        
        
        //set mainship to have no current planet
        _mainShip._currentPlanet = nil;
        //set mainship inOrbit property to no
        _mainShip._inOrbit = NO;
        //set mainShip planetToShipAngle property to 0
        _mainShip._planetToShipAngle = 0;
        
        //remove all actions on mainShip and run freefly action based on the mainship zRotation property
        [_mainShip removeAllActions];
        SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
        [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
        
        
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    if (!_paused){
        //_dt is the change in time since the last frame
        if(_lastUpdateTime){
            _dt = currentTime - _lastUpdateTime;
        }else{
            _dt=0;
        }
        _lastUpdateTime = currentTime;
        
        [self updateMiles];
        
        //fade and change planets' physics bodies
        [self removePlanets];
        
        //move background
        [self moveBackground];
        
        
        //adjust progress bars
        if (!_noMoreProgressBarUpdates)
            //if returns yes, mainship is above next checkpoint
            if ([_progressBar adjustProgressBars_nextCheckPoint:_nextCheckP yellowPos:_yellowShip.position.y redPos:_redShip.position.y mainPos:_mainShip.position.y greenPos:_greenShip.position.y bluePos:_blueShip.position.y])
            {
                if (_nextCheckP == _checkPoint2)
                    _nextCheckP = _checkPoint3;
                if (_nextCheckP == _checkPoint3)
                    _nextCheckP = _checkPoint4;
                if (_nextCheckP == _checkPoint4)
                    _noMoreProgressBarUpdates = YES;
            }
    }
}

-(void)didSimulatePhysics
{
    //for every ship
    for (Ship *ship in _ships) {
        //update z rotation based on change in position
        [self updateZRotation:ship];
        
        //if game is started and ship speed property is less than 1.5
        if(_gameStarted && ship.speed < 1.5){
            //increment speed by .1
            ship.speed += _dt*.1;
        }
        
        //reposition ship if off screen
        [self repositionShip:_mainShip];
    }

}

//when ship touches a planets gravity field
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"Contact");
    
    //gets collision bitmask based on two bodies
    uint32_t collision = (contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask);
    
    //if collision is between ship and gravzone
    if(collision == (CNPhysicsCategoryShip | CNPhysicsCategoryMainshipGravityZone)){
        
        //if body A of the contact is a gravity zone
        if(contact.bodyA.categoryBitMask == CNPhysicsCategoryMainshipGravityZone){
            
            //insert bellow code
            
        }else if(contact.bodyB.categoryBitMask == CNPhysicsCategoryMainshipGravityZone){
            
            //Ship *_currentShip = (Ship*)contact.bodyA.node;
            //set ships current planet as the parent of the body's node
            _mainShip._currentPlanet = (Planet *)contact.bodyB.node.parent;
            //removes actions on current planet's gravZone image
            [_mainShip._currentPlanet._gravZoneImage removeAllActions];
            //scale gravzone image to 1.03
            [_mainShip._currentPlanet._gravZoneImage runAction:[SKAction scaleTo:1.03 duration:0.2]];
            
            //remove all actions from mainship
            [_mainShip removeAllActions];
            
            //set the planet to ship angle to a number between 0 and 2PI
            _mainShip._planetToShipAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlanet.position));
            while (_mainShip._planetToShipAngle > M_PI){ _mainShip._planetToShipAngle -= M_PI; }
            while (_mainShip._planetToShipAngle < -M_PI) { _mainShip._planetToShipAngle += M_PI;}
            
            //set the angle from the ship to the planet to a number between -M_PI and M_PI
            float shipToPlanetAngle = CGPointToAngle(CGPointSubtract(_mainShip._currentPlanet.position, _mainShip.position));
            while (shipToPlanetAngle > M_PI){ shipToPlanetAngle -= M_PI; }
            while (shipToPlanetAngle < -M_PI) { shipToPlanetAngle += M_PI; }
            
            //set the accuracy angle to the angle between the ship to planet angle and the zRotation (directional angle) of the ship
            //set accuracy angle to a number between 0 and 2PI
            float accuracyAngle = ((float)180/M_PI*(_mainShip.zRotation - shipToPlanetAngle));
            while (accuracyAngle > 100){ accuracyAngle -= 90; }
            while (accuracyAngle < -100) { accuracyAngle += 90; }
            
            NSLog(@"z rotation: %f", _mainShip.zRotation);
            NSLog(@"shipToplanetAngle: %f", shipToPlanetAngle);
            NSLog(@"accuracy angle: %f", accuracyAngle);
            
            //sets the clockwise property depending on which side of the planet the ship hit with respect to where it last left orbit
            if(accuracyAngle >= 0){ _mainShip._clockwise = YES; } else { _mainShip._clockwise = NO; }
            
            //if accuracy angle is between -4 and 4
            if (accuracyAngle > -4 && accuracyAngle < 4){
                //set mainships dead property to yes
                NSLog(@"dead!");
                _mainShip._dead = YES;
                _paused = YES;
                _yellowShip.paused = YES;
                _redShip.paused = YES;
                _greenShip.paused = YES;
                _blueShip.paused = YES;

                if (_miles > _highScore){
                    _newHighScore = YES;
                    _highScore = _miles;
                }
                
                [self killShip:_mainShip];
                [self runAction: [SKAction waitForDuration:2] completion:^{
                    [self openDeadMenu];
                }];
                
                
            }
            
            //if mainship is not dead
            if(!_mainShip._dead){
                
                CGPoint newPosition;
                
                //if ship should rotate clockwise
                if(_mainShip._clockwise){
                    //create the curved path that the ship will take to go to the start of the orbit path
                    UIBezierPath *entrancePath = [UIBezierPath bezierPath];
                    //set the angle the ship should go to
                    CGFloat newAngle = _mainShip._planetToShipAngle - M_PI_4;
                    //set the end position with the new angle and the position and radius of the current planet
                    newPosition = CGPointMake(_mainShip._currentPlanet.position.x + cos(newAngle)*_mainShip._currentPlanet._radius*1.3, _mainShip._currentPlanet.position.y + sin(newAngle)*_mainShip._currentPlanet._radius*1.3);
                    //make a control point for the curve that is 0.3 times the radius of the current planet infront of the mainship
                    CGPoint controlPoint = CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlanet._radius*0.4*cos(_mainShip.zRotation), _mainShip._currentPlanet._radius*0.4*sin(_mainShip.zRotation)));
                    //make a curve that goes from ship position to the desired position
                    [entrancePath moveToPoint:_mainShip.position];
                    [entrancePath addQuadCurveToPoint: newPosition controlPoint:controlPoint];
                    [entrancePath addArcWithCenter:_mainShip._currentPlanet.position radius:_mainShip._currentPlanet._radius * 1.3 startAngle:newAngle endAngle:newAngle - (2*M_PI - 0.0001) clockwise:NO];
                    _mainShip._currentPlanet._entrancePath = entrancePath;
                    //set the entrancePathLength based on the entrancePath specifications
                    _mainShip._entrancePathLength = [self bezierCurveLengthFromStartPoint:_mainShip.position toEndPoint:newPosition withControlPoint:controlPoint];
                }else{
                    //create the curved path that the ship will take to go to the start of the orbit path
                    UIBezierPath *entrancePath = [UIBezierPath bezierPath];
                    //set the angle the ship shoul go to
                    CGFloat newAngle = _mainShip._planetToShipAngle + M_PI_4;
                    //set the end position with the new angle and the position and radius of the current planet
                    newPosition = CGPointMake(_mainShip._currentPlanet.position.x + cos(newAngle)*_mainShip._currentPlanet._radius*1.3, _mainShip._currentPlanet.position.y + sin(newAngle)*_mainShip._currentPlanet._radius*1.3);
                    //make a control point for the curve that is 0.3 times the radius of the current planet infront of the mainship
                    CGPoint controlPoint = CGPointAdd(_mainShip.position, CGPointMake(_mainShip._currentPlanet._radius*0.4*cos(_mainShip.zRotation), _mainShip._currentPlanet._radius*0.4*sin(_mainShip.zRotation)));
                    //make a curve that goes from ship position to the desired position
                    [entrancePath moveToPoint:_mainShip.position];
                    [entrancePath addQuadCurveToPoint: newPosition controlPoint:controlPoint];
                    [entrancePath addArcWithCenter:_mainShip._currentPlanet.position radius:_mainShip._currentPlanet._radius * 1.3 startAngle:newAngle endAngle:newAngle + (2*M_PI - 0.0001) clockwise:YES];
                    _mainShip._currentPlanet._entrancePath = entrancePath;
                    //set the entrancePathLength based on the entrancePath specifications
                    _mainShip._entrancePathLength = [self bezierCurveLengthFromStartPoint:_mainShip.position toEndPoint:newPosition withControlPoint:controlPoint];
                }
                
                //sets the path that the ship will follow, starting and ending with its current position
                //issue with clockwise - seems flipped for some reason here
                
                CGFloat theNewAngle;
                
                if(_mainShip._clockwise){
                    theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, _mainShip._currentPlanet.position));
                    _mainShip._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlanet.position radius: _mainShip._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle - (2*M_PI - 0.0001) clockwise: !_mainShip._clockwise];
                    theNewAngle -= M_PI_2;
                }else{
                    theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, _mainShip._currentPlanet.position));
                    _mainShip._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlanet.position radius: _mainShip._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle + (2*M_PI - 0.0001) clockwise: !_mainShip._clockwise];
                    theNewAngle += M_PI_2;
                }
                
                
                SKAction *followPath = [SKAction repeatActionForever: [SKAction followPath: _mainShip._currentPlanet._gravPath.CGPath asOffset: NO orientToPath: NO duration:((2*M_PI) *_mainShip._currentPlanet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS]];
                
                //run the actions that enter the ship into orbit, set _inOrbit to true, and run the ship laps around the planet
                [ _mainShip runAction: [ SKAction sequence:@[ [ SKAction followPath:_mainShip._currentPlanet._entrancePath.CGPath asOffset:NO orientToPath:NO duration:_mainShip._entrancePathLength/NORMAL_SHIP_SPEED_PPS+((2*M_PI) *_mainShip._currentPlanet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS ], followPath ] ] ];
                
                [ self runAction:[ SKAction waitForDuration:_mainShip._entrancePathLength/NORMAL_SHIP_SPEED_PPS] completion:^{
                    _mainShip._inOrbit = YES;
                } ];
                
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
    CGPoint deathPoint = CGPointAdd(ship._currentPlanet.position, CGPointMultiplyScalar(CGPointMake(cos(ship._planetToShipAngle), sin(ship._planetToShipAngle)), ship._currentPlanet._radius*1.1));
    CGPoint particleEmitterPosition = CGPointAdd(ship._currentPlanet.position, CGPointMultiplyScalar(CGPointMake(cos(ship._planetToShipAngle), sin(ship._planetToShipAngle)), ship._currentPlanet._radius));
    

    SKAction *flyToDeath = [SKAction moveTo:deathPoint duration:(ship._currentPlanet._radius*0.9)/NORMAL_SHIP_SPEED_PPS];
    
    [ship runAction: flyToDeath completion:^{
        
        [ship removeFromParent];
        
        //sets up the explosion effect
        SKEmitterNode *fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"]];
        SKEmitterNode *explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"]];
        
        [_backgroundLayer addChild:explosionEmitter];
        explosionEmitter.position = particleEmitterPosition;
        [explosionEmitter runAction:[SKAction sequence:@[[SKAction waitForDuration:2],[SKAction removeFromParent]]]];
        
        [ship._currentPlanet addChild:fireEmitter];
        fireEmitter.position = [_backgroundLayer convertPoint:particleEmitterPosition toNode:ship._currentPlanet];
        [fireEmitter setScale: 0];
        fireEmitter.emissionAngle = ship._planetToShipAngle;
        
        [fireEmitter runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5],[SKAction scaleTo:0 duration:2],[SKAction removeFromParent]]]];
        
        SKAction *screenShake1 = [SKAction moveBy:CGVectorMake(10*cos(ship._planetToShipAngle + M_PI_2), 10*sin(ship._planetToShipAngle + M_PI_2)) duration:0.025];
        SKAction *screenShake2 = [screenShake1 reversedAction];
        SKAction *sequence = [SKAction sequence:@[screenShake1, screenShake2, screenShake2,screenShake1]];
        
        //lighter shake
        SKAction *finalShake1 = [SKAction moveBy:CGVectorMake(5*cos(ship._planetToShipAngle + M_PI_2), 5*sin(ship._planetToShipAngle + M_PI_2)) duration:0.025];
        SKAction *finalShake2 = [finalShake1 reversedAction];
        SKAction *sequence2 = [SKAction sequence:@[finalShake1, finalShake2, finalShake2, finalShake1]];
        
        SKAction *fullShake = [SKAction sequence:@[sequence,sequence,sequence,sequence,sequence,sequence2,sequence2]];
        fullShake.timingMode = SKActionTimingEaseOut;
        [_background runAction: fullShake];
        [_backgroundLayer runAction:fullShake];
    }];
}

-(void) createPlanetField
{
    _planets = [[NSMutableArray alloc] init];
    
    _earth = [[Planet alloc] initWithSize:CGSizeMake(85,85) andPosition:CGPointMake(_backgroundLayer.size.width*0.5, 120) andImage:@"clear_earth"];
    [_backgroundLayer addChild:_earth];
    CGRect earthRect = CGRectMake(_backgroundLayer.size.width*0.5-42.5*1.8, 120-42.5*1.8, 90*1.8, 90*1.8);
    [_planets addObject:_earth];
    
    _stopLightPlanet1 = [[Planet alloc] initWithSize:CGSizeMake(40,40) andPosition:CGPointMake(35, 120) andImage:@"blank_planet"];
    _stopLightPlanet1._planetBody.colorBlendFactor = 1;
    [_backgroundLayer addChild:_stopLightPlanet1];
    CGRect stop1rect = CGRectMake(0, 80, 40*1.8, 40*1.8);
    [_planets addObject:_stopLightPlanet1];
    
    _stopLightPlanet2 = [[Planet alloc] initWithSize:CGSizeMake(40,40) andPosition:CGPointMake(_backgroundLayer.size.width-35, 120) andImage:@"blank_planet"];
    _stopLightPlanet2._planetBody.colorBlendFactor = 1;
    [_backgroundLayer addChild:_stopLightPlanet2];
    CGRect stop2rect = CGRectMake(_backgroundLayer.size.width-80, 80, 40*1.8, 40*1.8);
    [_planets addObject:_stopLightPlanet2];
    
    CGRect nilRect = CGRectMake(-20, -20, 0, 0);
    NSMutableArray *planetRectArray = [NSMutableArray arrayWithObjects: [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:stop1rect], [NSValue valueWithCGRect:earthRect], [NSValue valueWithCGRect:stop2rect], nil];
    
    for(int y = 0; y < 60; y++){
        for (int x = 0; x < 3; x++) {
            
            int xMin, xMax, yMin, yMax;
            
            if (x == 0){
                xMin = 10;
                xMax = _backgroundLayer.size.width*.33-10;
            }else if (x == 1){
                xMin = _backgroundLayer.size.width*.33+10;
                xMax = _backgroundLayer.size.width*.66-10;
            }else if (x == 2){
                xMin = _backgroundLayer.size.width*.66+10;
                xMax = _backgroundLayer.size.width-10;
            }
            
            yMin = 210+ y*(self.size.height*.33)+10;
            yMax = 210+(y+1)*(self.size.height*.33)-10;
            
            int size;
            CGPoint position = CGPointMake(0, 0);
            CGRect planetRect = CGRectMake(0, 0, 0, 0);
            
            int tries = 0;
            do{
                tries++;
                
                size = arc4random_uniform(50) + 30;
                
                position = CGPointMake(arc4random_uniform(xMax - xMin) + xMin, arc4random_uniform(yMax - yMin) + yMin);
                
                
                planetRect = CGRectMake(position.x - 0.5*size*1.8, position.y - 0.5*size*1.8, size*1.8, size*1.8);
                
                
            }while( (CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:5] CGRectValue])|| (planetRect.origin.x < 0) || (planetRect.origin.x + planetRect.size.width > _backgroundLayer.size.width)) && (tries < 20));
            
            if (CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:5] CGRectValue])|| (planetRect.origin.x + planetRect.size.width > _backgroundLayer.size.width)){
                //move on
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
                            imageName = @"blank_planet";
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
                            imageName = @"blank_planet";
                            break;
                    }
                }
                
                Planet *planet1 = [[Planet alloc] initWithSize:CGSizeMake(size, size) andPosition:CGPointMake(position.x, position.y) andImage:imageName];
                [_backgroundLayer addChild:planet1];
                
                [planetRectArray removeObjectAtIndex:0];
                [planetRectArray addObject:[NSValue valueWithCGRect:planetRect]];
                
                [_planets addObject:planet1];
                
            }
            
        }
    }
    
    NSLog(@"%lu", (unsigned long)[_planets count]);
    
}

- (float) bezierCurveLengthFromStartPoint: (CGPoint) start toEndPoint: (CGPoint) end withControlPoint: (CGPoint) control
{
    const int kSubdivisions = 3;
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

-(void) updateZRotation:(Ship *)ship
{
    ship._oldPos = ship._newPos;
    ship._newPos = ship.position;
    if ([_backgroundLayer convertPoint:ship.position toNode:self].y > 1 && [_backgroundLayer convertPoint:ship.position toNode:self].x > _backgroundLayer.position.x + 1 && [_backgroundLayer convertPoint:ship.position toNode:self].x < self.size.width - 1)
        if( CGPointToAngle(CGPointSubtract(ship._newPos, ship._oldPos)) != 0 && CGPointToAngle(CGPointSubtract(ship._newPos, ship._oldPos)) != M_PI)
            ship.zRotation = CGPointToAngle(CGPointSubtract(ship._newPos, ship._oldPos));
}

-(void) removePlanets
{
    //enumerate the bottom six objcts in the planets array, starting with [5], working down
    if(_gameStarted){
        for (int i = _plannetCounter + 7; i >= _plannetCounter; i--) {
            Planet *planet = [_planets objectAtIndex:i];
            //if planet's position is lower than y = size.height/2*1.4
            if([_backgroundLayer convertPoint:planet.position toNode:self].y < planet._size.height/2*1.4){
                //set the planets physics body to nil
                planet._gravZone.physicsBody.categoryBitMask = CNPhysicsCategoryOthershipGravityZone;
                //set the planets alpha transparency to (position+size.height/2*1.4) / size.height*1.4
                planet._gravZoneImage.alpha = ([_backgroundLayer convertPoint:planet.position toNode:self].y+planet._size.height/2*1.4) / (planet._size.height*1.4)*0.5;
                planet._planetBody.alpha = ([_backgroundLayer convertPoint:planet.position toNode:self].y+planet._size.height/2*1.4) / (planet._size.height*1.4);
                
                //if the planet's position+size.height/2*1.4 < 0
                if ([_backgroundLayer convertPoint:planet.position toNode:self].y + planet._size.height/2*1.4 < 0)
                {
                    _plannetCounter++;
                }
            }
        }
    }
}

-(void) moveBackground
{
    if (!_mainShip._currentPlanet && !_mainShip._dead){
        //if ship position is greater than y = 0.4
        if ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y > 0.3*self.size.height){
            //move backgroundlayer at speed relative to ships position and ships dy velocity
            _backgroundLayer.position = CGPointMake(31, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y - 0.3*self.size.height) / (0.1*self.size.height) * sin(_mainShip.zRotation)*NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        }
        
        //if ship is on planet and game is started
    }else  if (_gameStarted && !_mainShip._dead){
        
        //if planet position is greater than y = .5
        if ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y > 0.5*self.size.height){
            //move background layer down at ship speed
            _backgroundLayer.position = CGPointMake(30, _backgroundLayer.position.y -NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        //if planet is between y = .22 and y = .5 in scene coords
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y <= 0.5*self.size.height && [_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y > 0.22*self.size.height){
            //move backgroundLayer down at a fraction of mainship's speed relative to the planets position
            _backgroundLayer.position = CGPointMake(30, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y - 0.28*self.size.height) / (0.2*self.size.height) * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        //if planet is between y = .2 and y = .22
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y <= 0.22*self.size.height && [_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y > 0.2*self.size.height){
            //move backgroundLayer down at small fraction of the ship speed
            _backgroundLayer.position = CGPointMake(30, _backgroundLayer.position.y - .02/.2 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        }
    }

}

-(void) repositionShip:(Ship *)ship
{
    //if the ship is being affected by a planet
    if (!ship._currentPlanet && !ship._dead){
        
        //sets ship to reapear on opposite side of the screen
        if ( ship.position.x < 0){
            ship.position = CGPointMake(_backgroundLayer.size.width, ship.position.y);
        }else if (ship.position.x > _backgroundLayer.size.width){
            ship.position = CGPointMake(0, ship.position.y);
        }
        
        //if ship is bellow screen
        if ( [_backgroundLayer convertPoint:ship.position toNode:self].y < 0){
            //flip ship over line x = .5
            ship.position = CGPointMake(_backgroundLayer.size.width - ship.position.x, [self convertPoint:CGPointMake(0,1) toNode:_backgroundLayer].y);
            
            //set z rotation of ship so that it aims away at the same angle it pointed to the baseline with before
            if (ship.zRotation < 1.5 * M_PI)
                ship.zRotation = M_PI - (ship.zRotation - M_PI);
            else if (ship.zRotation > 1.5 * M_PI)
                ship.zRotation = 2 * M_PI - ship.zRotation;
            
            //remove all actions on ship and run freefly action based on the ships zRotation property
            [ship removeAllActions];
            SKAction *freeFly = [SKAction moveByX:cos(ship.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(ship.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
            [ship runAction:[SKAction repeatActionForever:freeFly]];
        }
    }

}

-(void) zoomOut
{
    //create action to scale _background out
    SKAction *scaleOut = [SKAction scaleTo:1.0 duration:0.5];
    SKAction *changePos = [SKAction moveTo:CGPointZero duration:0.5];
    SKAction *togetherNow =[SKAction group:@[scaleOut, changePos]];
    togetherNow.timingMode = SKActionTimingEaseOut;
    
    //create actions to fade labels
    SKAction *fadeLabel = [SKAction fadeAlphaBy:-1 duration:0.5];
    SKAction *fadeLabel2 = [SKAction fadeAlphaTo:0 duration:0.2];
    
    //run the actions to fade the labels
    [_orbitLabel runAction: fadeLabel];
    [_recordLabel runAction:fadeLabel2];
    [_recordNumLabel runAction:fadeLabel2];
    [_mileNumLabel runAction:[fadeLabel reversedAction]];
    [_milesLabel runAction:[fadeLabel reversedAction]];
    [_progressBar runAction:[fadeLabel reversedAction]];
    [_pauseButton runAction:[fadeLabel reversedAction]];
    
    //run the actions to scale _backgroundLayer and _background out
    [_backgroundLayer scaleOut];
    [_background runAction:togetherNow];
    
    
}

-(void) updateMiles
{
    //if ships position is greater than the next mile distance
    if(_mainShip.position.y > _nextMileDistance){
        //make mileNumLabel pop and change the miles
        _miles++;
        _mileNumLabel.text = [NSString stringWithFormat:@"%i", _miles];
        _milesLabel.text = (_miles == 1) ? @"MILE" : @"MILES";
        [_mileNumLabel runAction:_popMileNum];
        _nextMileDistance += 300;
    }
}

-(void) openDeadMenu
{
    CGPoint shipPosToTopLeftVector = CGPointSubtract(CGPointMake(30, self.size.height-35), [_backgroundLayer convertPoint:_mainShip.position toNode:self]);
    
    _deadMenu = [SKSpriteNode spriteNodeWithImageNamed:@"pause_death_screen"];
    _deadMenu.anchorPoint = CGPointMake(_mainShip.position.x/_backgroundLayer.size.width, [_backgroundLayer convertPoint:_mainShip.position toNode:self].y/(self.size.height-35));
    _deadMenu.position = [_backgroundLayer convertPoint:_mainShip.position toNode:self];
    _deadMenu.size = CGSizeMake(_backgroundLayer.size.width, self.size.height-35);
    _deadMenu.xScale = 0;
    _deadMenu.yScale = 0;
    
    _mainMenuButton = [SKSpriteNode spriteNodeWithImageNamed:@"main_menu_button"];
    _mainMenuButton.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.80));
    _mainMenuButton.size = CGSizeMake(_backgroundLayer.size.width*0.6, 0.25*_backgroundLayer.size.width*0.6);
    [_deadMenu addChild:_mainMenuButton];
    
    //[self createDeadShipsImage];
    _deadShips = [SKSpriteNode spriteNodeWithImageNamed:@"venus"];
    _deadShips.size = CGSizeMake(30, 30);
    _deadShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.68));
    [_deadMenu addChild:_deadShips];
    
    [self removeChildrenInArray:@[_recordLabel, _recordNumLabel]];
    _recordLabel.alpha = 1;
    _recordNumLabel.alpha = 1;
    _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.52));
    _recordNumLabel.position = CGPointAdd(shipPosToTopLeftVector,CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.52 - 10));
    _recordLabel.fontSize = 30;
    _recordNumLabel.fontSize = 30;
    [_deadMenu addChild:_recordLabel];
    [_deadMenu addChild:_recordNumLabel];
    
//    _yourScore = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
//    _yourScore.text = @"Your score:";
//    _yourScore.fontSize = 30;
//    _yourScore.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.35));
//    [_deadMenu addChild:_yourScore];
    
    
    _mileNumLabel.text = (_miles == 1) ? [NSString stringWithFormat:@"%i mile", _miles]: [NSString stringWithFormat:@"%i miles", _miles];
//    _mileNumLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _mileNumLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.35 - 10));
    [self removeChildrenInArray:@[_mileNumLabel]];
    [_deadMenu addChild:_mileNumLabel];
    
    //[self createAliveShipsImage];
    _aliveShips = [SKSpriteNode spriteNodeWithImageNamed:@"sun"];
    _aliveShips.size = CGSizeMake(30,30);
    _aliveShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.2));
    [_deadMenu addChild:_aliveShips];
    
    if (_newHighScore){
        _recordNumLabel.alpha = 0;
        _recordLabel.text = @"New Record!";
        _recordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.5));
        SKAction *pulse = [SKAction scaleBy: 1.1 duration:0.5];
        pulse.timingMode = SKActionTimingEaseInEaseOut;
        [_recordLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[pulse, [pulse reversedAction]]]]];
        [_mileNumLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[pulse, [pulse reversedAction]]]]];
    }
    
    [self addChild:_deadMenu];
    SKAction *presentDeadMenu = [SKAction scaleTo:1 duration:0.5];
    presentDeadMenu.timingMode = SKActionTimingEaseOut;
    [_deadMenu runAction:presentDeadMenu];
}

//test these methods, change create aliveshipimage and deadshipimage to random images to place on screen

-(void) openPausedMenu
{
    _pauseMenu = [SKSpriteNode spriteNodeWithImageNamed:@"pause_death_screen"];
    
    _pauseMenu.anchorPoint = CGPointMake(0, 1);
    _pauseMenu.position = CGPointMake(30, self.size.height-35);
    _pauseMenu.size = CGSizeMake(_backgroundLayer.size.width, self.size.height-35);
    _pauseMenu.xScale = 0;
    _pauseMenu.yScale = 0;
    
    _resumeButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"resume_button"]
                                                   size: CGSizeMake(_backgroundLayer.size.width*.45, 0.33*_backgroundLayer.size.width*.45) ];
    _resumeButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.57);
    [_pauseMenu addChild:_resumeButton];
    
    _mainMenuButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"main_menu_button"]
                                                     size: CGSizeMake(_backgroundLayer.size.width*0.6, 0.25*_backgroundLayer.size.width*0.6) ];
    _mainMenuButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.68);
    [_pauseMenu addChild:_mainMenuButton];
    
    [self removeChildrenInArray:@[_recordLabel, _recordNumLabel]];
    _recordLabel.alpha = 1;
    _recordNumLabel.alpha = 1;
    _recordLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.80);
    _recordNumLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.80 - 10);
    _recordLabel.fontSize = 30;
    _recordNumLabel.fontSize = 30;
    [_pauseMenu addChild:_recordLabel];
    [_pauseMenu addChild:_recordNumLabel];
    
    
    //[self createDeadShipsImage];
    _deadShips = [SKSpriteNode spriteNodeWithImageNamed:@"venus"];
    _deadShips.size = CGSizeMake(30, 30);
    _deadShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.4);
    [_pauseMenu addChild:_deadShips];
    
    //[self createAliveShipsImage];
    _aliveShips = [SKSpriteNode spriteNodeWithImageNamed:@"sun"];
    _aliveShips.size = CGSizeMake(30,30);
    _aliveShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(self.size.height-35)*0.22);
    [_pauseMenu addChild:_aliveShips];
    
    [self addChild:_pauseMenu];
    SKAction *presentPauseMenu = [SKAction scaleTo:1 duration:0.4];
    presentPauseMenu.timingMode = SKActionTimingEaseOut;
    [_pauseMenu runAction:presentPauseMenu];
}

//
//-(void)createDeadShipsImage
//{
//    NSMutableArray *deadArray = [NSMutableArray array];
//    for (Ship *ship in _ships){
//        if(ship._dead){
//          [deadArray addObject:ship];
//        }
//    }
//    
//    SKSpriteNode *yellowRubble = [SKSpriteNode spriteNodeWithImageNamed:@"yellow_ship_rubble"];
//    yellowRubble.zRotation = arc4random_uniform(2*M_PI);
//    yellowRubble.size = CGSizeMake(20, 20);
//    
//    SKSpriteNode *redRubble = [SKSpriteNode spriteNodeWithImageNamed:@"red_ship_rubble"];
//    redRubble.zRotation = arc4random_uniform(2*M_PI);
//    redRubble.size = CGSizeMake(20, 20);
//    
//    SKSpriteNode *mainRubble = [SKSpriteNode spriteNodeWithImageNamed:@"main_ship_rubble"];
//    mainRubble.zRotation = arc4random_uniform(2*M_PI);
//    mainRubble.size = CGSizeMake(20, 20);
//    
//    SKSpriteNode *greenRubble = [SKSpriteNode spriteNodeWithImageNamed:@"green_ship_rubble"];
//    greenRubble.zRotation = arc4random_uniform(2*M_PI);
//    greenRubble.size = CGSizeMake(20, 20);
//    
//    SKSpriteNode *blueRubble = [SKSpriteNode spriteNodeWithImageNamed:@"blue_ship_rubble"];
//    blueRubble.zRotation = arc4random_uniform(2*M_PI);
//    blueRubble.size = CGSizeMake(20, 20);
//    
//    switch ([deadArray count]) {
//        case 0:
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(0, 0)];
//            break;
//            
//        case 1:
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(30, 30)];
//            Ship *ship11 = (Ship *)[deadArray objectAtIndex:0];
//            if ([ship11.name  isEqual: @"yellow ship"]){
//                [_deadShips addChild:yellowRubble];
//            
//            }else if ([ship11.name  isEqual: @"red ship"]){
//                [_deadShips addChild:redRubble];
//            }else if ([ship11.name  isEqual: @"main ship"]){
//                [_deadShips addChild:mainRubble];
//            }else if ([ship11.name  isEqual: @"green ship"]){
//                [_deadShips addChild:greenRubble];
//            }else if ([ship11.name  isEqual: @"blue ship"]){
//                [_deadShips addChild:blueRubble];
//            }
//            break;
//            
//        case 2:
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(60,30)];
//            Ship *ship21 = (Ship *)[deadArray objectAtIndex:0];
//            if ([ship21.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(-_deadShips.size.width/4, 0);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship21.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(-_deadShips.size.width/4, 0);
//                [_deadShips addChild:redRubble];
//            }else if ([ship21.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(-_deadShips.size.width/4, 0);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship21.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(-_deadShips.size.width/4, 0);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship21.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(-_deadShips.size.width/4, 0);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship22 = (Ship *)[deadArray objectAtIndex:1];
//            if ([ship22.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width/4, 0);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship22.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width/4, 0);
//                [_deadShips addChild:redRubble];
//            }else if ([ship22.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width/4, 0);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship22.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width/4, 0);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship22.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width/4, 0);
//                [_deadShips addChild:blueRubble];
//            }
//            break;
//            
//        case 3:
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(60, 60)];
//            Ship *ship31 = (Ship *)[deadArray objectAtIndex:0];
//            if ([ship31.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(0, _deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship31.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(0, _deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship31.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(0, _deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship31.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(0, _deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship31.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(0, _deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship32 = (Ship *)[deadArray objectAtIndex:1];
//            if ([ship32.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(-_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship32.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(-_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship32.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(-_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship32.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(-_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship32.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(-_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship33 = (Ship *)[deadArray objectAtIndex:2];
//            if ([ship33.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship33.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship33.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship33.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship33.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width/4, -_deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//        
//            break;
//        
//        case 4:
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(90, 60)];
//            Ship *ship41 = (Ship *)[deadArray objectAtIndex:0];
//            if ([ship41.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship41.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship41.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship41.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship41.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship42 = (Ship *)[deadArray objectAtIndex:1];
//            if ([ship42.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship42.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship42.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship42.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship42.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship43 = (Ship *)[deadArray objectAtIndex:2];
//            if ([ship43.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship43.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//            }else if ([ship43.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship43.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship43.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship44 = (Ship *)[deadArray objectAtIndex:3];
//            if ([ship44.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship44.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship44.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship44.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship44.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            break;
//            
//        case 5:
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(90, 60)];
//            Ship *ship51 = (Ship *)[deadArray objectAtIndex:0];
//            if ([ship51.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship51.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship51.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship51.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship51.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(-_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship52 = (Ship *)[deadArray objectAtIndex:1];
//            if ([ship52.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship52.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship52.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship52.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship52.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(-_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship53 = (Ship *)[deadArray objectAtIndex:2];
//            if ([ship53.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship53.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship53.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship53.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship53.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width*0.333*0.5, -_deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship54 = (Ship *)[deadArray objectAtIndex:3];
//            if ([ship54.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship54.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship54.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship54.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship54.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width*0.333, _deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            Ship *ship55 = (Ship *)[deadArray objectAtIndex:4];
//            if ([ship55.name  isEqual: @"yellow ship"]){
//                yellowRubble.position = CGPointMake(_deadShips.size.width/2, _deadShips.size.height/4);
//                [_deadShips addChild:yellowRubble];
//            }else if ([ship55.name  isEqual: @"red ship"]){
//                redRubble.position = CGPointMake(_deadShips.size.width/2, _deadShips.size.height/4);
//                [_deadShips addChild:redRubble];
//            }else if ([ship55.name  isEqual: @"main ship"]){
//                mainRubble.position = CGPointMake(_deadShips.size.width/2, _deadShips.size.height/4);
//                [_deadShips addChild:mainRubble];
//            }else if ([ship55.name  isEqual: @"green ship"]){
//                greenRubble.position = CGPointMake(_deadShips.size.width/2, _deadShips.size.height/4);
//                [_deadShips addChild:greenRubble];
//            }else if ([ship55.name  isEqual: @"blue ship"]){
//                blueRubble.position = CGPointMake(_deadShips.size.width/2, _deadShips.size.height/4);
//                [_deadShips addChild:blueRubble];
//            }
//            break;
//    
//        default:
//            break;
//
//    }
//    
//}
//
//-(void) createAliveShipsImage
//{
//
//    NSMutableArray *livingArray = [NSMutableArray array];
//    for (Ship *ship in _ships){
//        if(!ship._dead){
//            [livingArray addObject:ship];
//        }
//    }
//
//    NSSortDescriptor *yPositionDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position.y"
//                                                                          ascending:NO];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:yPositionDescriptor];
//    NSArray *aliveArray = [aliveArray sortedArrayUsingDescriptors:sortDescriptors];
//    
//    
//    SKSpriteNode *yellowShip = [SKSpriteNode spriteNodeWithImageNamed:@"yellow_ship_trail"];
//    yellowShip.size = CGSizeMake(8, 24);
//    
//    SKSpriteNode *redShip = [SKSpriteNode spriteNodeWithImageNamed:@"red_ship_trail"];
//    redShip.size = CGSizeMake(8, 24);
//    
//    SKSpriteNode *mainShip = [SKSpriteNode spriteNodeWithImageNamed:@"main_ship_trail"];
//    mainShip.size = CGSizeMake(8, 24);
//    
//    SKSpriteNode *greenShip = [SKSpriteNode spriteNodeWithImageNamed:@"green_ship_trail"];
//    greenShip.size = CGSizeMake(8, 24);
//    
//    SKSpriteNode *blueShip = [SKSpriteNode spriteNodeWithImageNamed:@"blue_ship_trail"];
//    blueShip.size = CGSizeMake(8, 24);
//    
//    switch ([aliveArray count]) {
//        case 0:
//            _aliveShips = [SKSpriteNode spriteNodeWithColor: [SKColor clearColor]
//                                                       size: CGSizeMake(0, 0)];
//            break;
//            
//        case 1:
//            _aliveShips = [SKSpriteNode spriteNodeWithColor: [SKColor clearColor]
//                                                       size: CGSizeMake(30, 30)];
//            Ship *ship11 = (Ship *)[aliveArray objectAtIndex:0];
//            if ([ship11.name  isEqual: @"yellow ship"]){
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship11.name  isEqual: @"red ship"]){
//                [_aliveShips addChild:redShip];
//            }else if ([ship11.name  isEqual: @"main ship"]){
//                [_aliveShips addChild:mainShip];
//            }else if ([ship11.name  isEqual: @"green ship"]){
//                [_aliveShips addChild:greenShip];
//            }else if ([ship11.name  isEqual: @"blue ship"]){
//                [_aliveShips addChild:blueShip];
//            }
//            break;
//         
//            
//        case 2:
//            
//            _aliveShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(40, 40)];
//            Ship *ship21 = (Ship *)[aliveArray objectAtIndex:0];
//            if ([ship21.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(10, 10);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship21.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(10, 10);
//                [_aliveShips addChild:redShip];
//            }else if ([ship21.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(10, 10);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship21.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(10, 10);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship21.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(10, 10);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship22 = (Ship *)[aliveArray objectAtIndex:1];
//            if ([ship22.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(-10, -10);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship22.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(-10, -10);
//                [_aliveShips addChild:redShip];
//            }else if ([ship22.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(-10, -10);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship22.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(-10, -10);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship22.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(-10, -10);
//                [_aliveShips addChild:blueShip];
//            }
//            break;
//            
//        case 3:
//            _aliveShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(60, 40)];
//            Ship *ship31 = (Ship *)[aliveArray objectAtIndex:0];
//            if ([ship31.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(0, 10);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship31.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(0, 10);
//                [_aliveShips addChild:redShip];
//            }else if ([ship31.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(0, 10);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship31.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(0, 10);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship31.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(0, 10);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship32 = (Ship *)[aliveArray objectAtIndex:1];
//            if ([ship32.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(-20, 0);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship32.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(-20, 0);
//                [_aliveShips addChild:redShip];
//            }else if ([ship32.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(-20, 0);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship32.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(-20, 0);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship32.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(-20, 0);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship33 = (Ship *)[aliveArray objectAtIndex:2];
//            if ([ship33.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(20, -10);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship33.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(20, -10);
//                [_aliveShips addChild:redShip];
//            }else if ([ship33.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(20, -10);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship33.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(20, -10);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship33.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(20, -10);
//                [_aliveShips addChild:blueShip];
//            }
//            break;
//            
//        case 4:
//            _aliveShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(90, 60)];
//            Ship *ship41 = (Ship *)[aliveArray objectAtIndex:0];
//            if ([ship41.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(10, 15);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship41.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(10, 15);
//                [_aliveShips addChild:redShip];
//            }else if ([ship41.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(10, 15);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship41.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(10, 15);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship41.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(10, 15);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship42 = (Ship *)[aliveArray objectAtIndex:1];
//            if ([ship42.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(-10, 5);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship42.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(-10, 5);
//                [_aliveShips addChild:redShip];
//            }else if ([ship42.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(-10, 5);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship42.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(-10, 5);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship42.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(-10, 5);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship43 = (Ship *)[aliveArray objectAtIndex:2];
//            if ([ship43.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(30, - 5);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship43.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(30, - 5);
//            }else if ([ship43.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(30, - 5);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship43.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(30, - 5);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship43.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(30, - 5);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship44 = (Ship *)[aliveArray objectAtIndex:3];
//            if ([ship44.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(-30, -15);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship44.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(-30, -15);
//                [_aliveShips addChild:redShip];
//            }else if ([ship44.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(-30, -15);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship44.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(-30, -15);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship44.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(-30, -15);
//                [_aliveShips addChild:blueShip];
//            }
//            break;
//        
//        case 5:
//            _aliveShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(90, 60)];
//            Ship *ship51 = (Ship *)[aliveArray objectAtIndex:0];
//            if ([ship51.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(0, 20);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship51.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(0, 20);
//                [_aliveShips addChild:redShip];
//            }else if ([ship51.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(0, 20);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship51.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(0, 20);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship51.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(0, 20);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship52 = (Ship *)[aliveArray objectAtIndex:1];
//            if ([ship52.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(-20, 10);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship52.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(-20, 10);
//                [_aliveShips addChild:redShip];
//            }else if ([ship52.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(-20, 10);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship52.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(-20, 10);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship52.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(-20, 10);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship53 = (Ship *)[aliveArray objectAtIndex:2];
//            if ([ship53.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(20, 0);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship53.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(20, 0);
//                [_aliveShips addChild:redShip];
//            }else if ([ship53.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(20, 0);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship53.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(20, 0);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship53.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(20, 0);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship54 = (Ship *)[aliveArray objectAtIndex:3];
//            if ([ship54.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(-40, -10);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship54.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(-40, -10);
//                [_aliveShips addChild:redShip];
//            }else if ([ship54.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(-40, -10);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship54.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(-40, -10);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship54.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(-40, -10);
//                [_aliveShips addChild:blueShip];
//            }
//            Ship *ship55 = (Ship *)[aliveArray objectAtIndex:4];
//            if ([ship55.name  isEqual: @"yellow ship"]){
//                yellowShip.position = CGPointMake(40, -20);
//                [_aliveShips addChild:yellowShip];
//            }else if ([ship55.name  isEqual: @"red ship"]){
//                redShip.position = CGPointMake(40, -20);
//                [_aliveShips addChild:redShip];
//            }else if ([ship55.name  isEqual: @"main ship"]){
//                mainShip.position = CGPointMake(40, -20);
//                [_aliveShips addChild:mainShip];
//            }else if ([ship55.name  isEqual: @"green ship"]){
//                greenShip.position = CGPointMake(40, -20);
//                [_aliveShips addChild:greenShip];
//            }else if ([ship55.name  isEqual: @"blue ship"]){
//                blueShip.position = CGPointMake(40, -20);
//                [_aliveShips addChild:blueShip];
//            }
//            break;
//            
//        default:
//            break;
//    }
//    
//}
@end
