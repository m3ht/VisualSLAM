#include "include/fast_slam_app.hpp"

FastSlamApp::FastSlamApp() { }

FastSlamApp::~FastSlamApp() { }

bool FastSlamApp::checkTangoVersion(JNIEnv *env, jobject caller_activity, int min_tango_version) {
	int version;
	TangoErrorType error = TangoSupport_GetTangoVersion(env, caller_activity, &version);
	return ((error == TANGO_SUCCESS) && (version >= min_tango_version));
}

int FastSlamApp::tangoSetupConfig() {
	tango_config_= TangoService_getConfig(TANGO_CONFIG_DEFAULT);
	if (tango_config_ == nullptr) {
		LOGE("FastSlamApp: Failed to get the default config form.");
		return TANGO_ERROR;
	}

	int ret = TangoConfig_setBool(tango_config_, "config_enable_auto_recovery", true);
	if (ret != TANGO_SUCCESS) {
		LOGE(
				"FastSlamApp: config_enable_auto_recovery() failed with error"
						"Code: %d",
				ret);
		return ret;
	}
}