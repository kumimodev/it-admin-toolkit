# Changelog

All notable changes to this project are listed here.

## Copy update, 1 Nov 2026

### Changed

1. Softened a couple of changelog lines that sounded a bit corporate.

## Version 0.2.0 (1 Nov 2026)

### Changed

1. Tidied the scripts for a cleaner public repo. They now use comment based help, Verb-Noun names, exit codes and SecureString or environment based secrets.
2. Replaced thin one line wrappers with fewer proper helpers.
3. Moved Adobe Reader inventory beside the other Windows helpers.
4. Fixed ISO upgrade automatic variable misuse and quality update reboot exit codes.

### Removed

1. One line Defender, winget upgrade and VM Platform wrappers.
2. Batch DNS flush and Winsock helpers (replaced by PowerShell).
3. The 64 bit relaunch snippet file (pattern lives inside the scripts that need it).

## Version 0.1.0 (1 Nov 2026)

### Added

1. First public draft of the IT admin toolkit.
2. Windows helpers moved from the Intune home lab draft.
3. Acronis Cyber Protect Cloud samples that read credentials from environment variables only.
4. Sanitised monitoring, RMM and security policy JSON shapes with placeholder resource ids.
