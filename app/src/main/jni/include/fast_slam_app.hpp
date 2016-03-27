#ifndef EECS_568_FAST_SLAM_APP_HPP
#define EECS_568_FAST_SLAM_APP_HPP

#include <jni.h>
#include <mutex>

#include <tango_client_api.h>
#include <tango_support_api.h>
#include <tango-gl/util.h>

using namespace std;

class FastSlamApp {
public:
	FastSlamApp();
	~FastSlamApp();

	// Check that the installed version of the Tango API is up to date.
	bool checkTangoVersion(JNIEnv* env, jobject caller_activity, int min_tango_version);

	// Setup the configuration file for the Tango Service.
	int tangoSetupConfig();
	// Connect the onPoseAvailable callback.
	int tangoConnectCallbacks();

	// Connect to Tango Service.
	// This function will start the Tango Service
	// pipeline. So, in this case, it will start
	// Motion Tracking.
	bool tangoConnect();
	// Disconnect from Tango Service, release all
	// the resources that the app is holding from
	// the Tango Service.
	void tangoDisconnect();

	// Tango service pose callback function for pose
	// data. Called when new information about device
	// pose is available from the Tango Service.
	//
	// @param pose: The current pose returned by
	//              the service, caller allocated.
	void onPoseAvailable(const TangoPoseData* pose);

private:
	TangoConfig tango_config_;

	PoseData pose_data_;
	mutex pose_mutex_;
};

#endif //EECS_568_FAST_SLAM_APP_HPP
