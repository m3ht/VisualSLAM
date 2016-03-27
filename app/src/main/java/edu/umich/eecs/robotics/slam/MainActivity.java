package edu.umich.eecs.robotics.slam;

import android.graphics.Point;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {
	// The minimum Tango Core version required from this application.
	private static final int  MIN_TANGO_CORE_VERSION = 6804;

	// The package name of Tang Core, used for checking minimum Tango Core version.
	private static final String TANGO_PACKAGE_NAME = "com.projecttango.tango";

	// Tag for debug logging.
	private static final String TAG = MainActivity.class.getSimpleName();

	// A flag to check if the Tango Service is
	// connected. This flag avoids the program
	// attempting to disconnect from the service
	// while it is not connected. This is especially
	// important in the onPause() callback for the
	// activity class.
	private boolean mIsConnectedService = false;

	// Screen size for normalizing the touch
	// input for orbiting the render camera.
	private Point mScreenSize = new Point();

	// GLSurfaceView: all of the graphic content is
	// rendered through OpenGL ES 2.0 in native code.
	GLSurfaceView mGLSurfaceView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		mGLSurfaceView = (GLSurfaceView) findViewById(R.id.gl_surface_view);
		if (mGLSurfaceView != null) {
			mGLSurfaceView.setEGLContextClientVersion(2);
			mGLSurfaceView.setRenderer(new Renderer());
		}

		if (!Native.checkTangoVersion(this, MIN_TANGO_CORE_VERSION)) {
			Toast.makeText(this, "The Tango Core is out of date.", Toast.LENGTH_SHORT).show();
			finish();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
		mGLSurfaceView.onResume();
		Native.setupConfig();
		Native.connectCallbacks();

		if (Native.connect()) {
			mIsConnectedService = true;
		}
		else {
			// End the activity and let the user know something went wrong.
			Toast.makeText(this, "Connect Tango Service Error", Toast.LENGTH_LONG).show();
			finish();
		}
	}

	@Override
	protected void onPause() {
		super.onPause();
		mGLSurfaceView.onPause();
		Native.deleteResources();
		// Disconnect from the Tango Service,
		// and release all the resources that
		// the app is holding from the Tango
		// Service.
		if (mIsConnectedService) {
			Native.disconnect();
			mIsConnectedService = false;
		}
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
			case R.id.button_first_person:
				Native.setCameraType(0);
				break;
			case R.id.button_third_person:
				Native.setCameraType(1);
				break;
			case R.id.button_top_down:
				Native.setCameraType(2);
				break;
		}
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		// Pass the touch event to the native layer for camera control.
		// Single touch to rotate the camera around the device.
		// Two fingers to zoom in and out.
		int pointCount = event.getPointerCount();
		if (pointCount == 1) {
			float normalizedX = event.getX(0) / mScreenSize.x;
			float normalizedY = event.getY(0) / mScreenSize.y;
			Native.onTouchEvent(1,
					event.getActionMasked(), normalizedX, normalizedY, 0.0f, 0.0f);
		}
		if (pointCount == 2) {
			if (event.getActionMasked() == MotionEvent.ACTION_POINTER_UP) {
				int index = event.getActionIndex() == 0 ? 1 : 0;
				float normalizedX = event.getX(index) / mScreenSize.x;
				float normalizedY = event.getY(index) / mScreenSize.y;
				Native.onTouchEvent(
						1,
						MotionEvent.ACTION_DOWN,
						normalizedX,
						normalizedY,
						0.0f,
						0.0f);
			} else {
				float normalizedX0 = event.getX(0) / mScreenSize.x;
				float normalizedY0 = event.getY(0) / mScreenSize.y;
				float normalizedX1 = event.getX(1) / mScreenSize.x;
				float normalizedY1 = event.getY(1) / mScreenSize.y;
				Native.onTouchEvent(
						2,
						event.getActionMasked(),
						normalizedX0,
						normalizedY0,
						normalizedX1,
						normalizedY1);
			}
		}
		return true;
	}
}
