//
//  XCTestCase+AsyncTesting.m
//  AsyncXCTestingKit
//
//  Created by 小野 将司 on 12/03/17.
//  Modified for XCTest by Vincil Bishop
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//
// This code is licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// https://github.com/premosystems/XCAsyncTestCase

#import "XCTestCase+AsyncTesting.h"
#import "objc/runtime.h"

static void *kLoopUntil_Key = "LoopUntil_Key";
static void *kNotified_Key = "kNotified_Key";
static void *kNotifiedStatus_Key = "kNotifiedStatus_Key";
static void *kExpectedStatus_Key = "kExpectedStatus_Key";

@implementation XCTestCase (AsyncTesting)

#pragma mark - Public


- (void)waitForStatus:(XCTAsyncTestCaseStatus)status timeout:(NSTimeInterval)timeout
{
    self.notified = NO;
    self.expectedStatus = status;
    self.loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    NSDate *dt = [NSDate dateWithTimeIntervalSinceNow:0.1];
    while (!self.notified && [self.loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:dt];
        dt = [NSDate dateWithTimeIntervalSinceNow:0.1];
    }
    
    // Only assert when notified. Do not assert when timed out
    // Fail if not notified
    if (self.notified) {
        XCTAssertEqual(self.notifiedStatus, self.expectedStatus, @"Notified status does not match the expected status.");
    } else {
        XCTFail(@"Async test timed out.");
    }
}

- (void)waitForTimeout:(NSTimeInterval)timeout
{
    self.notified = NO;
    self.expectedStatus = XCTAsyncTestCaseStatusUnknown;
    self.loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    NSDate *dt = [NSDate dateWithTimeIntervalSinceNow:0.1];
    while (!self.notified && [self.loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:dt];
        dt = [NSDate dateWithTimeIntervalSinceNow:0.1];
    }
}

- (void)notify:(XCTAsyncTestCaseStatus)status
{
    self.notifiedStatus = status;
    // self.notified must be set at the last of this method
    self.notified = YES;
}

#pragma nark - Object Association Helpers -

- (void) setAssociatedObject:(id)anObject key:(void*)key
{
    objc_setAssociatedObject(self, key, anObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id) getAssociatedObject:(void*)key
{
    id anObject = objc_getAssociatedObject(self, key);
    return anObject;
}

#pragma mark - Property Implementations -

- (NSDate*) loopUntil
{
    return [self getAssociatedObject:kLoopUntil_Key];
}

- (void) setLoopUntil:(NSDate*)value
{
    [self setAssociatedObject:value key:kLoopUntil_Key];
}

- (BOOL) notified
{
    NSNumber *valueNumber = [self getAssociatedObject:kNotified_Key];
    return [valueNumber boolValue];
}

- (void) setNotified:(BOOL)value
{
    NSNumber *valueNumber = [NSNumber numberWithBool:value];
    [self setAssociatedObject:valueNumber key:kNotified_Key];
}

- (XCTAsyncTestCaseStatus) notifiedStatus
{
    NSNumber *valueNumber = [self getAssociatedObject:kNotifiedStatus_Key];
    return [valueNumber integerValue];
}

- (void) setNotifiedStatus:(XCTAsyncTestCaseStatus)value
{
    NSNumber *valueNumber = [NSNumber numberWithUnsignedInteger:value];
    [self setAssociatedObject:valueNumber key:kNotifiedStatus_Key];
}

- (XCTAsyncTestCaseStatus) expectedStatus
{
    NSNumber *valueNumber = [self getAssociatedObject:kExpectedStatus_Key];
    return [valueNumber integerValue];
}

- (void) setExpectedStatus:(XCTAsyncTestCaseStatus)value
{
    NSNumber *valueNumber = [NSNumber numberWithUnsignedInteger:value];
    [self setAssociatedObject:valueNumber key:kExpectedStatus_Key];
}

@end
