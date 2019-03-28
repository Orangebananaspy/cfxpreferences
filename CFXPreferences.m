#import "CFXPreferences.h"

static NSString * const kCustomErrorDomain = @"CFXPreferencesDomain";
static CFStringRef const kPreferencesContainer = (__bridge CFStringRef)@"/User";

@interface _CFXPreferences : NSObject
+ (_CFXPreferences *)copyDefaultPreferences;
- (CFArrayRef)copyKeyListForIdentifier:(CFStringRef)arg1 user:(CFStringRef)arg2 host:(CFStringRef)arg3 container:(CFStringRef)arg4;
- (CFDictionaryRef)copyValuesForKeys:(CFArrayRef)arg1 identifier:(CFStringRef)arg2 user:(CFStringRef)arg3 host:(CFStringRef)arg4 container:(CFStringRef)arg5;
- (void)flushCachesForAppIdentifier:(CFStringRef)arg1 user:(CFStringRef)arg2;
@end

@implementation CFXPreferences
// force cfprefsd to write preference to file and update the values of the cache
+ (void)flushPreferencesForIdentifier:(CFStringRef)identifier error:(NSError **)error {
	NSDictionary *errorUserInfo = nil;

	// grab _CFXPreferences class
  Class prefsClass = NSClassFromString(@"_CFXPreferences");
  if (prefsClass) {
		// if class exists then make sure we can run each of the functions
		if ([prefsClass respondsToSelector:@selector(copyDefaultPreferences)]) {
			_CFXPreferences *prefs = (_CFXPreferences *)[prefsClass copyDefaultPreferences];
			if ([prefs respondsToSelector:@selector(flushCachesForAppIdentifier:user:)]) {
				// flush for identifier
				[prefs flushCachesForAppIdentifier:identifier user:kCFPreferencesCurrentUser];
			} else {
				errorUserInfo = [CFXPreferences classDoesNotContainFunction:@"flushCachesForAppIdentifier:user:"];
			}
		} else {
			errorUserInfo = [CFXPreferences classDoesNotContainFunction:@"copyDefaultPreferences"];
		}
  } else {
		errorUserInfo = [CFXPreferences classNotExistsError];
	}

	if (error && errorUserInfo) {
		*error = [NSError errorWithDomain:kCustomErrorDomain code:-1 userInfo:errorUserInfo];
	}
}

// get preferences from cfprefsd
+ (NSDictionary *)preferenceForIdentifier:(CFStringRef)identifier error:(NSError **)error {
	NSDictionary *errorUserInfo = nil;
	NSDictionary *preferences = nil;

	@autoreleasepool {
	  Class prefsClass = NSClassFromString(@"_CFXPreferences");
	  if (prefsClass) {
			if ([prefsClass respondsToSelector:@selector(copyDefaultPreferences)]) {
				_CFXPreferences *prefs = (_CFXPreferences *)[prefsClass copyDefaultPreferences];
				if ([prefs respondsToSelector:@selector(copyKeyListForIdentifier:user:host:container:)]) {
					// get all keys for identifier
					CFArrayRef prefKeys = [prefs copyKeyListForIdentifier:identifier user:kCFPreferencesCurrentUser host:kCFPreferencesCurrentHost container:kPreferencesContainer];

					// make sure keys exists and is greater than 0
					if (prefKeys && CFArrayGetCount(prefKeys) > 0) {
						if ([prefs respondsToSelector:@selector(copyValuesForKeys:identifier:user:host:container:)]) {
							preferences = (__bridge NSDictionary *)[prefs copyValuesForKeys:prefKeys identifier:identifier user:kCFPreferencesCurrentUser host:kCFPreferencesCurrentHost container:kPreferencesContainer];
							if (!preferences || (preferences && [preferences count] == 0)) {
								errorUserInfo = [CFXPreferences simpleErrorWithDescription:@"Preference does not exist or is empty" recoverySuggestion:@"Preference does not exist or is empty, create a default one; If this is a mistake please contact the developer with detailed log to reproduce this bug"];
							}
						} else {
							errorUserInfo = [CFXPreferences classDoesNotContainFunction:@"copyValuesForKeys:identifier:user:host:container:"];
						}
					} else {
						errorUserInfo = [CFXPreferences simpleErrorWithDescription:@"Preference does not exist" recoverySuggestion:@"Preference does not exist, create a default one; If this is a mistake please contact the developer with detailed log to reproduce this bug"];
					}
				} else {
					errorUserInfo = [CFXPreferences classDoesNotContainFunction:@"copyKeyListForIdentifier:user:host:container:"];
				}
			} else {
				errorUserInfo = [CFXPreferences classDoesNotContainFunction:@"copyDefaultPreferences"];
			}
	  } else {
			errorUserInfo = [CFXPreferences classNotExistsError];
		}

		if (error && errorUserInfo) {
			*error = [NSError errorWithDomain:kCustomErrorDomain code:-1 userInfo:errorUserInfo];
		}
	}

	return preferences;
}

+ (NSDictionary *)simpleErrorWithDescription:(NSString *)desc recoverySuggestion:(NSString *)suggestion {
	return @{
		NSLocalizedDescriptionKey: desc,
		NSLocalizedFailureReasonErrorKey: desc,
		NSLocalizedRecoverySuggestionErrorKey: suggestion
	};
}

+ (NSDictionary *)classDoesNotContainFunction:(NSString *)function {
	return @{
		NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Function does not exist: -[_CFXPreferences %@]", function],
		NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Function does not exist: -[_CFXPreferences %@]", function],
		NSLocalizedRecoverySuggestionErrorKey: @"Library may be running on an older firmware than recommended"
	};
}

+ (NSDictionary *)classNotExistsError {
	return @{
		NSLocalizedDescriptionKey: @"Class does not exist: _CFXPreferences",
		NSLocalizedFailureReasonErrorKey: @"Class does not exist: _CFXPreferences",
		NSLocalizedRecoverySuggestionErrorKey: @"Contact the developer with detailed log to reproduce this bug"
	};
}
@end
