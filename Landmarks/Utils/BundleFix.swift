//
//  BundleFix.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 20.1.25..
//

import Foundation

// This workaround comes from Skyler_s and Nekitosss on <https://developer.apple.com/forums/thread/664295>

public let localBundle = Bundle.fixedModule

private final class CurrentBundleFinder {}

private let packageName: String = "GoogleSignIn"
private let targetName: String = "Landmarks"

extension Foundation.Bundle {
	
	/// Returns the resource bundle associated with the current Swift module.
	///
	/// # Notes: #
	/// 1. This is inspired by the `Bundle.module` declaration
	static var fixedModule: Bundle = {
		// The name of your local package, prepended by "LocalPackages_" for iOS and "PackageName_" for macOS
		// You may have same PackageName and TargetName
		let bundleNameIOS = "LocalPackages_\(targetName)"
		let bundleNameMacOs = "\(packageName)_\(targetName)"
		
		let candidates = [
			// Bundle should be present here when the package is linked into an App.
			Bundle.main.resourceURL,
			
			// Bundle should be present here when the package is linked into a framework.
			Bundle(for: CurrentBundleFinder.self).resourceURL,
			
			// For command-line tools.
			Bundle.main.bundleURL,
			
			// Bundle should be present here when running previews from a different package
			// (this is the path to "…/Debug-iphonesimulator/").
			Bundle(for: CurrentBundleFinder.self).resourceURL?
				.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
			Bundle(for: CurrentBundleFinder.self).resourceURL?
				.deletingLastPathComponent().deletingLastPathComponent(),
		]
		
		for candidate in candidates {
			let bundlePathiOS = candidate?.appendingPathComponent(bundleNameIOS + ".bundle")
			let bundlePathMacOS = candidate?.appendingPathComponent(bundleNameMacOs + ".bundle")
			if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
				return bundle
			} else if let bundle = bundlePathMacOS.flatMap(Bundle.init(url:)) {
				return bundle
			}
		}
		
		fatalError("unable to find bundle")
	}()
	
}
