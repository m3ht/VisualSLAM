#include "include/scene.hpp"

Scene::Scene() { }

Scene::~Scene() { }

void Scene::initializeOpenGLContent() {
	gesture_camera_ = new GestureCamera();
	axis_ = new Axis();
	frustum_ = new Frustum();
	trace_ = new Trace();
	grid_ = new Grid();

	trace_->SetColor(kTraceColor);
	grid_->SetColor(kGridColor);
	grid_->SetPosition(-kHeightOffset);
	gesture_camera_->SetCameraType(GestureCamera::CameraType::kThirdPerson);
}



