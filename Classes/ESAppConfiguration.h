//
//  ESAppConfiguration.h
//
//  Copyright (c) 2012 Erik Sundin (erik@eriksundin.se)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

/**
 A generic configuration class used for having a one-point entry for application configuration.
 Configuration keys are aggregated from two sources:
 - static configuration   (Dictionary plist files in the main bundle)
 - mutable configuration  (A dictionary in NSUserDefaults)
 
 Mutable configuration is prioritized over static configuration when accessing values.
 Subclass for customizing the behaviour and files.
*/
@interface ESAppConfiguration : NSObject

/**
 @return A shared configuration instance.
*/
+(id)defaultConfig;

/**
 Gets the value for a configuration key.
 @param key The configuration key;
 @return The value or nil.
*/
-(id)configValueForKey:(NSString *)key;

/**
 Set a value for a configuration key.
 @param value The value to set.
 @param key The configuration key.
 @discussion Setting a value is only possible in the mutable NSUserDefaults-backed configuration. If the key exists in the static config this value will be lost.
*/
-(void)setConfigValue:(id)value forKey:(NSString *)key;

/** @section Customization points for sub-classes. */

/**
 @return An array of file names for static configuration. Ex "core-config", "app-specific-config"...
 @discussion The order of the files decides which configuration takes priority.
*/
-(NSArray *)staticConfigurationFileNames;

/**
 @return The key to use for storing mutable configuration in NSUserDefaults. Defaults to the class name.
*/ 
-(NSString *)mutableConfigurationNSUserDefaultsKey;

/**
 Hook for validating configuration files when reading static config.
 Good for setting some files as mandatory and others optional.
 @param fileName The name of the missing config file.
 @return YES if it should pass unnoticed, NO if an exception should be thrown.
*/
-(BOOL)shouldAllowMissingStaticConfigurationFileWithName:(NSString *)fileName;

@end
