//
//  ViewController.m
//  Song Guessr
//
//  Created by Roger on 10/18/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FourCountCollectionViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *choices;
@property (nonatomic, strong) MPMusicPlayerController *player;
@property (nonatomic) int correctIndex;
@property (nonatomic, strong) NSMutableArray *songArrayForCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *missesLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.player = [MPMusicPlayerController systemMusicPlayer];
    if (!self.player.nowPlayingItem) {
        //nil
        //[self.player play];
        //handled in updateUI
    }
    //set listen to notifs. default apple code https://developer.apple.com/Library/ios/documentation/Audio/Conceptual/iPodLibraryAccess_Guide/UsingMediaPlayback/UsingMediaPlayback.html
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.player];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.player];
    
    [self.player beginGeneratingPlaybackNotifications];
    
    //self.mybutt.titleLabel.text = @"blah";
    [self updateUI];
}


- (void)updateUI {

    //for (UIButton *button in self.choices) {
        //button.titleLabel.text = self.player.nowPlayingItem.title;
        //[button setTitle:self.player.nowPlayingItem.title forState:UIControlStateNormal];
    //}
    
    //best way
    //get wrong titles into array (add obj)
    //insert correct title/song name into array at random index
    //use that array for collectionview datasource
    
    
    //set correct choice randomly, then remove from choices
    
    NSMutableArray *storeArray = [NSMutableArray array];
    //set incorrect choices by artist or randomly. filter
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    
    self.correctIndex = rand() % 4; //CHANGE LATER.
    
    //make sure there is something playing now...
    if (!self.player.nowPlayingItem) {
        [self.player setQueueWithQuery:query];
        [self.player play];
        [self.player setShuffleMode:MPMusicShuffleModeSongs];
    }
    
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
    int hold = 0;
    for (MPMediaItemCollection *album in albums) {
        NSUInteger g = [album count];
        //for (MPMediaItem *song in album) {
        for (int i = 0; i < g; i++) {
            hold++;
            if (hold >= 4)
                break;
        }
    }
    if (hold < 4 && artist) {
        //not enough songs in albums, set random others
        //later change so it gets some from album + random others
        [query removeFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyArtist]];
        query = [[MPMediaQuery alloc]init];
        [query setGroupingType:MPMediaGroupingAlbum];
        albums = [query collections];
    }
    
    //set wrong buttons randomly of choices
    for (int i = 0; i < 3; i++) {
        int index = rand() % [albums count];
        MPMediaItemCollection *album = albums[index];
        NSArray *songs = [album items];
        index = rand() % [songs count];
        MPMediaItem *song = songs[index];
        NSString *songTitle = [song valueForProperty:MPMediaItemPropertyTitle];
        //already contains the song in the available choices
        if ([storeArray containsObject:songTitle] || [self.player.nowPlayingItem.title isEqualToString:songTitle])
            i--;
        else
            [storeArray addObject:songTitle];
        //[tmpButtonHolder[i] setTitle:songTitle forState:UIControlStateNormal];
    }
    
    //get insert right one
    
    //moved to end
    
    //NSMutableArray *tmpButtonHolder = [NSMutableArray arrayWithArray:self.choices];
    
    
    
    [storeArray insertObject:self.player.nowPlayingItem.title atIndex:self.correctIndex];
    self.songArrayForCollectionView = storeArray;
     //UIButton *correctbutton = tmpButtonHolder[self.correctIndex];
     //[tmpButtonHolder removeObjectAtIndex:self.correctIndex];
     //[correctbutton setTitle:self.player.nowPlayingItem.title forState:UIControlStateNormal];
    
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

    [self.collectionView reloadData];
    
    //update labels
    [self updateLabels];

}
- (void)updateLabels {
    self.hitsLabel.text = [NSString stringWithFormat:@"Hits: %llu", self.hits];
    self.missesLabel.text = [NSString stringWithFormat:@"Misses: %llu", self.misses];
    self.pointsLabel.text = [NSString stringWithFormat:@"Points: %lli", self.points];
}

- (void)choiceSelected:(NSInteger)index {
    //check if correct choice. If so say so
    if (index == self.correctIndex) {
        self.hits++;
        self.points+=4;
    } else {
        self.misses++;
        self.points-=2;
    }
    //wait 1 sec
    
    //next song
    [self.player skipToNextItem];
    
    [self updateUI];
}

- (void)saveVars
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.points forKey:@"points"];
    [defaults setInteger:self.misses forKey:@"misses"];
    [defaults setInteger:self.hits forKey:@"hits"];
    [defaults synchronize];
}

- (void)loadVars
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.points = [defaults integerForKey:@"points"];
    self.misses = [defaults integerForKey:@"misses"];
    self.hits = [defaults integerForKey:@"hits"];
    if (!self.points && !self.misses && self.hits) {
        self.points = 0;
        self.misses = 0;
        self.hits = 0;
    }
    [self updateLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //default apple code https://developer.apple.com/Library/ios/documentation/Audio/Conceptual/iPodLibraryAccess_Guide/UsingMediaPlayback/UsingMediaPlayback.html
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:         self.player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:         self.player];
    
    [self.player endGeneratingPlaybackNotifications];

}

#pragma mark - Handling Changes to Playing
- (void) handle_NowPlayingItemChanged: (NSNotification *)notification {
    //song change
    //reload things
    //self.points -= 2;
    [self updateUI];
}

- (void) handle_PlaybackStateChanged: (NSNotification *) notification {
    //self.points -= 1;
}

#pragma mark - UICollectionView
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fourCell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[FourCountCollectionViewCell class]]) {
        //set title as what's stored in songArray
        FourCountCollectionViewCell *fourCell = (FourCountCollectionViewCell *)cell;
        //[fourCell.button setTitle:self.songArrayForCollectionView[indexPath.item] forState:UIControlStateNormal];
        fourCell.songTitle.text = self.songArrayForCollectionView[indexPath.item];
        //NSLog(@"%@, index %ld", fourCell.songTitle.text, (long)indexPath.item);
        
        //CGFloat half = collectionView.frame.size.width/2 - collectionView.layoutMargins.left - collectionView.layoutMargins.right - 1;
        //fourCell.frame = CGRectMake(0, 0, half, half);
        
        //[fourCell updateConstraintsIfNeeded];
        
        return fourCell;
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //use choiceSelected:
    [self choiceSelected:indexPath.item];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

#pragma mark - UICollectionViewFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    CGFloat half = collectionView.frame.size.width/2 - collectionView.layoutMargins.right/2 -1;
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(half/2, half/2);
    }
    return CGSizeMake(half+3, half+3); //lol
    
    return CGSizeMake(0, 0);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

@end
