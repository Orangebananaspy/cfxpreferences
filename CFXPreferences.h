#ifndef CFXPreferences_h
#define CFXPreferences_h

@interface CFXPreferences : NSObject
+ (void)flushPreferencesForIdentifier:(CFStringRef)identifier error:(NSError **)error;
+ (NSDictionary *)preferenceForIdentifier:(CFStringRef)identifier error:(NSError **)error;
@end

#endif /* CFXPreferences_h */
