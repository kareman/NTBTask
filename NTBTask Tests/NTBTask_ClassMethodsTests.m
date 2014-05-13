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

- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testPathForShellCommand
{
	NSString *result = [NTBTask pathForShellCommand:@"cat"];
	XCTAssertEqualObjects(result, @"/bin/cat");
}

- (void)testPathForShellCommand_SkipsCommandsBeginningWithPaths
{
	NSString *result = [NTBTask pathForShellCommand:@".cat"];
	XCTAssertEqualObjects(result, @".cat");

	result = [NTBTask pathForShellCommand:@"/cat"];
	XCTAssertEqualObjects(result, @"/cat");
}
@end
