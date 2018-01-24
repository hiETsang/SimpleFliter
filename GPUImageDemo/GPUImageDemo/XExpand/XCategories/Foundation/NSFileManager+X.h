//
//  NSFileManager+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/25.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (X)

/**
 Get URL of Documents directory.
 
 @return Documents directory URL.
 */
+ (NSURL *)documentsURL;

/**
 Get path of Documents directory.
 
 @return Documents directory path.
 */
+ (NSString *)documentsPath;

/**
 Get URL of Library directory.
 
 @return Library directory URL.
 */
+ (NSURL *)libraryURL;

/**
 Get path of Library directory.
 
 @return Library directory path.
 */
+ (NSString *)libraryPath;

/**
 Get URL of Caches directory.
 
 @return Caches directory URL.
 */
+ (NSURL *)cachesURL;

/**
 Get path of Caches directory.
 
 @return Caches directory path.
 */
+ (NSString *)cachesPath;

/**
 Get available disk space.
 
 @return An amount of available disk space in Megabytes.
 */
+ (double)availableDiskSpace;

@end
