//
//  MyScene.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

//regular speed = 100 pixels per second


#import "MyScene.h"
#import "Planet.h"
#import "Ship.h"
#import "RaceProgressBar.h"
#import "BlackHoleProgressBar.h"
#import "SKTUtils.h"
#import "iAd/iAd.h"
#import "StoreKit/StoreKit.h"
#import "InstructionsScene.h"

@import AVFoundation;

@interface MyScene()<SKPhysicsContactDelegate>
@end
@interface MyScene()<SKProductsRequestDelegate>
@end
@interface MyScene()<UIAlertViewDelegate>
@end
@interface MyScene()<SKPaymentTransactionObserver>

@end


@implementation MyScene
{
    NSFileManager *_fileManager;
    NSMutableDictionary *_data;
    NSString *_dataPath;
    
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
    
    AVAudioPlayer *_bgMusicPlayer;
    AVAudioPlayer *_beepInPlayer;
    AVAudioPlayer *_beepOutPlayer;
    AVAudioPlayer *_transportBeamPlayer;
    AVAudioPlayer *_explosionPlayer;
    AVAudioPlayer *_blackHolePlayer;
    AVAudioPlayer *_nextMileBeepPlayer;
    AVAudioPlayer *_newRecordBeepPlayer;
    
    SKSpriteNode *_background;
    SKSpriteNode *_backgroundLayer;
    Planet *_earth;
    Ship *_mainShip;      //_ships[0]
    Ship *_yellowShip;    //_ships[1]
    Ship *_greenShip;     //_ships[2]
    Ship *_redShip;       //_ships[3]
    Ship *_blueShip;      //_ships[4]
    
    Planet *_stopLightPlanet1;
    Planet *_stopLightPlanet2;
    
    SKProduct *_noAdsProduct;
    NSMutableArray *_backgroundImages;
    NSMutableArray *_backgroundImageNames;
    NSString *_bgName;
    NSArray *_ships;
    NSMutableArray *_planets;
    NSMutableArray *_bgImages;
    int _plannetCounter;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    int _record;
    int _timesPlayed;
    SKSpriteNode *_blackHoleMenuTrail;
    SKLabelNode *_orbitLabel;
    SKLabelNode *_recordLabel;
    SKLabelNode *_recordNumLabel;
    SKLabelNode *_lastScoreLabel;
    SKLabelNode *_yourScore;
    SKLabelNode *_blackHoleRunLabel;
    SKLabelNode *_blackHoleLabel;
    SKSpriteNode *_tapAndHold;
    SKSpriteNode *_arrowNode;
    SKSpriteNode *_milesBarBg;
    SKSpriteNode *_rateButton;
    SKSpriteNode *_instructionsButton;
    SKSpriteNode *_aboutButton;
    SKSpriteNode *_noAdsButton;
    
    SKLabelNode *_goLabel;
    BOOL _gameStarted;
    BOOL _zoomingOut;
    int _miles;
    int _updateNum;
    BOOL _newHighScore;
    SKLabelNode *_mileNumLabel;
    SKLabelNode *_milesLabel;
    int _clickNum;
    SKEmitterNode *_shipTrail;
    UIColor *_recordColor;
    float NORMAL_SHIP_SPEED_PPS;
    
    float _timeSinceCreation;
    float _nextBoost;
    float _nextBoostIncrement;
    
    int _nextMileDistance;
    SKAction *_popMileNum;
    RaceProgressBar *_raceProgressBar;
    BlackHoleProgressBar *_blackHoleProgressBar;
    CGFloat _checkPoint1;
    CGFloat _checkPoint2;
    CGFloat _checkPoint3;
    CGFloat _checkPoint4;
    CGFloat _nextCheckP;
    BOOL _noMoreProgressBarUpdates;
    BOOL _paused;
    BOOL _touching;
    NSString *_touchType;
    SKSpriteNode *_pauseMenu;
    SKSpriteNode *_deadMenu;
    SKSpriteNode *_resumeButton;
    SKSpriteNode *_mainMenuButton;
    SKSpriteNode *_deadShips;
    SKSpriteNode *_aliveShips;
    SKSpriteNode *_randSprite;
    SKSpriteNode *_pauseButton;
    SKSpriteNode *_blackHole;
    SKSpriteNode *_blackHoleTrail;
    SKSpriteNode *_transportBeam;
    SKSpriteNode *_contentNode;
    NSString *_gameMode;
    
}


