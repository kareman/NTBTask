//
//  NTBTask.h
//  Copy files
//
//  Created by Kåre Morstøl on 30/03/14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTBTask : NSObject {
	
@private
	NSTask* _task;
	
}

@property NSStringEncoding encoding;

@property (nonatomic,strong) void (^outputHandler)(NSString *);
@property (nonatomic,strong) void (^errorHandler)(NSString *);
@property (nonatomic,strong) void (^completionHandler)(NTBTask *);


- (instancetype) initWithLaunchPath:(NSString*) launchPath;
- (void) launch;
- (void) write:(NSString*)input;
- (void) writeAndCloseInput:(NSString*)input;
- (NSString *) waitForOutputString;

@end


@interface NTBTask (ForwardedToNSTask)

@property NSString* currentDirectoryPath;
@property NSArray* arguments;
@property NSDictionary* environment;
@property (readonly) int processIdentifier; 
@property (readonly) int terminationStatus; 
@property (readonly) NSTaskTerminationReason terminationReason;
@property (readonly) BOOL isRunning;
@property id standardInput;

- (void)waitUntilExit;
- (void)interrupt; // Not always possible. Sends SIGINT.
- (void)terminate; // Not always possible. Sends SIGTERM.

- (BOOL)suspend;
- (BOOL)resume;

@end
