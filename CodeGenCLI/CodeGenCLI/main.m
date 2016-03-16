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
    NSString *directory = @"/Users/rb/Documents/Shared Playground Data/Sources";
    NSArray *generators = @[[[ImmutableSettersGenerator alloc] init]];
    [[[CodeGenerator alloc] initWithGenerators:generators] generateForDirectory:directory];
  }
  return 0;
}
