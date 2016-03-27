package edu.umich.eecs.robotics.slam;

import android.opengl.GLSurfaceView;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/**
 * Renderer renders graphic content. This includes
 * the ground grid, the camera frustum, camera axis,
 * and trajectory based on the Tango device's pose.
 */
public class Renderer implements GLSurfaceView.Renderer {
	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		Native.onSurfaceCreated();
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		Native.onSurfaceChanged(width, height);
	}

	@Override
	public void onDrawFrame(GL10 gl) {
		Native.onDrawFrame();
	}
}
