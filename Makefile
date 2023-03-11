TARGET_CODESIGN = $(shell which ldid)

DRTMP = $(TMPDIR)/dualra1n
DR_STAGE_DIR = $(DRTMP)/stage
DR_APP_DIR 	= $(DRTMP)/Build/Products/Release-iphoneos/dualra1n-loader.app
DR_HELPER_PATH 	= $(DRTMP)/Build/Products/Release-iphoneos/dualra1n-helper
GIT_REV=$(shell git rev-parse --short HEAD)

package:
	/usr/libexec/PlistBuddy -c "Set :REVISION ${GIT_REV}" "dualra1n-loader/Info.plist"

	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'dualra1n-loader.xcodeproj' -scheme dualra1n-loader -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(DRTMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(DRTMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'dualra1n-loader.xcodeproj' -scheme dualra1n-helper -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(DRTMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(DRTMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	@rm -rf Payload
	@rm -rf $(DR_STAGE_DIR)/
	@mkdir -p $(DR_STAGE_DIR)/Payload
	@mv $(DR_APP_DIR) $(DR_STAGE_DIR)/Payload/dualra1n-loader.app

	@echo $(DRTMP)
	@echo $(DR_STAGE_DIR)

	@ls $(DR_HELPER_PATH)
	@ls $(DR_STAGE_DIR)
	@mv $(DR_HELPER_PATH) $(DR_STAGE_DIR)/Payload/dualra1n-loader.app/dualra1n-helper
	@$(TARGET_CODESIGN) -Sentitlements.xml $(DR_STAGE_DIR)/Payload/dualra1n-loader.app/
	@$(TARGET_CODESIGN) -Sentitlements.xml $(DR_STAGE_DIR)/Payload/dualra1n-loader.app/dualra1n-helper
	
	@rm -rf $(DR_STAGE_DIR)/Payload/dualra1n-loader.app/_CodeSignature

	@ln -sf $(DR_STAGE_DIR)/Payload Payload

	@rm -rf packages
	@mkdir -p packages

	@zip -r9 packages/dualra1n-loader.ipa Payload
