# CFXPreferences
- A lightweight library to load preferences and flush cfprefsd
- This allows developers to not worry about manually reading from preference files or writing to preference files
- Works with sandboxed and unsandboxed applications
- Utilizing the cfprefsd daemon is beneficial as it caches these preference files so there is an easier load on the device for reading and writing and more importantly this makes it easier for developers to not worrying about manually managing their preference file

## Instructions and Examples
### Control File
You will need to add ```com.orangebananaspy.cfxpreferences``` in the depends line of your control file to ensure that users have this library installed

### Saving Preferences
This is a very simple task, use the PreferenceBundles you have been using with no extra steps to actually saving the preferences to file on disk. cfprefsd automatically saves the values just ensure that you are adding the keys for each cell that you want to save as a preference. The keys being default, defaults, and key
```xml
<dict>
  <key>cell</key>
  <string>PSSwitchCell</string>
  <key>label</key>
  <string>Enabled</string>
  <key>default</key>
  <false/>
  <key>defaults</key>
  <string>com.orangebananaspy.example</string>
  <key>key</key>
  <string>_Enabled</string>
</dict>
<dict>
  <key>cell</key>
  <string>PSSliderCell</string>
  <key>label</key>
  <string>Animation Duration</string>
  <key>min</key>
  <real>0.0</real>
  <key>max</key>
  <real>1.0</real>
  <key>showValue</key>
  <true/>
  <key>isSegmented</key>
  <true/>
  <key>segmentCount</key>
  <integer>10</integer>
  <key>default</key>
  <real>1.0</real>
  <key>defaults</key>
  <string>com.orangebananaspy.example</string>
  <key>key</key>
  <string>_Duration</string>
</dict>
```
### Getting Preferences
Load the library into the process using dlopen() and make sure to use the flag RTLD_NOW as you want the symbols of the library to be resolved before the dlopen() function returns. Also make sure to use dlclose() as soon as you are done as it flags the library that it is good to close so when the process needs to deallocate memory due to an exception it can do so otherwise the library will always be loaded into the process and take up the space in memory even when it is not being used.
```objectivec
NSDictionary *preferences = nil;
void *prefsHandle = dlopen("/usr/lib/CFXPreferences.dylib", RTLD_NOW);
if (prefsHandle) {
  Class prefsClass = NSClassFromString(@"CFXPreferences");
  if (prefsClass) {
    NSError *error = nil;
    preferences = [prefsClass preferenceForIdentifier:(__bridge CFStringRef)@"com.orangebananaspy.example" error:&error];

    // handle error and find out the reason for the error if any
    if (error) {
      NSLog(@"Error: %@", error);
    }
  }

  dlclose(prefsHandle);
}

// fail safe if CFXPreferences fails
if (!preferences) {
  NSData *data = [NSData dataWithContentsOfFile:@"/User/Library/Preferences/com.orangebananaspy.example.plist"];
  if(data) {
    preferences = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];
  } else {
    // default settings as the preferences file is not there
    preferences = @{};
  }
}
```

### Flushing Preferences
Flushing preferences basically transfers preferences loaded in cfprefsd from a temporary storage to a permanent storage on the device, important to call when a user has updated tweak preferences. The recommended places to call this is right before a respring, or if a respring is not required for your tweak basically when the user is done making any changed to the preferences of the tweak. Calling this ensures that the preference values stay up to date
```objectivec
void *prefsHandle = dlopen("/usr/lib/CFXPreferences.dylib", RTLD_NOW);
if (prefsHandle) {
  Class prefsClass = NSClassFromString(@"CFXPreferences");
  if (prefsClass) {
    NSError *error = nil;
    [prefsClass flushPreferencesForIdentifier:(__bridge CFStringRef)@"com.orangebananaspy.example" error:&error];

    // handle error and find out the reason for the error if any
    if (error) {
      NSLog(@"Error: %@", error);
    }
  }

  dlclose(prefsHandle);
}
```

Read more about Dynamically Loaded Libraries
- <http://tldp.org/HOWTO/Program-Library-HOWTO/dl-libraries.html>

A tweak example where CFXPreferences is used
- <https://github.com/Orangebananaspy/organicemojiscrubber>
