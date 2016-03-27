#include "include/pose_data.hpp"

PoseData::PoseData() { }

PoseData::~PoseData() { }

void PoseData::updatePose(const TangoPoseData *pose) {
	current_pose_ = *pose;
}

mat4 PoseData::getLatestPose() {
	return getMatrixFromPose(current_pose_);
}

mat4 PoseData::getExtrinsicsAppliedOpenGLWorldFrame(const mat4 pose_matrix) {
	// This full multiplication is equal to:
	//   opengl_world_T_opengl_camera =
	//      opengl_world_T_start_service *
	//      start_service_T_device *
	//      device_T_imu *
	//      imu_T_depth_camera *
	//      depth_camera_T_opengl_camera;
	return
			tango_gl::conversions::opengl_world_T_tango_world() *
					pose_matrix *
					inverse(getImuDevice()) *
					getImuDepthCamera() *
					tango_gl::conversions::depth_camera_T_opengl_camera();
}

mat4 PoseData::getMatrixFromPose(const TangoPoseData& pose) {
	vec3 translation = vec3(
			pose.translation[0],
			pose.translation[1],
			pose.translation[2]);
	quat rotation = quat(
			pose.orientation[3],
			pose.orientation[0],
			pose.orientation[1],
			pose.orientation[2]);
	// Convert pose data to vec3 for position and quaternion for orientation.
	return translate(mat4(1.0f), translation) * mat4_cast(rotation);;
}

