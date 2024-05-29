# tuist-make-mergeable
Sample project showcasing MAKE_MERGEABLE issue: https://github.com/tuist/tuist/issues/6347

---

### What problem or need do you have?

When generating projects with mergeable libraries, by setting `mergeable: true` and `mergedBinaryType: .manual` in respective targets settings, tuist won't embedd such a library and adds a custom build setting: `MAKE_MERGEABLE = YES`. This prevents Xcode from reexporting in Debug builds, and in Release builds mergeable library is missing from the Frameworks folder.

Tested with Xcode 15.3 and 15.4

### Steps to reproduce:

Use the sample project: https://github.com/dmytro-anokhin/tuist-make-mergeable

1. `tuist generate`;
2. Open the project in Xcode and inspect **App** target. Under General/Frameworks/Libraries, and Embedded Content `Framework.framework` is set to `Do Not Embed`;
3. Inspect **Framework** target, Build Settings, find `MAKE_MERGEABLE = YES` build setting;
4. Build **App** scheme with Debug configuration;
5. Explore the app bundle - see structure 1;
6. Embedd `Framework.framework` by setting `Embed & Sign`; rebuild and explore the app bundle - see structure 2. Note bundle structure for the release build is correct. Framework in the debug build is not reexported.
7. Remove `MAKE_MERGEABLE` build setting from **Framework** build settings in Xcode and rebuild **App** scheme with Debug configuration;
8. Explore the app bundle - see structure 3. Debug and Release builds are correct.

### Do Not Embed; MAKE_MERGEABLE = YES (1)

#### Debug

```
App.app
├── App
├── Info.plist
├── PkgInfo
└── _CodeSignature
    └── CodeResources
```
Framework code is in the app binary (statically linked).

#### Release

```
App.app
├── App
├── Info.plist
├── PkgInfo
└── _CodeSignature
    └── CodeResources
```
`Frameworks/Framework.framework/` is missing from the bundle. When configuring a new project in Xcode with mergeable libraries, each library is present in the `Frameworks` folder (empty, no symbols).

### Embed & Sign; MAKE_MERGEABLE = YES (2)

#### Debug

```
App.app
├── App
├── Frameworks
│   └── Framework.framework
│       ├── Framework
│       ├── Info.plist
│       └── _CodeSignature
│           └── CodeResources
├── Info.plist
├── PkgInfo
└── _CodeSignature
    └── CodeResources
```
Framework code is in the `Frameworks/Framework.framework` and dynamically linked with the app. However `Framework.framework/Framework` is empty:
```
nm App.app/Frameworks/Framework.framework/Framework
App.app/Frameworks/Framework.framework/Framework: no symbols
```

#### Release

```
App.app
├── App
├── Frameworks
│   └── Framework.framework
│       ├── Framework
│       ├── Info.plist
│       └── _CodeSignature
│           └── CodeResources
├── Info.plist
├── PkgInfo
└── _CodeSignature
    └── CodeResources
```
This is expected structure. `Framework.framework/Framework` is empty, code is statically linked with the app:
```
nm App.app/Frameworks/Framework.framework/Framework
App.app/Frameworks/Framework.framework/Framework: no symbols
```

### Embed & Sign; No MAKE_MERGEABLE (3)

#### Debug

```
App.app
├── App
├── Frameworks
│   └── Framework.framework
│       ├── Framework
│       ├── Info.plist
│       └── _CodeSignature
│           └── CodeResources
├── Info.plist
├── PkgInfo
├── ReexportedBinaries
│   └── Framework.framework
│       ├── Framework
│       ├── Info.plist
│       └── _CodeSignature
│           └── CodeResources
└── _CodeSignature
    └── CodeResources
```

Framework is reexported correctly, code present in `ReexportedBinaries/Framework.framework/Framework`.

#### Release

```
App.app
├── App
├── Frameworks
│   └── Framework.framework
│       ├── Framework
│       ├── Info.plist
│       └── _CodeSignature
│           └── CodeResources
├── Info.plist
├── PkgInfo
└── _CodeSignature
    └── CodeResources
```

Release build structure is correct.

### Potential solution

Target of `product: .framework` and `mergeable: true` should be configured with `MERGEABLE_LIBRARY = YES` build setting; all other settings should not be different from a normal `product: .framework` target, i.e. Embed & Sign and no `MAKE_MERGEABLE` build setting.


### macOS version

14.5

### Tuist version

4.15.0

### Xcode version

15.3
