#ifndef EECS_568_FAST_SLAM_APP_HPP
#define EECS_568_FAST_SLAM_APP_HPP

#include <jni.h>
#include <mutex>

#include <tango_client_api.h>
#include <tango_support_api.h>
#include <tango-gl/util.h>

#include "include/pose_data.hpp"
#include "include/scene.hpp"

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

	// Allocate OpenGL resources for rendering,
	// mainly for initializing the Scene.
	void initializeOpenGLContent();

	// Tango service pose callback function for pose
	// data. Called when new information about device
	// pose is available from the Tango Service.
	//
	// @param pose: The current pose returned by
	//              the service, caller allocated.
	void onPoseAvailable(const TangoPoseData* pose);

private:
	// Tango configuration file, this object is
	// for configuring Tango Service setup  before
	// connecting to service. Here, we turn on
	// motion tracking for receiving pose data.
	TangoConfig tango_config_;

	// pose_data_ handles all pose onPoseAvailable
	// callbacks, onPoseAvailable() in this object
	// will be routed to pose_data_ to handle.
	PoseData pose_data_;
	// Mutex for protecting the pose data. The pose
	// data is shared between render thread and
	// TangoService callback thread.
	mutex pose_mutex_;

	// main_scene_ includes all drawable objects
	// for visualizing Tango device's movement.
	Scene main_scene_;

	// Query sensor/camera extrinsic from the Tango
	// Service, the extrinsic is only available after
	// the service is connected.
	//
	// @return: error code.
	TangoErrorType updateExtrinsic();
};

#endif //EECS_568_FAST_SLAM_APP_HPP
