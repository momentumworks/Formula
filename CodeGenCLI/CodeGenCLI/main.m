//
//  main.m
//  CodeGenCLI
//
//  Created by Rheese Burgess on 16/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CodeGen;

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *targetDirectory = [userDefaults stringForKey:@"target"];

    if (targetDirectory == nil) {
      NSLog(@"Usage: \"codegen -target <target-dir>\"");
      return 1;
    }

    NSArray *generators = @[[[ImmutableSettersGenerator alloc] init]];
    [[[CodeGenerator alloc] initWithGenerators:generators] generateForDirectory:targetDirectory];
  }
  return 0;
}
