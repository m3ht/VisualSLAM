#ifndef EECS_568_FAST_SLAM_APP_HPP
#define EECS_568_FAST_SLAM_APP_HPP

#include <jni.h>

#include <tango_client_api.h>
#include <tango_support_api.h>
#include <tango-gl/util.h>

class FastSlamApp {
public:
		FastSlamApp();
		~FastSlamApp();

		bool checkTangoVersion(JNIEnv* env, jobject caller_activity, int min_tango_version);

		int tangoSetupConfig();

private:
		TangoConfig tango_config_;
};


#endif //EECS_568_FAST_SLAM_APP_HPP
