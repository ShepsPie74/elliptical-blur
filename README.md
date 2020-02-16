# elliptical-blur

This MATLAB program induces noise in an .mp4 video file such that the elliptical ROI is intact and a selected

DCT noise [ bulkBlurring_dct.m ], or

Gaussian noise [bulkBlurring_gauss.m].

The position of the ROI is a 1x4 double array, which can be acquired by the following steps:
1) In the command window create a video object. 

        ipVidFile = VideoReader('Enter video directory here');
        
2) Read the first frame for reference

        im = readFrame(ipVidFile);
        
3) Show the frame and draw the ellipse on the top left corner

        h = imshow(frame);
        
        e = imellipse(gca, [0 0 200 200]);
        
4) Drag the Ellipse to your desired location, change the dimensions to your liking.

5) Right Click and Copy Position.

6) Paste the position in the "pos" array in the code.
