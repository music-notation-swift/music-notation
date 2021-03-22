![music-notation](https://user-images.githubusercontent.com/62043/111560932-cf4d1180-8750-11eb-842e-3159015c61ab.png)

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-lightgrey.svg)](https://github.com/music-notation-swift/music-notation)

# music-notation

This is a **work in progress**, Cross-Platform Music Notation API written in Swift. It is written so that it can be used in most any operating system, such as iOS, macOS, tvOS. Windows & Linux is aspirational at this point, but since the plan is to eschew all dependencies, this should not be much of a stretch. This library is being created with the goal of having 0 dependencies; not even Foundation.

`music-notation` is meant to implement the model and controller layers, which understands how music notation works. It will have no render capabilities, nor input/output. Those functionalities will be implemented in add-on packages.

See `music-notation-render` and `music-notation-io` as well as `music-notation-import`.

The goal is to provide these as Swift Package Manager based packages. Cocoapods and Carthage will no longer be supported. Manually adding the package into Xcode projects will still be supported.

Please consult this [Swift style guide](https://github.com/music-notation-swift/swift-style-guide) for coding style guidelines used in this repo and be sure to adhere to them.

There is a Slack channel you can join if you want to see more into the development process at [Music Notation Swift Slack](https://join.slack.com/t/musicnotationswift/shared_invite/enQtOTE1NzQyMzI5MTA2LWZlN2MyNmI5MjA2Njc4MGQ5N2IxNzYzY2QxMmYwNmFlNDNmNjUwNjBlMGY1MWIzNDkxMzY2MzAwNjc4NTJkNjU).

## Contents

- [Features](Features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Examples](#examples)
- [FAQ](#faq)
- [Notes](#notes)
- [License](#license)

## Features

- [x] Modern Swift API
- [x] High Performance Music Notation modeling
- [x] No 3rd party dependencies
- [x] Comprehensive Unit and Performance Test Coverage
- [x] Complete Documentation
- [x] Modular Design for Package Based Extension

## Requirements

- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 7+
- Swift 5.4+

> Note please see [Package.swift](Package.swift) for the latest Requirements

## Installation

**WIP** This will be either SPM or manual install

### Swift Package Manager

**WIP**

### Manual Installation

**WIP**

## Getting Started

**WIP** `music-notation-import` is currently the first real client and usage example for the package.
It isn't on github yet, but as soon as it starts working, I will be selecting snippets to show here.

## Configuration

**WIP** Since much of the concrete implementation will be in packages, this will be the main avenue for configuration.

## Examples
## FAQ

## Note

`music-notation` and the libraries that flesh out specific components based on it, are based on earlier work that can be found in:
- [MusicNotationCore](https://github.com/drumnkyle/music-notation-core)
- [MusicNotationKit](https://github.com/drumnkyle/music-notation-kit)

`music-notation` and the add-on packages are first and foremost designed as Swift Package Manager packages and as such will not provide Xcode projects.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for guidelines to contribute back to
music-notation. This might be a bit premature, but once things start working, please feel free to ask.

## License

music-notation is released under the MIT license. See [LICENSE](LICENSE) for details.
