

originalTitle = getTitle();
originalTitleWithoutExtension = file_name_remove_extension(originalTitle); //remove extension from image title
direcory_path = getDirectory("image");	//get directory path of image and use that later as direcoty for output files

run("Mean...", "radius=1 stack");
run("Bandpass Filter...", "filter_large=100 filter_small=10 suppress=None tolerance=5 autoscale saturate process");
setAutoThreshold("Default no-reset");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Light calculate black");
run("Watershed", "stack");
saveAs("Tiff", direcory_path + File.separator + originalTitleWithoutExtension + "_masks.tif");
run("Analyze Particles...", "size=50.00-Infinity clear summarize add stack");
//run("Analyze Particles...", "size=50.00-Infinity clear summarize add");

IJ.renameResults(originalTitleWithoutExtension + "-Results");
saveAs("Results", direcory_path + File.separator + originalTitleWithoutExtension + "_results.csv");



function file_name_remove_extension(originalTitle){
	dotIndex = lastIndexOf(originalTitle, "." ); 
	file_name_without_extension = substring(originalTitle, 0, dotIndex );
	//print( "Name without extension: " + file_name_without_extension );
	return file_name_without_extension;
}