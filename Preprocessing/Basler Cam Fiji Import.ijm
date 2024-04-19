//User Inputs
call("java.lang.System.gc");
Folderpath="Jaidyn" // Path to data folder that contains subfolders with all the images for a single experimental run
UID="230810_01" // Name of subfolder containing all the images for a single experimental run (e.g. a single worm). Best practice: this folder is a unique ID corresponding to the experiment/worm

// How many frames should be used for background subtraction?
	BackgroundWindowStart="0"
	BackgroundWindowStop="540"

// How many images do you want to process? (This should probably match the total number of images in your experiment, but it doesn't have it.)
	NumImages="540" //number of images to import

// Set the pixels per cm camera scales. You should keep track of this number in your notes. Calculate the number by taking a photo of a ruler using the camera, then measure the pixels in a 1 cm distance in FIJI. 
	// August 2023 settings:
	CamScale="159" //pixels per cm

// What size of grid should be drawn? This is determined by the Calculator tab in the Thermotaxis Worksheets Excel file. You should keep track of this number in your notes
	GridSize="100000" // If set to 100000 this is an arbitrarily large number that ensures grid lines won't be visible for worm tracking where a grid isn't necessary.

// Set the distance in pixels to shift the cameras to align the grid to the edge of the plate. You should keep track of this number in your notes
	Translate="0" // distance in pixels to shift camera images to align grid to edge of plate 

setOption("BlackBackground", true);
//Program Generated Variables
	avgfile= "AVG_" + UID
	filepath="../../Documents/" + Folderpath + "/" + UID + "/"

// Process Camera Images
call("java.lang.System.gc");

		run("Image Sequence...", "dir=["+filepath+ "] number="+NumImages+" sort"); //Import Sequences
		call("java.lang.System.gc");
		run("Rotate... ", "angle=.73 grid=1 interpolation=Bilinear stack");
		makeRectangle(1050, 34, 3612, 3612);
		run("Crop");
		run("Z Project...", "start="+BackgroundWindowStart+ " stop="+BackgroundWindowStop+" projection=[Average Intensity]"); // Take Average of Image Sequence
			call("java.lang.System.gc");
		imageCalculator("Subtract create stack", UID, avgfile); // Subtract Average from Every Image in Stack
			setBatchMode(true); 
				selectWindow(UID); 
				run("Close");
				selectWindow("AVG_"+UID);
				run("Close"); 
			setBatchMode(false); 
			call("java.lang.System.gc");
			run("Flip Horizontally", "stack");
			run("Flip Vertically", "stack");
			call("java.lang.System.gc");
		run("Enhance Contrast", "saturated=0.35 process_all"); //Readjust Contrast
			call("java.lang.System.gc");
		run("Set Scale...", "distance="+CamScale+" known=1 unit=cm"); //Set Scale for Images
		run("Grid...", "grid=Lines area="+GridSize+" color=Cyan"); //Draw Grid
			call("java.lang.System.gc");
		run("Translate...", "x="+Translate+" y=0 interpolation=None stack"); //If necessary, adjust image so grid aligns to edge of gel
			call("java.lang.System.gc");
		run("Save", "save=[../../Documents/" + Folderpath + "/" + UID + "_processed.tif]"); //Save Image
		close();	

call("java.lang.System.gc");
