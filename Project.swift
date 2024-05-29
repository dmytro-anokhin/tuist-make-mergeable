import ProjectDescription

let project = Project(
    name: "App",
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "org.danokhin.tuist-mergeable-libraries.app",
            infoPlist: "Info.plist",
            sources: "App/**",
            dependencies: [
                .target(name: "Framework"),
            ],
            mergedBinaryType: .manual(mergeableDependencies: ["Framework"])
        ),
        .target(
            name: "Framework",
            destinations: .iOS,
            product: .framework,
            bundleId: "org.danokhin.tuist-mergeable-libraries.framework",
            infoPlist: "Info.plist",
            sources: "Framework/**",
            dependencies: [
            ],
            mergeable: true
        ),
    ],
    schemes: [
        .scheme(
            name: "AppCustomScheme",
            buildAction: .buildAction(targets: [TargetReference("App")])
        ),
    ]
)
