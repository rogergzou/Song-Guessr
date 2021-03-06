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

@property (nonatomic, strong) MPMusicPlayerController *player;
@property (nonatomic) int correctIndex;
@property (nonatomic, strong) NSMutableArray *songArrayForCollectionView;
//@property (nonatomic, strong) UIColor *backgroundColor;
//@property (nonatomic, strong) UIColor *textColor;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *missesLabel;
@property (weak, nonatomic) IBOutlet UILabel *plusPoints;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.player = [MPMusicPlayerController systemMusicPlayer];

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
    if (self.player.nowPlayingItem && self.player.playbackState == MPMusicPlaybackStatePlaying)
        [self.player play];
    [self updateUI];
}


- (void)updateUI {

    //get wrong titles into array (add obj)
    //insert correct title/song name into array at random index
    
    NSMutableArray *storeArray = [NSMutableArray array];
    //set incorrect choices by artist or randomly. set query
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    
    self.correctIndex = rand() % 4; //CHANGE LATER.
    
    //make sure there is something playing now...
    if (!self.player.nowPlayingItem) {
        [self.player setQueueWithQuery:query];
        [self.player play];
        [self.player setShuffleMode:MPMusicShuffleModeSongs];
    }
    
    //set filter based on artist
    NSString *artist = self.player.nowPlayingItem.artist;
    if (!artist)
        artist = @"";
    else
        [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyAlbumArtist]];
    // Sets the grouping type for the media query as nothing, which will default it to MPMediaGroupingTitle or something
    
    NSArray *titlesArray = [query collections];

    if ([titlesArray count] < 4 && artist) {
        //not enough songs in albums, set random others
        //later change so it gets some from album + random others
        [query removeFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyArtist]];
        query = [[MPMediaQuery alloc]init];
        titlesArray = [query collections];
        if (![titlesArray count])
            NSLog(@"no music found...");
    }
    //set wrong buttons randomly of choices
    for (int i = 0; i < 3; i++) {
        int index = rand() % [titlesArray count];
        MPMediaItemCollection *tar = titlesArray[index];
        NSArray *songs = [tar items];
        //cuz how it's set up, MPMediaGroupingTitle, only 1 element will be the song
        MPMediaItem *song = songs[0];
        //already contains the song in the available choices
        if ([storeArray containsObject:song] || [self.player.nowPlayingItem.title isEqualToString:song.title])
            i--;
        else
            [storeArray addObject:song];
        }
    
    //get insert right one
    [storeArray insertObject:self.player.nowPlayingItem atIndex:self.correctIndex];
    self.songArrayForCollectionView = storeArray;
    //update rest of UI
    [self.collectionView reloadData];
    [self updateLabels];

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
        self.plusPoints.textColor = [UIColor greenColor];
        self.plusPoints.text = @"+4";
    } else {
        self.misses++;
        self.points-=3;
        self.plusPoints.textColor = [UIColor redColor];
        self.plusPoints.text = @"-3";
    }
    self.plusPoints.alpha = 1;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{ self.plusPoints.alpha = 0;} completion:^(BOOL finished){
        if (finished) {
            self.plusPoints.text = @"";
        }
    }];
    //wait 1 sec
    //insert reward animations here
    
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
    [self updateUI];
}

- (void) handle_PlaybackStateChanged: (NSNotification *) notification {

}

#pragma mark - UICollectionView
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fourCell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[FourCountCollectionViewCell class]]) {
        //set title as what's stored in songArray
        FourCountCollectionViewCell *fourCell = (FourCountCollectionViewCell *)cell;
        MPMediaItem *song = self.songArrayForCollectionView[indexPath.item];
        fourCell.songTitle.text = song.title;
        if (song.artwork && [[NSUserDefaults standardUserDefaults]boolForKey:@"artwork"]) {
            fourCell.backgroundView = [[UIImageView alloc]initWithImage: [song.artwork imageWithSize:fourCell.frame.size]];
            fourCell.songTitle.textColor = [UIColor whiteColor];
            fourCell.songTitle.shadowColor = [UIColor blackColor];
            //fourCell.songTitle.shadowOffset = 1;
        } else {
            fourCell.backgroundView = nil;
            fourCell.songTitle.textColor = [UIColor blackColor];
            fourCell.songTitle.shadowColor = [UIColor clearColor];
        }
        return fourCell;
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    return CGSizeMake(half+3, half+3); //lol sizing so exact
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self saveVars];
}

@end