-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        NORMAL_SHIP_SPEED_PPS =  self.size.width*0.19;
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        _contentNode = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.size.width, self.size.height)];
        _contentNode.anchorPoint = CGPointMake(0, 0);
        _contentNode.position = CGPointMake(0, 0);
        [self addChild:_contentNode];
        
        _fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _dataPath = [documentsDirectory stringByAppendingPathComponent:@"appData.plist"];
        //[_fileManager removeItemAtPath:_dataPath error:nil];
        if (![_fileManager fileExistsAtPath: _dataPath])
        {
            _dataPath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"appData.plist"] ];
            
        }
        if ([_fileManager fileExistsAtPath: _dataPath])
        {
            _data = [[NSMutableDictionary alloc] initWithContentsOfFile: _dataPath];
        }
        else
        {
            // If the file doesn’t exist, create an empty dictionary
            _data = [[NSMutableDictionary alloc] init];
            [_data setObject:[NSNumber numberWithInt:0] forKey:@"record"];
            [_data setObject:[NSNumber numberWithInt:_timesPlayed] forKey:@"times_played"];
        }
        
        //To reterive the data from the plist
        _record = [[_data objectForKey:@"record"] intValue];
        _timesPlayed = [[_data objectForKey:@"times_played"] intValue];
        _timesPlayed++;
        [_data setObject:[NSNumber numberWithInt:_timesPlayed] forKey:@"times_played"];
        [_data writeToFile: _dataPath atomically:YES];
        
        
        if (_timesPlayed == 1)
        {
            InstructionsScene *newScene = [InstructionsScene sceneWithSize:self.size];
            newScene.scaleMode = SKSceneScaleModeAspectFill;
            if (![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
                [self.view.window.rootViewController requestInterstitialAdPresentation];
            }
            [self runAction:[SKAction waitForDuration:0.3] completion:^{
                [self.view presentScene: newScene];
            }];
            [_bgMusicPlayer stop];
        }
        
        
        [self playBackgroundMusic];
        
        _updateNum = 0;
        _clickNum = 0;
    
        
        SKSpriteNode *blackGround = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
        blackGround.zPosition = -100;
        blackGround.anchorPoint = CGPointZero;
        [self addChild:blackGround];
        
        //sets up background images and related variables
        _backgroundImageNames = [NSMutableArray arrayWithObjects:@"bg1", @"bg2", @"bg3", @"bg4", @"bg5", @"bg6", @"bg7", @"bg8", @"bg9", @"bg10", nil];
        _backgroundImages = [[NSMutableArray alloc] init];
        for (int i = 0; i<_backgroundImageNames.count; i++) {
            //set up _background
            SKTexture *background = [SKTexture textureWithImageNamed:_backgroundImageNames[i]];
            _backgroundImages[i] = background;
        }
        
        int bgIndex = arc4random_uniform((int)_backgroundImages.count);
        
        //set up _background
        _background = [SKSpriteNode spriteNodeWithTexture:_backgroundImages[bgIndex] size:CGSizeMake(self.size.width, self.size.height)];
        //set scale and position for start screen
        _background.anchorPoint = CGPointMake(0.5, 0);
        _background.position = CGPointMake(self.size.width/2, 0);
        [_background setScale:1.5];
        
        
        //set up _backgroundLayer
        _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake((self.size.width*0.9), 100000)];
        //set anchorPoint and position for start screen
        _backgroundLayer.anchorPoint = CGPointZero;

        
        //initialize ships 45.5
        _mainShip = [[Ship alloc] initWithPosition:CGPointMake(_backgroundLayer.size.width*0.305, -30) andSize:CGSizeMake(1.82*0.25*_backgroundLayer.size.width*0.27/1.6, 0.25*_backgroundLayer.size.width*0.27/1.6) andImage:@"main_ship"];
        _mainShip.name = @"main ship";
        _mainShip.zPosition = 100;
        _mainShip._newPos = _mainShip.position;
        _mainShip.zRotation = M_PI_2;
        _ships = [NSArray arrayWithObject:_mainShip];
        
        
        //sets _mainShip running
        SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
        [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
        
        //set up orbit label
        _orbitLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
        _orbitLabel.text = @"Orbit";
        _orbitLabel.fontSize = (int)_contentNode.size.height*0.13;
        _orbitLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.88);
        
        _blackHoleRunLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
        _blackHoleRunLabel.text = @"black hole run";
        _blackHoleRunLabel.fontSize = (int)_contentNode.size.height*0.06;
        _blackHoleRunLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _blackHoleRunLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.87);
        
        _recordColor = [UIColor redColor];
        //set up record label
        _recordLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
        _recordLabel.text = @"Record:";
        _recordLabel.fontSize = (int)_contentNode.size.width*0.12;
        _recordLabel.fontColor = _recordColor;
        _recordLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.width*0.33);
        _recordLabel.zPosition = 300;
        _recordNumLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
        _recordNumLabel.text = (_record == 1) ? [NSString stringWithFormat:@"%i LIGHT YEAR", _record]: [NSString stringWithFormat:@"%i LIGHT YEARS", _record];
        _recordNumLabel.fontSize = (int)_contentNode.size.width*0.12;
        _recordNumLabel.fontColor = _recordColor;
        _recordNumLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _recordNumLabel.position = CGPointMake(_recordLabel.position.x, _contentNode.size.width*0.31);
        _recordNumLabel.zPosition = 300;
        
        //set up physics world
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        //set up pause button node
        _pauseButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"pause_button"] size:CGSizeMake(_contentNode.size.height*0.06*1.6, _contentNode.size.height*0.06)];
        _pauseButton.anchorPoint = CGPointMake(0, 1);
        _pauseButton.position = CGPointMake(0, _contentNode.size.height+1);
        _pauseButton.alpha = 0;
        
        //set up miles counter
        //get font with outline
        _miles = 0;
        _mileNumLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
        _mileNumLabel.text = [NSString stringWithFormat:@"%i", _miles];
        _mileNumLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _mileNumLabel.fontSize = (int)_contentNode.size.height*0.06;
        _mileNumLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.967);
        _mileNumLabel.alpha = 0;
        _milesLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
        _milesLabel.text = @"LIGHT YEARS";
        _milesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _milesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        _milesLabel.fontSize = (int)0.029;
        _milesLabel.position = CGPointMake(_contentNode.size.width*0.967, _mileNumLabel.position.y);
        _milesLabel.alpha = 0;
        _milesBarBg = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"miles_bar_background"] size:CGSizeMake(_contentNode.size.width, _contentNode.size.height*0.077)];
        _milesBarBg.anchorPoint = CGPointMake(0, 1);
        _milesBarBg.position = CGPointMake(0, _contentNode.size.height+1);
        _milesBarBg.alpha = 0;
        
        
        _popMileNum = [SKAction sequence:@[[SKAction scaleTo:1.4 duration:0.1],[SKAction scaleTo:1.0 duration:0.1]]];
        _nextMileDistance = 350;

        //set up other variables
        _randSprite = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeZero];
        _transportBeam = [SKSpriteNode spriteNodeWithImageNamed:@"transport_beam"];
        _transportBeam.alpha = 0;
        _transportBeam.anchorPoint = CGPointZero;
        _transportBeam.size = CGSizeMake(_backgroundLayer.size.width, 20);
        [_backgroundLayer addChild:_transportBeam];
        
        _rateButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"rate_button"] size:CGSizeMake(0.125*_contentNode.size.width, 0.125*_contentNode.size.width)];
        _rateButton.position = CGPointMake(0.1*_contentNode.size.width, _contentNode.size.height*0.06);
        _rateButton.zPosition = 300;
        
        _instructionsButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"instructions_button"] size:CGSizeMake(0.6*_contentNode.size.width, 0.156*_contentNode.size.width)];
        _instructionsButton.position = CGPointMake(0.5*_contentNode.size.width, _contentNode.size.height*0.06);
        _instructionsButton.zPosition = 300;
        
        _noAdsButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"no_ads_button"] size:CGSizeMake(0.125*_contentNode.size.width, 0.125*_contentNode.size.width)];
        if([[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
            _noAdsButton.texture = [SKTexture textureWithImageNamed:@"no_ads_button_greyed"];
        }
        _noAdsButton.position = CGPointMake(0.9*_contentNode.size.width, _contentNode.size.height*0.06);
        _noAdsButton.zPosition = 300;

        //set up planets
        [self createPlanetField];
        
        [_backgroundLayer addChild:_mainShip];
        
        //add _background, _backgroundLayer, _orbitLabel, _recordLabel nodes to the scene
        [self addChild:_background];
        [self addChild:_backgroundLayer];
        [self addChild:_milesBarBg];
        [self addChild:_orbitLabel];
        [self addChild:_blackHoleRunLabel];
        [self addChild:_recordLabel];
        [self addChild:_recordNumLabel];
        [self addChild:_mileNumLabel];
        [self addChild:_milesLabel];
        [self addChild:_pauseButton];
        [self addChild:_rateButton];
        [self addChild:_instructionsButton];
        [self addChild:_noAdsButton];
        if (_timesPlayed < 4){
            _tapAndHold = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"tap_and_hold_label"] size:CGSizeMake(0.3*self.size.width,1.143*0.3*self.size.width)];
            _tapAndHold.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.5+16);
            _tapAndHold.alpha = 0.85;
            [_tapAndHold runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.1 duration:0.5], [SKAction scaleTo:1.0 duration:0.5]]]]];
            [self addChild:_tapAndHold];
        }
        
        
        //scale the backgroundLayer in
        _backgroundLayer.xScale = 2;
        _backgroundLayer.yScale = 2;
        _backgroundLayer.position = CGPointMake(-_backgroundLayer.size.width/4+_contentNode.size.width*0.05, 0);
        
        //preset now, but will be set by button in future game
        _gameMode = @"black_hole";
        
        _touching = YES;
        
        _timeSinceCreation = 0;
        _nextBoost = _timeSinceCreation + 1;
        _nextBoostIncrement = 0;
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //if pause button is pressed
    if (!_paused && !_mainShip._dead && CGRectContainsPoint(CGRectMake(0, _contentNode.size.height-_pauseButton.size.height, _pauseButton.size.width, _pauseButton.size.height), location)) {
        
        [self pauseScene];
        
    //if resume button is pressed
    }else if (_paused && (CGRectContainsPoint(CGRectMake([_pauseMenu convertPoint:_resumeButton.position toNode:self].x - 0.5*_resumeButton.size.width, [_pauseMenu convertPoint:_resumeButton.position toNode:self].y - 0.5*_resumeButton.size.height, _resumeButton.size.width, _resumeButton.size.height), location)))
    {
        _resumeButton.texture = [SKTexture textureWithImageNamed:@"resume_button_pressed"];
        _touchType = @"resume";
        
    //if main menu button is pressed
    }else if (_paused && (CGRectContainsPoint(CGRectMake([_pauseMenu convertPoint:_mainMenuButton.position toNode:self].x - 0.5*_mainMenuButton.size.width, [_pauseMenu convertPoint:_mainMenuButton.position toNode:self].y - 0.5*_mainMenuButton.size.height, _mainMenuButton.size.width, _mainMenuButton.size.height), location)))
    {
        _mainMenuButton.texture = [SKTexture textureWithImageNamed:@"loading_button"];
        _touchType = @"main_menu";
        
    //if main menu button is pressed
    }else if (_mainShip._dead && (CGRectContainsPoint(CGRectMake([_deadMenu convertPoint:_mainMenuButton.position toNode:self].x - 0.5*_mainMenuButton.size.width, [_deadMenu convertPoint:_mainMenuButton.position toNode:self].y - 0.5*_mainMenuButton.size.height, _mainMenuButton.size.width, _mainMenuButton.size.height), location)))
    {
        _mainMenuButton.texture = [SKTexture textureWithImageNamed:@"loading_button"];
        _touchType = @"main_menu";
        
    //if game has not been started
    }else if(!_gameStarted){
        //touch is on rate button
        if (CGRectContainsPoint(CGRectMake(_rateButton.position.x - _rateButton.size.width*0.5, _rateButton.position.y - _rateButton.size.height*0.5, _rateButton.size.width, _rateButton.size.height), location)){
            _rateButton.texture = [SKTexture textureWithImageNamed:@"rate_button_pressed"];
            _touchType = @"rate";
        //touch is on instructions button
        }else if (CGRectContainsPoint(CGRectMake(_instructionsButton.position.x - _instructionsButton.size.width*0.5, _instructionsButton.position.y - _instructionsButton.size.height*0.5, _instructionsButton.size.width, _instructionsButton.size.height), location)){
            _instructionsButton.texture = [SKTexture textureWithImageNamed:@"instructions_button_pressed"];
            _touchType = @"instructions";
        //touch is on no ads button
        }else if (CGRectContainsPoint(CGRectMake(_noAdsButton.position.x - _noAdsButton.size.width*0.5, _noAdsButton.position.y - _noAdsButton.size.height*0.5, _noAdsButton.size.width, _noAdsButton.size.height), location) && ![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
            _touchType = @"no_ads";
            //if no ads is already purchased
        }else if(CGRectContainsPoint(CGRectMake(_noAdsButton.position.x - _noAdsButton.size.width*0.5, _noAdsButton.position.y - _noAdsButton.size.height*0.5, _noAdsButton.size.height, _noAdsButton.size.width), location) && [[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
            //do nothing
            
        //touch is on screen
        }else if(_clickNum == 0){
            _clickNum++;
            
            //if blackhole button is selected
            if ([_gameMode isEqualToString:@"black_hole"])
            {
                [self setUpBlackHoleGame];
            }
            
            
            [self zoomOut];
        }
    
    //if game is in play and _mainShip has a current planet
    }else if(_gameStarted && !_mainShip._dead && CGRectContainsPoint(CGRectMake(_contentNode.size.width*0.1, 0, _backgroundLayer.size.width, _contentNode.size.height*0.923), location))
    {
        _touching = YES;
        _mainShip._glow.alpha = 1;
        [_beepInPlayer play];
        
        //if ship has not already entered the orbit of the current planet and _mainShip is in gravzone
        if (!_mainShip._hasEntered && _mainShip._inGravZone && _mainShip._currentPlanet)
        {
            [self enterOrbit:_mainShip];
        }

    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    
    if ([_touchType isEqualToString:@"main_menu"])
    {
        //new game
        [self newGame];
    }else if ([_touchType isEqualToString:@"resume"])
    {
        //resume game
        [self resumeGame];
        _touchType = nil;
    }else if ([_touchType isEqualToString:@"rate"])
    {
        [_rateButton runAction:[SKAction waitForDuration:0.05] completion:^{
            _rateButton.texture = [SKTexture textureWithImageNamed:@"rate_button"];
        }];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/orbit-black-hole-run/id917429675?mt=8"]];
        _touchType = nil;

    }else if ([_touchType isEqualToString:@"instructions"])
    {
        [_bgMusicPlayer stop];
        
        [_instructionsButton runAction:[SKAction waitForDuration:0.05] completion:^{
            _instructionsButton.texture = [SKTexture textureWithImageNamed:@"instructions_button"];
        }];
        
        _touchType = nil;
        InstructionsScene *newScene = [InstructionsScene sceneWithSize:self.size];
        newScene.scaleMode = SKSceneScaleModeAspectFill;
        if (![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
            [self.view.window.rootViewController requestInterstitialAdPresentation];
        }
        [self runAction:[SKAction waitForDuration:0.3] completion:^{
            [self.view presentScene: newScene];
        }];
    }else if ([_touchType isEqualToString:@"no_ads"])
    {
        [_noAdsButton runAction:[SKAction waitForDuration:0.05] completion:^{
            _noAdsButton.texture = [SKTexture textureWithImageNamed:@"no_ads_button"];
        }];
        
        NSString *productID = @"no_ads";
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productID]];
        productsRequest.delegate = self;
        [productsRequest start];
        
        _touchType = nil;
        
    }else if(_gameStarted && !_mainShip._dead && CGRectContainsPoint(CGRectMake(_contentNode.size.width*0.1, 0, _backgroundLayer.size.width, _contentNode.size.height*0.923), location))
    {
        
        if(_clickNum == 1){
            _blackHole.speed = 1;
            _blackHoleTrail.speed = 1;
            _clickNum++;
        }

        _touching = NO;
        _mainShip._glow.alpha = 0;
        [_beepInPlayer stop];
        [_beepInPlayer prepareToPlay];
        
        if(_mainShip._hasEntered){
            [self exitOrbit];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if (!_paused)
    {
        //_dt is the change in time since the last frame
        if(_lastUpdateTime)
        {
            _dt = currentTime - _lastUpdateTime;
        }else
        {
            _dt=0;
        }
        _lastUpdateTime = currentTime;
        
//        if ([_gameMode isEqualToString:@"race"])
//        {
//            //for every ship
//            for (Ship *ship in _ships) {
//                //if game is started and ship speed property is less than 1.5
//                if(_gameStarted && ship.speed < 1.5){
//                    //increment speed by .1
//                    ship.speed += _dt*.1;
//                }
//            }
//        } else if ([_gameMode isEqualToString:@"black_hole"])
        {
            //if game is started and ship speed property is less than 1.5
            if((_updateNum%4 == 0) && _gameStarted && _mainShip.speed < 1.5){
                //increment speed by .1
                _mainShip.speed += _dt*.4;
            }
            
            //speed up black hole
            [self speedUpBlackHole];
        }
        
        //update mile counter
        [self updateMiles];
        
        //move background
        [self moveBackgroundLayer];
    }else
    {
        _lastUpdateTime = currentTime;
    }

}

-(void)didSimulatePhysics
{
    if (!_paused){
//        if([_gameMode isEqualToString:@"race"])
//        {
//            for(Ship *ship in _ships)
//            {
//                //reposition ship if off screen
//                if ([self repositionShip:ship])
//                {
//                    //update z rotation based on change in position
//                    //[self updateZRotation:ship];
//                }
//                
//                if (ship != _mainShip && ship._inOrbit && ship.zRotation < ship._releaseAngle + 0.01 && ship.zRotation > ship._releaseAngle - 0.01)
//                {
//                    //remove all actions on the planets gravzone image and start the pulsing action on it
//                    [ship._currentPlanet._gravZoneImage removeAllActions];
//                    [ship._currentPlanet._gravZoneImage runAction:ship._currentPlanet._pulseAction];
//                    [ship._currentPlanet popPlanet];
//                    
//                    
//                    //set mainship to have no current planet
//                    ship._currentPlanet = nil;
//                    //set mainship inOrbit property to no
//                    ship._inOrbit = NO;
//                    //set mainShip planetToShipAngle property to 0
//                    ship._planetToShipAngle = 0;
//                    
//                    //remove all actions on mainShip and run freefly action based on the mainship zRotation property
//                    [ship removeAllActions];
//                    SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
//                    [ship runAction:[SKAction repeatActionForever:freeFly]];
//                }
//            }
//        }else if ([_gameMode isEqualToString:@"black_hole"] && !_mainShip._dead)
        {
            //reposition ship if off screen
            if ([self repositionShip:_mainShip])
            {
                //update z rotation based on change in position
                [self updateZRotation];
            }
        }
        
        //fade and change planets' physics bodies
        [self removePlanets];
    
        //update progress bar
        [self updateProgressBars];
        
        //check if ship should be dead
        [self checkShipDeath];
    }

}

//when ship touches a planets gravity field
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    
    
    //if ship hits asteroid
    if(contact.bodyB.categoryBitMask == CNPhysicsCategoryAsteroid){
        
        Ship *ship = (Ship*)contact.bodyA.node;
        
        ship._currentPlanet = (Planet *)contact.bodyB.node;
        
        //set the planet to ship angle to a number between 0 and 2PI
        ship._planetToShipAngle = CGPointToAngle(CGPointSubtract(ship.position, ship._currentPlanet.position));
        while (ship._planetToShipAngle > M_PI){ ship._planetToShipAngle -= M_PI; }
        while (ship._planetToShipAngle < -M_PI) { ship._planetToShipAngle += M_PI;}
        
        [self killShip:ship];
        
    }
    
    //if ship hits planet
    if(contact.bodyB.categoryBitMask == CNPhysicsCategoryPlanetBody){
        
        Ship *ship = (Ship *)contact.bodyA.node;
        
        ship._currentPlanet = (Planet *)contact.bodyB.node.parent;
        
        //set the planet to ship angle to a number between 0 and 2PI
        ship._planetToShipAngle = CGPointToAngle(CGPointSubtract(ship.position, ship._currentPlanet.position));
        while (ship._planetToShipAngle > M_PI){ ship._planetToShipAngle -= M_PI; }
        while (ship._planetToShipAngle < -M_PI) { ship._planetToShipAngle += M_PI;}
        
        [self killShip:ship];
        
    }
    
    if(contact.bodyB.categoryBitMask == CNPhysicsCategoryMainshipGravityZone || contact.bodyB.categoryBitMask == CNPhysicsCategoryOthershipGravityZone){
        
        Ship *ship = (Ship*)contact.bodyA.node;
        //set ships current planet as the parent of the body's node
        ship._currentPlanet = (Planet *)contact.bodyB.node.parent;
        
        ship._inGravZone = YES;
        
        if(ship._inGravZone && _touching)
            [self enterOrbit:ship];
        
        }
}

-(void) didEndContact:(SKPhysicsContact *)contact
{
    if(contact.bodyB.categoryBitMask == CNPhysicsCategoryMainshipGravityZone || contact.bodyB.categoryBitMask == CNPhysicsCategoryOthershipGravityZone){
        
        Ship *ship = (Ship*)contact.bodyA.node;
        
        ship._inGravZone = NO;
    }
}
//
//-(void) flyToDeath:(Ship *)ship
//{
//    CGPoint deathPoint = CGPointAdd(ship._currentPlanet.position, CGPointMultiplyScalar(CGPointMake(cos(ship._planetToShipAngle), sin(ship._planetToShipAngle)), ship._currentPlanet._radius*1.1));
//    
//    UIBezierPath *deathPath = [UIBezierPath bezierPath];
//    [deathPath moveToPoint:CGPointAdd(ship.position, CGPointMake(3*cos(ship.zRotation)*_mainShip.speed, 3*sin(ship.zRotation)*_mainShip.speed))];
//    [deathPath addLineToPoint:deathPoint];
//    
//    SKAction *flyToDeath = [SKAction followPath:deathPath.CGPath asOffset:NO orientToPath:NO duration:(ship._currentPlanet._radius*0.6)/NORMAL_SHIP_SPEED_PPS];
//    
//    [ship runAction: flyToDeath completion:^{
//        
//        [self killShip:ship];
//    }];
//}

-(void) killShip:(Ship *)ship
{
    [_explosionPlayer play];
    
    //set ships dead property to yes
    ship._dead = YES;
    [_beepInPlayer stop];
    
    CGPoint particleEmitterPosition = CGPointAdd(ship._currentPlanet.position, CGPointMultiplyScalar(CGPointMake(cos(ship._planetToShipAngle), sin(ship._planetToShipAngle)), ship._currentPlanet._radius));
        
        [ship removeFromParent];
        
        //sets up the explosion effect
        SKEmitterNode *fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"]];
        SKEmitterNode *explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"]];
        
        [_backgroundLayer addChild:explosionEmitter];
        explosionEmitter.position = particleEmitterPosition;
        [explosionEmitter runAction:[SKAction sequence:@[[SKAction waitForDuration:2],[SKAction removeFromParent]]]];
        
        [_backgroundLayer addChild:fireEmitter];
        fireEmitter.position = particleEmitterPosition;
        [fireEmitter setScale: 0];
        fireEmitter.emissionAngle = ship._planetToShipAngle;
    
        [fireEmitter runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5],[SKAction scaleTo:0 duration:2],[SKAction removeFromParent]]]];
        [_bgMusicPlayer stop];
        
        SKAction *screenShake1 = [SKAction moveBy:CGVectorMake(10*cos(ship._planetToShipAngle + M_PI_2), 10*sin(ship._planetToShipAngle + M_PI_2)) duration:0.05];
        SKAction *screenShake2 = [screenShake1 reversedAction];
        SKAction *sequence = [SKAction sequence:@[screenShake1, screenShake2, screenShake2,screenShake1]];
        
        //lighter shake
        SKAction *finalShake1 = [SKAction moveBy:CGVectorMake(5*cos(ship._planetToShipAngle + M_PI_2), 5*sin(ship._planetToShipAngle + M_PI_2)) duration:0.05];
        SKAction *finalShake2 = [finalShake1 reversedAction];
        SKAction *sequence2 = [SKAction sequence:@[finalShake1, finalShake2, finalShake2, finalShake1]];
        
        SKAction *fullShake = [SKAction sequence:@[sequence,sequence,sequence,sequence,sequence,sequence2,sequence2]];
        fullShake.timingMode = SKActionTimingEaseOut;
        [_backgroundLayer runAction:fullShake completion:^{
            [self openDeadMenu];
        }];
    
}

