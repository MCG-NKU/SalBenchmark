# SalBenchmark
Salient Object Detection: A Benchmark


The Saliency Benchmark compare, qualitatively and quan- titatively, 42 state-of-the-art 
models(30 salient object detection, 10 fixation prediction, 1 objectness, and 1 baseline) 
over 6challenging datasets for the purpose of benchmarking salient object detection and 
segmentation methods. 


Please refer our project page for the url of each method:
http://mmcheng.net/salobjbenchmark/


This is a sample of the Benchmark.

Table of Contents
=================

- Quick Start
	1.Download and UnZip SalBenchmark.rar.
	2.Install OpenCV (2.0 and 3.0 are both OK).
	3.Run ./Code/matlab/RunAll.m to produce SaliencyMap.
	4.Open ./Code/Demo.sln (Visual Studio 2013).
	5.Press "Ctrl + F5" in release x64(recommend).
	6.OK,you have got all materials.
	
- Introduction
	1. There are tow DataSets named "DataSet1" and "DataSet2" in ./Data Folder.
	2. In the DataSet exist one Folder named "Imgs", which include Source images and
	   correspond Ground Truth. 
	3. You can put your own Dataset using the format above.
	4. If "Quick Start" is finished, You will get a Folder-"Results", which include
	   anything. In this Folder, you can run "DataSet***.m" by Matlab to get all evaluate
	   curve in correspond DataSet. And run the Results.tex, you can get all charts.	
	
- Warning
	You should not put this sample in the Folder using ChineseName.
	