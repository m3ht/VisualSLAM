#include <string.h>
#include <jni.h>

extern "C" {
	JNIEXPORT jstring JNICALL
	Java_edu_umich_eecs_robotics_slam_MainActivity_stringFromJNI(JNIEnv *env, jobject instance) {
		return env->NewStringUTF("Hello World!");
	}
}