-(void) createPlanetField
{
    _planets = [[NSMutableArray alloc] init];
    NSMutableArray *imageNumArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:20],[NSNumber numberWithInt:20],[NSNumber numberWithInt:20], [NSNumber numberWithInt:20],[NSNumber numberWithInt:20], nil];
    
    _earth = [[Planet alloc] initWithSize:CGSizeMake(0.3*_backgroundLayer.size.width,0.3*_backgroundLayer.size.width) andPosition:CGPointMake(_backgroundLayer.size.width*0.5, self.size.height*0.25+8) andImage:@"clear_earth"];
    [_backgroundLayer addChild:_earth];
    CGRect earthRect = CGRectMake(_backgroundLayer.size.width*0.5-0.15*_backgroundLayer.size.width*1.6, self.size.height*0.25+8-0.15*_backgroundLayer.size.width*1.6, 0.3*_backgroundLayer.size.width*1.6, 0.3*_backgroundLayer.size.width*1.6);
    [_planets addObject:_earth];
    
    CGRect stop1rect = CGRectMake(0, 80, 40*1.6, 40*1.6);
    CGRect stop2rect = CGRectMake(_backgroundLayer.size.width-80, 80, 40*1.6, 40*1.6);
    
    CGRect nilRect = CGRectMake(-20, -20, 0, 0);
    NSMutableArray *planetRectArray = [NSMutableArray arrayWithObjects: [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:nilRect], [NSValue valueWithCGRect:stop1rect], [NSValue valueWithCGRect:earthRect], [NSValue valueWithCGRect:stop2rect], nil];
    
    for(int y = 0; y < 200; y++){
        for (int x = 0; x < 3; x++) {
            
            int xMin, xMax, yMin, yMax;
            
            if (x == 0){
                xMin = _backgroundLayer.size.width*0.05;
                xMax = _backgroundLayer.size.width*0.28;
            }else if (x == 1){
                xMin = _backgroundLayer.size.width*0.38;
                xMax = _backgroundLayer.size.width*0.61;
            }else if (x == 2){
                xMin = _backgroundLayer.size.width*0.71;
                xMax = _backgroundLayer.size.width*0.95;
            }
            
            yMin = 0.5*self.size.height+_backgroundLayer.size.width*.25 + y*(self.size.height*.33);
            yMax = 0.5*self.size.height+_backgroundLayer.size.width*.25 + (y+1)*(self.size.height*.33)-self.size.height*0.05;
            
            int size;
            CGPoint position = CGPointMake(0, 0);
            CGRect planetRect = CGRectMake(0, 0, 0, 0);
            
            int tries = 0;
            do{
                tries++;
                
                size = arc4random_uniform(_backgroundLayer.size.width*0.2/1.6) + _backgroundLayer.size.width*0.27/1.6;
                
                position = CGPointMake(arc4random_uniform(xMax - xMin) + xMin, arc4random_uniform(yMax - yMin) + yMin);
                
                
                planetRect = CGRectMake(position.x - 0.5*size*1.6, position.y - 0.5*size*1.6, size*1.6, size*1.6);
                
                
            }while( (CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:5] CGRectValue])|| (planetRect.origin.x < 0) || (planetRect.origin.x + planetRect.size.width > _backgroundLayer.size.width)) && (tries < 20));
            
            if (CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:0] CGRectValue])|| CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:1] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:2] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:3] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:4] CGRectValue])||CGRectIntersectsRect(planetRect, [[planetRectArray objectAtIndex:5] CGRectValue])|| (planetRect.origin.x + planetRect.size.width > _backgroundLayer.size.width)){
                //move on
            }else{
                
                //create random imageNum that is not the same as last 5 imageNums
                int imageNum;
                do{
                    imageNum = arc4random_uniform(16);
                }while ((imageNum == [[imageNumArray objectAtIndex:0] intValue] || imageNum == [[imageNumArray objectAtIndex:1] intValue] || imageNum == [[imageNumArray objectAtIndex:2] intValue] || imageNum == [[imageNumArray objectAtIndex:3] intValue] || imageNum == [[imageNumArray objectAtIndex:4] intValue]));
                
                
                [imageNumArray addObject:[NSNumber numberWithInt:imageNum]];
                [imageNumArray removeObjectAtIndex:0];
                
                
                
                NSString *imageName;
                
                switch (imageNum){
                    case 0:
                        imageName = @"tethys";
                        break;
                    case 1:
                        imageName = @"newEarth";
                        break;
                    case 2:
                        imageName = @"jupiter";
                        break;
                    case 3:
                        imageName = @"mars";
                        break;
                    case 4:
                        imageName = @"murcury";
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
                        imageName = @"callisto";
                        break;
                    case 9:
                        imageName = @"sun";
                        break;
                    case 10:
                        imageName = @"triton";
                        break;
                    case 11:
                        imageName = @"iapetus";
                        break;
                    case 12:
                        imageName = @"uranus";
                        break;
                    case 13:
                        imageName = @"io";
                        break;
                    case 14:
                        imageName = @"europa";
                        break;
                    case 15:
                        imageName = @"ganymede";
                        break;
                    default:
                        imageName = @"blank_planet";
                        break;
                }
            
            // create the plannet
                if (arc4random_uniform(30) == 1){
                    Planet *asteroid = [[Planet alloc] initWithSize:CGSizeMake(0.7*size, 0.7*size) andPosition:CGPointMake(position.x, position.y) andImage:@"asteroid"];
                    asteroid._gravZoneImage.size = CGSizeZero;
                    asteroid._gravZone.physicsBody = nil;
                    asteroid._planetBody.physicsBody = nil;
                    asteroid.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:.35*size];
                    asteroid.physicsBody.categoryBitMask = CNPhysicsCategoryAsteroid;
                    asteroid.physicsBody.linearDamping = 0;
                    asteroid.physicsBody.angularDamping = 0;
                    asteroid.physicsBody.allowsRotation = NO;
                    asteroid.physicsBody.collisionBitMask = 0;
                    
                    asteroid.zRotation = (float)arc4random_uniform(10)/9*2*M_PI;
                    [_backgroundLayer addChild:asteroid];
                    
                }else{
                    Planet *planet1 = [[Planet alloc] initWithSize:CGSizeMake(size, size) andPosition:CGPointMake(position.x, position.y) andImage:imageName];
                    [_backgroundLayer addChild:planet1];
                    [_planets addObject:planet1];
                }
                
                [planetRectArray removeObjectAtIndex:0];
                [planetRectArray addObject:[NSValue valueWithCGRect:planetRect]];
            }
            
        }
    }
}

- (float) bezierCurveLengthFromStartPoint: (CGPoint) start toEndPoint: (CGPoint) end withControlPoint: (CGPoint) control
{
    const int kSubdivisions = 4;
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

-(void) updateZRotation
{
    _mainShip._oldPos = _mainShip._newPos;
    _mainShip._newPos = _mainShip.position;
    
    if (!_mainShip._dead && _mainShip._hasEntered && !_zoomingOut){
        
        float newAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._oldPos));

        _mainShip.zRotation = newAngle;
    }
}

-(void) removePlanets
{
    //enumerate the bottom six objcts in the planets array, starting with [5], working down
    if(_gameStarted){
        for (int i = _plannetCounter + 9; i >= _plannetCounter; i--) {
            
            Planet *planet = [_planets objectAtIndex:i];
            if(_plannetCounter > 2)
                planet = [_planets objectAtIndex:i-3];
            //if planet's position is lower than y = size.height/2*1.4
            if(_backgroundLayer.position.y + planet.position.y < planet._size.height/2*1.4){
                //set the planets physics body to nil
                planet._gravZone.physicsBody.categoryBitMask = CNPhysicsCategoryOthershipGravityZone;
                //set the planets alpha transparency to (position+size.height/2*1.4) / size.height*1.4
                planet._gravZoneImage.alpha = (_backgroundLayer.position.y + planet.position.y + planet._size.height*0.7) / (planet._size.height*1.4)*0.5;
                planet._planetBody.alpha = (_backgroundLayer.position.y + planet.position.y + planet._size.height*0.7) / (planet._size.height*1.4);
                
                //if the planet's position+size.height/2*1.4 < 0
                if (_backgroundLayer.position.y + planet.position.y + planet._size.height*0.7 < 0)
                {
                    _plannetCounter++;
                }
            }
        }
    }
}

-(void) moveBackgroundLayer
{
    if ((!_mainShip._hasEntered || (_mainShip._hasEntered && !_mainShip._currentPlanet)) && _gameStarted && !_mainShip._dead){
        //if ship position is greater than y = 0.4
        if ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y > 0.3*self.size.height){
            //move backgroundlayer at speed relative to ships position and ships dy velocity
            _backgroundLayer.position = CGPointMake(self.size.width*0.1, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip.position toNode:self].y - 0.3*self.size.height) / (0.1*self.size.height) * sin(_mainShip.zRotation)*NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        }
        
        //if ship is on planet and game is started
    }else if (_gameStarted && !_mainShip._dead){
        
        //if planet position is greater than y = .5
        if ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y > 0.5*self.size.height){
            //move background layer down at ship speed
            _backgroundLayer.position = CGPointMake(self.size.width*0.1, _backgroundLayer.position.y -NORMAL_SHIP_SPEED_PPS*_mainShip.speed * _dt);
        //if planet is between y = .22 and y = .5 in scene coords
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y <= 0.5*self.size.height && [_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y > 0.22*self.size.height){
            //move backgroundLayer down at a fraction of mainship's speed relative to the planets position
            _backgroundLayer.position = CGPointMake(self.size.width*0.1, _backgroundLayer.position.y - ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y - 0.28*self.size.height) / (0.2*self.size.height) * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        //if planet is between y = .2 and y = .22
        }else if ([_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y <= 0.22*self.size.height && [_backgroundLayer convertPoint:_mainShip._currentPlanet.position toNode:self].y > 0.2*self.size.height){
            //move backgroundLayer down at small fraction of the ship speed
            _backgroundLayer.position = CGPointMake(self.size.width*0.1, _backgroundLayer.position.y - .02/.2 * NORMAL_SHIP_SPEED_PPS * _mainShip.speed * _dt);
        }
    }

}

