/*
Macro to generate a time series stack from individual images exported from an Incucyte. Image scaling is applied via drop down menu of magnification selection. Option to convert to 16 bit. 

INSTRUCTIONS: 
Open all images to be included into one stack by selecting them all in the file explorer and dragging them onto the main Fiji window. Then hit "Run" below. 

												- Written by Marie Held [mheldb@liverpool.ac.uk] January 2023
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Copyright (c) [2022], [Marie Held {mheldb@liverpool.ac.uk}, Image Analyst Liverpool CCI (https://cci.liverpool.ac.uk/)]

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

title = "Parameters";
magnifications = newArray("5x", "10x", "20x");
Dialog.create("Calibration Dialog");
Dialog.addChoice("Magnification:", magnifications);
Dialog.addCheckbox("Convert to 16-bit", true);
Dialog.show();
magnification = Dialog.getChoice();
BitDepthConversionOption = Dialog.getCheckbox();

if (magnification == "5x") {
	xy = 2.82;
}
if (magnification == "10x"){
	xy = 1.24;
}
if (magnification == "20x"){
	xy = 0.62;
}



originalTitle = getTitle();
//print(originalTitle); 
BaseTitleLastIndex = lengthOf(originalTitle) - 14;
baseTitle = substring(originalTitle, 0, BaseTitleLastIndex); 
//print(baseTitle); 
direcory_path = getDirectory("image");
run("Images to Stack", "use name=" + baseTitle);

resetMinAndMax;
BitDepthOfImage = bitDepth();
if (BitDepthConversionOption == true && BitDepthOfImage != "16"){ 
		run("16-bit");
}
getDimensions(width, height, channels, slices, frames);

Stack.setXUnit("micron");
run("Properties...", "channels=1 slices=1 frames=" + slices + " pixel_width=" + xy + " pixel_height=" + xy + " voxel_depth=0");
saveAs("Tiff", direcory_path + File.separator + baseTitle + "-stack.tif");
