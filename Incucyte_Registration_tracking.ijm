/*
Macro to generate a time series stack from individual images exported from an Incucyte. Select images from one channel only. Image scaling is applied automatically via drop down menu of magnification selection. Option to convert to 16 bit. 

INSTRUCTIONS: 
Open all images to be included into one stack by selecting them all in the file explorer and dragging them onto the main Fiji window. Then hit "Run" below. 

												- Written by Marie Held [mheldb@liverpool.ac.uk] May 2023
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

originalTitle = getTitle();
getVoxelSize(width, height, depth, unit); 
pixel_calibration = width; 
pixel_unit = unit;
originalName = file_name_remove_extension(originalTitle); 
registeredStack = originalName + "-registered"; 
direcory_path = getDirectory("image");

run("Enhance Contrast", "saturated=0.35");
run("Descriptor-based series registration (2d/3d + t)");
//run("Descriptor-based series registration (2d/3d + t)", originalName + " brightness_of=[Interactive ...] approximate_size=[Interactive ...] type_of_detections=[Interactive ...] subpixel_localization=[3-dimensional quadratic fit] transformation_model=[Translation (2d)] number_of_neighbors=6 redundancy=3 significance=3 allowed_error_for_ransac=5 global_optimization=[Consecutive matching of images (no global optimization)] range=5 choose_registration_channel=1 image=[Fuse and display] interpolation=[Linear Interpolation]");
//run("Descriptor-based series registration (2d/3d + t)", originalName + " brightness_of=[Advanced ...] approximate_size=[Advanced ...] type_of_detections=[Minima only] subpixel_localization=[3-dimensional quadratic fit] transformation_model=[Translation (2d)] number_of_neighbors=3 redundancy=1 significance=3 allowed_error_for_ransac=5 global_optimization=[All-to-all matching with range ('reasonable' global optimization)] range=5 choose_registration_channel=1 image=[Fuse and display] interpolation=[Linear Interpolation] detection_sigma=9.4110 threshold=0.0063");
rename(registeredStack); 
run("Z Project...", "projection=[Min Intensity]");
run("Duplicate...", " ");
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setThreshold(1, 65535, "raw");
run("Convert to Mask");
mask = getTitle();

run("Analyze Particles...", "clear add");

selectWindow(registeredStack); 
roiManager("select", 0);
run("Duplicate...", "duplicate");
run("Select None");
run("Enhance Contrast", "saturated=0.35");

getDimensions(width, height, channels, slices, frames);
Stack.setXUnit(pixel_unit);

Dialog.create("What is the time interval at which the series was taken?");
Dialog.addNumber("Interval at which the series was taken (min)", 0);
Dialog.show();
interval = Dialog.getNumber();

run("Properties...", "channels=" + channels + " slices=" + slices + " frames=" + frames + " pixel_width=" + pixel_calibration + " pixel_height=" + pixel_calibration + " voxel_depth=1 frame=[" + interval + " min]");

for (i = 1; i < channels; i++) {
	Stack.setChannel(i);
	//run("Brightness/Contrast...");
	resetMinAndMax();
}


saveAs("Tiff", direcory_path + File.separator + registeredStack + "-cropped.tif");
segmentation_input = getTitle();
segmentation_input_name = file_name_remove_extension(segmentation_input); 
rename(segmentation_input_name); 


close("*"); 
roiManager("reset");

function file_name_remove_extension(originalTitle){
	dotIndex = lastIndexOf(originalTitle, "." ); 
	file_name_without_extension = substring(originalTitle, 0, dotIndex );
	//print( "Name without extension: " + file_name_without_extension );
	return file_name_without_extension;
}