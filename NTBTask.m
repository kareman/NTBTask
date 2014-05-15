//
//  NTBTask.m
//
//  Created by Kåre Morstøl on 30/03/14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//
//  This program and the accompanying materials are made available under the terms of the Eclipse Public License v1.0 which accompanies this
//  distribution, and is available at http://www.eclipse.org/legal/epl-v10.html

#import "NTBTask.h"

@implementation NTBTask

- (instancetype)initWithLaunchPath:(NSString *)launchPath
{
	self = [super init];
	if (self) {
		_task = [[NSTask alloc] init];
		_encoding = NSUTF8StringEncoding;

		NSString *path = [NTBTask pathForShellCommand:launchPath];
		_task.launchPath = path ? path : launchPath;
	}
	return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([super respondsToSelector:aSelector]) {
		return [super forwardingTargetForSelector:aSelector];
	} else {
		return _task;
	}
}

#pragma mark helper methods

/**
 *  Stops the file handle from reading. Should be called before replacing/releasing standard output and standard error.
 *
 *  @param outputhandler  NSTask standardOutput or standardError.
 */
+ (void)stopFileHandle:(id)standardoutputorerror
{
	if (standardoutputorerror && [standardoutputorerror isKindOfClass:[NSPipe class]]) {
		[standardoutputorerror fileHandleForReading].readabilityHandler = nil;
	}
}

+ (NSString *)pathForShellCommand:(NSString *)command
{
	if ([command hasPrefix:@"."] || [command hasPrefix:@"/"]) {
		return command;
	} else {
		NTBTask *pathfinder = [[NTBTask alloc] initWithLaunchPath:@"/usr/bin/which"];
		pathfinder.arguments = @[ command ];
		NSString *result = [[pathfinder waitForOutputString] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		return [result length] > 0 ? result : nil;
	}
}

#pragma mark properties

// http://stackoverflow.com/a/16274586
- (void)setOutputHandler:(void (^)(NSString *))outputHandler
{
	[NTBTask stopFileHandle:_task.standardOutput];
	_outputHandler = outputHandler;
	_task.standardOutput = [NSPipe pipe];
	[_task.standardOutput fileHandleForReading].readabilityHandler = ^(NSFileHandle *file)
	{
		NSData *data = [file availableData]; // this will read to EOF, so call only once
		NSString *output = [[NSString alloc] initWithData:data encoding:self.encoding];
		_outputHandler(output);
	};
}

// http://stackoverflow.com/a/16274586
- (void)setErrorHandler:(void (^)(NSString *))errorHandler
{
	[NTBTask stopFileHandle:_task.standardError];
	_errorHandler = errorHandler;
	_task.standardError = [NSPipe pipe];
	[_task.standardError fileHandleForReading].readabilityHandler = ^(NSFileHandle *file)
	{
		NSData *data = [file availableData]; // this will read to EOF, so call only once
		NSString *output = [[NSString alloc] initWithData:data encoding:self.encoding];
		_errorHandler(output);
	};
}

#pragma mark actions

- (void)write:(NSString *)input
{
	if (!_task.standardInput || ![_task.standardInput isKindOfClass:[NSPipe class]]) {
		_task.standardInput = [NSPipe pipe];
	}
	NSData *data = [input dataUsingEncoding:_encoding];
	[[_task.standardInput fileHandleForWriting] writeData:data];
}

- (void)writeAndCloseInput:(NSString *)input
{
	[self write:input];
	[[_task.standardInput fileHandleForWriting] closeFile];
}

- (NSString *)waitForOutputString
{
	[NTBTask stopFileHandle:_task.standardOutput];
	NSPipe *output = [NSPipe pipe];
	_task.standardOutput = output;
	if (!_task.standardError) {
		_task.standardError = _task.standardOutput;
	}

	if ([_task.standardInput isKindOfClass:[NSPipe class]]) {
		[[_task.standardInput fileHandleForWriting] closeFile];
	}

	if (!_task.isRunning) {
		[_task launch];
	}
	[_task waitUntilExit];

	NSFileHandle *read = [output fileHandleForReading];
	NSData *dataRead = [read readDataToEndOfFile];
	NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:self.encoding];

	return stringRead;
}

- (void)launch
{
	if (!_task.standardError) {
		_task.standardError = _task.standardOutput;
	}
	__weak NTBTask *weakself = self;
	[_task setTerminationHandler:^(NSTask *thistask) {

		[NTBTask stopFileHandle:thistask.standardOutput];
		[NTBTask stopFileHandle:thistask.standardError];

		if (weakself.completionHandler) {
			weakself.completionHandler(weakself);
		}
	}];
	[_task launch];
}
@end
