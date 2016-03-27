#include "include/fast_slam_app.hpp"

void onPoseAvailableRouter(void* context, const TangoPoseData* pose) {
	FastSlamApp* app = static_cast<FastSlamApp*> (context);
	app->onPoseAvailable(pose);
}

FastSlamApp::FastSlamApp() { }

FastSlamApp::~FastSlamApp() {
	if (tango_config_ != nullptr) {
		TangoConfig_free(tango_config_);
	}
}

bool FastSlamApp::checkTangoVersion(JNIEnv *env, jobject caller_activity, int min_tango_version) {
	int version;
	TangoErrorType errorType = TangoSupport_GetTangoVersion(env, caller_activity, &version);
	return ((errorType == TANGO_SUCCESS) && (version >= min_tango_version));
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
	TangoErrorType errorType = TangoService_connect(this, tango_config_);
	if (errorType != TANGO_SUCCESS) {
		LOGE(
				"FastSlamApp: Failed to connect to the "
				"Tango service with error code: %d",
				static_cast<int> (errorType));
		return false;
	}

	errorType = updateExtrinsic();
	if (errorType != TANGO_SUCCESS) {
		LOGE(
				"FastSlamAPp: Failed to query sensor "
				"extrinsic with error code: %d",
				 errorType);
		return false;
	}

	return true;
}

void FastSlamApp::tangoDisconnect() {
	// When disconnecting from the Tango Service,
	// it is important to make sure to free your
	// configuration object. Note that disconnecting
	// from the service, resets all configuration,
	// and disconnects all callbacks. If an application
	// resumes after disconnecting, it must re-register
	// configuration and callbacks with the service.
	TangoConfig_free(tango_config_);
	tango_config_ = nullptr;
	TangoService_disconnect();
}

void FastSlamApp::onPoseAvailable(const TangoPoseData* pose) {
	lock_guard<mutex> lock(pose_mutex_);
	pose_data_.updatePose(pose);
}

TangoErrorType FastSlamApp::updateExtrinsic() {
	TangoErrorType errorType;
	TangoPoseData pose_data;
	TangoCoordinateFramePair frame_pair;

	// TangoService_getPoseAtTime function is used for
	// query device extrinsics as well. We use timestamp
	// 0.0 and the target frame pair to get the extrinsics
	// from the sensors.
	//
	// Get device with respect to imu transformation matrix.
	frame_pair.base = TANGO_COORDINATE_FRAME_IMU;
	frame_pair.target = TANGO_COORDINATE_FRAME_DEVICE;
	errorType = TangoService_getPoseAtTime(0.0, frame_pair, &pose_data);
	if (errorType != TANGO_SUCCESS) {
		LOGE(
				"FastSlamSpp: Failed to get transform between "
				"the IMU frame and the device frames.");
		return errorType;
	}
	pose_data_.setImuDevice(pose_data_.getMatrixFromPose(pose_data));

	// Get color camera with respect to imu transformation matrix.
	frame_pair.base = TANGO_COORDINATE_FRAME_IMU;
	frame_pair.target = TANGO_COORDINATE_FRAME_CAMERA_DEPTH;
	errorType = TangoService_getPoseAtTime(0.0, frame_pair, &pose_data);
	if (errorType != TANGO_SUCCESS) {
		LOGE(
				"FastSlamApp: Failed to get transform between "
				"the color camera frame and device frames.");
		return errorType;
	}

	pose_data_.setImuDepthCamera(pose_data_.getMatrixFromPose(pose_data));
	return errorType;
}
