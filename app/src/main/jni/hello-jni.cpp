#include <jni.h>
#include <sstream>
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

extern "C" {
	JNIEXPORT jstring JNICALL
	Java_edu_umich_eecs_robotics_slam_MainActivity_stringFromJNI(JNIEnv *env, jobject instance) {
		MatrixXd m1(2, 2);
		m1(0, 0) = 1;
		m1(0, 1) = 2;
		m1(1, 0) = 3;
		m1(1, 1) = 4;

		MatrixXd m2(2, 2);
		m2(0, 0) = 5;
		m2(0, 1) = 6;
		m2(1, 0) = 7;
		m2(1, 1) = 8;

		stringstream ss;
		ss << "Hello Eigen3! A Matrix: " << m1 * m2 << endl;
		return env->NewStringUTF(ss.str().c_str());
	}
}