-(BOOL) repositionShip:(Ship *)ship
{
    
    //if the ship is being affected by a planet
    if (!ship._dead){
        
        //sets ship to reapear on opposite side of the screen
        if ( ship.position.x < 0 && ship.position.x > -50){
            [_transportBeamPlayer play];
            [_mainShip removeAllActions];
            ship.position = CGPointMake(-200, ship.position.y);
            ship.alpha = 0;
            [self runAction:[SKAction waitForDuration:.1] completion:^{
                ship.position = CGPointMake(_backgroundLayer.size.width-1, ship.position.y);
                ship.alpha = 1;
                ship.zRotation += M_PI_2/6;
                SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
                
                [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
            }];
            
            _transportBeam.position = CGPointMake(0, ship.position.y);
            [_transportBeam runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:0.05], [SKAction fadeAlphaTo:0 duration:0.2]]] completion:^{
                [_transportBeamPlayer stop];
                [_transportBeamPlayer prepareToPlay];
            }];
            return NO;

        }else if (ship.position.x > _backgroundLayer.size.width){
            //places the ship on the other side of the screen and adjusts the angle it is flying at
            [_transportBeamPlayer play];
            [_mainShip removeAllActions];
            
            ship.position = CGPointMake(-200, ship.position.y);
            ship.alpha = 0;
            [self runAction:[SKAction waitForDuration:.1] completion:^{
                ship.position = CGPointMake(1, ship.position.y);
                ship.alpha = 1;
                ship.zRotation -= M_PI_2/6;
                SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
                [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
            }];
            
            _transportBeam.position = CGPointMake(0, ship.position.y);
            [_transportBeam runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:0.05], [SKAction fadeAlphaTo:0 duration:0.2]]] completion:^{
                [_transportBeamPlayer stop];
                [_transportBeamPlayer prepareToPlay];
            }];
            return NO;

        }
        
        //if ship is bellow screen
        if (ship == _mainShip && ship.position.y < -_backgroundLayer.position.y){
            //flip ship over line x = .5
            ship.position = CGPointMake(_backgroundLayer.size.width - ship.position.x, -_backgroundLayer.position.y+1);
            
            //set z rotation of ship so that it aims away at the same angle it pointed to the baseline with before
            if (ship.zRotation < 1.5 * M_PI)
                ship.zRotation = M_PI - (ship.zRotation - M_PI);
            else if (ship.zRotation > 1.5 * M_PI)
                ship.zRotation = 2 * M_PI - ship.zRotation;
            
            //remove all actions on ship and run freefly action based on the ships zRotation property
            [ship removeAllActions];
            SKAction *freeFly = [SKAction moveByX:cos(ship.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(ship.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
            [ship runAction:[SKAction repeatActionForever:freeFly]];
            return NO;
        }
    }

    return YES;
}

-(void) zoomOut
{
    _zoomingOut = YES;
    
    _goLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
    _goLabel.position = CGPointMake(0.55*_contentNode.size.width,_contentNode.size.height*0.45);
    _goLabel.text = @"Go!";
    _goLabel.fontSize = 50;
    _goLabel.alpha = 0;
    [self addChild:_goLabel];
    
    //create action to scale _background out
    SKAction *scaleOut = [SKAction scaleTo:1.0 duration:0.5];
    scaleOut.timingMode = SKActionTimingEaseOut;
    
    //create actions to fade labels
    SKAction *fadeLabel = [SKAction fadeAlphaTo:1 duration:0.5];
    SKAction *fadeLabel2 = [SKAction fadeAlphaTo:0 duration:0.3];
    
    //run the actions to fade the labels
    [_orbitLabel runAction: fadeLabel2];
    if (_mainShip._inOrbit) {
        [_mainShip runAction:[SKAction rotateByAngle:-(0.5*_mainShip.speed*NORMAL_SHIP_SPEED_PPS/_mainShip._currentPlanet._radius) duration:0.5]];
    }

    [_blackHoleRunLabel runAction:fadeLabel2];
    [_recordLabel runAction:fadeLabel2];
    [_recordNumLabel runAction:fadeLabel2];
    [_rateButton runAction:fadeLabel2];
    [_instructionsButton runAction:fadeLabel2];
    [_noAdsButton runAction:fadeLabel2];
    [_mileNumLabel runAction:fadeLabel];
    [_milesLabel runAction:fadeLabel];
    [_milesBarBg runAction:fadeLabel completion:^{
        _zoomingOut = NO;
        [_goLabel runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:0.2], [SKAction waitForDuration:0.2],[SKAction fadeAlphaTo:0 duration:0.6]]] completion:^{
            [_goLabel removeFromParent];
        }];
    [_pauseButton runAction:fadeLabel];
    [_blackHoleLabel runAction:fadeLabel];
    [_arrowNode runAction:fadeLabel];
    [_tapAndHold runAction:fadeLabel2];
    [_blackHole runAction:fadeLabel];
        if (_mainShip._inOrbit){
            float theNewAngle = CGPointToAngle(CGPointSubtract(_mainShip.position, _mainShip._currentPlanet.position));
            _mainShip._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: _mainShip._currentPlanet.position radius: _mainShip._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle - (2*M_PI - 0.0001) clockwise: NO];
            [_mainShip removeAllActions];
            [_mainShip runAction:[SKAction repeatActionForever: [SKAction followPath: _mainShip._currentPlanet._gravPath.CGPath asOffset: NO orientToPath: NO duration:((2*M_PI) *_mainShip._currentPlanet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS]]];
        }
    }];
    
    SKAction *unfadeProgressBar = [SKAction fadeAlphaBy:1 duration:0.5];
    if ([_gameMode isEqualToString: @"race"])
        [_raceProgressBar runAction:unfadeProgressBar];
    else if([_gameMode isEqualToString:@"black_hole"])
        [_blackHoleProgressBar runAction:unfadeProgressBar];
    
    //run the actions to scale _backgroundLayer and _background out
    SKAction *togetherNow =[SKAction group:@[[SKAction scaleTo:1.0 duration:0.5], [SKAction moveToX:self.size.width*0.1 duration:0.5]]];
    togetherNow.timingMode = SKActionTimingEaseOut;
    [_backgroundLayer runAction:togetherNow];
    [_background runAction:scaleOut];
    
}

-(void) updateMiles
{
    //if ships position is greater than the next mile distance
    if(_mainShip.position.y > _nextMileDistance && !_mainShip._dead){
        //make mileNumLabel pop and change the miles
        _miles++;
        if (_miles % 5 == 0){
            [_background runAction:[SKAction fadeAlphaTo:0 duration:0.5] completion:^{
                int bgIndex = arc4random_uniform((int)_backgroundImages.count);
                _background.texture = _backgroundImages[bgIndex];
                [_background runAction:[SKAction sequence:@[[SKAction waitForDuration:0.1],[SKAction fadeAlphaTo:1 duration:0.5]]]];
            }];
        }
        
        _mileNumLabel.text = [NSString stringWithFormat:@"%i", _miles];
        _milesLabel.text = (_miles == 1) ? @"LIGHT YEAR" : @"LIGHT YEARS";
        [_mileNumLabel runAction:_popMileNum];
        _nextMileDistance += 200;
        if (_miles > _record)
        {
            _milesLabel.fontColor = _recordColor;
            _mileNumLabel.fontColor = _recordColor;
            [_newRecordBeepPlayer play];
            
        }else
        {
            [_nextMileBeepPlayer play];
        }
    }
}

-(void) openDeadMenu
{
    
    if (_miles > _record){
        _newHighScore = YES;
        _record = _miles;
    }
    
    CGPoint shipPosToTopLeftVector = CGPointSubtract(CGPointMake(0, _contentNode.size.height), CGPointMake(_mainShip.position.x + _contentNode.size.width*0.1, _backgroundLayer.position.y + _mainShip.position.y));
    _deadMenu = [SKSpriteNode spriteNodeWithImageNamed:@"pause_death_screen"];
    _deadMenu.size = CGSizeMake(_contentNode.size.width, _contentNode.size.height);
    _deadMenu.anchorPoint = CGPointMake((_mainShip.position.x+_contentNode.size.width*0.1)/_contentNode.size.width, (_backgroundLayer.position.y + _mainShip.position.y)/_contentNode.size.height);
    _deadMenu.position = CGPointMake(_mainShip.position.x + _contentNode.size.width*0.1, _backgroundLayer.position.y + _mainShip.position.y);
    _deadMenu.xScale = 0;
    _deadMenu.yScale = 0;
    _deadMenu.zPosition  = 200;
    
    _mainMenuButton = [SKSpriteNode spriteNodeWithImageNamed:@"new_game_button"];
    _mainMenuButton.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.83));
    _mainMenuButton.size = CGSizeMake(_contentNode.size.width*0.6, 0.25*_contentNode.size.width*0.6);
    

    [_recordNumLabel removeFromParent];
    [_milesLabel removeFromParent];
    [_recordLabel removeFromParent];
    _recordLabel.alpha = 1;
    _recordNumLabel.alpha = 1;
    _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.52));
    _recordNumLabel.position = CGPointAdd(shipPosToTopLeftVector,CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.53));
    _recordLabel.fontSize = 0.094*_contentNode.size.width;
    _recordNumLabel.fontSize = 0.094*_contentNode.size.width;

    
//    _yourScore = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
//    _yourScore.text = @"Your score:";
//    _yourScore.fontSize = 30;
//    _yourScore.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height-35)*0.35));
//    [_deadMenu addChild:_yourScore];
    
    
    _mileNumLabel.text = (_miles == 1) ? [NSString stringWithFormat:@"%i LIGHT YEAR", _miles]: [NSString stringWithFormat:@"%i LIGHT YEARS", _miles];
    _mileNumLabel.fontSize = 0.094*_contentNode.size.width;
//    _mileNumLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _mileNumLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.36));
    [_mileNumLabel removeFromParent];
    
    
    if (_newHighScore){
        _mileNumLabel.fontColor = _recordColor;
        _recordNumLabel.alpha = 0;
        _recordLabel.text = @"New Record!";
        _recordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.48));
        
        //To insert the data into the plist
        [_data setObject:[NSNumber numberWithInt:_record] forKey:@"record"];
        [_data writeToFile: _dataPath atomically:YES];
    }
{
//    if([_gameMode isEqualToString:@"race"])
//    {
//        [_raceProgressBar runAction:[SKAction fadeAlphaTo:0 duration:0.5]];
//        [_pauseButton runAction:[SKAction fadeAlphaTo:0 duration:0.5] completion:^{
//            [_raceProgressBar removeFromParent];
//            [_pauseButton removeFromParent];
//        }];
//        [_milesBarBg runAction:[SKAction fadeAlphaTo:0 duration:0.5]];
//        
//        //[self createDeadShipsImage];
//        _deadShips = [SKSpriteNode spriteNodeWithImageNamed:@"venus"];
//        _deadShips.size = CGSizeMake(0.1*_contentNode.size.width, 0.1*_contentNode.size.width);
//        _deadShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.68));
//        
//        //[self createAliveShipsImage];
//        _aliveShips = [SKSpriteNode spriteNodeWithImageNamed:@"sun"];
//        _aliveShips.size = CGSizeMake(0.1*_contentNode.size.width, 0.1*_contentNode.size.width);
//        _aliveShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.2));
//        
//    }else if ([_gameMode isEqualToString:@"black_hole"])
}
    {
        [_blackHole runAction:[SKAction group:@[[SKAction moveToX:-_contentNode.size.width*0.1 duration:0.5], [SKAction scaleXTo:_contentNode.size.width/_backgroundLayer.size.width y:1 duration:0.5]]]];
        [_blackHoleTrail runAction:[SKAction moveToX:-_contentNode.size.width*0.1 duration:0.5]];
        
        [_blackHoleProgressBar runAction:[SKAction fadeAlphaTo:0 duration:0.5]];
        [_pauseButton runAction:[SKAction fadeAlphaTo:0 duration:0.5] completion:^{
            [_blackHoleProgressBar removeFromParent];
            [_pauseButton removeFromParent];
        }];
        [_milesBarBg runAction:[SKAction fadeAlphaTo:0 duration:0.5]];
        
        _aliveShips = [SKSpriteNode spriteNodeWithImageNamed:@"main_ship_rubble"];
        _aliveShips.size = CGSizeMake(0.2*_contentNode.size.width, 0.2*_contentNode.size.width);
        _aliveShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.68));
        
        _deadShips = [SKSpriteNode spriteNodeWithImageNamed:@"black_hole"];
        _deadShips.size = CGSizeMake(0.22*_contentNode.size.width, 0.22*_contentNode.size.width);
        _deadShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.2));
        
        _blackHoleMenuTrail = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"black_hole_menu_trail"] size:CGSizeMake(0.29*_contentNode.size.width, _contentNode.size.height*0.63)];
        _blackHoleMenuTrail.anchorPoint = CGPointMake(0.5, 1);
        _blackHoleMenuTrail.position = _deadShips.position;
        [_deadMenu addChild:_blackHoleMenuTrail];
        
    }
    [_deadMenu addChild:_aliveShips];
    [_deadMenu addChild:_deadShips];
    [_deadMenu addChild:_mileNumLabel];
    [_deadMenu addChild:_recordLabel];
    [_deadMenu addChild:_recordNumLabel];
    [_deadMenu addChild:_mainMenuButton];
    
    [self addChild:_deadMenu];
    SKAction *presentDeadMenu = [SKAction scaleTo:1 duration:0.5];
    presentDeadMenu.timingMode = SKActionTimingEaseOut;
    [_deadMenu runAction:presentDeadMenu];
}

