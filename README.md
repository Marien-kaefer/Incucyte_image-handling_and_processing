# Incucyte image handling and processing

Automatically process individual images in to time series stacks, including adding the correct calibration depending on used magnification. This applies to an Incucyte S3. 

## Incucyte_create_stack_apply_calibration_save.ijm
* Download .ijm file and open via dragging and dropping into the Fiji main window. The script editor will open automatically. 
* Open all time points of one channel for one image for one well in Fiji (select all in File Explorer and drag first time point into Fiji main window. All files will open). 
* Click “Run” in the script editor. 
* Select the appropriate magnification when prompted and click ok. 
* The macro creates a stack with the correct order of dimensions and the selected calibration applied. The stack is automatically saved in the same folder as the original files. 

## Proliferation.ijm
* Download .ijm file and open via dragging and dropping into the Fiji main window. The script editor will open automatically.
*	Open a phase stack. 
*	Click “Run” in the script editor.
*	The phase contrast stack is segmented and the mask stack is saved automatically in the same folder as the original stack. 


## Proliferation_intensity-measurements.ijm
* Download .ijm file and open via dragging and dropping into the Fiji main window. The script editor will open automatically.
*	Open the corresponding phase and red fluorescence stacks (e.g. created with the above macro). 
*	Click “Run” in the script editor.
*	Select the phase and red stacks from the drop down menu when prompted. 
*	Adjust the minimum and maximum sizes for size filtering objects as required.
*	Enter the minimum threshold value as determined in the intermediate step above. This number should be the same for all files of this plate. 
*	Click ok. 
*	The macro creates (and automatically saves) an overview stack that contains: 
    -	original phase data (converted to 16 bit), 
    - original fluorescence stack, 
    - phase segmentation mask stack, 
    - background removed fluorescence stack, 
    - BG removed fluorescence segmentation mask stack
* 	The macro outputs multiple excel files: 
    - Phase image cell counts: total number of cells per time point in this image of this well
    - Flourescence intensity measurements in phase contrast ROIs
    - Fluorescence cell counts: total number of cells per time point in this image of this well – this cell count depends on the minimum threshold determined from one image and applied throughout all files. 
