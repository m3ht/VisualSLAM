#include "include/fast_slam_app.hpp"

void onPoseAvailableRouter(void* context, const TangoPoseData* pose) {
	FastSlamApp* app = static_cast<FastSlamApp*> (context);
	app->onPoseAvailable(pose);
}

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
				"FastSlamApp: config_enable_auto_recovery()"
				"failed with error code: %d",
				ret);
		return ret;
	}
}

int FastSlamApp::tangoConnectCallbacks() {
	TangoCoordinateFramePair pairs;
	pairs.base = TANGO_COORDINATE_FRAME_START_OF_SERVICE;
	pairs.target = TANGO_COORDINATE_FRAME_DEVICE;

	int ret = TangoService_connectOnPoseAvailable(1, &pairs, onPoseAvailableRouter);
	if (ret != TANGO_SUCCESS) {
		LOGE(
				"FastSlamApp: Failed to connect to "
				"pose callback with error code: %d",
				ret);
	}

	return ret;
}

bool FastSlamApp::tangoConnect() {
	TangoErrorType error = TangoService_connect(this, tango_config_);
	if (error != TANGO_SUCCESS) {
		LOGE(
				"FastSlamApp: Failed to connect to the "
				"Tango service with error code: %d",
				static_cast<int> (error));
		return JNI_FALSE;
	}
}

void FastSlamApp::onPoseAvailable(const TangoPoseData* pose) {
	// TODO
}
