package edu.umich.eecs.robotics.slam;

public class Native {
	static {
		System.loadLibrary("cpp_fast_slam");
	}

	// Check that the installed version of the Tango API is up to date.
	public static native boolean checkTangoVersion(MainActivity activity, int minTangoVersion);

	// Setup the configuration file of the
	// Tango Service. We are also setting up
	// the auto-recovery option from here.
	public static native int setupConfig();

	// Connect the onPoseAvailable callback.
	public static native int connectCallbacks();
	// Connect to the Tango Service.
	// This function will start the Tango
	// Service pipeline, in this case, it
	// will start Motion Tracking.
	public static native boolean connect();
	// Disconnect from the Tango Service,
	// release all the resources that the
	// app is holding from the Tango Service.
	public static native void disconnect();
}
