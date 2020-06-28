//===----------- PrintTargetInfoJob.swift - Swift Target Info Job ---------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// Describes information about the target as provided by the Swift frontend.
struct FrontendTargetInfo: Codable {
  struct Target: Codable {
    /// The target triple
    let triple: Triple

    /// The target triple without any version information.
    let unversionedTriple: Triple

    /// The triple used for module names.
    let moduleTriple: Triple

    /// Whether the Swift libraries need to be referenced in their system
    /// location (/usr/lib/swift) via rpath .
    let librariesRequireRPath: Bool
  }

  struct Paths: Codable {
    let runtimeLibraryPaths: [String]
    let runtimeLibraryImportPaths: [String]
    let runtimeResourcePath: String
  }

  let target: Target
  let targetVariant: Target?
}

extension Toolchain {
  func printTargetInfoJob(target: Triple?,
                          targetVariant: Triple?,
                          sdkPath: VirtualPath? = nil,
                          resourceDirPath: VirtualPath? = nil,
                          requiresInPlaceExecution: Bool = false) throws -> Job {
    var commandLine: [Job.ArgTemplate] = [.flag("-frontend"),
                                          .flag("-print-target-info")]
    // If we were given a target, include it. Otherwise, let the frontend
    // tell us the host target.
    if let target = target {
      commandLine += [.flag("-target"), .flag(target.triple)]
    }

    // If there is a target variant, include that too.
    if let targetVariant = targetVariant {
      commandLine += [.flag("-target-variant"), .flag(targetVariant.triple)]
    }

    if let sdkPath = sdkPath {
      commandLine += [.flag("-sdk"), .path(sdkPath)]
    }

    if let resourceDirPath = resourceDirPath {
      commandLine += [.flag("-resource-dir"), .path(resourceDirPath)]
    }

    return Job(
      moduleName: "",
      kind: .printTargetInfo,
      tool: .absolute(try getToolPath(.swiftCompiler)),
      commandLine: commandLine,
      displayInputs: [],
      inputs: [],
      outputs: [.init(file: .standardOutput, type: .jsonTargetInfo)],
      requiresInPlaceExecution: requiresInPlaceExecution,
      supportsResponseFiles: false
    )
  }
}