-(void) openPausedMenu
{
    if (_miles > _record){
        _newHighScore = YES;
        _record = _miles;
    }
    
    _pauseMenu = [SKSpriteNode spriteNodeWithImageNamed:@"pause_death_screen"];
    _pauseMenu.anchorPoint = CGPointMake(0, 1);
    _pauseMenu.position = CGPointMake(_contentNode.size.width*0.1, _contentNode.size.height*0.923);
    _pauseMenu.size = CGSizeMake(_backgroundLayer.size.width, _contentNode.size.height*0.923);
    _pauseMenu.xScale = 0;
    _pauseMenu.yScale = 0;
    _pauseMenu.zPosition = 200;
    
    _resumeButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"resume_button"] size: CGSizeMake(_backgroundLayer.size.width*.45, 0.33*_backgroundLayer.size.width*.45) ];
    _resumeButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.57);
    
    _mainMenuButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"new_game_button"] size: CGSizeMake(_backgroundLayer.size.width*0.6, 0.25*_backgroundLayer.size.width*0.6) ];
    _mainMenuButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.68);
    
    [_recordLabel removeFromParent];
    [_recordNumLabel removeFromParent];
    
    
    if (_newHighScore){
        _recordLabel.text = @"New Record!";
        _recordNumLabel.text = (_record == 1) ? [NSString stringWithFormat:@"%i LIGHT YEAR", _record]: [NSString stringWithFormat:@"%i LIGHT YEARS", _record];
        //insert the data into the plist
        [_data setObject:[NSNumber numberWithInt:_record] forKey:@"record"];
        [_data writeToFile: _dataPath atomically:YES];
    }
    
    _recordLabel.alpha = 1;
    _recordNumLabel.alpha = 1;
    _recordLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.80);
    _recordNumLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.82);
    _recordNumLabel.fontSize = 0.078*_contentNode.size.width;
    _recordLabel.fontSize = 0.094*_contentNode.size.width;
    
    
//    if([_gameMode isEqualToString:@"race"])
//    {
//        
//        //[self createDeadShipsImage];
//        _deadShips = [SKSpriteNode spriteNodeWithImageNamed:@"venus"];
//        _deadShips.size = CGSizeMake(30, 30);
//        _deadShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height-35)*0.4);
//        
//        //[self createAliveShipsImage];
//        _aliveShips = [SKSpriteNode spriteNodeWithImageNamed:@"sun"];
//        _aliveShips.size = CGSizeMake(30,30);
//        _aliveShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height-35)*0.22);
//        
//    }else if ([_gameMode isEqualToString:@"black_hole"])
    {
        
        _deadShips = [SKSpriteNode spriteNodeWithImageNamed:@"black_hole"];
        _deadShips.size = CGSizeMake(0.22*_contentNode.size.width, 0.22*_contentNode.size.width);
        _deadShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.4);
        
        _aliveShips = [SKSpriteNode spriteNodeWithImageNamed:@"main_ship_trail"];
        _aliveShips.size = CGSizeMake(0.1*_contentNode.size.width, 0.3*_contentNode.size.width);
        _aliveShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.22);
        
        _blackHoleMenuTrail = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"black_hole_menu_trail"] size:CGSizeMake(0.29*_contentNode.size.width, _contentNode.size.height*0.48)];
        _blackHoleMenuTrail.anchorPoint = CGPointMake(0.5, 1);
        _blackHoleMenuTrail.position = _deadShips.position;
        [_pauseMenu addChild:_blackHoleMenuTrail];
        
    }
    
    [_pauseMenu addChild:_resumeButton];
    [_pauseMenu addChild:_mainMenuButton];
    [_pauseMenu addChild:_recordLabel];
    [_pauseMenu addChild:_recordNumLabel];
    [_pauseMenu addChild:_deadShips];
    [_pauseMenu addChild:_aliveShips];
    
    [self addChild:_pauseMenu];
    SKAction *presentPauseMenu = [SKAction scaleTo:1 duration:0.3];
    presentPauseMenu.timingMode = SKActionTimingEaseOut;
    [_pauseMenu runAction:presentPauseMenu];
}

-(void) updateProgressBars
{
//    if ( !_mainShip._dead && [_gameMode isEqualToString:@"race"]){
//        if (!_noMoreProgressBarUpdates){
//            //if returns yes, mainship is above next checkpoint
//            if ([_raceProgressBar adjustProgressBars_nextCheckPoint:_nextCheckP yellowPos:_yellowShip.position.y redPos:_redShip.position.y mainPos:_mainShip.position.y greenPos:_greenShip.position.y bluePos:_blueShip.position.y])
//            {
//                if (_nextCheckP == _checkPoint2)
//                    _nextCheckP = _checkPoint3;
//                if (_nextCheckP == _checkPoint3)
//                    _nextCheckP = _checkPoint4;
//                if (_nextCheckP == _checkPoint4)
//                    _noMoreProgressBarUpdates = YES;
//            }
//        }
//    }else if ([_gameMode isEqualToString:@"black_hole"])
        if(!_mainShip._dead )
        {
            [_blackHoleProgressBar adjustBlackHoleProgressBar_mainShipPos:_mainShip.position _blackHolePos:_blackHole.position];
        }
}

-(void) checkShipDeath
{
    if(_gameStarted){
//        if ([_gameMode isEqualToString:@"race"])
//        {
//            _yellowShip.paused = YES;
//            _redShip.paused = YES;
//            _greenShip.paused = YES;
//            _blueShip.paused = YES;
//            
//        } else if ([_gameMode isEqualToString:@"black_hole"])
        {
            if (_mainShip.position.y < _blackHole.position.y + _blackHole.size.height*0.5 && !_mainShip._dead)
            {
                _mainShip._dead = YES;
                _mainShip.physicsBody.contactTestBitMask = 0;
                
                [_blackHoleProgressBar killShip];
                
                [_blackHolePlayer play];
                [_beepInPlayer stop];
                
                [_mainShip removeAllActions];
                _mainShip.speed = 1;
                [_mainShip runAction: [SKAction group:@[[SKAction rotateByAngle:6*M_PI duration:1.5], [SKAction moveTo:CGPointMake(_blackHole.position.x+_blackHole.size.width/2, _blackHole.position.y+1.5*NORMAL_SHIP_SPEED_PPS*_blackHole.speed) duration:1.5],[SKAction scaleTo:0 duration:1.5]]]];
                [self runAction:[SKAction waitForDuration:1.5] completion:^{
                    [self openDeadMenu];
                }];
            }
        }
    }
}

//-(void) setUpRaceGame
//{
//    _stopLightPlanet1 = [[Planet alloc] initWithSize:CGSizeMake(40,40) andPosition:CGPointMake(35, 120) andImage:@"blank_planet"];
//    [_backgroundLayer addChild:_stopLightPlanet1];
//    [_planets insertObject:_stopLightPlanet1 atIndex:1];
//    
//    _stopLightPlanet2 = [[Planet alloc] initWithSize:CGSizeMake(40,40) andPosition:CGPointMake(_backgroundLayer.size.width-35, 120) andImage:@"blank_planet"];
//    [_backgroundLayer addChild:_stopLightPlanet2];
//    [_planets insertObject:_stopLightPlanet2 atIndex:2];
//    
//    _yellowShip = [[Ship alloc] initWithPosition:CGPointMake(5,120) andSize:CGSizeMake(1.82*0.25*_backgroundLayer.size.width*0.27/1.6, 0.25*_backgroundLayer.size.width*0.27/1.6) andImage:@"yellow_ship"];
//    _yellowShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone| CNPhysicsCategoryAsteroid;
//    _yellowShip.name = @"yellow ship";
//    _greenShip = [[Ship alloc] initWithPosition:CGPointMake(65,120) andSize:CGSizeMake(1.82*0.25*_backgroundLayer.size.width*0.27/1.6, 0.25*_backgroundLayer.size.width*0.27/1.6) andImage:@"green_ship"];
//    _greenShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone | CNPhysicsCategoryAsteroid;
//    _greenShip.name = @"green ship";
//    _redShip = [[Ship alloc] initWithPosition:CGPointMake(_backgroundLayer.size.width-5,120) andSize:CGSizeMake(1.82*0.25*_backgroundLayer.size.width*0.27/1.6, 0.25*_backgroundLayer.size.width*0.27/1.6) andImage:@"red_ship"];
//    _redShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone | CNPhysicsCategoryAsteroid;
//    _redShip.name = @"red ship";
//    _blueShip = [[Ship alloc] initWithPosition:CGPointMake(_backgroundLayer.size.width-65,120) andSize:CGSizeMake(1.82*0.25*_backgroundLayer.size.width*0.27/1.6, 0.25*_backgroundLayer.size.width*0.27/1.6) andImage:@"blue_ship"];
//    _blueShip.physicsBody.contactTestBitMask = CNPhysicsCategoryMainshipGravityZone | CNPhysicsCategoryOthershipGravityZone | CNPhysicsCategoryAsteroid;
//    _blueShip.name = @"blue ship";
//    //initialize an array of the ships
//    _ships = [NSArray arrayWithObjects:_mainShip, _yellowShip, _redShip, _greenShip, _blueShip, nil];
//    
//    _yellowShip._newPos = _yellowShip.position;
//    _redShip._newPos = _redShip.position;
//    _greenShip._newPos = _greenShip.position;
//    _blueShip._newPos = _blueShip.position;
//    
//    _yellowShip.zRotation = M_PI_2;
//    _greenShip.zRotation = -M_PI_2;
//    _redShip.zRotation = -M_PI_2;
//    _blueShip.zRotation = M_PI_2;
//    
//    //set up progress bar
//    _raceProgressBar = [[RaceProgressBar alloc] initWithScreenSize:self.size];
//    _raceProgressBar.alpha = 0;
//    //set up checkpoints and progressbar variables
//    _checkPoint1 = 400 + 300*2;
//    _checkPoint2 = _checkPoint1 + 300*2;
//    _checkPoint3 = _checkPoint2 + 300*5;
//    _checkPoint4 = _checkPoint3 + 300*5;
//    _raceProgressBar._beforeLastCheckpointPos = 0;
//    _raceProgressBar._lastCheckpointPos = 0;
//    _raceProgressBar._nextCheckpointPos = _checkPoint1;
//    _nextCheckP = _checkPoint2;
//    _noMoreProgressBarUpdates = NO;
//    
//    [_backgroundLayer addChild:_yellowShip];
//    [_backgroundLayer addChild:_greenShip];
//    [_backgroundLayer addChild:_redShip];
//    [_backgroundLayer addChild:_blueShip];
//    [self addChild:_raceProgressBar];
//    
//    NSArray *_otherShips = [NSArray arrayWithObjects:_yellowShip, _greenShip, _redShip, _blueShip, nil];
//    
//    //set startgame to true after 3.5 and changes the stoplight color every 1 second
//    SKAction *startGame = [SKAction sequence:@[[SKAction waitForDuration:0.5], [SKAction runBlock:^{
//        _stopLightPlanet1._planetBody.color = [SKColor redColor];
//        _stopLightPlanet2._planetBody.color = [SKColor redColor];
//        _stopLightPlanet1._planetBody.colorBlendFactor = 1;
//        _stopLightPlanet2._planetBody.colorBlendFactor = 1;
//    }], [SKAction waitForDuration:1],[SKAction runBlock:^{
//        _stopLightPlanet1._planetBody.color = [SKColor yellowColor];
//        _stopLightPlanet2._planetBody.color = [SKColor yellowColor];
//    }], [SKAction waitForDuration:1], [SKAction runBlock:^{
//        _stopLightPlanet1._planetBody.color = [SKColor greenColor];
//        _stopLightPlanet2._planetBody.color = [SKColor greenColor];
//    }], [SKAction runBlock:^{
//        _gameStarted = YES;
//    }]]];
//    [_stopLightPlanet1._planetBody runAction:startGame];
//    
//    //sets ships running
//    for (Ship* ship in _otherShips) {
//        SKAction *freeFly = [SKAction moveByX:cos(ship.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(ship.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
//        [ship runAction:[SKAction repeatActionForever:freeFly]];
//    }
//}

