# Incucyte image handling and processing

Automatically process individual images in to time series stacks, including adding the correct calibration depending on used magnification. This applies to an Incucyte S3. 

## Incucyte_create_stack_apply_calibration_save.ijm
* Download .ijm file and open via dragging and dropping into the Fiji main window. The script editor will open automatically. 
* Open all time points of one channel for one image for one well in Fiji (select all in File Explorer and drag first time point into Fiji main window. All files will open). 
* Click “Run” in the script editor. 
* Select the appropriate magnification when prompted and click ok. 
* The macro creates a stack with the correct order of dimensions and the selected calibration applied. The stack is automatically saved in the same folder as the original files. 
* Do this for phase and red fluorescence images
