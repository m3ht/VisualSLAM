#ifndef EECS_568_SCENE_HPP
#define EECS_568_SCENE_HPP

#include <jni.h>
#include <memory>
#include <vector>

#include <tango_client_api.h>
#include <tango-gl/axis.h>
#include <tango-gl/camera.h>
#include <tango-gl/color.h>
#include <tango-gl/conversions.h>
#include <tango-gl/gesture_camera.h>
#include <tango-gl/grid.h>
#include <tango-gl/frustum.h>
#include <tango-gl/trace.h>
#include <tango-gl/transform.h>
#include <tango-gl/util.h>

#include "pose_data.hpp"

using namespace glm;
using namespace std;
using namespace tango_gl;

// We want to represent the device properly with respect to the ground so we'll
// add an offset in z to our origin. We'll set this offset to 1.3 meters based
// on the average height of a human standing with a Tango device. This allows us
// to place a grid roughly on the ground for most users.
const vec3 kHeightOffset = glm::vec3(0.0f, 1.3f, 0.0f);

// Color of the motion tracking trajectory.
const Color kTraceColor(0.22f, 0.28f, 0.67f);

// Color of the ground grid.
const Color kGridColor(0.85f, 0.85f, 0.85f);

// Frustum scale.
const vec3 kFrustumScale = glm::vec3(0.4f, 0.3f, 0.5f);

// Scene provides OpenGL drawable objects
// and renders them for visualization.
class Scene {
public:
	Scene();
	~Scene();

	// Allocate OpenGL resources for rendering.
	void initializeOpenGLContent();

	// Release non-OpenGL
	// allocated resources.
	void feleteResources();

	// Setup OpenGL view port.
	void setupViewPort(int width, int height);

	// Render loop.
	// @param: current_pose_transformation,
	//         latest pose transformation.
	// @param: point_cloud_transformation,
	//         pose transformation at point
	//         cloud frame's timestamp.
	// @param: point_cloud_vertices, point
	//         cloud's vertices of the
	//         current point frame.
	void render(
			const mat4& current_pose_transformation,
			const mat4& point_cloud_transformation,
			const vector<float>& point_cloud_vertices);

	// Set the render camera's viewing angle,
	// first person, third person or top down.
	//
	// @param: camera_type: camera type
	//         includes the first person,
	//         third person and top down.
	void setCameraType(GestureCamera::CameraType camera_type);

	// Touch event passed from android activity.
	// This function only support two touches.
	//
	// @param: touch_count, total count for touches.
	// @param: event, touch event of current touch.
	// @param: x0, normalized touch location for touch 0 on x axis.
	// @param: y0, normalized touch location for touch 0 on y axis.
	// @param: x1, normalized touch location for touch 1 on x axis.
	// @param: y1, normalized touch location for touch 1 on y axis.
	void onTouchEvent(
			int touch_count,
			GestureCamera::TouchEvent event,
			float x0, float y0,
			float x1, float y1);

private:
	// Camera object that allows user to use touch input to interact with.
	tango_gl::GestureCamera* gesture_camera_;

	// Device axis (in device frame of reference).
	tango_gl::Axis* axis_;

	// Device frustum.
	tango_gl::Frustum* frustum_;

	// Ground grid.
	tango_gl::Grid* grid_;

	// Trace of pose data.
	tango_gl::Trace* trace_;
};

#endif //EECS_568_SCENE_HPP
