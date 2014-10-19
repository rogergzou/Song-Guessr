//
//  ViewController.h
//  Song Guessr
//
//  Created by Roger on 10/18/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic) long long points;
@property (nonatomic) unsigned long long hits;
@property (nonatomic) unsigned long long misses;

-(void)saveVars;
-(void)loadVars;

@end

