# Semi‑automatic macro ImageJ analysis for collagen and fibrosis from biopsies images in BrightField and polarised light

Pierre Delobel september 30th 2021 (pierre.delobel@inrae.fr)

## Copyright

Copyright (C) 2021  Pierre DELOBEL for INRAE

This file is part of the Macro-sirius_polarised-collagen&fibrosis.ijm software. Macro-sirius_polarised-collagen&fibrosis.ijm is free and open source
software, distributed under the GNU General Public License v3 (https://www.gnu.org/licenses/gpl-3.0.en.html).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY (That is the user must be an expert and know what he does); without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for more details.

## Introduction

This Fiji / ImageJ macro aim to help users for calculation of the collagen and fibrosis percentage per area.
It works on whole folder with pictures of picro-Sirius red labeled sections from muscle biopsies.
Images acquisition must be done twice with RGB images Bright Field and Polarised in the same file (6 channels file).  
In order to compare highly variable biopsies, it was decided to retain areas of endomysium only. User is asked to define all areas to be excluded (some sections showed fibrotic perimisium veins, others showed endomysium only).
Results are saved in one csv tab including 1) area of the region of interest, 2) the collagen surface (picro-Sirius red marked) and 3) the fibrosis region, with polarized red due to the modelling of collagen fibers.

The macro allows the user to calculate the % of collagen in the slice and the % of collagen fibrosis from each areas (µm²).

## Operating presentation

### Reusable structure

This macro is structured to be reused. The different parts are well identified, therefore it is possible to change basic function and then perform an analysis macro for another staining. Operations are done in a folder with following steps 1) interactive control of the basic parameters 2) opening and treatment of different channels 3) Interactive crop of the area of interest, 4) Interactive selection of the areas to be excluded,  5) analysis, 6) saving of the Images, 7) saving Log and Results files. 

### Over view

Picro-Sirius red stained slice exerts yellow tissues with red outlines in Bright Field (BF) color pictures due to red fixation on collagens. The same slice with polarised light allow to see ordonated stuctures of collagen that is considered as fibrosis. The larger collagen fibers showed bright yellow or orange staining, and the thinner ones, including reticular fibers, showed green staining. Here, only the red polarised light is used.

The heterogeneity of biopsies sampling led us to consider the endomysium part only. The solution chosen was to insert a user selection action in the semi‑automated analysis to exclude the perimysium, epimysium and others eclused zones.

Figure 1 shows the processing from the two images (BF & Polarised), the interest mask and the analysis result colored. On the mask, it is possible to see the automatic hole detection (black spots) done in LAB space color at the user's discretion (done or not on the entire folder).

![Figure 1: Image processing](data/analyse.png) [Figure 1: Image processing  
A&B part of source image: A) in BrightField, B) in polarized light, C) mask used to retained "section to be analyzed" in white with suppression of the background, D) Spots manually supressed on the perimysium and epimysium zones, and  E) D the representation of the different identified zones (fibrosis: white, collagen: cyan, section: green, background: black). Scale bar represent 500 µm lenght and approximately 5000 µm² thick.

A situation analysis is shown in figure 2 with two conditions control and cuff, before and after a dry immersion of 5 days,  publication in submition "Severe muscle deconditioning triggers early Extra Cellular Matrix remodeling and residents stem cells fate/behavior" Corentin Guilhot 2021.

![Figure 2: An analysed exemple: Control and cuff at pre and DI5](data/ctrl-cuff.png) Figure 2: An analysed exemple: Control and cuff at pre and DI5  
We showed a image zoom on a small part of the section for control (A:F) and cuff (G:L) subjects in pre ( A:C and G:I) and After 5 days of dry immersion DI5 (D:F and J:L). In the order, we represented brightField, Polarized images and the representation of the different areas identified for each stage (white: fibrosis, cyan: collagen, green: section and black: background and exluded zones).

### Default settings

The default settings are written in the macro, so they are changeable in the first lines of the code.
For the macro, default image extention stay ".lif".  
Images must be scales in µm. Filter adjustment used to remove small particles were realize with the following caracteristics:

- 5000 µm² minimal size for tissue section area
- 50 µm² minimal size for collagen detection
- 0 µm², no exclusion, for the minimal size of fibrosis

### User interaction

#### Opening

First, some parameters have to be controlled. An interactive window specifies the extension of the target images and how split image structure into the 6 channels, that is determine colour order of these channels. It is also possible or not to indicate whether applying the black spot correction for the whole folder. This correction is only usefull for whole section with black non numerised parts in the photo montage. If the field shows exclusively tissue, this correction is not useful because the thresholding will not work sufficiently.

Then, user have to choose the processed directory as well as, the results directory where all backups will be saved.

#### For each image

For each image, two steps require user intervention. First, the user must select the area of the slice to reduce the image size. The second step is the addition of the excluded areas to the ROImanager (with "t"), i.e. spots, slice defects and especially endomysium and epimysium parts.

### Automated control

First of all, to avoid deleting previous data or in case of a crash, the "Summary" and "Log" files are saved (addition of "_before_" and macro strating date). 

At the end of the macro, the new "Log" and "Summary" files are saved with the starting date. 

### Log file control

The basic information and track of the program's progress are saved in the "log" file, which is frequently saved.
Log file contains the following data: 

