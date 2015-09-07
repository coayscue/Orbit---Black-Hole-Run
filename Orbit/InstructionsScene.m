//
//  InstructionsScene.m
//  Orbit
//
//  Created by Christian Ayscue on 9/10/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "InstructionsScene.h"
#import "MyScene.h"
#import "AVFoundation/AVFoundation.h"


@implementation InstructionsScene{
    SKNode *_slideNode;
    SKAction *_slideAction;
    int _slideCount;
    
    NSString *_touchType;
    
    AVAudioPlayer *_beepInPlayer;
    
    SKSpriteNode *_nextButton1;
    SKSpriteNode *_nextButton2;
    SKSpriteNode *_nextButton3;
    SKSpriteNode *_nextButton4;
    SKSpriteNode *_nextButton5;
    SKSpriteNode *_gotItButton;
    SKSpriteNode *_randNode;
    
    SKSpriteNode *_welcomeLabel;
    SKSpriteNode *_instruction1Label;
    SKSpriteNode *_instruction2Label;
    SKSpriteNode *_instruction3Label;
    SKSpriteNode *_instruction4Label;
    SKSpriteNode *_instruction5Label;
    
    AVPlayer *_player1;
    AVPlayer *_player2;
    AVPlayer *_player3;
    AVPlayer *_player4;
    AVPlayer *_player5;
    
    SKSpriteNode *_touch1;
    SKSpriteNode *_touch2;
    SKSpriteNode *_touch3;
    SKSpriteNode *_touch4;
    SKSpriteNode *_touch5;
    
    SKVideoNode *_instruction1Video;
    SKVideoNode *_instruction2Video;
    SKVideoNode *_instruction3Video;
    SKVideoNode *_instruction4Video;
    SKVideoNode *_instruction5Video;
    
    
    NSURL *_fileURL;
    
}

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *_background = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
        _background.anchorPoint = CGPointZero;
        [self addChild:_background];
        
        _randNode = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(0,0)];
        [self addChild:_randNode];
        
        NSError *error;
        
        NSURL *beepIn = [[NSBundle mainBundle] URLForResource:@"in_orbit.m4a" withExtension:nil];
        _beepInPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepIn error:&error];
        _beepInPlayer.numberOfLoops = -1;
        _beepInPlayer.volume = 0.7;
        [_beepInPlayer prepareToPlay];
        
        _slideNode = [SKNode node];
        _slideNode.position = CGPointZero;
        [self addChild:_slideNode];
        _slideAction = [SKAction moveByX:-self.size.width y:0 duration:0.7];
        _slideAction.timingMode = SKActionTimingEaseInEaseOut;
        _slideCount = 0;
        
        
        _fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"entrance_instruction" ofType:@"mov"]];
        _player1 = [AVPlayer playerWithURL:_fileURL];
        _instruction1Video = [[SKVideoNode alloc] initWithAVPlayer:_player1];
        _instruction1Video.size = CGSizeMake(self.size.width*1.05, self.size.height*1.05);
        _instruction1Video.position = CGPointMake(self.size.width*1.5, self.size.height*0.5);
        [_slideNode addChild:_instruction1Video];
        
        _fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"release_instruction" ofType:@"mov"]];
        _player2 = [AVPlayer playerWithURL:_fileURL];
        _instruction2Video = [[SKVideoNode alloc] initWithAVPlayer:_player2];
        _instruction2Video.size = CGSizeMake(self.size.width*1.05, self.size.height*1.05);
        _instruction2Video.position = CGPointMake(self.size.width*2.5, self.size.height*0.5);
        [_slideNode addChild:_instruction2Video];
        
        _fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bad_entrance" ofType:@"mov"]];
        _player3 = [AVPlayer playerWithURL:_fileURL];
        _instruction3Video = [[SKVideoNode alloc] initWithAVPlayer:_player3];
        _instruction3Video.size = CGSizeMake(self.size.width*1.05, self.size.height*1.05);
        _instruction3Video.position = CGPointMake(self.size.width*3.5, self.size.height*0.5);
        [_slideNode addChild:_instruction3Video];
        
        _fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"good_entrance_instruction" ofType:@"mov"]];
        _player4 = [AVPlayer playerWithURL:_fileURL];
        _instruction4Video = [[SKVideoNode alloc] initWithAVPlayer:_player4];
        _instruction4Video.size = CGSizeMake(self.size.width*1.05, self.size.height*1.05);
        _instruction4Video.position = CGPointMake(self.size.width*4.5, self.size.height*0.5);
        [_slideNode addChild:_instruction4Video];
        
        _fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"run_instruction" ofType:@"mov"]];
        _player5 = [AVPlayer playerWithURL:_fileURL];
        _instruction5Video = [[SKVideoNode alloc] initWithAVPlayer:_player5];
        _instruction5Video.size = CGSizeMake(self.size.width*1, self.size.height*1.05);
        _instruction5Video.position = CGPointMake(self.size.width*5.5, self.size.height*0.5);
        [_slideNode addChild:_instruction5Video];
        
        _nextButton1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"next_button"] size:CGSizeMake(116, 60)];
        _nextButton1.position = CGPointMake(self.size.width*0.5, 55);
        [_slideNode addChild:_nextButton1];
        
        _nextButton2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"next_button"] size:CGSizeMake(116, 60)];
        _nextButton2.position = CGPointMake(self.size.width*1.5, 55);
        [_slideNode addChild:_nextButton2];
        
        _nextButton3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"next_button"] size:CGSizeMake(116, 60)];
        _nextButton3.position = CGPointMake(self.size.width*2.5, 55);
        [_slideNode addChild:_nextButton3];
        
        _nextButton4 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"next_button"] size:CGSizeMake(116, 60)];
        _nextButton4.position = CGPointMake(self.size.width*3.5, 55);
        [_slideNode addChild:_nextButton4];
        
        _nextButton5 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"next_button"] size:CGSizeMake(116, 60)];
        _nextButton5.position = CGPointMake(self.size.width*4.5, 55);
        [_slideNode addChild:_nextButton5];

        _gotItButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"got_it_button"] size:CGSizeMake(135, 60)];
        _gotItButton.position = CGPointMake(self.size.width*5.5, 55);
        [_slideNode addChild:_gotItButton];
        
        _welcomeLabel = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"welcome_label"] size:CGSizeMake(self.size.width*0.85, self.size.width*0.85)];
        _welcomeLabel.anchorPoint = CGPointMake(0.5, 1);
        _welcomeLabel.position = CGPointMake(self.size.width/2, self.size.height-60);
        [_slideNode addChild:_welcomeLabel];
        
        _instruction1Label = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"enter_instruction"] size:CGSizeMake(self.size.width*0.85, self.size.width*0.85/3.91)];
        _instruction1Label.anchorPoint = CGPointMake(0.5, 1);
        _instruction1Label.position = CGPointMake(self.size.width*1.5, self.size.height-10);
        [_slideNode addChild:_instruction1Label];
        
        _instruction2Label = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"exit_instruction"] size:CGSizeMake(self.size.width*0.85, self.size.width*0.85/3.83)];
        _instruction2Label.anchorPoint = CGPointMake(0.5, 1);
        _instruction2Label.position = CGPointMake(self.size.width*2.5, self.size.height-10);
        [_slideNode addChild:_instruction2Label];
        
        _instruction3Label = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"slow_down_instruction"] size:CGSizeMake(self.size.width*0.85, self.size.width*0.85/2.51)];
        _instruction3Label.anchorPoint = CGPointMake(0.5, 1);
        _instruction3Label.position = CGPointMake(self.size.width*3.5, self.size.height-10);
        [_slideNode addChild:_instruction3Label];
        
        _instruction4Label = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"speed_up_instruction"] size:CGSizeMake(self.size.width*0.85, self.size.width*0.85/2.45)];
        _instruction4Label.anchorPoint = CGPointMake(0.5, 1);
        _instruction4Label.position = CGPointMake(self.size.width*4.5, self.size.height-10);
        [_slideNode addChild:_instruction4Label];
        
        _instruction5Label = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"run_instruction"] size:CGSizeMake(self.size.width*0.85, self.size.width*0.85/3.35)];
        _instruction5Label.anchorPoint = CGPointMake(0.5, 1);
        _instruction5Label.position = CGPointMake(self.size.width*5.5, self.size.height-10);
        [_slideNode addChild:_instruction5Label];
        
        _touch1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"thumb_extended"] size:CGSizeMake(80, 160)];
        _touch1.position = CGPointMake(self.size.width*2, self.size.height*0.1);
        _touch1.anchorPoint = CGPointZero;
        _touch1.zRotation = 60 * M_PI/180;
        _touch2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"thumb_pressed"] size:CGSizeMake(80, 160)];
        _touch2.position = CGPointMake(self.size.width*3, self.size.height*0.1);
        _touch2.anchorPoint = CGPointZero;
        _touch2.zRotation = 60 * M_PI/180;
        _touch3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"thumb_extended"] size:CGSizeMake(80, 160)];
        _touch3.position = CGPointMake(self.size.width*4, self.size.height*0.1);
        _touch3.anchorPoint = CGPointZero;
        _touch3.zRotation = 60 * M_PI/180;
        _touch4 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"thumb_extended"] size:CGSizeMake(80, 160)];
        _touch4.position = CGPointMake(self.size.width*5, self.size.height*0.1);
        _touch4.anchorPoint = CGPointZero;
        _touch4.zRotation = 60 * M_PI/180;
        
        [_slideNode addChild:_touch1];
        [_slideNode addChild:_touch2];
        [_slideNode addChild:_touch3];
        [_slideNode addChild:_touch4];
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (CGRectContainsPoint(CGRectMake(self.size.width*0.5 - 80, 20, 150, 70), location)){
        if(_slideCount == 5){
            _touchType = @"main_scene";
            _gotItButton.texture = [SKTexture textureWithImageNamed:@"got_it_button_pressed"];
        }else{
            _touchType = @"next_slide";
            
            switch (_slideCount) {
                case 0:
                    _nextButton1.texture = [SKTexture textureWithImageNamed:@"next_button_pressed"];
                    break;
                case 1:
                    _nextButton2.texture = [SKTexture textureWithImageNamed:@"next_button_pressed"];
                    [_randNode removeAllActions];
                    [_beepInPlayer stop];
                    [_beepInPlayer prepareToPlay];
                    break;
                case 2:
                    _nextButton3.texture = [SKTexture textureWithImageNamed:@"next_button_pressed"];
                    [_randNode removeAllActions];
                    [_beepInPlayer stop];
                    [_beepInPlayer prepareToPlay];
                    break;
                case 3:
                    _nextButton4.texture = [SKTexture textureWithImageNamed:@"next_button_pressed"];
                    [_randNode removeAllActions];
                    [_beepInPlayer stop];
                    [_beepInPlayer prepareToPlay];
                    break;
                case 4:
                    _nextButton5.texture = [SKTexture textureWithImageNamed:@"next_button_pressed"];
                    [_randNode removeAllActions];
                    [_beepInPlayer stop];
                    [_beepInPlayer prepareToPlay];
                    break;
                default:
                    break;
            }
            
        }
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (CGRectContainsPoint(CGRectMake(self.size.width*0.5 - 80, 20, 150, 70), location)){
        
        if ([_touchType isEqualToString:@"main_scene"]){
            
            [_gotItButton runAction:[SKAction waitForDuration:0.05] completion:^{
                _gotItButton.texture = [SKTexture textureWithImageNamed:@"got_it_button"];
            }];
            [self.view.window.rootViewController requestInterstitialAdPresentation];
            MyScene *newScene = [MyScene sceneWithSize:self.size];
            newScene.scaleMode = SKSceneScaleModeAspectFill;
            [self runAction:[SKAction waitForDuration:0.3] completion:^{
                [self.view presentScene: newScene transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:1.5]];
            }];
        }else if([_touchType isEqualToString:@"next_slide"]){
            
            switch (_slideCount) {
                case 0:
                {[_nextButton1 runAction:[SKAction waitForDuration:0.05] completion:^{
                    _nextButton1.texture = [SKTexture textureWithImageNamed:@"next_button"];
                }];
                    [_touch1 runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction waitForDuration:1.9], [SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_pressed"]], [SKAction waitForDuration:1.68],[SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_extended"]]]] count:5]];
                    [_instruction1Video play];
                    [_randNode runAction: [SKAction waitForDuration:1.9] completion:^{
                        [_beepInPlayer play];
                        [_randNode runAction:[SKAction waitForDuration:1.68] completion:^{
                            [_beepInPlayer stop];
                            [_beepInPlayer prepareToPlay];
                        }];
                    }];
                    [self runAction:[SKAction waitForDuration:3.5] completion:^{
                        [_player1 seekToTime:kCMTimeZero];
                        [_randNode runAction: [SKAction waitForDuration:1.9] completion:^{
                            [_beepInPlayer play];
                            [_randNode runAction:[SKAction waitForDuration:1.68] completion:^{
                                [_beepInPlayer stop];
                                [_beepInPlayer prepareToPlay];
                            }];
                        }];
                        [self runAction:[SKAction waitForDuration:3.5] completion:^{
                            [_player1 seekToTime:kCMTimeZero];
                            [_randNode runAction: [SKAction waitForDuration:1.9] completion:^{
                                [_beepInPlayer play];
                                [_randNode runAction:[SKAction waitForDuration:1.68] completion:^{
                                    [_beepInPlayer stop];
                                    [_beepInPlayer prepareToPlay];
                                }];
                            }];
                            [self runAction:[SKAction waitForDuration:3.5] completion:^{
                                [_player1 seekToTime:kCMTimeZero];
                                [_randNode runAction: [SKAction waitForDuration:1.9] completion:^{
                                    [_beepInPlayer play];
                                    [_randNode runAction:[SKAction waitForDuration:1.68] completion:^{
                                        [_beepInPlayer stop];
                                        [_beepInPlayer prepareToPlay];
                                    }];
                                }];
                                [self runAction:[SKAction waitForDuration:3.5] completion:^{
                                    [_player1 seekToTime:kCMTimeZero];
                                    [_randNode runAction: [SKAction waitForDuration:1.9] completion:^{
                                        [_beepInPlayer play];
                                        [_randNode runAction:[SKAction waitForDuration:1.68] completion:^{
                                            [_beepInPlayer stop];
                                            [_beepInPlayer prepareToPlay];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                    
                    
                }
                    break;
                case 1:
                {[_nextButton2 runAction:[SKAction waitForDuration:0.05] completion:^{
                    _nextButton2.texture = [SKTexture textureWithImageNamed:@"next_button"];
                }];
                    _touch1.alpha = 0;
                    [_touch2 runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction waitForDuration:4.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_extended"]], [SKAction waitForDuration:1.48], [SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_pressed"]]]] count:5]];
                    [_instruction1Video pause];
                    [_instruction2Video play];
                    [_randNode runAction: [SKAction waitForDuration:0] completion:^{
                        [_beepInPlayer play];
                        [_randNode runAction:[SKAction waitForDuration:4.1] completion:^{
                            [_beepInPlayer stop];
                            [_beepInPlayer prepareToPlay];
                        }];
                    }];
                    [self removeAllActions];
                    [self runAction:[SKAction waitForDuration:5.5] completion:^{
                        [_player2 seekToTime:kCMTimeZero];
                        [_randNode runAction: [SKAction waitForDuration:0] completion:^{
                            [_beepInPlayer play];
                            [_randNode runAction:[SKAction waitForDuration:4.1] completion:^{
                                [_beepInPlayer stop];
                                [_beepInPlayer prepareToPlay];
                            }];
                        }];
                        [self runAction:[SKAction waitForDuration:5.5] completion:^{
                            [_player2 seekToTime:kCMTimeZero];
                            [_randNode runAction: [SKAction waitForDuration:0] completion:^{
                                [_beepInPlayer play];
                                [_randNode runAction:[SKAction waitForDuration:4.1] completion:^{
                                    [_beepInPlayer stop];
                                    [_beepInPlayer prepareToPlay];
                                }];
                            }];
                            [self runAction:[SKAction waitForDuration:5.5] completion:^{
                                [_player2 seekToTime:kCMTimeZero];
                                [_randNode runAction: [SKAction waitForDuration:0] completion:^{
                                    [_beepInPlayer play];
                                    [_randNode runAction:[SKAction waitForDuration:4.1] completion:^{
                                        [_beepInPlayer stop];
                                        [_beepInPlayer prepareToPlay];
                                    }];
                                }];
                                [self runAction:[SKAction waitForDuration:5.5] completion:^{
                                    [_player2 seekToTime:kCMTimeZero];
                                    [_randNode runAction: [SKAction waitForDuration:0] completion:^{
                                        [_beepInPlayer play];
                                        [_randNode runAction:[SKAction waitForDuration:4.1] completion:^{
                                            [_beepInPlayer stop];
                                            [_beepInPlayer prepareToPlay];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }
                    break;
                case 2:
                {[_nextButton3 runAction:[SKAction waitForDuration:0.05] completion:^{
                    _nextButton3.texture = [SKTexture textureWithImageNamed:@"next_button"];
                }];
                    _touch2.alpha = 0;
                    [_touch3 runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction waitForDuration:1.5], [SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_pressed"]], [SKAction waitForDuration:3.08],[SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_extended"]]]] count:5]];
                    [_instruction2Video pause];
                    [_instruction3Video play];
                    [_randNode runAction: [SKAction waitForDuration:1.5] completion:^{
                        [_beepInPlayer play];
                        [_randNode runAction:[SKAction waitForDuration:3.08] completion:^{
                            [_beepInPlayer stop];
                            [_beepInPlayer prepareToPlay];
                        }];
                    }];
                    [self removeAllActions];
                    [self runAction:[SKAction waitForDuration:4.5] completion:^{
                        [_player3 seekToTime:kCMTimeZero];
                        [_randNode runAction: [SKAction waitForDuration:1.5] completion:^{
                            [_beepInPlayer play];
                            [_randNode runAction:[SKAction waitForDuration:3.08] completion:^{
                                [_beepInPlayer stop];
                                [_beepInPlayer prepareToPlay];
                            }];
                        }];
                        [self runAction:[SKAction waitForDuration:4.5] completion:^{
                            [_player3 seekToTime:kCMTimeZero];
                            [_randNode runAction: [SKAction waitForDuration:1.5] completion:^{
                                [_beepInPlayer play];
                                [_randNode runAction:[SKAction waitForDuration:3.08] completion:^{
                                    [_beepInPlayer stop];
                                    [_beepInPlayer prepareToPlay];
                                }];
                            }];
                            [self runAction:[SKAction waitForDuration:4.5] completion:^{
                                [_player3 seekToTime:kCMTimeZero];
                                [_randNode runAction: [SKAction waitForDuration:1.5] completion:^{
                                    [_beepInPlayer play];
                                    [_randNode runAction:[SKAction waitForDuration:3.08] completion:^{
                                        [_beepInPlayer stop];
                                        [_beepInPlayer prepareToPlay];
                                    }];
                                }];
                                [self runAction:[SKAction waitForDuration:4.5] completion:^{
                                    [_player3 seekToTime:kCMTimeZero];
                                    [_randNode runAction: [SKAction waitForDuration:1.5] completion:^{
                                        [_beepInPlayer play];
                                        [_randNode runAction:[SKAction waitForDuration:3.08] completion:^{
                                            [_beepInPlayer stop];
                                            [_beepInPlayer prepareToPlay];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }
                    break;
                case 3:
                {[_nextButton4 runAction:[SKAction waitForDuration:0.05] completion:^{
                    _nextButton4.texture = [SKTexture textureWithImageNamed:@"next_button"];
                }];
                    _touch3.alpha = 0;
                    [_touch4 runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction waitForDuration:1.13], [SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_pressed"]], [SKAction waitForDuration:2.96],[SKAction setTexture:[SKTexture textureWithImageNamed:@"thumb_extended"]]]] count:5]];
                    [_instruction3Video pause];
                    [_instruction4Video play];
                    [_randNode runAction: [SKAction waitForDuration:1.13] completion:^{
                        [_beepInPlayer play];
                        [_randNode runAction:[SKAction waitForDuration:2.96] completion:^{
                            [_beepInPlayer stop];
                            [_beepInPlayer prepareToPlay];
                        }];
                    }];
                    [self removeAllActions];
                    [self runAction:[SKAction waitForDuration:4] completion:^{
                        [_player4 seekToTime:kCMTimeZero];
                        [_randNode runAction: [SKAction waitForDuration:1.13] completion:^{
                            [_beepInPlayer play];
                            [_randNode runAction:[SKAction waitForDuration:2.96] completion:^{
                                [_beepInPlayer stop];
                                [_beepInPlayer prepareToPlay];
                            }];
                        }];
                        [self runAction:[SKAction waitForDuration:4] completion:^{
                            [_player4 seekToTime:kCMTimeZero];
                            [_randNode runAction: [SKAction waitForDuration:1.13] completion:^{
                                [_beepInPlayer play];
                                [_randNode runAction:[SKAction waitForDuration:2.96] completion:^{
                                    [_beepInPlayer stop];
                                    [_beepInPlayer prepareToPlay];
                                }];
                            }];
                            [self runAction:[SKAction waitForDuration:4] completion:^{
                                [_player4 seekToTime:kCMTimeZero];
                                [_randNode runAction: [SKAction waitForDuration:1.13] completion:^{
                                    [_beepInPlayer play];
                                    [_randNode runAction:[SKAction waitForDuration:2.96] completion:^{
                                        [_beepInPlayer stop];
                                        [_beepInPlayer prepareToPlay];
                                    }];
                                }];
                                [self runAction:[SKAction waitForDuration:4] completion:^{
                                    [_player4 seekToTime:kCMTimeZero];
                                    [_randNode runAction: [SKAction waitForDuration:1.13] completion:^{
                                        [_beepInPlayer play];
                                        [_randNode runAction:[SKAction waitForDuration:2.96] completion:^{
                                            [_beepInPlayer stop];
                                            [_beepInPlayer prepareToPlay];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }
                    break;
                case 4:
                {[_nextButton5 runAction:[SKAction waitForDuration:0.05] completion:^{
                    _nextButton5.texture = [SKTexture textureWithImageNamed:@"next_button"];
                }];
                    _touch4.alpha = 0;
                    [_instruction4Video pause];
                    [_instruction5Video play];
                    [self removeAllActions];
                    [self runAction:[SKAction waitForDuration:5.5] completion:^{
                        [_player5 seekToTime:kCMTimeZero];
                        [self runAction:[SKAction waitForDuration:5.5] completion:^{
                            [_player5 seekToTime:kCMTimeZero];
                            [self runAction:[SKAction waitForDuration:5.5] completion:^{
                                [_player5 seekToTime:kCMTimeZero];
                                [self runAction:[SKAction waitForDuration:5.5] completion:^{
                                    [_player5 seekToTime:kCMTimeZero];
                                }];
                            }];
                        }];
                    }];
                }
                    break;
                default:
                    break;
            }
            _slideCount++;
            [_slideNode runAction:_slideAction];
        }
    }
}

@end
