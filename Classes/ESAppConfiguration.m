//
//  ESAppConfiguration.m
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


#import "ESAppConfiguration.h"

@interface ESAppConfiguration ()

@property (nonatomic, strong) NSDictionary *staticConfiguration;
@property (nonatomic, strong) NSMutableDictionary *mutableConfiguration;

@end

@implementation ESAppConfiguration

+ (instancetype)defaultConfig {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[[self class] alloc] init];
  });
  return _sharedInstance;
}

- (id)init
{
  self = [super init];
  if (self) {
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{[self mutableConfigurationNSUserDefaultsKey] : [NSDictionary dictionary]}];
  
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name: NSApplicationWillResignActiveNotification object:nil];
#endif

  
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)applicationDidEnterBackground:(NSNotification *)notification {
  // Synchronize user defaults when app moves to background,
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)applicationDidReceiveMemoryWarning:(NSNotification *)notification {
  // Release in-memory configuration on memory warnings.
  self.staticConfiguration = nil;
  self.mutableConfiguration = nil;
}


-(NSDictionary *)loadStaticConfiguration {
  NSMutableDictionary *staticConfiguration = [[NSMutableDictionary alloc] init];
  
  // Read the configuration files in order from the bundle.
  for (NSString *configFileName in [self staticConfigurationFileNames]) {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:configFileName withExtension:@"plist"];
    NSDictionary *fileConfiguration = [NSDictionary dictionaryWithContentsOfURL:fileURL];
    if (fileConfiguration) {
      [staticConfiguration addEntriesFromDictionary:fileConfiguration];
    } else if (![self shouldAllowMissingStaticConfigurationFileWithName:configFileName]) {
      
      @throw [NSException exceptionWithName:@"ConfigurationFileMissingException"
                                     reason:[NSString stringWithFormat:@"The configuration file %@ is missing or is not a valid NSDictionary!", configFileName]
                                   userInfo:nil];
    }
  }
  return staticConfiguration;
}

-(NSDictionary *)staticConfiguration {
  @synchronized(self) {
    if (_staticConfiguration == nil) {
      _staticConfiguration = [self loadStaticConfiguration];
    }
  }
  return _staticConfiguration;
}

-(NSMutableDictionary *)loadMutableConfiguration {
  NSDictionary *storedConfiguration = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[self mutableConfigurationNSUserDefaultsKey]];
  return [[NSMutableDictionary alloc] initWithDictionary:storedConfiguration];
}

-(NSMutableDictionary *)mutableConfiguration {
  @synchronized(self) {
    if (_mutableConfiguration == nil) {
      _mutableConfiguration = [self loadMutableConfiguration];
    }
  }
  return _mutableConfiguration;
}

-(NSString *)mutableConfigurationNSUserDefaultsKey {
  return NSStringFromClass([self class]);
}

-(NSArray *)staticConfigurationFileNames {
  return @[@"app-configuration"];
}

-(BOOL)shouldAllowMissingStaticConfigurationFileWithName:(NSString *)fileName {
  return YES;
}

-(id)configValueForKey:(NSString *)key {
  id value = [[self mutableConfiguration] valueForKey:key];
  if (value == nil) {
    value = [[self staticConfiguration] valueForKey:key];
  }
  return value;
}

-(void)setConfigValue:(id)value forKey:(NSString *)key {
  if ([[self.staticConfiguration allKeys] containsObject:key]) {
    NSLog(@"WARNING! The configuration key %@ is part of the static configuration. This is now overridden by the value you set.", key);
  }
  [self.mutableConfiguration setObject:value forKey:key];
  [[NSUserDefaults standardUserDefaults] setObject:self.mutableConfiguration forKey:[self mutableConfigurationNSUserDefaultsKey]];
}

@end