- analyzed folder path
- results folder path
- Analysis starting date
- Excluding parameters: 
    - Minimum size of the section parts: 5000 µm²
    - Minimum size of collagen parts: 50 µm²
    - Minimum size of fibrosis parts: 0 µm² (no exclusion)


After this generals informations, image specific information are specified:

- original image name processing 
- title of the last opened image (getTitle) corresponding to the name of the image opened with the specified channel.
- start indication of the "zone of interest" (ZoI) function on the image name
- selection informations x, y, width, height to be able to do the cutting again (crop function)
- Threshold type applied for collagen analysis 

### Image treatement

### Images openning and slice selection

Images are open and split with "Bio-Formats Importer" (Linkert et al., 2010). The 6 separate channels allow the reconstruction of the BF and polarised images as RGB with "Merge Channels..." for user visualisation. Channels are keep opened for analyse.
	
### Black spots

Black spots elimination has be processed on the RGB images after reduction ("run("Scale...", "x=0.5 y=0.5 ...)"), the image is cleaned by "run("Despeckle")" then a thresholding by "setAutoThreshold("Otsu")" allowed to locate the darkest zones. The "black spots" then correspond to the dark pixels in the three R, G and B channels of the BF. This triple selection creates a mask which is resized to the analysis image size. It can be possible, if requested by the user, to remove the non-usable black areas.

### Detection of collagen

In the BF image collagen detection refers to the red color detection. The best way is to choose the channel A of the LAB color space, representing the value on a green → red axis. 

Collagen corresponds to the intersection of "Moments dark" threshold in the channel A with defined slice of interest surface.
	
### Detection of fibrosis

Fibrosis corresponds to the intersection of "Triangle dark" threshold in the red channel of the polarised image  with previously defined "collagen" part.

### Data production and created files

To avoid errors, the macro manages all the saved files based on the name of the starting image and adding complements. The list of created files is:

- Log.txt : generic log file contains steps and crop zone to repeat if necessary
- Log+"DATE".csv: is the ultimate log file at the end of a full analysis
- Summary: generic result file to save work if macro crashes
and Each single image file producing several files in order to control macro's work and correct if necessary
- Summary+"DATE".csv: is the ultimate summary file at the end of a full analysis
- "Imagename"_zones.tif: image of the identified areas (black represents the exclusion zones, green: analyzed section, cyan: collagen
and white: fibrosis)
- "Imagename"_fibrosis_RoiSet.zip: ROI of all fibrosis spots
- "Imagename"_collagenselection.roi: selection of all collagen zones in one selection
- "Imagename"_collagen_RoiSet.zip: ROI of all collagen spots BUT does not save the inner part of the selected areas 
- "Imagename"_slicemask.tif: binary slice mask
- "Imagename"_POLA.tif: polarized picture in RGB
- "Imagename"_RGB.tif: BF picture in RGB
- "Imagename"_sliceselection.roi: election of all conserved slice parts in one selection
- "Imagename"_slice_RoiSet.zip: ROI of each slice parts without user excluded zones

### Result file and analysis

The result file "Summary+DATE.csv" contains the following columns:

- __Slice__: Slice name+ interest zone (slice, collagen and fibrosis)
- Count: unuse: number of ROI interest zone
- __Total Area__: desired surface measurement in µm²
- Average Size: unuse 
- %Area: unuse 

The analysis is therefore performed by taking into account the three lines from an image (slice, collagen and fibrosis). 
The percentage of collagen corresponds to: (the surface of collagen divided by the slice)*100. 
The percentage of fibrosed collagen is: (the surface of fibrosis divided by the collagen)*100.

## References

Red Picro-Sirius reference

- Junqueira, L.C.U., Bignolas, G. & Brentani, R.R. Picrosirius staining plus polarization microscopy, a specific method for collagen detection in tissue sections. Histochem J 11, 447–455 (1979). https://doi.org/10.1007/BF01002772

Images treated by Fiji / ImageJ , open with Bio-Formats and figures done with Scientifig:

- Fiji: ImageJ 1.53f51 Http://imagej.nih.gov/ij Java 1.8.0_172 (64-bit)
- Schindelin, Johannes, Ignacio Arganda-Carreras, Erwin Frise, Verena Kaynig, Mark Longair, Tobias Pietzsch, Stephan Preibisch, et al. 2012. « Fiji: an open-source platform for biological-image analysis ». Nature methods 9 (7): 676. https://doi.org/10.1038/nmeth.2019.
- Aigouy, Benoit, et Vincent Mirouse. 2013. « ScientiFig: a tool to build publication-ready scientific figures ». Nature Methods 10 (11): 1048‑8. https://doi.org/10.1038/nmeth.2692.
- Linkert, M.; Rueden, C. T.; Allan, C.; Burel, J.-M.; Moore, W.; Patterson, A.; Loranger, B.; Moore, J.; Neves, C.; MacDonald, D.; Tarkowska, A.; Sticco, C.; Hill, E.; Rossner, M.; Eliceiri, K. W. & Swedlow, J. R. (2010), 'Metadata matters: access to image data in the real world', Journal of Cell Biology 189(5), 777--782.

Text translated mostly with 

- www.DeepL.com/Translator (free version)

## Thanks

Thanks to my colleagues Guillaume Py and Corentin Guilhot for supporting and reviewing and Volker Bäcker (mri, cnrs, Montpellier) for his help.
