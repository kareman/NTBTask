NTBTask
=======

A Cocoa class for running shell commands, supporting asynchronous I/O. Specifically it's a wrapper for NSTask making it simpler to use.

## Installation

Add NTBTask.h and NTBTask.m to your project.

## Usage

#### Get output from command

```Objective-C
NTBTask *task = [[NTBTask alloc] initWithLaunchPath:@"/bin/env"];
NSString *output = [task waitForOutputString];
```

#### Send input to command

```Objective-C
NTBTask *task = [[NTBTask alloc] initWithLaunchPath:@"/bin/cat"];
NSString *input = @"What goes in, must come out";
[task write:input];
NSString *output = [task waitForOutputString];
```
#### Add arguments

```Objective-C
task.arguments = @[ @"testing testing", @"123" ];
```

#### Run shell script

```Objective-C
NTBTask *task = [[NTBTask alloc] initWithLaunchPath:@"/bin/bash"];
NSString *slowscript = @"echo 'sleeping for 0.3'\n"
			"sleep 0.3\n"
			"echo 'sleeping for 0.3'\n"
			"sleep 0.3\n"
			"echo 'sleeping for 0.3'\n"
			"sleep 0.3";
[task writeAndCloseInput:slowscript];
[task launch];
```

#### Get continuous output

```Objective-C
NTBTask *task = [[NTBTask alloc] initWithLaunchPath:@"/bin/cp"];
NSString *tempdir = NSTemporaryDirectory();
task.arguments = @[ @"-Rpnv", @".", tempdir ];

NSMutableString *result = [[NSMutableString alloc] init];

task.outputHandler = ^(NSString *output)
{
	[result appendString:output];
	[self newOutputAvailable:output];
};
task.completionHandler = ^(NTBTask *thistask)
{
	[self doSomethingWhenCopyingIsFinished];
};

[task launch];
```
