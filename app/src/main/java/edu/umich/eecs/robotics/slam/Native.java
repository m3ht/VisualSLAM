package edu.umich.eecs.robotics.slam;

public class Native {
	static {
		System.loadLibrary("cpp_fast_slam");
	}

	public static native boolean checkTangoVersion(MainActivity activity, int minTangoVersion);

	public static native int setupConfig();

	public static native int connectCallbacks();
}
