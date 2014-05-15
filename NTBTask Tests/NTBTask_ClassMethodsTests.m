//
//  NTBTask_ClassMethodsTests.m
//  NTBTask
//
//  Created by Kåre Morstøl on 13/05/14.
//
//

#import <XCTest/XCTest.h>
#import "NTBTask.h"

@interface NTBTask_ClassMethodsTests : XCTestCase

@end

@implementation NTBTask_ClassMethodsTests

- (void)testPathForShellCommand
{
	NSString *result = [NTBTask pathForShellCommand:@"cat"];
	XCTAssertEqualObjects(result, @"/bin/cat");
}

- (void)testPathForShellCommandSkipsCommandsBeginningWithPaths
{
	NSString *result = [NTBTask pathForShellCommand:@".cat"];
	XCTAssertEqualObjects(result, @".cat");

	result = [NTBTask pathForShellCommand:@"/cat"];
	XCTAssertEqualObjects(result, @"/cat");
}

- (void)testPathForShellCommandReturnsNilWhenCommandIsNotFound
{
	NSString *result = [NTBTask pathForShellCommand:@"nowaythiscommandexists"];
	XCTAssertNil(result);
}

@end