-(void) setUpBlackHoleGame
{
    if (![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
        _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        _adBanner.delegate = self;
        [UIViewController prepareInterstitialAds];
    }
    
    _blackHoleProgressBar = [[BlackHoleProgressBar alloc] initWithScreenSize:_contentNode.size _recordPos:350+200*_record];
    _blackHoleProgressBar.alpha = 0;
    [self addChild:_blackHoleProgressBar];
    
    //(width set as such due to _backgroundLayer's scale of 2)
    _blackHole = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"black_hole_squished"] size:CGSizeMake(_backgroundLayer.size.width/2, _backgroundLayer.size.width/4)];
    _blackHole.anchorPoint = CGPointMake(0, 0.5);
    _blackHole.position = CGPointMake(0, -_contentNode.size.height);
    _blackHole.alpha = 0;
    _blackHole.zPosition = 99;
    
    _blackHoleTrail = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"black_hole_screen_trail"] size:CGSizeMake(_contentNode.size.width, 6000)];
    _blackHoleTrail.anchorPoint = CGPointMake(0, 1);
    _blackHoleTrail.position = _blackHole.position;
    
    [_backgroundLayer addChild:_blackHoleTrail];
    [_backgroundLayer addChild:_blackHole];
    
    SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
    [_mainShip runAction:[SKAction repeatActionForever:freeFly]];
    
    SKAction *moveBlackHole = [SKAction repeatActionForever:[SKAction moveBy:CGVectorMake(0, NORMAL_SHIP_SPEED_PPS) duration:1]];
    [_blackHole runAction:moveBlackHole];
    [_blackHoleTrail runAction:moveBlackHole];
    _blackHole.speed = 0;
    _blackHoleTrail.speed = 0;
    
    _blackHoleLabel = [SKLabelNode labelNodeWithFontNamed:@"Hemi Head"];
    _blackHoleLabel.text = @"BLACK HOLE";
    _blackHoleLabel.fontSize = 25;
    _blackHoleLabel.position = CGPointMake(self.size.width*0.55,0.087*_contentNode.size.height);
    _blackHoleLabel.alpha = 0;
    [self addChild:_blackHoleLabel];
    
    _arrowNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"white_arrow"] size:CGSizeMake(0.1*_contentNode.size.width, 0.1*_contentNode.size.width)];
    _arrowNode.position = CGPointMake(self.size.width*0.55, 0.029*_contentNode.size.height);
    _arrowNode.alpha = 0;
    [self addChild:_arrowNode];
    SKAction *moveDown = [SKAction moveBy: CGVectorMake(0,10) duration:0.5];
    moveDown.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *point = [SKAction repeatActionForever:[SKAction sequence:@[moveDown, [moveDown reversedAction]]]];
    [_arrowNode runAction:point];
    
    [self runAction:[SKAction waitForDuration:0.5] completion:^{
        _gameStarted = YES;
    }];

}

-(void) speedUpBlackHole
{
    
    _timeSinceCreation += _dt;
    if (_clickNum >= 2 && _timeSinceCreation > _nextBoost){
        _nextBoostIncrement = 0;
        _blackHole.speed += .1;
        if (_blackHole.speed > 1.2) {
            _nextBoostIncrement += 0.6;
        }
        if (_blackHole.speed > 1.4) {
            _nextBoostIncrement += 0.6;
        }
        if (_blackHole.speed > 1.6){
            _nextBoostIncrement += 0.6;
        }
        if (_blackHole.speed >= 1.7){
            _blackHole.speed -= 0.05;
            _nextBoostIncrement += 0.6;
        }
        if (_blackHole.speed >= 1.75){
            _nextBoostIncrement += 0.6;
        }
        if (_blackHole.speed >= 1.8){
            _nextBoostIncrement += 10000000;
        }
        _nextBoostIncrement += 0.6;

        _nextBoost = _timeSinceCreation + _nextBoostIncrement;
        _blackHoleTrail.position = _blackHole.position;
        _blackHoleTrail.speed = _blackHole.speed;
    }
    
}

-(void) pauseScene
{
    if (!_paused && !_mainShip._dead && _gameStarted){
        _paused = YES;
        _pauseButton.texture = [SKTexture textureWithImageNamed:@"pause_button_pressed"];
        _mainShip.paused = YES;
        if ([_gameMode isEqualToString:@"race"]) {
            _yellowShip.paused = YES;
            _redShip.paused = YES;
            _greenShip.paused = YES;
            _blueShip.paused = YES;
        }else if ([_gameMode isEqualToString:@"black_hole"]){
            _blackHole.paused = YES;
            _blackHoleTrail.paused = YES;
        }
        
        for (int i = _plannetCounter + 15; i >= _plannetCounter; i--){
            Planet *planet = [_planets objectAtIndex:i];
            planet.paused = YES;
        }
        [self openPausedMenu];
    }else if(!_gameStarted)
    {
        _mainShip.paused = YES;
    }

}

-(void) unpauseScene
{
    if(!_gameStarted){
        _mainShip.paused = NO;
    }
}

