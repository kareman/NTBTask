//
//  NTBTask.m
//  Copy files
//
//  Created by Kåre Morstøl on 30/03/14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

#import "NTBTask.h"

@implementation NTBTask

- (instancetype)initWithLaunchPath:(NSString *)launchPath
{
	self = [super init];
	if (self) {
		_task = [[NSTask alloc] init];
		_encoding = NSUTF8StringEncoding;
		_task.launchPath = launchPath;
	}
	return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return _task;
}

#pragma mark properties

// http://stackoverflow.com/a/16274586
- (void)setOutputHandler:(void (^)(NSString *))outputHandler
{
	// @todo: - (void)releaseoutputhandler
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
	_errorHandler = errorHandler;
	_task.standardError = [NSPipe pipe];
	[_task.standardError fileHandleForReading].readabilityHandler = ^(NSFileHandle *file)
	{
		NSData *data = [file availableData]; // this will read to EOF, so call only once
		NSString *output = [[NSString alloc] initWithData:data encoding:self.encoding];
		_errorHandler(output);
	};
}

- (void)releaseoutputhandler
{
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
	NSPipe *output = [NSPipe pipe];
	[_task setStandardOutput:output];
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

		if (thistask.standardOutput && [thistask.standardOutput isKindOfClass:[NSPipe class]]) {
			[thistask.standardOutput fileHandleForReading].readabilityHandler = nil;
		}
		if (thistask.standardError && [thistask.standardError isKindOfClass:[NSPipe class]]) {
			[thistask.standardError fileHandleForReading].readabilityHandler = nil;
		}

		if (weakself.completionHandler) {
			weakself.completionHandler(weakself);
		}
	}];
	[_task launch];
}
@end
