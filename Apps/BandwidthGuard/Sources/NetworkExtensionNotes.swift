import Foundation

/*
 Production integration notes

 BandwidthGuard currently discovers running apps with WorkspaceAppDiscovery and
 stores user rules locally. A production build should add a Network Extension
 target that emits real TrafficSample values:

 - NEFilterDataProvider observes socket flows and reports verdicts.
 - NEFilterControlProvider stores user rules and returns allow/drop decisions.
 - The provider sends compact TrafficSample messages to the containing app via
   App Groups, XPC, or shared storage.
 - Each NEFilterFlow exposes sourceAppIdentifier/sourceAppAuditToken metadata
   that can be mapped to bundle identifiers for per-app accounting.

 Those targets require Apple Developer Program membership and the appropriate
 Network Extension entitlements before macOS will load them.
 */
