package edu.umich.eecs.robotics.slam;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

public class SensorsThread extends Thread implements SensorEventListener {

	private Context mContext;
	private SensorManager mSensorManager;
	private Sensor mSensorAccelerometer;
	private Sensor mSensorGyroscope;
	private Sensor mSensorMagentometer;

	public SensorsThread()

	@Override
	public void onSensorChanged(SensorEvent event) {

	}

	@Override
	public void onAccuracyChanged(Sensor sensor, int accuracy) {

	}
}
