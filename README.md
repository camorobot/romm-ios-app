# RomM iOS App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A native iOS client for [RomM](https://github.com/rommapp/romm) - your personal ROM collection manager.

## Download

### TestFlight Beta Access (Early Releases)

[Join the RomM Beta on TestFlight](https://testflight.apple.com/join/F4C5mhrC)

For early access to new features and beta versions (use with caution). To participate, simply install TestFlight from the App Store and open the link above on your iPhone or iPad. This early version lets you explore all core features before the official release. Your feedback is incredibly valuable and will help shape the final app.

What to test:

- See the feature list below for an overview of what you can try out.
- Test the connection to your RomM server and browse your ROM collection.

Please report any bugs, crashes, or suggestions directly through TestFlight, or email me at <ilhallak@gmail.com>. Thank you for helping make RomM iOS better!

## Overview

RomM iOS App is a SwiftUI-based mobile client that connects to your RomM server, allowing you to browse, manage, and organize your retro game ROM collection directly from your iPhone or iPad.

## Features

### 🎮 ROM Management

- Browse, search, and filter your entire ROM collection
- View detailed information with metadata and cover art
- Support for multiple gaming platforms
- Favorite ROMs and manage collections
- Download ROMs directly to your iOS device or transfer to retro gaming devices via SFTP

### 📚 Collections & Organization

- Create and manage regular collections (virtual/smart is coming soon!)
- Platform-based browsing and filtering
- Multiple view modes (grid/list)

### 🔌 Device Integration & Transfers

- Configure and manage SFTP connections to retro gaming devices
- Upload ROMs with progress tracking
- Browse and manage remote directories
- Complete transfer history grouped by platform and device

## Requirements

- iOS 26.0 or later
- A running [RomM server](https://github.com/rommapp/romm) instance
- RomM server URL and authentication credentials

## Contributing

1. Follow the established Clean Architecture patterns
2. Maintain one ViewModel per View (no sharing between views)
3. Use the existing dependency injection system
4. Follow SwiftUI best practices
5. Ensure proper error handling and logging

