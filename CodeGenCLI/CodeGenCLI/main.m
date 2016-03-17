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
    
    BOOL cleanFirst = [userDefaults boolForKey:@"clean"];
    NSString *targetDirectory = [userDefaults stringForKey:@"target"];

    if (targetDirectory == nil) {
      NSLog(@"Usage: \"codegen -target <target-dir> [-clean true]\"");
      return 1;
    }

    NSArray *generators = @[[[ImmutableSettersGenerator alloc] init]];
    [[[CodeGenerator alloc] initWithGenerators:generators] generateForDirectory:targetDirectory cleanFirst: cleanFirst];
  }
  return 0;
}
