//
//  ViewController.m
//  Song Guessr
//
//  Created by Roger on 10/18/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *choices;
@property (nonatomic, strong) MPMusicPlayerController *player;
@property (nonatomic) int correctIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.player = [MPMusicPlayerController systemMusicPlayer];
    //self.mybutt.titleLabel.text = @"blah";
    [self updateUI];
}

- (void)updateUI {
    for (UIButton *button in self.choices) {
        //button.titleLabel.text = self.player.nowPlayingItem.title;
        [button setTitle:self.player.nowPlayingItem.title forState:UIControlStateNormal];
    }
    NSMutableArray *tmpButtonHolder = [NSMutableArray arrayWithArray:self.choices];
    self.correctIndex = rand() % 4;
    UIButton *correctbutton = tmpButtonHolder[self.correctIndex];
    [tmpButtonHolder removeObjectAtIndex:self.correctIndex];
    [correctbutton setTitle:self.player.nowPlayingItem.title forState:UIControlStateNormal];
    
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSString *artist = self.player.nowPlayingItem.artist;
    if (!artist)
        artist = @"";
    //NSString *songname = self.player.nowPlayingItem.title;
    //if (!songname)
    //    songname = @"";
    //else
    //    songname = [songname substringToIndex:1];
    //[query addFilterPredicate: [MPMediaPropertyPredicate
      //                          predicateWithValue: artist
        //                        forProperty: MPMediaItemPropertyArtist]];
    else
        [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyAlbumArtist]];
    // Sets the grouping type for the media query
    [query setGroupingType: MPMediaGroupingAlbum];
    
    
    NSArray *albums = [query collections];
    if ([albums count] < 3 && artist) {
        [query removeFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyArtist]];
        query = [[MPMediaQuery alloc]init];
        [query setGroupingType:MPMediaGroupingAlbum];
        albums = [query collections];
    }
    for (int i = 0; i < 3; i++) {
        int index = rand() % [albums count];
        MPMediaItemCollection *album = albums[index];
        NSArray *songs = [album items];
        index = rand() % [songs count];
        MPMediaItem *song = songs[index];
        NSString *songTitle = [song valueForProperty:MPMediaItemPropertyTitle];
        [tmpButtonHolder[i] setTitle:songTitle forState:UIControlStateNormal];
    }
    
    /*
    for (MPMediaItemCollection *album in albums) {
        MPMediaItem *representativeItem = [album representativeItem];
        NSString *artistName =
        [representativeItem valueForProperty: MPMediaItemPropertyArtist];
        NSString *albumName =
        [representativeItem valueForProperty: MPMediaItemPropertyAlbumTitle];
        NSLog (@"%@ by %@", albumName, artistName);
        
        NSArray *songs = [album items];
        for (MPMediaItem *song in songs) {
            NSString *songTitle =
            [song valueForProperty: MPMediaItemPropertyTitle];
            NSLog (@"\t\t%@", songTitle);
        }
    }*/

    
}

- (IBAction)choiceSelected:(UIButton *)sender {
    //check if correct choice. If so say so
    
    //wait 1 sec
    
    //next song
    [self.player skipToNextItem];
    
    [self updateUI];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
