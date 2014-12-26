/*
 Copyright (c) 2009, OpenEmu Team

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OEGameCore.h"
#import "OEGameCoreController.h"
#import "OEAbstractAdditions.h"
#import "OERingBuffer.h"
#import "OETimingUtils.h"

#ifndef BOOL_STR
#define BOOL_STR(b) ((b) ? "YES" : "NO")
#endif

NSString *const OEGameCoreErrorDomain = @"org.openemu.GameCore.ErrorDomain";

@implementation OEGameCore

static Class GameCoreClass = Nil;
static NSTimeInterval defaultTimeInterval = 60.0;

+ (void)initialize
{
    if(self == [OEGameCore class])
    {
        GameCoreClass = [OEGameCore class];
    }
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        tenFrameCounter = 10;
        frameRateModifier = 1;
        NSUInteger count = [self audioBufferCount];
        ringBuffers = (__strong OERingBuffer **)calloc(count, sizeof(OERingBuffer *));

        NSLog(@"Some shit about the game.");
    }
    return self;
}

- (void)dealloc
{
    DLog(@"%s", __FUNCTION__);

    for(NSUInteger i = 0, count = [self audioBufferCount]; i < count; i++)
        ringBuffers[i] = nil;

    free(ringBuffers);
}

- (OERingBuffer *)ringBufferAtIndex:(NSUInteger)index
{
    NSAssert1(index < [self audioBufferCount], @"The index %lu is too high", index);
    if(ringBuffers[index] == nil)
        ringBuffers[index] = [[OERingBuffer alloc] initWithLength:[self audioBufferSizeForBuffer:index] * 16];

    return ringBuffers[index];
}

- (NSString *)pluginName
{
    return [[self owner] pluginName];
}

- (NSString *)biosDirectoryPath
{
    return [[self owner] biosDirectoryPath];
}

- (NSString *)supportDirectoryPath
{
    return [[self owner] supportDirectoryPath];
}

- (NSString *)batterySavesDirectoryPath
{
    return [[self supportDirectoryPath] stringByAppendingPathComponent:@"Battery Saves"];
}

#pragma mark - Execution

- (void)calculateFrameSkip:(NSUInteger)rate
{
    NSUInteger time = OEMonotonicTime() * 1000;
    NSUInteger diff = time - autoFrameSkipLastTime;
    int speed = 100;

    if(diff != 0) speed = (1000 / rate) / diff;

    if(speed >= 98)
    {
        frameskipadjust++;

        if(frameskipadjust >= 3)
        {
            frameskipadjust = 0;
            if(frameSkip > 0) frameSkip--;
        }
    }
    else
    {
        if(speed < 80)         frameskipadjust -= (90 - speed) / 5;
        else if(frameSkip < 9) frameskipadjust--;

        if(frameskipadjust <= -2)
        {
            frameskipadjust += 2;
            if(frameSkip < 9)  frameSkip++;
        }
    }

    DLog(@"Speed: %d", speed);
    autoFrameSkipLastTime = time;
}

// GameCores that render direct to OpenGL rather than a buffer should override this and return YES
// If the GameCore subclass returns YES, the renderDelegate will set the appropriate GL Context
// So the GameCore subclass can just draw to OpenGL
- (BOOL)rendersToOpenGL
{
    return NO;
}

- (void)setPauseEmulation:(BOOL)flag
{
    if(flag) isRunning = NO;
    else     isRunning = YES;
}

- (void)setupEmulation
{
}

- (void)runStartUpFrameWithCompletionHandler:(void(^)(void))handler
{
    [_renderDelegate willExecute];

    [self executeFrameSkippingFrame:NO];

    [_renderDelegate didExecute];

    handler();
}

- (void)frameRefreshThread:(id)anArgument
{
    NSTimeInterval realTime, emulatedTime = OEMonotonicTime();

    willSkipFrame = NO;
    frameSkip = 0;

#if 0
    __block NSTimeInterval gameTime = 0;
    __block int wasZero=1;
#endif

    DLog(@"main thread: %s", BOOL_STR([NSThread isMainThread]));

    OESetThreadRealtime(1. / (frameRateModifier * [self frameInterval]), .007, .03); // guessed from bsnes

    while(!shouldStop)
    {
        @autoreleasepool
        {
#if 0
            gameTime += 1. / [self frameInterval];
            if(wasZero && gameTime >= 1)
            {
                NSUInteger audioBytesGenerated = ringBuffers[0].bytesWritten;
                double expectedRate = [self audioSampleRateForBuffer:0];
                NSUInteger audioSamplesGenerated = audioBytesGenerated/(2*[self channelCount]);
                double realRate = audioSamplesGenerated/gameTime;
                NSLog(@"AUDIO STATS: sample rate %f, real rate %f", expectedRate, realRate);
                wasZero = 0;
            }
#endif

            willSkipFrame = (frameCounter != frameSkip);

            if(isRunning || stepFrameForward)
            {
                stepFrameForward = NO;
                //OEPerfMonitorObserve(@"executeFrame", gameInterval, ^{
                [_renderDelegate willExecute];

                [self executeFrameSkippingFrame:willSkipFrame];

                [_renderDelegate didExecute];
                //});
            }
            if(frameCounter >= frameSkip) frameCounter = 0;
            else                          frameCounter++;
        }
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, 0);

        emulatedTime += 1. / (frameRateModifier * [self frameInterval]);
        realTime = OEMonotonicTime();

        // if we are running more than a second behind, synchronize
        if(realTime - emulatedTime > 1)
        {
            NSLog(@"Synchronizing because we are %g seconds behind", realTime - emulatedTime);
            emulatedTime = realTime;
        }

        OEWaitUntil(emulatedTime);
    }

    [[self delegate] gameCoreDidFinishFrameRefreshThread:self];
}

- (BOOL)isEmulationPaused
{
    return !isRunning;
}

- (void)stopEmulation
{
    shouldStop = YES;
    isRunning  = NO;
    DLog(@"Ending thread");
    [self didStopEmulation];
}

- (void)stopEmulationWithCompletionHandler:(void(^)(void))completionHandler;
{
    _stopEmulationHandler = [completionHandler copy];
    [self stopEmulation];
}

- (void)didStopEmulation;
{
    if(_stopEmulationHandler != nil) _stopEmulationHandler();
    _stopEmulationHandler = nil;
}

- (void)startEmulation
{
    if([self class] != GameCoreClass)
    {
        if(!isRunning)
        {
            isRunning  = YES;
            shouldStop = NO;

            // The selector is performed after a delay to let the application loop finish,
            // afterwards, the GameCore's runloop takes over and only stops when the whole helper stops.
            [self performSelector:@selector(frameRefreshThread:) withObject:nil afterDelay:0.0];
        }
    }
}

- (void)fastForwardAtSpeed:(CGFloat)fastForwardSpeed;
{
    // FIXME: Need implementation.
}

- (void)rewindAtSpeed:(CGFloat)rewindSpeed;
{
    // FIXME: Need implementation.
}

- (void)slowMotionAtSpeed:(CGFloat)slowMotionSpeed;
{
    // FIXME: Need implementation.
}

- (void)stepFrameForward;
{
    if(![self isEmulationPaused])
        [self setPauseEmulation:YES];

    stepFrameForward = YES;
}

- (void)stepFrameBackward;
{
    // FIXME: Need implementation.
}

#pragma mark - ABSTRACT METHODS

// Never call super on them.
- (void)resetEmulation
{
    [self doesNotImplementSelector:_cmd];
}

- (void)executeFrameSkippingFrame:(BOOL)skip
{
    [self executeFrame];
}

- (void)executeFrame
{
    [self doesNotImplementSelector:_cmd];
}

- (BOOL)loadFileAtPath:(NSString *)path
{
    [self doesNotImplementSelector:_cmd];
    return NO;
}

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError **)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    return [self loadFileAtPath:path];
#pragma clang diagnostic pop
}

#pragma mark - Video

- (OEIntRect)screenRect
{
    return (OEIntRect){ {}, [self bufferSize]};
}

- (OEIntSize)bufferSize
{
    [self doesNotImplementSelector:_cmd];
    return (OEIntSize){};
}

- (OEIntSize)aspectSize
{
    return (OEIntSize){ 4, 3 };
}

- (const void *)videoBuffer
{
    [self doesNotImplementSelector:_cmd];
    return NULL;
}

- (GLenum)pixelFormat
{
    [self doesNotImplementSelector:_cmd];
    return 0;
}

- (GLenum)pixelType
{
    [self doesNotImplementSelector:_cmd];
    return 0;
}

- (GLenum)internalPixelFormat
{
    [self doesNotImplementSelector:_cmd];
    return 0;
}

- (NSTimeInterval)frameInterval
{
    return defaultTimeInterval;
}

- (void)fastForward:(BOOL)flag;
{
    if(flag == isFastForwarding)
        return;

    if(flag)
    {
        isFastForwarding = YES;
        frameRateModifier = 5; // 5x speed
    }
    else
    {
        isFastForwarding = NO;
        frameRateModifier = 1;
    }

    [_renderDelegate setEnableVSync:!isFastForwarding];
    OESetThreadRealtime(1./(frameRateModifier * [self frameInterval]), .007, .03);
}

#pragma mark - Audio

- (NSUInteger)audioBufferCount
{
    return 1;
}

- (void)getAudioBuffer:(void *)buffer frameCount:(NSUInteger)frameCount bufferIndex:(NSUInteger)index
{
    [[self ringBufferAtIndex:index] read:buffer maxLength:frameCount * [self channelCountForBuffer:index] * sizeof(UInt16)];
}

- (NSUInteger)channelCount
{
    [self doesNotImplementSelector:_cmd];
    return 0;
}

- (double)audioSampleRate
{
    [self doesNotImplementSelector:_cmd];
    return 0;
}

- (NSUInteger)audioBitDepth
{
    return 16;
}

- (NSUInteger)channelCountForBuffer:(NSUInteger)buffer
{
    if(buffer == 0) return [self channelCount];

    NSLog(@"Buffer count is greater than 1, must implement %@", NSStringFromSelector(_cmd));
    [self doesNotImplementSelector:_cmd];
    return 0;
}

- (NSUInteger)audioBufferSizeForBuffer:(NSUInteger)buffer
{
    // 4 frames is a complete guess
    double frameSampleCount = [self audioSampleRateForBuffer:buffer] / [self frameInterval];
    NSUInteger channelCount = [self channelCountForBuffer:buffer];
    NSUInteger bytesPerSample = [self audioBitDepth] / 8;
    NSAssert(frameSampleCount, @"frameSampleCount is 0");
    return channelCount*bytesPerSample * frameSampleCount;
}

- (double)audioSampleRateForBuffer:(NSUInteger)buffer
{
    if(buffer == 0) return [self audioSampleRate];

    NSLog(@"Buffer count is greater than 1, must implement %@", NSStringFromSelector(_cmd));
    [self doesNotImplementSelector:_cmd];
    return 0;
}


#pragma mark - Input

- (NSTrackingAreaOptions)mouseTrackingOptions
{
    return 0;
}

#pragma mark - Save state

- (BOOL)saveStateToFileAtPath:(NSString *)fileName
{
    return NO;
}

- (BOOL)loadStateFromFileAtPath:(NSString *)fileName
{
    return NO;
}

- (void)saveStateToFileAtPath:(NSString *)fileName completionHandler:(void(^)(BOOL success, NSError *error))block
{
    block([self saveStateToFileAtPath:fileName], nil);
}

- (void)loadStateFromFileAtPath:(NSString *)fileName completionHandler:(void(^)(BOOL success, NSError *error))block
{
    block([self loadStateFromFileAtPath:fileName], nil);
}

#pragma mark - Cheats

- (void)setCheat:(NSString *)code setType:(NSString *)type setEnabled:(BOOL)enabled
{
}

#pragma mark - Misc

- (void)changeDisplayMode;
{
}

@end
