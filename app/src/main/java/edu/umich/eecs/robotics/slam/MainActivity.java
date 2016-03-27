package edu.umich.eecs.robotics.slam;

import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {
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
		// Disconnect from the Tango Service,
		// and release all the resources that
		// the app is holding from the Tango
		// Service.
		if (mIsConnectedService) {
			Native.disconnect();
			mIsConnectedService = false;
		}
	}
}
