/*
Macro to Segment cells in phase contract channel and count cells per frame.  

INSTRUCTIONS: 
Open a phase contrast stack (e.g. created with the Incucyte_create_stack_apply_calibration_save.ijm macro) and hit "run" below. 

												- Written by Marie Held [mheldb@liverpool.ac.uk] January 2023
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

#@ String (label = "Mean filter size", value = 1, persist=true) mean_filter_size
#@ String (label = "Bandpass filter - filter small structures up to (px) ", value = 10, persist=true) bandpass_small_structure_filter
#@ String (label = "Bandpass filter - filter large structures down to (px) ", value = 100, persist=true) bandpass_large_structure_filter
#@ String (choices={"Default", "Huang","Intermodes","IsoData","IJ_IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox") threshold_algorithm
#@ String(choices={"Split objects via Watershed","Do not split objects"}, style="radioButtonHorizontal") watershed_selection
#@ String (label = "Minimum object size to be considered a cell (calibrated unit^2) ", value = 50, persist=true) particle_analyzer_small_structure_filter
#@ String (label = "Maximum object size to be considered a cell (calibrated unit^2) ", value = Infinity, persist=true) particle_analyzer_large_structure_filter

originalTitle = getTitle();
originalTitleWithoutExtension = file_name_remove_extension(originalTitle); //remove extension from image title
direcory_path = getDirectory("image");	//get directory path of image and use that later as directory for output files

run("Mean...", "radius=" + mean_filter_size + " stack");
run("Bandpass Filter...", "filter_large=" + bandpass_large_structure_filter + " filter_small=" + bandpass_small_structure_filter + " suppress=None tolerance=5 autoscale saturate process");
setAutoThreshold(threshold_algorithm + " no-reset");
setOption("BlackBackground", true);
run("Convert to Mask", "method=" + threshold_algorithm + " background=Light calculate black");
if (watershed_selection == "Split objects via Watershed") {
	run("Watershed", "stack");
}

saveAs("Tiff", direcory_path + File.separator + originalTitleWithoutExtension + "_masks.tif");
run("Analyze Particles...", "size=" + particle_analyzer_small_structure_filter + "-" + particle_analyzer_large_structure_filter + " clear summarize add stack");

IJ.renameResults(originalTitleWithoutExtension + "-Results");
saveAs("Results", direcory_path + File.separator + originalTitleWithoutExtension + "_results.csv");
run("Close");
roiManager("reset");
close("ROI Manager");
close("*");

function file_name_remove_extension(originalTitle){
	dotIndex = lastIndexOf(originalTitle, "." ); 
	file_name_without_extension = substring(originalTitle, 0, dotIndex );
	//print( "Name without extension: " + file_name_without_extension );
	return file_name_without_extension;
}

