package edu.umich.eecs.robotics.slam;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.TextView;

import org.jscience.mathematics.number.Real;
import org.jscience.mathematics.vector.DenseMatrix;

public class MainActivity extends AppCompatActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		TextView textView = (TextView) findViewById(R.id.text_view);

		DenseMatrix<Real> m1 = DenseMatrix.valueOf(
				new Real[][] {
						{Real.valueOf(1), Real.valueOf(2)},
						{Real.valueOf(3), Real.valueOf(4)}});
		DenseMatrix<Real> m2 = DenseMatrix.valueOf(
				new Real[][] {
						{Real.valueOf(5), Real.valueOf(6)},
						{Real.valueOf(7), Real.valueOf(8)}});
		textView.setText(m1.times(m2).inverse().toText());
	}
}
