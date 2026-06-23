/// No-op stub for web platform where dart:io is unavailable.
/// HttpOverrides are not needed on web since the browser handles HTTP.
void applyHttpOverrides() {
  // No-op on web — dart:io is not available.
}
