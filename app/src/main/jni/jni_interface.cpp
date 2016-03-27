#include <jni.h>
#include "include/fast_slam_app.hpp"

static FastSlamApp app;

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_checkTangoVersion(
		JNIEnv *env, jclass type, jobject activity, jint min_tango_version) {
	return static_cast<jboolean> (app.checkTangoVersion(env, activity, min_tango_version));
}

JNIEXPORT jint JNICALL
Java_edu_umich_eecs_robotics_slam_Native_setupConfig(
		JNIEnv *env, jclass type, jobject activity) {
	return static_cast<jint> (app.tangoSetupConfig());
}

JNIEXPORT jint JNICALL
Java_edu_umich_eecs_robotics_slam_Native_connectCallbacks(
		JNIEnv *env, jclass type, jobject activity) {
	return static_cast<jint> (app.tangoConnectCallbacks());
}

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_connect(
		JNIEnv *env, jclass type, jobject activity) {
	return static_cast<jboolean> (app.tangoConnect());
}

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_disconnect(
		JNIEnv *env, jclass type, jobject activity) {
	app.tangoDisconnect();
}

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_onSurfaceCreated(
		JNIEnv *env, jclass type, jobject activity) {
	app.initializeOpenGLContent();
}

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_onSurfaceChanged(
		JNIEnv *env, jclass type, jobject activity, jint width, jint height) {
	app.setupViewPort(static_cast<int> (width), static_cast<int> (height));
}

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_onDrawFrame(
		JNIEnv *env, jclass type, jobject activity) {
	app.render();
}

JNIEXPORT void JNICALL
Java_edu_umich_eecs_robotics_slam_Native_setCameraType(
		JNIEnv *env, jclass type, jobject activity, jint camera_index) {
	GestureCamera::CameraType cam_type = static_cast<GestureCamera::CameraType>(camera_index);
	app.setCameraType(cam_type);
}

JNIEXPORT jboolean JNICALL
Java_edu_umich_eecs_robotics_slam_Native_deleteResources(
		JNIEnv *env, jclass type, jobject activity) {
	app.deleteResources();
}

JNIEXPORT void JNICALL
Java_edu_umich_eecs_robotics_slam_Native_onTouchEvent(
		JNIEnv*, jobject, jclass type, jobject activity,
		jint touch_count, jint event, jfloat x0, jfloat y0, jfloat x1, jfloat y1) {
	GestureCamera::TouchEvent touch_event = static_cast<GestureCamera::TouchEvent>(event);
	app.onTouchEvent(
			static_cast<int> (touch_count),
			touch_event,
			static_cast<float> (x0),
			static_cast<float> (y0),
			static_cast<float> (x1),
			static_cast<float> (y1));
}

#ifdef __cplusplus
};
#endif