-(void) newGame
{
    if (![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
        [_adBanner removeFromSuperview];
        [self.view.window.rootViewController requestInterstitialAdPresentation];
    }
    [_mainMenuButton runAction:[SKAction waitForDuration:0.05] completion:^{
        _mainMenuButton.texture = [SKTexture textureWithImageNamed:@"new_game_button"];
    }];
    [_bgMusicPlayer stop];

    MyScene *newScene = [MyScene sceneWithSize:self.size];
    newScene.scaleMode = SKSceneScaleModeAspectFill;
    [self runAction:[SKAction waitForDuration:0.3] completion:^{
        [self.view presentScene: newScene];
    }];
}

-(void) resumeGame
{
    [_resumeButton runAction:[SKAction waitForDuration:0.05] completion:^{
        _resumeButton.texture = [SKTexture textureWithImageNamed:@"resume_button"];
    }];
    
    [_pauseMenu runAction:[SKAction scaleTo:0 duration:0.4] completion:^{
        _paused = NO;
        _pauseButton.texture = [SKTexture textureWithImageNamed:@"pause_button"];
        _mainShip.paused = NO;
        if ([_gameMode isEqualToString:@"race"]) {
            _yellowShip.paused = NO;
            _redShip.paused = NO;
            _greenShip.paused = NO;
            _blueShip.paused = NO;
        }else if ([_gameMode isEqualToString:@"black_hole"]){
            _blackHole.paused = NO;
            _blackHoleTrail.paused = NO;
        }
        for (int i = _plannetCounter + 15; i >= _plannetCounter; i--){
            Planet *planet = [_planets objectAtIndex:i];
            planet.paused = NO;
        }
    }];
}

-(void) enterOrbit:(Ship *)ship
{
    
    ship._hasEntered = YES;
    
    //removes actions on current planet's gravZone image
    [ship._currentPlanet._gravZoneImage removeAllActions];
    //scale gravzone image to 1.03
    [ship._currentPlanet._gravZoneImage runAction:[SKAction scaleTo:1.03 duration:0.2]];
    
    //remove all actions from ship
    [ship removeAllActions];
    
    //set the planet to ship angle to a number between 0 and 2PI
    ship._planetToShipAngle = CGPointToAngle(CGPointSubtract(ship.position, ship._currentPlanet.position));
    while (ship._planetToShipAngle > M_PI){ ship._planetToShipAngle -= M_PI; }
    while (ship._planetToShipAngle < -M_PI) { ship._planetToShipAngle += M_PI;}
    
    //set the angle from the ship to the planet to a number between -M_PI and M_PI
    float shipToPlanetAngle = CGPointToAngle(CGPointSubtract(ship._currentPlanet.position, ship.position));
    while (shipToPlanetAngle > M_PI){ shipToPlanetAngle -= 2*M_PI; }
    while (shipToPlanetAngle < -M_PI) { shipToPlanetAngle += 2*M_PI; }
    
    //set the accuracy angle to the angle between the ship to planet angle and the zRotation (directional angle) of the ship
    //set accuracy angle to a number between 0 and 2PI
    ship._accuracyAngle = ship.zRotation - shipToPlanetAngle;
    while (ship._accuracyAngle > M_PI){ ship._accuracyAngle -= 2*M_PI; }
    while (ship._accuracyAngle < -M_PI) { ship._accuracyAngle += 2*M_PI; }
    
    //switches accuracy angle to degrees
    ship._accuracyAngle *= (float)180/M_PI;
    
    //sets the clockwise property depending on which side of the planet the ship hit with respect to where it last left orbit
    if(ship._accuracyAngle >= 0){
        ship._clockwise = YES;
        ship._clockwiseInt = 1;
    } else {
        ship._clockwise = NO;
        ship._clockwiseInt = -1;
    }
    
    //for game if other ships are added
//    int currentPlannetIndex = (int)[_planets indexOfObject:ship._currentPlanet];
//    if (ship._currentPlanet.position.x <= _backgroundLayer.size.width*0.33-10){
//        Planet *newPlanet = [_planets objectAtIndex: currentPlannetIndex + 3 + arc4random_uniform(2)];
//        float newPlanetToReleasePointAngle = CGPointToAngle(CGPointSubtract(ship._currentPlanet.position, newPlanet.position)) - ship._clockwiseInt*asin((1.3*ship._currentPlanet._radius)/CGPointLength( CGPointSubtract(ship._currentPlanet.position, newPlanet.position)));
//        float newAccuracyAngle = arc4random_uniform(90)*M_PI/180;
//        CGPoint pointToHit = CGPointMake(newPlanet.position.x + cos(newPlanetToReleasePointAngle+newAccuracyAngle)*newPlanet._radius*1.6, newPlanet.position.y + sin(newPlanetToReleasePointAngle+newAccuracyAngle)*newPlanet._radius*1.6);
//        ship._releaseAngle = CGPointToAngle(CGPointSubtract(pointToHit, ship._currentPlanet.position)) + ship._clockwiseInt*(acos((1.3*ship._currentPlanet._radius)/CGPointLength(CGPointSubtract(pointToHit, ship._currentPlanet.position))) - 90);
//        
//    }else if (ship._currentPlanet.position.x <= _backgroundLayer.size.width*0.67-10){
//        Planet *newPlanet = [_planets objectAtIndex:currentPlannetIndex + 2 + arc4random_uniform(3)];
//        float newPlanetToReleasePointAngle = CGPointToAngle(CGPointSubtract(ship._currentPlanet.position, newPlanet.position)) - ship._clockwiseInt*asin((1.3*ship._currentPlanet._radius)/CGPointLength( CGPointSubtract(ship._currentPlanet.position, newPlanet.position)));
//        float newAccuracyAngle = arc4random_uniform(90)*M_PI/180;
//        CGPoint pointToHit = CGPointMake(newPlanet.position.x + cos(newPlanetToReleasePointAngle+newAccuracyAngle)*newPlanet._radius*1.6, newPlanet.position.y + sin(newPlanetToReleasePointAngle+newAccuracyAngle)*newPlanet._radius*1.6);
//        ship._releaseAngle = CGPointToAngle(CGPointSubtract(pointToHit, ship._currentPlanet.position)) + ship._clockwiseInt*(acos((1.3*ship._currentPlanet._radius)/CGPointLength(CGPointSubtract(pointToHit, ship._currentPlanet.position))) - 90);
//        
//    }else{
//        Planet* newPlanet = [_planets objectAtIndex: currentPlannetIndex + 2 + arc4random_uniform(2)];
//        float newPlanetToReleasePointAngle = CGPointToAngle(CGPointSubtract(ship._currentPlanet.position, newPlanet.position)) - ship._clockwiseInt*asin((1.3*ship._currentPlanet._radius)/CGPointLength( CGPointSubtract(ship._currentPlanet.position, newPlanet.position)));
//        float newAccuracyAngle = arc4random_uniform(90)*M_PI/180;
//        CGPoint pointToHit = CGPointMake(newPlanet.position.x + cos(newPlanetToReleasePointAngle+newAccuracyAngle)*newPlanet._radius*1.6, newPlanet.position.y + sin(newPlanetToReleasePointAngle+newAccuracyAngle)*newPlanet._radius*1.6);
//        ship._releaseAngle = CGPointToAngle(CGPointSubtract(pointToHit, ship._currentPlanet.position)) + ship._clockwiseInt*(acos((1.3*ship._currentPlanet._radius)/CGPointLength(CGPointSubtract(pointToHit, ship._currentPlanet.position))) - 90);
//    }
    
    if (abs(ship._accuracyAngle) > 55){
        
        CGPoint newPosition;
        
        //if ship should rotate clockwise
        if(ship._clockwise){
            //create the curved path that the ship will take to go to the start of the orbit path
            UIBezierPath *entrancePath = [UIBezierPath bezierPath];
            //set the angle the ship should go to
            CGFloat newAngle = ship._planetToShipAngle - M_PI_2*0.7;
            //set the end position with the new angle and the position and radius of the current planet
            newPosition = CGPointMake(ship._currentPlanet.position.x + cos(newAngle)*ship._currentPlanet._radius*1.3, ship._currentPlanet.position.y + sin(newAngle)*ship._currentPlanet._radius*1.3);
            //make a control point for the curve that is 0.3 times the radius of the current planet infront of the ship
            CGPoint controlPoint1 = CGPointAdd(ship.position, CGPointMake(ship._currentPlanet._radius*0.4*cos(ship.zRotation), ship._currentPlanet._radius*0.4*sin(ship.zRotation)));
            CGPoint controlPoint2 = CGPointAdd(newPosition, CGPointMake(0.6*ship._currentPlanet._radius*cos(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))+M_PI_2),0.6*ship._currentPlanet._radius*sin(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))+M_PI_2)));
            //make a curve that goes from ship position to the desired position
            [entrancePath moveToPoint:CGPointAdd(ship.position, CGPointMake(_dt*50*cos(ship.zRotation)*_mainShip.speed, _dt*50*sin(ship.zRotation)*_mainShip.speed))];
            [entrancePath addCurveToPoint: newPosition controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            [entrancePath addArcWithCenter:ship._currentPlanet.position radius:ship._currentPlanet._radius * 1.3 startAngle:newAngle endAngle:newAngle - (2*M_PI - 0.0001) clockwise:NO];
            ship._currentPlanet._entrancePath = entrancePath;
            //set the entrancePathLength based on the entrancePath specifications
            ship._entrancePathLength = [self bezierCurveLengthFromStartPoint:ship.position toEndPoint:newPosition withControlPoint:controlPoint1];
        }else{
            //create the curved path that the ship will take to go to the start of the orbit path
            UIBezierPath *entrancePath = [UIBezierPath bezierPath];
            //set the angle the ship shoul go to
            CGFloat newAngle = ship._planetToShipAngle + M_PI_2*0.7;
            //set the end position with the new angle and the position and radius of the current planet
            newPosition = CGPointMake(ship._currentPlanet.position.x + cos(newAngle)*ship._currentPlanet._radius*1.3, ship._currentPlanet.position.y + sin(newAngle)*ship._currentPlanet._radius*1.3);
            //make a control point for the curve that is 0.3 times the radius of the current planet infront of the ship
            CGPoint controlPoint1 = CGPointAdd(ship.position, CGPointMake(ship._currentPlanet._radius*0.4*cos(ship.zRotation), ship._currentPlanet._radius*0.4*sin(ship.zRotation)));
            CGPoint controlPoint2 = CGPointAdd(newPosition, CGPointMake(0.6*ship._currentPlanet._radius*cos(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))-M_PI_2),0.6*ship._currentPlanet._radius*sin(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))-M_PI_2)));
            //make a curve that goes from ship position to the desired position
            [entrancePath moveToPoint:CGPointAdd(ship.position, CGPointMake(_dt*50*cos(ship.zRotation)*_mainShip.speed, _dt*50*sin(ship.zRotation)*_mainShip.speed))];
            [entrancePath addCurveToPoint: newPosition controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            [entrancePath addArcWithCenter:ship._currentPlanet.position radius:ship._currentPlanet._radius * 1.3 startAngle:newAngle endAngle:newAngle + (2*M_PI - 0.0001) clockwise:YES];
            ship._currentPlanet._entrancePath = entrancePath;
            //set the entrancePathLength based on the entrancePath specifications
            ship._entrancePathLength = [self bezierCurveLengthFromStartPoint:ship.position toEndPoint:newPosition withControlPoint:controlPoint1];
        }
        
        //sets the path that the ship will follow, starting and ending with its current position
        //issue with clockwise - seems flipped for some reason here
        
        CGFloat theNewAngle;
        
        if(ship._clockwise){
            theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position));
            ship._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: ship._currentPlanet.position radius: ship._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle - (2*M_PI - 0.0001) clockwise: !ship._clockwise];
            theNewAngle -= M_PI_2;
        }else{
            theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position));
            ship._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: ship._currentPlanet.position radius: ship._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle + (2*M_PI - 0.0001) clockwise: !ship._clockwise];
            theNewAngle += M_PI_2;
        }
    }else{
        
        CGPoint newPosition;
        
        //if ship should rotate clockwise
        if(ship._clockwise){
            //create the curved path that the ship will take to go to the start of the orbit path
            UIBezierPath *entrancePath = [UIBezierPath bezierPath];
            //set the angle the ship should go to
            CGFloat newAngle = ship._planetToShipAngle - M_PI_4;
            //set the end position with the new angle and the position and radius of the current planet
            newPosition = CGPointMake(ship._currentPlanet.position.x + cos(newAngle)*ship._currentPlanet._radius*1.3, ship._currentPlanet.position.y + sin(newAngle)*ship._currentPlanet._radius*1.3);
            //make a control point for the curve that is 0.3 times the radius of the current planet infront of the ship
            CGPoint controlPoint1 = CGPointAdd(ship.position, CGPointMake(ship._currentPlanet._radius*0.2*cos(ship.zRotation), ship._currentPlanet._radius*0.2*sin(ship.zRotation)));
            CGPoint controlPoint2 = CGPointAdd(newPosition, CGPointMake(0.2*ship._currentPlanet._radius*cos(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))+M_PI_2),0.2*ship._currentPlanet._radius*sin(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))+M_PI_2)));
            //make a curve that goes from ship position to the desired position
            [entrancePath moveToPoint:CGPointAdd(ship.position, CGPointMake(_dt*50*cos(ship.zRotation)*_mainShip.speed, _dt*50*sin(ship.zRotation)*_mainShip.speed))];
            [entrancePath addCurveToPoint: newPosition controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            [entrancePath addArcWithCenter:ship._currentPlanet.position radius:ship._currentPlanet._radius * 1.3 startAngle:newAngle endAngle:newAngle - (2*M_PI - 0.0001) clockwise:NO];
            ship._currentPlanet._entrancePath = entrancePath;
            //set the entrancePathLength based on the entrancePath specifications
            ship._entrancePathLength = [self bezierCurveLengthFromStartPoint:ship.position toEndPoint:newPosition withControlPoint:controlPoint1];
        }else{
            //create the curved path that the ship will take to go to the start of the orbit path
            UIBezierPath *entrancePath = [UIBezierPath bezierPath];
            //set the angle the ship shoul go to
            CGFloat newAngle = ship._planetToShipAngle + M_PI_4;
            //set the end position with the new angle and the position and radius of the current planet
            newPosition = CGPointMake(ship._currentPlanet.position.x + cos(newAngle)*ship._currentPlanet._radius*1.3, ship._currentPlanet.position.y + sin(newAngle)*ship._currentPlanet._radius*1.3);
            //make a control point for the curve that is 0.3 times the radius of the current planet infront of the ship
            CGPoint controlPoint1 = CGPointAdd(ship.position, CGPointMake(ship._currentPlanet._radius*0.2*cos(ship.zRotation), ship._currentPlanet._radius*0.2*sin(ship.zRotation)));
            CGPoint controlPoint2 = CGPointAdd(newPosition, CGPointMake(0.2*ship._currentPlanet._radius*cos(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))-M_PI_2),0.2*ship._currentPlanet._radius*sin(CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position))-M_PI_2)));
            //make a curve that goes from ship position to the desired position
            [entrancePath moveToPoint:CGPointAdd(ship.position, CGPointMake(_dt*50*cos(ship.zRotation)*_mainShip.speed, _dt*50*sin(ship.zRotation)*_mainShip.speed))];
            [entrancePath addCurveToPoint: newPosition controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            [entrancePath addArcWithCenter:ship._currentPlanet.position radius:ship._currentPlanet._radius * 1.3 startAngle:newAngle endAngle:newAngle + (2*M_PI - 0.0001) clockwise:YES];
            ship._currentPlanet._entrancePath = entrancePath;
            //set the entrancePathLength based on the entrancePath specifications
            ship._entrancePathLength = [self bezierCurveLengthFromStartPoint:ship.position toEndPoint:newPosition withControlPoint:controlPoint1];
        }
        
        //sets the path that the ship will follow, starting and ending with its current position
        //issue with clockwise - seems flipped for some reason here
        
        CGFloat theNewAngle;
        
        if(ship._clockwise){
            theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position));
            ship._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: ship._currentPlanet.position radius: ship._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle - (2*M_PI - 0.0001) clockwise: !ship._clockwise];
            theNewAngle -= M_PI_2;
        }else{
            theNewAngle = CGPointToAngle(CGPointSubtract(newPosition, ship._currentPlanet.position));
            ship._currentPlanet._gravPath = [UIBezierPath bezierPathWithArcCenter: ship._currentPlanet.position radius: ship._currentPlanet._radius * 1.3 startAngle:theNewAngle endAngle: theNewAngle + (2*M_PI - 0.0001) clockwise: !ship._clockwise];
            theNewAngle += M_PI_2;
        }
    }
    
    SKAction *followPath = [SKAction repeatActionForever: [SKAction followPath: ship._currentPlanet._gravPath.CGPath asOffset: NO orientToPath: NO duration:((2*M_PI) *ship._currentPlanet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS]];
    
    //run the actions that enter the ship into orbit, set _inOrbit to true, and run the ship laps around the planet
    [ ship runAction: [ SKAction sequence:@[ [ SKAction followPath:ship._currentPlanet._entrancePath.CGPath asOffset:NO orientToPath:NO duration:ship._entrancePathLength/NORMAL_SHIP_SPEED_PPS+((2*M_PI) *ship._currentPlanet._radius * 1.3 ) / NORMAL_SHIP_SPEED_PPS ], followPath ] ] ];
    
    [ self runAction:[ SKAction waitForDuration:ship._entrancePathLength/NORMAL_SHIP_SPEED_PPS] completion:^{
        ship._inOrbit = YES;
    } ];
    
    
    
    if ( ship._accuracyAngle >= 0){
        
        ship._accuracyAngle = abs(ship._accuracyAngle);
        
        if(ship._accuracyAngle > 60){
            if (ship.speed * 1.45 < 2)
                [ship runAction:[SKAction speedTo: ship.speed * 1.45 duration:0.2]];
            else
                [ship runAction:[SKAction speedTo:2 duration:0.2]];
            //make sonic boom effect if ship.speed * 1.3 > 1.5
        }else if(ship._accuracyAngle <= 60 && ship._accuracyAngle > 50){
            if (ship.speed * 1.3 < 2)
                [ship runAction:[SKAction speedTo: ship.speed * 1.3 duration:0.2]];
            else
                [ship runAction:[SKAction speedTo:2 duration:0.2]];
        }else if(ship._accuracyAngle <= 50 && ship._accuracyAngle > 40){
            if (ship.speed * 1.15 < 2)
                [ship runAction:[SKAction speedTo: ship.speed * 1.15 duration:0.2]];
            else
                [ship runAction:[SKAction speedTo:2 duration:0.2]];
        }else if(ship._accuracyAngle <= 40 && ship._accuracyAngle > 30){
            //no speed change
        }else if(ship._accuracyAngle <= 30 && ship._accuracyAngle > 22){
            [ship runAction:[SKAction speedTo: ship.speed * 0.8 duration:0.2]];
        }else if(ship._accuracyAngle <= 22 && ship._accuracyAngle > 14){
            [ship runAction:[SKAction speedTo: ship.speed * 0.6 duration:0.2]];
        }else if(ship._accuracyAngle <= 14 && ship._accuracyAngle > 7){
            [ship runAction:[SKAction speedTo: ship.speed * 0.4 duration:0.2]];
        }else if(ship._accuracyAngle <= 7){
            [ship runAction:[SKAction speedTo: ship.speed * 0.2 duration:0.2]];
        }
        
    }else if(ship._accuracyAngle < 0){
        
        ship._accuracyAngle = abs(ship._accuracyAngle);
        
        if(ship._accuracyAngle > 60){
            if(ship.speed * 1.45 < 2)
                [ship runAction:[SKAction speedTo: ship.speed * 1.45 duration:0.2]];
            else
                [ship runAction:[SKAction speedTo:2 duration:0.2]];
            //make sonic boom effect if ship.speed * 1.3 > 1.5
        }else if(ship._accuracyAngle <= 60 && ship._accuracyAngle > 50){
            if(ship.speed * 1.3 < 2)
                [ship runAction:[SKAction speedTo: ship.speed * 1.3 duration:0.2]];
            else
                [ship runAction:[SKAction speedTo:2 duration:0.2]];
        }else if(ship._accuracyAngle <= 50 && ship._accuracyAngle > 40){
            if(ship.speed * 1.15 < 2)
                [ship runAction:[SKAction speedTo: ship.speed * 1.15 duration:0.2]];
            else
                [ship runAction:[SKAction speedTo:2 duration:0.2]];
        }else if(ship._accuracyAngle <= 40 && ship._accuracyAngle > 30){
            //no speed change
        }else if(ship._accuracyAngle <= 30 && ship._accuracyAngle > 22){
            [ship runAction:[SKAction speedTo: ship.speed * 0.8 duration:0.2]];
        }else if(ship._accuracyAngle <= 22 && ship._accuracyAngle > 14){
            [ship runAction:[SKAction speedTo: ship.speed * 0.6 duration:0.2]];
        }else if(ship._accuracyAngle <= 14 && ship._accuracyAngle > 7){
            [ship runAction:[SKAction speedTo: ship.speed * 0.4 duration:0.2]];
        }else if(ship._accuracyAngle <= 7){
            [ship runAction:[SKAction speedTo: ship.speed * 0.2 duration:0.2]];
        }
    }
    
}

