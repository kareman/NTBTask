//
//  NTBTask.h
//
//  Created by Kåre Morstøl on 30/03/14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//
//  This program and the accompanying materials are made available under the terms of the Eclipse Public License v1.0 which accompanies this
//  distribution, and is available at http://www.eclipse.org/legal/epl-v10.html

#import <Foundation/Foundation.h>

/**
 *  A class for running another program asynchronously in a separate process, sending input and receiving output from it.
 */
@interface NTBTask : NSObject {

  @private
	NSTask *_task;
}

/**
 *  Text encoding for the task's input and output. The default is NSUTF8StringEncoding.
 */
@property NSStringEncoding encoding;

/**
 *  Invoked when more output is ready. Can happen many times while the task is running.
 */
@property (nonatomic, strong) void (^outputHandler)(NSString *);

/**
 *  Invoked when more error output is ready. Can happen many times while the task is running.
 */
@property (nonatomic, strong) void (^errorHandler)(NSString *);

/**
 *  Invoked when the task is completed.
 *
 *  This block is not guaranteed to be fully executed prior to waitUntilExit returning.
 */
@property (nonatomic, strong) void (^completionHandler)(NTBTask *);

/**
 Initialises a new task. Unless launchPath begins with a "." or a "/" NTBTask will try to find the full path automatically, using the search
 path of the current process.

 @param launchPath  The path for the executable to be launched.
 */
- (instancetype)initWithLaunchPath:(NSString *)launchPath;

/**
 *  Launches the task in its own process, and returns before the task is finished.
 *  @throws  NSInvalidArgumentException if the launch path has not been set or is invalid or if it fails to create a process.
 */
- (void)launch;

/**
 *  Writes text to the standard input of the task. Works both before and after it is launched.
 *  @warning When used together with "launch" the last write must use "writeAndCloseInput:" instead, otherwise the task will never end.
 *
 *  @param input  The text to send to the task.
 */
- (void)write:(NSString *)input;

/**
 *  Writes text to the standard input of the task, and then closes standard input. Works both before and after the task is launched.
 *
 *  @param input  The text to send to the task.
 */
- (void)writeAndCloseInput:(NSString *)input;

/**
 *  Launches the task, waits until it's finished, and returns with the output.
 *  @warning  Any existing output handler will be replaced.
 *
 *  @return  The standard output from the task. Also includes error output if no errorHandler is defined.
 */
- (NSString *)waitForOutputString;

/**
 Finds the full path for the given command. If the command begins with a "." or a "/" it just returns the command since it then presumably
 already contains the path.

 @param command  The command

 @return  The full path, or nil if the command was not found.
 */
+ (NSString *)pathForShellCommand:(NSString *)command;

@end

@interface NTBTask (ForwardedToNSTask)

@property (readonly) NSString *launchPath;
@property NSString *currentDirectoryPath;
@property NSArray *arguments;
@property NSDictionary *environment;
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
