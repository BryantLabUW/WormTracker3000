# WormTracker3000
The ultimate Bryant/Hallem Lab worm tracking software system.

A combination of the Thermotaxis and Chemotaxis trackers, with additional code for custom linear behavioral assays.

In order to function properly, this software requires a specifically formatted excel spreadsheet containing tracking data. The code includes built-in quantifications for 2 general assay categories, each comprised of several built-in types, as well as plotting for custom assays:  

- Thermotaxis assays (i.e. those recorded using the thermotaxis behavioral rig)  
    + Pure Thermotaxis
    + Thermotaxis + Odor (currently not implemented)
    + Isothermal Odor (currently not implemented)
    + Pure Isothermal (currently not implemented)
- Chemotaxis assays (i.e. those recorded using the chemotaxis tracking stations)
    + Bacteria assay (4.9 cm arena)
    + CO2 assay (3.75 cm arena)
    + Pheromone assay (5 cm arena)
    + Odor assay (5 cm arena)
- Custom assays (for plotting tracks with minimal information)
    + Custom linear gradient (square assay)
    
## Required user inputs
Inputs to the worm tracker come in the form of an excel spreadsheet containing an Index tab as well as individual tabs containing the output of the ImageJ/FIJI Manual Tracking plugin, for each worm track on each camera. Example spreadsheets are located in this repository; for a text description of the required elements please see below.  

For tabs containing worm tracks: each tab should be named with the worms Unique ID (often the UID of the experiment followed by a numerical designation matching the Cell Counter track number from ImageJ/FIJI). The results of the tracking plugin should be pasted into the tab such that the two columns that have the values -1 in row 1 are located in Excel columns F and G, and the final column is located in Excel column H. This will ensure that the X/Y coordinates (in pixels) are located in Excel columns D and E, and the frame information is located in Excel column C. 

The index tab must include the following header/value pairs (capitalization matters): 

- For all assays
    - "Number of Worms": number of worms to track. Should be <= number of UIDs
    - "Number of Images": number of images per worm track

The index tab must also include the following labeled columns (capitalization matters):

- "UID": The worms Unique IDs. These much match exactly the names of the tabs. These values are used by Matlab to identify which tabs contain data for importing. 
- "pixels per cm": The pixels per cm conversion rate for the camera system
- For non-thermotaxis assays:
    - "orientation": a logical value (1 or 0) indicating whether the track should be flipped horizontally
- For assays in which two reference points are used for alignment and orientation:  
    - "XL": x-coordinates for left-side reference point (e.g. left gas port or odor centroid)
    - "YL": y-coordinates for left-side reference point (e.g. left gas port or odor centroid)
    - "XR": x-coordinates for right-side reference point (e.g. right gas port or odor centroid)
    - "YR": y-coordinates for right-side reference point (e.g. right gas port or odor centroid)
    - "Alignment distance": distance in cm between left-side and right-side reference points
- For general linear gradients and thermal gradients:  
    - "Low gradient": lowest gradient value in assay
    - "High gradient": greatest gradient value in assay
    - "Distance between": distance between high and low gradient values
    - "Gradient slope": change in gradient per cm
- For thermal gradients:
    - "T(start): temperature worms start at
    - "T(s) XCoord": Landmark coordinate indicating pixel value of T(start) temperature

## Optioanl user inputs
Users may provide an "Overlay" tab that plots experimental events on top of worm tracks. 
The overlay tab should contain the following columns:  

- UID, matching the worm UID the event belongs to)
- Frame, a number that enables the code to locate the X/Y coordinates of the event by indexing the rows of the appropriate UID tab)
- Event, a categorical string. Up to 6 distinct event types are supported.