-(void) exitOrbit
{
    
    if (_blackHoleLabel.alpha > 0)
    {
        [_blackHoleLabel runAction:[SKAction fadeAlphaTo:0 duration:0.5]];
        [_arrowNode runAction:[SKAction fadeAlphaTo:0 duration:0.5] completion:^{
            [_arrowNode removeFromParent];
            [_blackHoleLabel removeFromParent];
        }];
    }
    
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
    
        _mainShip._hasEntered = NO;
    
        //remove all actions on mainShip and run freefly action based on the mainship zRotation property
        [_mainShip removeAllActions];
        
        while (_mainShip.zRotation > M_PI) { _mainShip.zRotation -= 2*M_PI; }
        while (_mainShip.zRotation < -M_PI) { _mainShip.zRotation += 2*M_PI; }
        
        _mainShip.position = CGPointAdd(_mainShip.position, CGPointMake(3*cos(_mainShip.zRotation)*_mainShip.speed, 3*sin(_mainShip.zRotation)*_mainShip.speed));
        
        SKAction *freeFly = [SKAction moveByX:cos(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS y:sin(_mainShip.zRotation) * NORMAL_SHIP_SPEED_PPS duration:1];
        [_mainShip runAction:[SKAction repeatActionForever:freeFly]];

}


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
//        case 0:{
//            _deadShips = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(0, 0)];
//            break;
//    }
//        case 1:{
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
//    }
//        case 2:{
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
//    }
//        case 3:{
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
//    }
//        case 4:{
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
//    }
//        case 5:{
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
//    }
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
//    NSArray *aliveArray = [livingArray sortedArrayUsingDescriptors:sortDescriptors];
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
//        case 0:{
//            _aliveShips = [SKSpriteNode spriteNodeWithColor: [SKColor clearColor]
//                                                       size: CGSizeMake(0, 0)];
//            break;
//    }
//        case 1:{
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
//    }
//        case 2:{
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
//    }
//        case 3:{
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
//    }
//        case 4:{
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
//    }
//        case 5:{
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
//        
//            break;
//        }
//        default:
//            break;
//    }
//    
//}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
        if (!_bannerIsVisible)
        {
            // If banner isn't part of view hierarchy, add it
            if (banner.superview == nil)
            {
                [self.view addSubview:banner];
            }
            
            [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
            
            banner.frame = CGRectMake(0, 0, banner.frame.size.width, banner.frame.size.height);
            
            [UIView commitAnimations];
            
            _bannerIsVisible = YES;
            
        }
        _contentNode.size = CGSizeMake(self.size.width, self.size.height - banner.frame.size.height);
        
        if (true)
        {
            _mileNumLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.967);
            _pauseButton.position = CGPointMake(0, _contentNode.size.height+1);
            _pauseButton.size = CGSizeMake(_contentNode.size.height*0.06*1.6, _contentNode.size.height*0.06);
            _milesBarBg.position = CGPointMake(0, _contentNode.size.height+1);
            _milesBarBg.size = CGSizeMake(_contentNode.size.width, _contentNode.size.height*0.077);
            _mileNumLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.967);
            _milesLabel.position = CGPointMake(_contentNode.size.width*0.97, _mileNumLabel.position.y);
            
            
            if ([_gameMode isEqualToString:@"black_hole"])
            {
                [_blackHoleProgressBar resizeWithScreenSize:_contentNode.size];
                _blackHoleLabel.position = CGPointMake(_backgroundLayer.size.width*0.55,0.087*_contentNode.size.height);
                
            }
        }
        if(_paused)
        {
            _pauseMenu.position = CGPointMake(_contentNode.size.width*0.1, _contentNode.size.height*0.923);
            _pauseMenu.size = CGSizeMake(_backgroundLayer.size.width, _contentNode.size.height*0.923);
            _resumeButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.57);
            _mainMenuButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.68);
            _recordLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.80);
            _recordNumLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.82);
            _deadShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.4);
            _aliveShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.22);
            _blackHoleMenuTrail.size = CGSizeMake(0.29*_contentNode.size.width, _contentNode.size.height*0.48);
            _blackHoleMenuTrail.position = _deadShips.position;
            
        }

        if(_mainShip._dead)
        {
            CGPoint shipPosToTopLeftVector = CGPointSubtract(CGPointMake(0, _contentNode.size.height), CGPointMake(_mainShip.position.x + _contentNode.size.width*0.1, _backgroundLayer.position.y + _mainShip.position.y));
            _deadMenu.size = CGSizeMake(_contentNode.size.width, _contentNode.size.height);
            _deadMenu.anchorPoint = CGPointMake((_mainShip.position.x+_contentNode.size.width*0.1)/_contentNode.size.width, (_backgroundLayer.position.y + _mainShip.position.y)/_contentNode.size.height);
            _deadMenu.position = CGPointMake(_mainShip.position.x + _contentNode.size.width*0.1, _backgroundLayer.position.y + _mainShip.position.y);
            _mainMenuButton.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.83));
            _mainMenuButton.size = CGSizeMake(_contentNode.size.width*0.6, 0.25*_contentNode.size.width*0.6);
            _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.52));
            _mainMenuButton.size = CGSizeMake(_contentNode.size.width*0.6, 0.25*_contentNode.size.width*0.6);
            _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.52));
            _recordNumLabel.position = CGPointAdd(shipPosToTopLeftVector,CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.54));
            _mileNumLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.36));
            if(_newHighScore)
            {
                _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.5));
            }
            if ([_gameMode isEqualToString:@"black_hole"])
            {
                
                _aliveShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.68));
                _deadShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.2));
                _blackHoleMenuTrail.size = CGSizeMake(0.29*_contentNode.size.width, _contentNode.size.height*0.63);
                _blackHoleMenuTrail.position = _deadShips.position;
            }
        }
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (![[_data objectForKey:@"ads?"] isEqualToString:@"no_ads"]){
        
        if (_bannerIsVisible)
        {
            [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
            
            banner.frame = CGRectMake(0, -banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
            
            [UIView commitAnimations];
            
            _bannerIsVisible = NO;
            
        }
        
        _contentNode.size = CGSizeMake(self.size.width, self.size.height);
        
        if (true)
        {
            _mileNumLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.967);
            _pauseButton.position = CGPointMake(0, _contentNode.size.height+1);
            _pauseButton.size = CGSizeMake(_contentNode.size.height*0.06*1.6, _contentNode.size.height*0.06);
            _milesBarBg.position = CGPointMake(0, _contentNode.size.height+1);
            _milesBarBg.size = CGSizeMake(_contentNode.size.width, _contentNode.size.height*0.077);
            _mileNumLabel.position = CGPointMake(_contentNode.size.width*0.5, _contentNode.size.height*0.967);
            _milesLabel.position = CGPointMake(_contentNode.size.width*0.97, _mileNumLabel.position.y);
            
            if ([_gameMode isEqualToString:@"black_hole"])
            {
                [_blackHoleProgressBar resizeWithScreenSize:_contentNode.size];
                _blackHoleLabel.position = CGPointMake(_backgroundLayer.size.width*0.55,0.087*_contentNode.size.height);
                
            }
        }
        if(_paused)
        {
            _pauseMenu.position = CGPointMake(_contentNode.size.width*0.1, _contentNode.size.height*0.923);
            _pauseMenu.size = CGSizeMake(_backgroundLayer.size.width, _contentNode.size.height*0.923);
            _resumeButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.57);
            _mainMenuButton.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.68);
            _recordLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.80);
            _recordNumLabel.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.82);
            _deadShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.4);
            _aliveShips.position = CGPointMake(_backgroundLayer.size.width*0.5, -(_contentNode.size.height*0.923)*0.22);
            _blackHoleMenuTrail.size = CGSizeMake(0.29*_contentNode.size.width, _contentNode.size.height*0.48);
            _blackHoleMenuTrail.position = _deadShips.position;
            
        }
        if(_mainShip._dead)
        {
            CGPoint shipPosToTopLeftVector = CGPointSubtract(CGPointMake(0, _contentNode.size.height), CGPointMake(_mainShip.position.x + _contentNode.size.width*0.1, _backgroundLayer.position.y + _mainShip.position.y));
            _deadMenu.size = CGSizeMake(_contentNode.size.width, _contentNode.size.height);
            _deadMenu.anchorPoint = CGPointMake((_mainShip.position.x+_contentNode.size.width*0.1)/_contentNode.size.width, (_backgroundLayer.position.y + _mainShip.position.y)/_contentNode.size.height);
            _deadMenu.position = CGPointMake(_mainShip.position.x + _contentNode.size.width*0.1, _backgroundLayer.position.y + _mainShip.position.y);
            _mainMenuButton.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.83));
            _mainMenuButton.size = CGSizeMake(_contentNode.size.width*0.6, 0.25*_contentNode.size.width*0.6);
            _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.52));
            _mainMenuButton.size = CGSizeMake(_contentNode.size.width*0.6, 0.25*_contentNode.size.width*0.6);
            _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.52));
            _recordNumLabel.position = CGPointAdd(shipPosToTopLeftVector,CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.54));
            _mileNumLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.36));
            if(_newHighScore)
            {
                _recordLabel.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.5));
            }
            if ([_gameMode isEqualToString:@"black_hole"])
            {
                
                _aliveShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.68));
                _deadShips.position = CGPointAdd(shipPosToTopLeftVector, CGPointMake(_contentNode.size.width*0.5, -(_contentNode.size.height)*0.2));
                _blackHoleMenuTrail.size = CGSizeMake(0.29*_contentNode.size.width, _contentNode.size.height*0.63);
                _blackHoleMenuTrail.position = _deadShips.position;
            }
        }
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [self pauseScene];
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    _mainShip.paused = YES;
//    if ([_gameMode isEqualToString:@"race"]) {
//        _yellowShip.paused = YES;
//        _redShip.paused = YES;
//        _greenShip.paused = YES;
//        _blueShip.paused = YES;
//    }else if ([_gameMode isEqualToString:@"black_hole"])
    {
        _blackHole.paused = YES;
        _blackHoleTrail.paused = YES;
    }
    for (int i = _plannetCounter + 15; i >= _plannetCounter; i--){
        Planet *planet = [_planets objectAtIndex:i];
        planet.paused = YES;
    }
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    _noAdsProduct = [response.products objectAtIndex:0];
    
    [[[UIAlertView alloc] initWithTitle:@"No Ads"
                                message:@"$0.99"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Purchase", @"Restore", nil] show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_noAdsProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }else if (buttonIndex == 2){
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
                [_data setObject:@"no_ads" forKey:@"ads?"];
                [_data writeToFile: _dataPath atomically:YES];
                if (!_gameStarted){
                    [[[UIAlertView alloc] initWithTitle:@"Ads removed."
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if (!_gameStarted){
                    [[[UIAlertView alloc] initWithTitle:@"No ads purchase failed."
                                                message:@"Try again another time."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [_data setObject:@"no_ads" forKey:@"ads?"];
                [_data writeToFile: _dataPath atomically:YES];
                if (!_gameStarted){
                    [[[UIAlertView alloc] initWithTitle:@"Ads removed."
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue
restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (!_gameStarted){
        [[[UIAlertView alloc] initWithTitle:@"Could not restore purchaces."
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)playBackgroundMusic
{
    NSError *error;
    
    NSURL *beepIn = [[NSBundle mainBundle] URLForResource:@"in_orbit.m4a" withExtension:nil];
    _beepInPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepIn error:&error];
    _beepInPlayer.numberOfLoops = -1;
    _beepInPlayer.volume = 0.7;
    [_beepInPlayer prepareToPlay];
    
    NSURL *blackHole = [[NSBundle mainBundle] URLForResource:@"black_hole_suck.m4a" withExtension:nil];
    _blackHolePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:blackHole error:&error];
    [_blackHolePlayer prepareToPlay];
    NSURL *transportBeam = [[NSBundle mainBundle] URLForResource:@"transport_beam.m4a" withExtension:nil];
    _transportBeamPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:transportBeam error:&error];
    _transportBeamPlayer.volume = 0.4;
    [_transportBeamPlayer prepareToPlay];
    NSURL *nextMile = [[NSBundle mainBundle] URLForResource:@"next_mile_beep.m4a" withExtension:nil];
    _nextMileBeepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:nextMile error:&error];
    [_nextMileBeepPlayer prepareToPlay];
    NSURL *explosion = [[NSBundle mainBundle] URLForResource:@"explosion.mp3" withExtension:nil];
    _explosionPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:explosion error:&error];
    [_explosionPlayer prepareToPlay];
    NSURL *newRecord = [[NSBundle mainBundle] URLForResource:@"new_record_beep.m4a" withExtension:nil];
    _newRecordBeepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newRecord error:&error];
    [_newRecordBeepPlayer prepareToPlay];
    
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"orbit_bg_music.m4a" withExtension:nil];
    _bgMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _bgMusicPlayer.numberOfLoops = -1;
    _bgMusicPlayer.volume = 0.2;
    [_bgMusicPlayer prepareToPlay];
    [_bgMusicPlayer play];
}
@end
