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

void Scene::render(const mat4& current_pose_transformation) {
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);

	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);

	vec3 position = vec3(
			current_pose_transformation[3][0],
			current_pose_transformation[3][1],
			current_pose_transformation[3][2]);

	if (gesture_camera_->GetCameraType() == GestureCamera::CameraType::kFirstPerson) {
		// In first person mode, we directly control camera's motion.
		gesture_camera_->SetTransformationMatrix(current_pose_transformation);
	}
	else {
		// In third person or top down more, we follow the camera movement.
		gesture_camera_->SetAnchorPosition(position);

		frustum_->SetTransformationMatrix(current_pose_transformation);

		// Set the frustum scale to 4:3,
		// this doesn't necessarily match
		// the physical camera's aspect
		// ratio, but this is just for
		// visualization purposes.
		frustum_->SetScale(kFrustumScale);
		frustum_->Render(
				gesture_camera_->GetProjectionMatrix(),
				gesture_camera_->GetViewMatrix());

		axis_->SetTransformationMatrix(current_pose_transformation);
		axis_->Render(
				gesture_camera_->GetProjectionMatrix(),
				gesture_camera_->GetViewMatrix());
	}

	trace_->UpdateVertexArray(position);
	trace_->Render(
			gesture_camera_->GetProjectionMatrix(),
			gesture_camera_->GetViewMatrix());

	grid_->Render(
			gesture_camera_->GetProjectionMatrix(),
			gesture_camera_->GetViewMatrix());
}

void Scene::setCameraType(GestureCamera::CameraType camera_type) {
	gesture_camera_->SetCameraType(camera_type);
}

void Scene::onTouchEvent(
		int touch_count,
		GestureCamera::TouchEvent event,
		float x0, float y0,
		float x1, float y1) {
	gesture_camera_->OnTouchEvent(touch_count, event, x0, y0, x1, y1);
}


