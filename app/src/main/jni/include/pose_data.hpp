#ifndef EECS_568_POSE_DATA_HPP
#define EECS_568_POSE_DATA_HPP

#include <jni.h>
#include <mutex>
#include <string>

#include <tango_client_api.h>
#include <tango-gl/conversions.h>
#include <tango-gl/util.h>

using namespace glm;
using namespace std;

class PoseData {
public:
	PoseData();
	~PoseData();

	// Update current pose and previous pose.
	//
	// @param pose: pose data of current frame.
	void updatePose(const TangoPoseData *pose);

	// Get latest pose in matrix format
	// with extrinsics in OpenGl space.
	//
	// @return: latest pose in matrix format.
	mat4 getLatestPoseMatrix();

	// @return: device frame with
	// respect to IMU frame matrix.
	mat4 getImuDevice() { return imu_device_; }

	// Set device frame with respect to IMU frame matrix.
	// @param: imu_device, imu_T_device_ matrix.
	void setImuDevice(const mat4 & imu_device) {
		imu_device_ = imu_device;
	}

	// @return: depth camera frame with respect to IMU frame.
	mat4 getImuDepthCamera() { return imu_depth_camera_; }

	// Set depth camera frame with respect to IMU frame matrix.
	// @param: imu_color_camera, imu_T_color_camera_ matrix.
	void setImuDepthCamera(const mat4& imu_depth_camera) {
		imu_depth_camera_ = imu_depth_camera;
	}

	// Get pose transformation in OpenGL coordinate
	// system. This function also applies sensor
	// extrinsics transformation to the current pose.
	//
	// @param: pose, pose to be converted to matrix.
	//
	// @return: corresponding matrix of the pose data.
	mat4 getMatrixFromPose(const TangoPoseData& pose);

	// Apply extrinsics and coordinate frame transformations
	// to the matrix. This funciton will transform the passed
	// in matrix into opengl world frame.
	mat4 getExtrinsicsAppliedOpenGLWorldFrame(const mat4 pose_matrix);

private:
	string getStringFromStatusCode(TangoPoseStatusType status);

	// Format the pose debug string based on
	// current pose and previous pose data.
	mat4 imu_device_;

	// Color camera frame with respect to IMU frame.
	mat4 imu_depth_camera_;

	// Pose data of current frame.
	TangoPoseData current_pose_;
};

#endif //EECS_568_POSE_DATA_HPP
