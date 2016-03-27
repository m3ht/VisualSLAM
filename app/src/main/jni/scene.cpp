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

void Scene::deleteResources() {
	delete gesture_camera_;
	delete axis_;
	delete frustum_;
	delete trace_;
	delete grid_;
}

void Scene::setupViewPort(int width, int height) {
	if (height == 0) {
		LOGE("Setup graphic height not valid.");
	}
	gesture_camera_->SetAspectRatio(static_cast<float>(width) / static_cast<float>(height));
	glViewport(0, 0, width, height);
}


