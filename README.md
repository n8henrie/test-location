Posted to <https://apple.stackexchange.com/questions/457341/cllocation-doesnt-work-from-cli-app-on-macos-ventura> originally, then moved to <https://stackoverflow.com/questions/75782846/cllocation-doesnt-work-from-cli-app-on-macos-ventura>

---

MacOS 13.2.1, Xcode 14.2

I'm struggling to get CLLocation to work on Ventura from a command line executable. It works fine from a GUI app. I have the same experience with Swift and Objective C (using the `app` template works but `command line tool` doesn't); I'm using ObjC for the example below.

I found some example code online that I've put into two Xcode projects at <https://github.com/n8henrie/test-location>.

- [`location-objc-app`](https://github.com/n8henrie/test-location/tree/master/location-objc-app) was created with the `Xcode` -> `new project` -> `macos` -> `app` template (using `storyboard` and `objective c`)
- [`location-objc`](https://github.com/n8henrie/test-location/tree/master/location-objc) was created with the `Xcode` -> `new project` -> `macos` -> `Command Line Tool` template (`objective c`)

When I run it in Xcode, `location-objc` does **not** prompt for any permissions, and can't retrieve the location:

```
2023-03-18 09:30:50.109158-0600 location-objc[92344:8383074] authorization status: 0
2023-03-18 09:30:52.121832-0600 location-objc[92344:8383074] status: 1
2023-03-18 09:30:52.121868-0600 location-objc[92344:8383074] 0.000000.0.000000
Program ended with exit code: 0
```

`location-objc-app` **does** give me a popup for permissions and successfully prints the location:

```
2023-03-18 09:30:56.815837-0600 location-objc-app[92346:8383607] authorization status: 0
2023-03-18 09:30:56.823216-0600 location-objc-app[92346:8383607] status: 0
2023-03-18 09:30:56.823263-0600 location-objc-app[92346:8383607] 12.REDACTED.-34.REDACTED
```


I've ensured that the resulting `location-objc` binary has the `Info.plist` information embedded:

```console
$ otool -P location-objc
location-objc:
(__TEXT,__info_plist) section
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BuildMachineOSBuild</key>
	<string>22D68</string>
	<key>CFBundleExecutable</key>
	<string>location-objc</string>
	<key>CFBundleIdentifier</key>
	<string>com.n8henrie.location-objc</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>location-objc</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>DTCompiler</key>
	<string>com.apple.compilers.llvm.clang.1_0</string>
	<key>DTPlatformBuild</key>
	<string>14C18</string>
	<key>DTPlatformName</key>
	<string>macosx</string>
	<key>DTPlatformVersion</key>
	<string>13.1</string>
	<key>DTSDKBuild</key>
	<string>22C55</string>
	<key>DTSDKName</key>
	<string>macosx13.1</string>
	<key>DTXcode</key>
	<string>1420</string>
	<key>DTXcodeBuild</key>
	<string>14C18</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.1</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>Always and When!</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>Always!</string>
	<key>NSLocationUsageDescription</key>
	<string>General!</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>When in use</string>
</dict>
</plist>
```

and it seems to have appropriate entitlements:

```console
$ codesign -dvv --entitlements - location-objc
Executable=/Users/n8henrie/Library/Developer/Xcode/DerivedData/location-objc-gxafbuxirpiqouanzeqrgitsgzss/Build/Products/Debug/location-objc
Identifier=com.n8henrie.location-objc
Format=Mach-O thin (arm64)
CodeDirectory v=20500 size=795 flags=0x10002(adhoc,runtime) hashes=14+7 location=embedded
Signature=adhoc
Info.plist entries=21
TeamIdentifier=not set
Runtime Version=13.1.0
Sealed Resources=none
Internal requirements count=0 size=12
[Dict]
	[Key] com.apple.security.app-sandbox
	[Value]
		[Bool] true
	[Key] com.apple.security.files.user-selected.read-only
	[Value]
		[Bool] true
	[Key] com.apple.security.get-task-allow
	[Value]
		[Bool] true
	[Key] com.apple.security.personal-information.location
	[Value]
		[Bool] true
```

I've tried every combination I can think of enabling and disabling the sandbox, hardened runtime, manually re-codesigning (with numerous combinations of the below flags):

```console
$ codesign --sign - --force --deep --strict --timestamp --options runtime --entitlements entitlements.plist --identifier com.n8henrie.location-objc ./location-objc
./location-objc: replacing existing signature
$ ./location-objc
2023-03-18 09:40:34.517 location-objc[96782:8398475] authorization status: 0
2023-03-18 09:40:36.527 location-objc[96782:8398475] status: 1
2023-03-18 09:40:36.527 location-objc[96782:8398475] 0.000000.0.000000
```

I've tried manually opening the executable from Finder, hoping that would give me the permissions popup, but no matter what I try it doesn't work.

In console, `locationd` looks like it's *trying* to prompt me:

```
{"msg":"Showing #AuthPrompt", "requestType":5, "client":"92F5C54E-CAEB-44A5-AF60-85E44A017BD2:com.n8henrie.location-objc"}
{"msg":"#AuthPrompt AuthorizationRequest completion", "ClientKey":"92F5C54E-CAEB-44A5-AF60-85E44A017BD2:com.n8henrie.location-objc", "RequestType":"CLClientManager_Type::AuthorizationRequestTypeLegacyAlways"}
{"msg":"#AuthPrompt sending message to #CoreLocationAgent", "MessageDict":"{\n    bundleid = \"com.n8henrie.location-objc\";\n    isMarzipan = 0;\n    isMasquerading = 0;\n    pid = 97813;\n    uuid = \"09278F43-651E-4E29-9E34-0AC87F7ABE35\";\n}", "Connection":"\/System\/Library\/CoreServices\/CoreLocationAgent.app\/Contents\/MacOS\/CoreLocationAgent", "User":"92F5C54E-CAEB-44A5-AF60-85E44A017BD2"}
client '[92F5C54E-CAEB-44A5-AF60-85E44A017BD2]com.n8henrie.location-objc' not authorized for location; not starting yet
{"msg":"client not currently authorized for location; sending error", "client":"[92F5C54E-CAEB-44A5-AF60-85E44A017BD2]com.n8henrie.location-objc"}
```

but nothing ever shows.

How can I get a standalone CLI executable to use `CLLocation`? I do *not* consider using `Shortcuts.app` to be a reasonable workaround in this case, though users looking for a "quick and dirty" solution might take this approach.

Sidenote:

This was originally [asked on AskDifferent](https://apple.stackexchange.com/questions/457341/cllocation-doesnt-work-from-cli-app-on-macos-ventura) but closed as off-topic (with a recommendation to post at SO) based on [their rules](https://apple.stackexchange.com/help/on-topic), though I had thought this fell under their specific example of Xcode for non-language specific tasks (as I think the issue is with permissions, codesigning, sandboxing, etc and not swift or objc).

> Code-level programming questions (cocoa, LLVM, etc…) are off-topic here. We do encourage AppleScript, Automator, and UNIX shell scripting questions as well as how to use tools like Xcode for non-language specific tasks.
