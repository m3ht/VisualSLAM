package edu.umich.eecs.robotics.slam;

import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

	private static final int  MIN_TANGO_CORE_VERSION = 6804;

	GLSurfaceView mGLSurfaceView;
	Renderer mRenderer;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		mGLSurfaceView = (GLSurfaceView) findViewById(R.id.gl_surface_view);
		if (mGLSurfaceView != null) {
			mGLSurfaceView.setEGLContextClientVersion(2);
			mRenderer = new Renderer();
			mGLSurfaceView.setRenderer(mRenderer);
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
	}

	@Override
	protected void onPause() {
		super.onPause();
		mGLSurfaceView.onPause();
	}
}
