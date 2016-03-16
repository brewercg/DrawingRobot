#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include "mex.h" //matlab libraries
#include "matrix.h"

using namespace cv;
using namespace std;

	/* This program gets the minimum number of 
	contours in the source image and sends them to matlab*/

	Mat src; Mat src_gray; Mat canny_output;
	RNG rng(12345);
	vector<vector<Point> > contours;
	vector<Vec4i> hierarchy;


	//returns the number of separate contours found for the given filter setting
	int find_ncontours(int number)
	{
		Mat canny_output;
		vector<vector<Point> > contours;
		vector<Vec4i> hierarchy;

		/// Detect edges using canny
		Canny(src_gray, canny_output, number, number * 2, 3);
		/// Find contours
		findContours(canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_TC89_KCOS, Point(0, 0));

		return contours.size();
	}

	/** MATLAB entry point */
	void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
	{

		VideoCapture cam(0);		// open webcam

		//exit if no camera
		if (!cam.isOpened())
		{
			mexErrMsgTxt( "Could not open camera!\n");
		}

		//get a frame
		cam >> src;	// capture a frame
		src = src(Range(40, 380), Range(120, 540)); //crop image to get rid of page edges
		
		/// Convert image to gray and blur it
		cvtColor(src, src_gray, CV_BGR2GRAY);
		blur(src_gray, src_gray, Size(3, 3));

		/* Sweep through canny filter threshold settings to find the 
		   one that gives the least number of contours.*/
		int min_contours = 50;
		int current_contours;
		int min_setting = 0;
		for (int i = 0; i < 100; i++){
			current_contours = find_ncontours(i);
			if (current_contours < min_contours && current_contours > 0){
				min_setting = i; // keep track of best setting
				min_contours = current_contours; // keep track of least contours
			}
		}

		mexPrintf("Minimum setting: %i\n",  min_setting);
		mexPrintf("Minimum # contours: %i\n",min_contours);

		/// Create Window
		char* source_window = "Source";
		namedWindow(source_window, CV_WINDOW_AUTOSIZE);
		imshow(source_window, src);


		// Use previously determined best settings to get contours
		/// Detect edges using canny
		Canny(src_gray, canny_output, min_setting, min_setting * 2, 3);
		/// Find contours
		findContours(canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_TC89_KCOS, Point(0, 0));

		/// Draw contours
		Mat drawing = Mat::zeros(canny_output.size(), CV_8UC3);
		for (int i = 0; i< contours.size(); i++)
		{
			Scalar color = Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255));
			drawContours(drawing, contours, i, color, 2, 8, hierarchy, 0, Point());
		}

		/// Show in a window
		namedWindow("Contours", CV_WINDOW_AUTOSIZE);
		imshow("Contours", drawing);

		int Size = 0;
		
		// Get total size of all contours laid end-to-end
		for (int j = 0; j < contours.size(); j++) {
				Size = Size + contours[j].size();
		}

		//Data that will be sent to MATLAB must be in dynamic memory (required by MEX API)
		const int ARRAY_SIZE = Size; // number of points in array, NOT the total number of elements!
		UINT16_T *dynamicData;
		dynamicData = (UINT16_T *)mxCalloc(ARRAY_SIZE*2, sizeof(UINT16_T));
		

		int index2 = 0; // track where last contour ended

		/*populate dynamically allocated array with contours in 
		Column-major format*/
		
		// add x-values of each point in all contours
		for (mwSize contour = 0; contour < contours.size(); contour++){

			for (mwSize index = 0; index < contours[contour].size(); index++){
				dynamicData[index + index2] = contours[contour][index].x;
			}
			index2 += 1 + contours[contour].size();
		}

		// add y-values
		index2 = ARRAY_SIZE;
		for (mwSize contour = 0; contour < contours.size(); contour++){

			for (mwSize index = 0; index < contours[contour].size(); index++){
				dynamicData[index + index2] = contours[contour][index].y;
			}
			index2 += 1 + contours[contour].size();
		}
		

		plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT16_CLASS, mxREAL);

		// copy the data to the output array
		mxSetData(plhs[0], dynamicData); //copy data
		mxSetM(plhs[0], ARRAY_SIZE); //set number of rows
		mxSetN(plhs[0], 2); //set number of columns

		return;
		
}
