# WormTracker3000 Code Description 
A pseudocode description of WormTracker 3000 functionality.

The WormTracker3000 is the Bryant/Hallem Lab general purpose software for analysis and plotting on worm tracks. This code provides a unified codebase for the analysis and plotting of worm tracks collected during the course of behavioral assays, including: thermotaxis, odor tracking, C02 tracking, etc...

The major elements of the code are as follows: 
1. Load experimental data from an Excel file  
  - Read the 'Index' tab to obtain: 
    - number of worms
    - number of images per worm
    - unique IDs (UIDs) for each worm
    - pixels per cm conversion factor
    - assay-specific parameters
  - For each UID, read the corresponding tab to obtain:
    - frame numbers
    - X and Y coordinates of worm positions
    
2. Preprocess tracks (for each track)
  - Convert pixel coordinates to cm
  - Depending on assay and provided paramters:
    - align track to reference points
    - flip track orientation
    - adjust scaling
    - map cm positions to gradient values

3. Analyze tracks (for each track)
  - For all assays, compute path statistics (*e.g.*, speed, direction)
  - Calculate other parameters based on assay type (*e.g.*, change in temperature, time navigating up/down the gradient, time in chemotaxis zones)
  
4. Generate plots
  - Create visualizations of worm tracks
  - If 'Overlay' tab is provided, annotate plots with experimental events (up to 6 event types)
  
5. Save results
  - Export analyzed data (.xlsx file) and plots (.pdf)