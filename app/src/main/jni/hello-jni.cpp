#include <jni.h>

#include <iostream>
#include <sstream>
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

extern "C" {
	JNIEXPORT jstring JNICALL
	Java_edu_umich_eecs_robotics_slam_MainActivity_stringFromJNI(JNIEnv *env, jobject instance) {
		MatrixXd matrix(2, 2);
		matrix(0, 0) = 1;
		matrix(0, 1) = 2;
		matrix(1, 0) = 3;
		matrix(1, 1) = 4;
		stringstream ss;
		ss << "Hello Eigen3! A Matrix: " << matrix << endl;
		return env->NewStringUTF(ss.str().c_str());
	}
}