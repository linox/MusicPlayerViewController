//
//  BeamIpodExampleProvider.m
//  BeamMusicPlayerExample
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "BeamIpodExampleProvider.h"


@implementation BeamIpodExampleProvider

@synthesize musicPlayer;
@synthesize query;
@synthesize backBlock;
@synthesize actionBlock;
@synthesize onAskingForDataPropagationBlock;

-(id)init {
    self = [super init];
    if ( self ){
        
        self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        
        [musicPlayer beginGeneratingPlaybackNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:nil object:self.musicPlayer queue:nil usingBlock:^(NSNotification* notification){
            if(onAskingForDataPropagationBlock)
                onAskingForDataPropagationBlock(self);
        }];
        
        
        // Using an unspecific query we extract all files from the library for playback.
        //MPMediaQuery *everything = [[MPMediaQuery alloc] init];
        
//        [self.musicPlayer setQueueWithQuery:everything];
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        MPVolumeView* view = [MPVolumeView new];
        // Put it far offscreen
        view.frame = CGRectMake(1000, 1000, 120, 12);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    
    return self;
}

-(void)propagateDataTo:(BeamMusicPlayerViewController*) controller {
    propagatingData = YES;
//    [controller reloadData];
    // ensure controller's UI has been loaded from NIB
    [controller view];
    
    [controller playTrack:musicPlayer.indexOfNowPlayingItem atPosition:musicPlayer.currentPlaybackTime volume:-1];
    controller.volume = musicPlayer.volume;
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        [controller play];
    else
        [controller pause];
    propagatingData = NO;
}

-(void)setQuery:(MPMediaQuery *)aQuery {
    query = aQuery;
}

-(NSArray *)mediaItems {
    return self.query.items;
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    
}

-(NSUInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController *)player
{
    return self.mediaItems.count;
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    MPMediaItemArtwork* artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    if ( artwork ){
        UIImage* foo = [artwork imageWithSize:player.preferredSizeForCoverArt];
        receivingBlock(foo, nil);
    } else {
        receivingBlock(nil,nil);
    }
}

#pragma mark Delegate Methods ( Used to control the music player )

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    if(!propagatingData)
        [self.musicPlayer setNowPlayingItem:[self.mediaItems objectAtIndex:track]];    
}

-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController *)player {
    if(!propagatingData)
        [self.musicPlayer play];
}

-(void)musicPlayerDidStopPlaying:(BeamMusicPlayerViewController *)player {
    if(!propagatingData)
        [self.musicPlayer pause];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    if(!propagatingData)
        [self.musicPlayer setVolume:volume];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    if(!propagatingData)
        [self.musicPlayer setCurrentPlaybackTime:position];
}

-(void)musicPlayerActionRequested:(BeamMusicPlayerViewController *)aMusicPlayer {
    if(actionBlock)
        actionBlock(aMusicPlayer);
}

-(void)musicPlayerBackRequested:(BeamMusicPlayerViewController *)aMusicPlayer {
    if(backBlock)
        backBlock(aMusicPlayer);
}


@end
