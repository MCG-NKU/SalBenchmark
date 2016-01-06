# SalBenchmark
Salient Object Detection: A Benchmark


The Saliency Benchmark compare, qualitatively and quantitatively, 42 state-of-the-art models(30 salient object detection, 10 fixation prediction, 1 objectness, and 1 baseline) over 6 challenging datasets for the purpose of benchmarking salient object detection and segmentation methods. 


Please refer our project page for the url of each method: http://mmcheng.net/salobjbenchmark/


This is a sample code for the Benchmark evaluation.

#Table of Contents
=================

- Quick Start
	1. Download the code from this Git project page: https://github.com/MingMingCheng/SalBenchmark.
	2. Install OpenCV (2.0 and 3.0 are both OK).
	3. Run ./Code/matlab/RunAll.m to produce SaliencyMap.
	4. Open ./Code/Demo.sln (Visual Studio 2013).
	5. Press "Ctrl + F5" in release x64(recommend).
	6. OK,you have got all materials (saliency maps for each image, tables and figures in our paper, etc.).
	
- Noets
	1. There are tow DataSets named "DataSet1" and "DataSet2" in ./Data Folder.
	2. In the DataSet exist one Folder named "Imgs", which include Source images and correspond Ground Truth. 
	3. You can put your own Dataset using the format above.
	4. If "Quick Start" is finished, You will get a Folder-"Results", which include all the results. In this Folder, you can run "DataSet***.m" by Matlab to get all evaluate curve in correspond DataSet. And run the Results.tex, you can get all charts.	
	5. Questions directly related to my source code and project is welcome. Please refer to the project page for detailed contact information. Emails regarding questions like how to install and configure OpenCV will not be replied.
	
- Warning
	1. You should not put this sample in the Folder using ChineseName or name with space.

- The source code is for educational and research use only. If you use any part of the source code, please cite related papers.
	1. Salient Object Detection: A Benchmark, Ali Borji, Ming-Ming Cheng, Huaizu Jiang, Jia Li, IEEE TIP, 2015.
	2. Salient Object Detection: A Survey, Ali Borji, Ming-Ming Cheng, Huaizu Jiang, Jia Li, arXiv eprint, 2014.
	3. Global Contrast based Salient Region Detection. Ming-Ming Cheng, Niloy J. Mitra, Xiaolei Huang, Philip H. S. Torr, Shi-Min Hu. IEEE TPAMI, 2015.
