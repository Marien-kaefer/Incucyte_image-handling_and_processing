/*
Macro to generate a time series stack from individual images exported from an Incucyte. Select images from one channel only. Image scaling is applied automatically via drop down menu of magnification selection. Option to convert to 16 bit. 

INSTRUCTIONS: 
Open all images to be included into one stack by selecting them all in the file explorer and dragging them onto the main Fiji window. Then hit "Run" below. 

												- Written by Marie Held [mheldb@liverpool.ac.uk] February 2024
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

input = getDirectory("Input folder for images");
output = input + File.separator + "Stacks"; 
File.makeDirectory(output); 

title = "Parameters";
magnifications = newArray("4x", "10x", "20x");
Dialog.create("Calibration Dialog");
Dialog.addChoice("Magnification:", magnifications);
Dialog.addNumber("Interval at which the series was taken (min)", 60);
Dialog.addNumber("Number of wells imaged", 6);
Dialog.addNumber("Images per well", 5);
Dialog.addNumber("Number of time points imaged", 20);
Dialog.addCheckbox("Convert to 16-bit", false);


Dialog.show();
magnification = Dialog.getChoice();
interval = Dialog.getNumber();
number_of_wells = Dialog.getNumber();
number_of_images_per_well = Dialog.getNumber();
number_of_time_points = Dialog.getNumber();
BitDepthConversionOption = Dialog.getCheckbox();
total_number_of_files_to_be_processed = number_of_wells * number_of_images_per_well * number_of_time_points;


if (magnification == "4x") {
	xy = 2.82;
}
if (magnification == "10x"){
	xy = 1.24;
}
if (magnification == "20x"){
	xy = 0.62;
}


list = getFileList(input);
list = Array.sort(list);
Array.print(list); 

start_image = 1; 
for (k = 1; k < (number_of_wells + 1);  k++) {
	print("k: " + k); 
	for (i = 1; i < (number_of_images_per_well + 1); i++) {
		//print("i: " + i); 
		//start_image = (k * i * number_of_time_points - number_of_time_points + 1); 
		print("start image: " +  start_image); 
		
		open(input + list[start_image-1]); 
		originalTitle = getTitle();
		//print(originalTitle); 
		BaseTitleLastIndex = lengthOf(originalTitle) - 14;
		baseTitle = substring(originalTitle, 0, BaseTitleLastIndex); 
		print("Stack being created:" + baseTitle); 
		close(); 
		
		if (number_of_images_per_well < 10) {
			File.openSequence(input, "filter=tif start=" + start_image + " step=1 count=" + number_of_time_points + " virtual");
		}
		if (number_of_images_per_well >= 10) {
			for (n = 0; n < number_of_time_points ; n++) {
				//print("Image number to be opened: " + (start_image + n - 1)); 
				open(input + list[(start_image + n - 1)]); 
			}
		run("Images to Stack", "use");
		}
		
		rename(baseTitle); 
		resetMinAndMax;
		BitDepthOfImage = bitDepth();
		if (BitDepthConversionOption == true && BitDepthOfImage != "16"){ 
			run("16-bit");
		}
		getDimensions(width, height, channels, slices, frames);
		Stack.setXUnit("micron");
		run("Properties...", "channels=1 slices=1 frames=" + slices + " pixel_width=" + xy + " pixel_height=" + xy + " voxel_depth=0 frame=[" + interval + " min]");
		saveAs("Tiff", output +File.separator + baseTitle + "-stack.tif");
		close(); 
		start_image += number_of_time_points;  
	} 
}
print("Done!"); 
