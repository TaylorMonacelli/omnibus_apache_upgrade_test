#
# Copyright 2017 YOUR NAME
#
# All Rights Reserved.
#

name "apache-upgrade-test"
maintainer "Taylor Monacelli"
homepage "https://github.com/TaylorMonacelli/omnibus_apache_upgrade_test"
license "Apache License 2.0"
license_file "LICENSE.txt"

# Defaults to C:/apache_upgrade_test on Windows
# and /opt/apache_upgrade_test on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# apache_upgrade_test dependencies/components
dependency "apache"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

package :msi do
	upgrade_code "650bc54a-bf6f-403e-89e7-49bb2b02b6f5"
end
