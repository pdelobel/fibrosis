# ImageJ analysis for collagen and fibrosis from biopsies

Pierre Delobel september 30th 2021

## Introduction

This Fiji / ImageJ macro aim to help users to determine the collagen ant the fibrosis level from Biopies.
It works on wholle folder with pictures of Sirius red labeled sections.
Images must be take twice BVR images Bright Field and Polarised in the same picture.  
In order to compare highly variable biopsies, it was decided to retain only areas of endomysium because some sections showed fibrotic perimisium veins while others showed only endomysium. To do this, the user is asked to define the areas to be excluded.
All Results are stored in a csv tab with the area of the region of interest, the collagen surface (marked in red with Sirius red) and the fibrosis region, polarizing red due to the ordering of the collagen fibers.

The macro lead the user calculate the % of collagen in the slice and the % of fibrosis of this collagen from each areas in µm².

## Operating presentation

### Over view

A sirius red labeled slice lead to see yellow tissus with red menbrans due to red fixation on collagen with Bright Field (BF) color pictures. The same slice with polarised light allow to see ordonated stuctures of collagen that is fibrosis.

The heterogeneity of the biopsy sampling led us to consider only the endomysium part of the slice. The solution chosen was to insert in the automated analysis a user selection action to exclude the perimysium and epimysium.

Figure 1 shows the processing from the two images (BF & Polarised) thes analized mask and the result colored alaysis. It's possible to see the automatic hole detection in LAB space and a detection possible of black spots (on the entire folder at the user's discretion).

Figure 1: Image processing [Figure 1](data/analyse.png{ width=100% }  
A&B part of source image : A in BrightField, B in polarized light, C the mask of all that is retained as "section to be analyzed" in white with suppression of the background, the spots and manually supressed of the perimysium and epimysium zones, and D the representation of the different identified zones (the fibrosis in white, the collagen in cyan and the section in green, on a black background). The scale bar is 500 µm lenght and is about 5000 µm² with it thickness.

A situation analysis is presented in figure 2 with two conditions control and cuff, before and after a dry immersion of 5 days.

Figure 2: Control and cuff at pre and DI5 [Figure 2](data/ctrl-cuff.png{ width=100% }  
Zoom on a small part of the section for a control subject (A:F) and a cuff subject  (G:L) in pre ( A:C and G:I) and After 5 days of dry immersion DI5 (D:F and J:L) . The images are the brightField, Polarized and the representation of the differents areas identified for each stage.


### Open images

### image treatement

### Detection of collagen

### Detection of fibrosis


### Files created


This Fiji / ImageJ macro aim to help users to determine the collagen ant the fibrosis level from Biopies.
It works on wholle folder with pictures of Sirius red labeled sections.
Images must be take twice BVR images Bright Field and Polarised in the same picture.
It had been developed with "lif" format but it can be change on the interactive pannel.
The macro open images,and ask user to select the interst region in the aim to reduce image size and  search for the section ant
analyze all file with specified extention from a folder
specialised for biopsies with manual selection of exclued zones




Translated with www.DeepL.com/Translator (free version)





wait until the person has selected an area and clicked on OK
waits for the person to select an area and click on OK

specified informations
scale unit are suposed to be set by the microscope
inclusion/exclusion sized are based on µm 
initial development scaled on human biopsies observed 
on a Leica Thunder microscope  with HC PL FLUOTAR    20x/0.55 DRY
extention format is based on "lif" images but it can be modified in the first macro's lines (around line 55)
open order is supposed to be BGR BF and BGR polazised but it can be adjusted in the window interaction

pictures must be taken BF first then polarised
imageJ open order can be modified to ordonates as required


on the "zones" image : black represents the exclusion zones, green corresponds to the analyzed section, the cyan corresponds to the collagen
and white represents fibrosis
collagen is analyzed exclusively on the green section
fibrosis is analyzed exclusively on the collagen

the spots are suppressed if they are lower than a variable minimum between the cut, the collagen and the fibrosis

auto local threshold https://imagej.net/Auto_Local_Threshold (september the 27th 2021)


double quantification of collagen and fibrosis  (ordered collagen)
the result file "Summary+DATE.csv" contains the following columns
Slice : Slice name+ interest zone (slice, collagen and fibrosis)
Count : unuse : number of ROI
Total Area : desired surface measurement in µm²
Average Size : unuse 
%Area : unuse 

Files produced :
Log.txt  : generic log file it contains steps and crop zone to repeat it if necessary
Summary : generic result file to save done work if macro crashes
and Each single image file lead to produce serval files aim to control maro's work and correct it if necessary
"Imagename"_zones.tif : image image of the identified areas (black represents the exclusion zones, green : analyzed section, cyan : collagen
and white : fibrosis)
"Imagename"_fibrosis_RoiSet.zip : ROI of all fibrosis spots
"Imagename"_collagenselection.roi : selection of all collagen zones in one selection
"Imagename"_collagen_RoiSet.zip : ROI of all collagen spots BUT does not save the inner part of the selected areas 
"Imagename"_slicemask.tif : binary slice mask
"Imagename"_POLA.tif : polarised picture in RGB
"Imagename"_RGB.tif : BF picture in RGB
"Imagename"_sliceselection.roi : election of all conserved slice parts in one selection
"Imagename"_slice_RoiSet.zip : ROI of each slice partswitout user excluded zones

Imagename  		the name of the open image

/It's possible to modified the image extention HERE :
extention_images_base=".lif";












