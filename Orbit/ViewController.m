//
//  ViewController.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"


@implementation ViewController
{
    MyScene *_scene;
}

@synthesize _skView;

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
    
    // Configure the view.
    if(!_skView){
    _skView = (SKView *)self.view;
    //_skView.showsFPS = YES;
    //_skView.showsNodeCount = YES;
    //_skView.showsPhysics = YES;

    // Create and configure the scene.
    _scene = [MyScene sceneWithSize:_skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
        
    // Present the scene.
    [_skView presentScene:_scene];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden{ return YES; }

@end
