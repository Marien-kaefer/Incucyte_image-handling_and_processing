/*
Macro to Segment cells in phase contract channel and count cells per frame. Then the same regions of interest are used to measure the intensity of red fluorescence to calculate the fraction of dead cells in the field of view.   

INSTRUCTIONS: 
Open a phase contrast stack (e.g. created with the Incucyte_create_stack_apply_calibration_save.ijm macro) and corresponding fluorescence stack and hit "run" below. 

												- Written by Marie Held [mheldb@liverpool.ac.uk] February 2023
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

FileList = getList("image.titles");
//Array.print(FileList);
threshold_list = newArray("Default", "Huang","Intermodes","IsoData","IJ_IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen");
binary_choice = newArray("Yes", "No");

title = "Files and Parameters";
Dialog.create("Calibration Dialog");
Dialog.addChoice("Phase contrast stack", FileList);
Dialog.addChoice("Fluorescence stack", FileList);
Dialog.addNumber("Mean filter size radius", 1);
Dialog.addNumber("Bandpass filter - filter small structures up to (px)", 10);
Dialog.addNumber("Bandpass filter - filter large structures down to (px)", 100);
Dialog.addNumber("Minimum size threshold (um^2 for calibrated images)", 50);
Dialog.addNumber("Maximum size threshold (um^2 for calibrated images)", 5000);
Dialog.addChoice("Global Threshold algorithm", threshold_list, "Default") 
Dialog.addRadioButtonGroup("Separate touching objects via watershed?", binary_choice, 1, 2, "Yes");
Dialog.addMessage("The lower threshold should be determined for the condition that yields the brightest fluorescent signal \n and then used for all images from the same dataset.");
Dialog.addNumber("Lower Threshold", 50);
Dialog.addNumber("Upper Threshold", 65535);
Dialog.show();

phaseStack = Dialog.getChoice();
fluorescenceStack = Dialog.getChoice();
mean_filter_size = Dialog.getNumber();
bandpass_small_structure_filter = Dialog.getNumber();
bandpass_large_structure_filter = Dialog.getNumber();
minimum_size_threshold = Dialog.getNumber();
maximum_size_threshold = Dialog.getNumber();
threshold_algorithm = Dialog.getChoice();
watershed_selection = Dialog.getRadioButton() ; 
fluorescence_lower_threshold = Dialog.getNumber();
fluorescence_upper_threshold = Dialog.getNumber();

selectWindow(phaseStack);
phaseStack = file_name_remove_extension(phaseStack); //remove extension from image title
rename(phaseStack); 
selectWindow(fluorescenceStack); 
fluorescenceStack = file_name_remove_extension(fluorescenceStack); 
rename(fluorescenceStack); 
phaseMaskStack = phaseStack + "-mask-stack"; 
BG_removed_stack = fluorescenceStack + "-BG-removed";
fluorescenseMaskStack = fluorescenceStack + "-mask-stack"; 
directory_path = getDirectory("image");	//get directory path of image and use that later as direcoty for output files


// list of functions processing the image
phase_segmentation_and_count(phaseStack, mean_filter_size, bandpass_large_structure_filter, bandpass_small_structure_filter, threshold_algorithm, phaseMaskStack, watershed_selection, directory_path, minimum_size_threshold, maximum_size_threshold);
background_removal(fluorescenceStack, BG_removed_stack);
measure_fluorescence_in_phase_ROIs(phaseMaskStack, BG_removed_stack,minimum_size_threshold); 
threshold_preprocessed_fluorescence_channel(BG_removed_stack,fluorescence_lower_threshold,fluorescence_upper_threshold,minimum_size_threshold); 
assemble_final_hyperstack(phaseStack, fluorescenceStack, phaseMaskStack, BG_removed_stack, fluorescenseMaskStack, directory_path);
clean_up();


// functions
function phase_segmentation_and_count(phaseStack, mean_filter_size, bandpass_large_structure_filter, bandpass_small_structure_filter, threshold_algorithm, phaseMaskStack, watershed_selection, directory_path, minimum_size_threshold, maximum_size_threshold){
	selectWindow(phaseStack); 	
	run("Duplicate...", "duplicate");
	run("Mean...", "radius=" + mean_filter_size + " stack");
	run("Bandpass Filter...", "filter_large=" + bandpass_large_structure_filter + " filter_small=" + bandpass_small_structure_filter + " suppress=None tolerance=5 autoscale saturate process");
	setAutoThreshold(threshold_algorithm + " no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=" + threshold_algorithm + " background=Light calculate black");
	if (watershed_selection == "Split objects via Watershed") {
		run("Watershed", "stack");
	}
	//saveAs("Tiff", direcory_path + File.separator + originalTitleWithoutExtension + "_masks.tif");
	rename(phaseMaskStack);
	run("Set Measurements...", "  redirect=None decimal=3");
	run("Analyze Particles...", "size=" + minimum_size_threshold + "-" + maximum_size_threshold + " clear summarize add stack");
	// to run on one image only
	//run("Analyze Particles...", "size=50.00-Infinity clear summarize add");
	
	IJ.renameResults(phaseStack + "-Results");
	saveAs("Results", directory_path + File.separator + phaseStack + "_cell-counts.csv");
	close(phaseStack + "_cell-counts.csv"); 
	roiManager("reset");
	run("Select None");
}

function background_removal(fluorescenceStack, BG_removed_stack){
	run("Set Measurements...", "mean modal redirect=None decimal=3");
	//selectWindow(fluorescenceStack);	
	//run("Plot Z-axis Profile");
	selectWindow(fluorescenceStack);	
	run("Subtract Background...", "rolling=5 stack");
	run("Duplicate...", "duplicate"); 
	BG_removed_stack = fluorescenceStack + "-BG-removed";
	rename(BG_removed_stack);
	run("Median...", "radius=1 stack");
	resetMinAndMax;
	//run("Plot Z-axis Profile");
	run("Clear Results");
	close("Results"); 

}


function measure_fluorescence_in_phase_ROIs(phaseMaskStack, BG_removed_stack,minimum_size_threshold){
	selectWindow(phaseMaskStack); 
	getDimensions(width, height, channels, slices, frames);
	run("Set Measurements...", "mean standard modal min integrated median skewness kurtosis display redirect=None decimal=3");

	for (i = 1; i <= nSlices; i++) {	
		selectWindow(phaseMaskStack);
		setSlice(i); 
		run("Analyze Particles...", "size=" + minimum_size_threshold + "-" + maximum_size_threshold + " add");
		selectWindow(BG_removed_stack);
		setSlice(i); 
		roiManager("multi-measure append");
		roiManager("reset"); 
		selectWindow(phaseMaskStack);
		roiManager("Show None");
		run("Select None"); 
	}
	saveAs("Results", directory_path + File.separator + fluorescenceStack + "_intensity-measurements.csv");
}

function threshold_preprocessed_fluorescence_channel(BG_removed_stack, fluorescence_lower_threshold, fluorescence_upper_threshold,minimum_size_threshold){
	selectWindow(BG_removed_stack); 
	getDimensions(width, height, channels, slices, frames);
	setOption("BlackBackground", true);
	setThreshold(fluorescence_lower_threshold, fluorescence_upper_threshold, "raw");
	run("Convert to Mask", "background=Dark black create");
	rename(fluorescenseMaskStack); 
	run("Set Measurements...", "  redirect=None decimal=3");
	run("Analyze Particles...", "size=" + minimum_size_threshold + "-" + maximum_size_threshold + " clear summarize add stack");
	saveAs("Results", directory_path + File.separator + fluorescenceStack + "_fluorescence-cell-counts.csv");
	close(fluorescenceStack + "_fluorescence-cell-counts.csv"); 
}

function assemble_final_hyperstack(phaseStack, fluorescenceStack, phaseMaskStack, BG_removed_stack,fluorescenseMaskStack, directory_path){
	selectWindow(phaseStack); 
	resetMinAndMax;
	BitDepthOfImage = bitDepth();
	if (BitDepthOfImage != "16"){ 
			run("16-bit");
	}
	selectWindow(BG_removed_stack); 
	resetMinAndMax; 
	BitDepthOfImage = bitDepth();
	if (BitDepthOfImage != "16"){ 
			run("16-bit");
	}
	selectWindow(phaseMaskStack); 
	run("16-bit");
	selectWindow(fluorescenseMaskStack);
	run("16-bit");
	run("Merge Channels...", "c1=" + phaseStack + " c2=" + fluorescenceStack +" c3=" + phaseMaskStack + " c4=" + BG_removed_stack + " c5=" + fluorescenseMaskStack + " create");
	setSlice(1); 
	run("Grays");
	resetMinAndMax; 
	setSlice(2);
	run("Magenta"); 
	resetMinAndMax; 
	setSlice(3); 
	run("Cyan"); 
	//run("Brightness/Contrast...");
	setMinAndMax(0, 2000);
	setSlice(4); 
	run("Grays"); 
	resetMinAndMax; 
	setSlice(5);
	run("Magenta"); 
	setMinAndMax(0, 2000);
	saveAs("TIFF", directory_path + File.separator + phaseStack + "-overlay.tif");
}

function file_name_remove_extension(originalTitle){
	dotIndex = lastIndexOf(originalTitle, "." ); 
	file_name_without_extension = substring(originalTitle, 0, dotIndex );
	//print( "Name without extension: " + file_name_without_extension );
	return file_name_without_extension;
}

//clean up: close results window, close image window
function clean_up(){
	run("Fresh Start");
}