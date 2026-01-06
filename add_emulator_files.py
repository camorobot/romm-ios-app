#!/usr/bin/env python3
"""
Script to add EmulatorJS UseCase files to Xcode project
"""

import sys
import os

# Add project root to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from pbxproj import XcodeProject

def main():
    project_path = "romm/romm.xcodeproj/project.pbxproj"

    # Load project
    project = XcodeProject.load(project_path)

    # Files to add
    files_to_add = [
        "romm/romm/Domain/UseCases/Emulator/CheckEmulatorSupportUseCase.swift",
        "romm/romm/Domain/UseCases/Emulator/LaunchEmulatorUseCase.swift"
    ]

    # Add files to project
    for file_path in files_to_add:
        if os.path.exists(file_path):
            print(f"Adding {file_path}")
            project.add_file(file_path, parent=project.get_or_create_group('Domain/UseCases/Emulator'))
        else:
            print(f"Warning: {file_path} not found")

    # Save project
    project.save()
    print("✅ Files added to Xcode project successfully!")

if __name__ == "__main__":
    main()
