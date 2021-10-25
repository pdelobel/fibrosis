# Semi‑automatic macro ImageJ analysis for collagen and fibrosis from biopsies images in BrightField and polarised light

Pierre Delobel september 30th 2021

## Introduction

This Fiji / ImageJ macro aim to help users for calculation of the percentage collagen and fibrosis per area from Biopies.
It works on whole folder with pictures of Sirius red labeled sections.
Images must be take twice BVR images Bright Field and Polarised in the same picture.  
In order to compare highly variable biopsies, it was decided to retain only areas of endomysium because some sections showed fibrotic perimisium veins while others showed only endomysium. To do this, the user is asked to define the areas to be excluded.
All Results are stored in a csv tab with the area of the region of interest, the collagen surface (marked in red with Sirius red) and the fibrosis region, polarizing red due to the ordering of the collagen fibers.

The macro lead the user calculate the % of collagen in the slice and the % of fibrosis of this collagen from each areas in µm².

## Operating presentation

### Reusable structure

This macro has been written so that its structure can be reused. The different parts are well identified, which means that by changing a basic function, it is possible to redo an analysis macro for another marking. The operation in a folder with interactive control of the basic parameters, the saving of the Images, Log and Results files or the reduction to the area of the cut or the definition of the areas to be excluded are different recoverable or modifiable parts.

### Over view

A Picrosirius red labeled slice lead to see yellow tissus with red menbrans due to red fixation on collagen with Bright Field (BF) color pictures. The same slice with polarised light allow to see ordonated stuctures of collagen that is fibrosis, the larger collagen fibers are bright yellow or orange, and the thinner ones, including reticular fibers, are green. Here, only the red polarised light is used.

The heterogeneity of  biopsies sampling led us to consider only the endomysium part of the slice. The solution chosen to focus on it was to insert in the semi‑automated analysis a user selection action to exclude the perimysium and epimysium (and others eclused zones).

Figure 1 shows the processing from the two images (BF & Polarised) thes analized mask and the result colored alaysis. It's possible to see the automatic hole detection in LAB space and a detection possible of black spots (on the entire folder at the user's discretion).

![Figure 1: Image processing](data/analyse.png)Figure 1: Image processing  
A&B: part of source image: A in BrightField, B in polarized light, C the mask of all that is retained as "section to be analyzed" in white with suppression of the background, the spots and manually supressed of the perimysium and epimysium zones, and D the representation of the different identified zones (the fibrosis in white, the collagen in cyan and the section in green, on a black background). The scale bar is 500 µm lenght and is about 5000 µm² with it thickness.

A situation analysis is presented in figure 2 with two conditions control and cuff, before and after a dry immersion of 5 days,  publication submitted "Severe muscle deconditioning triggers early Extra Cellular Matrix remodeling and residents stem cells fate/behavior" Corentin Guilhot 2021.

![Figure 2: example: Control and cuff at pre and DI5](data/ctrl-cuff.png){width=80%} Figure 2: example: Control and cuff at pre and DI5  
Zoom on a small part of the section for a control subject (A:F) and a cuff subject (G:L) in pre ( A:C and G:I) and After 5 days of dry immersion DI5 (D:F and J:L) . The images are the brightField, Polarized and the representation of the differents areas identified for each stage (white: fibrosis, cyan: collagen, green : section and black: background and exluded zones).

### default settings

In the macro, it's possible to change but default image extention is ".lif"
Images must be scales in µm so the filter adjustment to remove small particles are :

- 5000 µm² minimal size µ² for tissue section area
- 50 µm² minimal size for collagen detection
- 0 µm², so no exclusion, for the minimal size of fibrosis

-> centrer<-

### User interaction

#### At the opening

At the beginning of the operation of the Macro, some parameters have to be controlled.
A window specifies the extension of the target images and breaks down the image structure into 6 channels.  The colour order of these 6 channels can be predicted. It is also possible to indicate whether or not to apply the black spot correction. This correction is only usefull for whole images. If the image is reduced exclusively to tissue, this correction is not useful because the thresholding will not work sufficiently.

After this step, user is invitated to choose the directory to be processed and then, the results directory where all backups will be made.

#### For each image

Two steps required user intervention for each image. The first step involved selecting the area of the slice comprising the slice to reduce the size of the image. The second step required adding to the ROImanager (with "t") the areas that one wished to exclude from the analysis, i.e. the spots and the pluses of the slice, the endomysium and epimysium parts.

### Automated control

First, in order not to erase previous data in case of a crash, the "Summary" and "Log" files are saved with the addition of "_before_" and the start date of the macro. 

At the end of the macro, the new "Log" and "Summary" files are saved with the start date of the macro. 

### The log file control

The basic information and traces of the program's progress are recorded in the "log" file, which is saved on a regular basis.
It contains the following data: 

- start date of the analysis 
- Basic parameters of the rejection of the stains: Minimum size of the parts of cut: 5000 µm²
- minimum size of collagen parts: 50 µm²
- minimum size of the fibrosis parts: 0 µm² (not use)


After this generals informations, we can found the image specific information as:

- original image name processing 
- title of the last opened image (getTitle) which is the name of the image opened with the specified channel.
- the zone of interest (ZoI) function on the image named
- the selection informations x, y, width, height for the crop function in order to be able to redo the cutting if necessary
- the threshold type applied for collagen 

### image treatement

### Open images and slice selection

	Dialog.addMessage("one "+extention_images_base+" image with 6 channels,\n for measuring collagen and fibrosis sirius red marking image in 2 channels RGB direct color and polarized light\n open order of .lif used for the 6 channels: BGR, BGR\ncan be modified below :");
	
	The part of usefull image is ask to the user, otherwise the macro works on the whole image. (function cropcrop() resize all opened images)

	Images are opened with "Bio-Formats Importer" with split channels. Each 6 channels are independant.
	
	Images BF and polarised are reconstructed as RGB with "Merge Channels..." for user visualisation.
	
### Black spots

For the elimination of the black spots, a processing of the RGB images is carried out after reduction ("run("Scale...", "x=0.5 y=0.5 ...)"), the image is cleaned by "run("Despeckle")" then a thresholding by "setAutoThreshold("Otsu")" makes it possible to locate the darkest zones. The "black spots" therefore correspond to the pixels that come out dark in the three R, G and B channels of the LF. This triple selection creates a mask that is resized to the analysis image size to remove, if requested by the user, the non-useable black areas.

### Detection of collagen

The detection of collagen refers to a detection of the red color in the BF image. The best rendering found is to pass through the A channel of LAB  represents the value on a green → red axis. 

The collagen corresponds to the intersection of dark moments in the A channel with the surface defined as the slice of interest.
	
### Detection of fibrosis

The detection of fibrosis is the common part determined as "collagen" with a detection "Triangle dark" on the red channel of the polarized image.

### Data production and created files

To avoid errors, it is the macro that manages all the file records using the name of the starting image as a basis and adding complements. The list of files created is as follows:

- Log.txt : generic log file it contains steps and crop zone to repeat it if necessary
- Log+"DATE".csv: is the ultimate log file at the end of a full analysis
- Summary: generic result file to save done work if macro crashes
and Each single image file lead to produce serval files aim to control macro's work and correct it if necessary
- Summary+"DATE".csv: is the ultimate summary file at the end of a full analysis
- "Imagename"_zones.tif: image image of the identified areas (black represents the exclusion zones, green: analyzed section, cyan: collagen
and white: fibrosis)
- "Imagename"_fibrosis_RoiSet.zip: ROI of all fibrosis spots
- "Imagename"_collagenselection.roi: selection of all collagen zones in one selection
- "Imagename"_collagen_RoiSet.zip: ROI of all collagen spots BUT does not save the inner part of the selected areas 
- "Imagename"_slicemask.tif: binary slice mask
- "Imagename"_POLA.tif: polarised picture in RGB
- "Imagename"_RGB.tif: BF picture in RGB
- "Imagename"_sliceselection.roi: election of all conserved slice parts in one selection
- "Imagename"_slice_RoiSet.zip: ROI of each slice parts without user excluded zones

### Result file and analysis

The result file "Summary+DATE.csv" contains the following columns:

- Slice: Slice name+ interest zone (slice, collagen and fibrosis)
- Count: unuse: number of ROI of the interst zone
- Total Area: desired surface measurement in µm²
- Average Size: unuse 
- %Area: unuse 

The analysis is therefore performed by taking into account the three lines from an image (slice, collagen and fibrosis). The percentage of collagen corresponds to (the surface of collagen divided by the slice)*100. the percentage (the surface of fibrosis divided by the collagen)*100.

## Referenses

Red Picrosirius reference

- Junqueira, L.C.U., Bignolas, G. & Brentani, R.R. PicroPicrosirius staining plus polarization microscopy, a specific method for collagen detection in tissue sections. Histochem J 11, 447–455 (1979). https://doi.org/10.1007/BF01002772

Images treated by Fiji / ImageJ , open with Bio-Formats and figures done with Scientifig :

- Fiji: ImageJ 1.53f51 Http://imagej.nih.gov/ij Java 1.8.0_172 (64-bit)
- Schindelin, Johannes, Ignacio Arganda-Carreras, Erwin Frise, Verena Kaynig, Mark Longair, Tobias Pietzsch, Stephan Preibisch, et al. 2012. « Fiji: an open-source platform for biological-image analysis ». Nature methods 9 (7): 676. https://doi.org/10.1038/nmeth.2019.
- Aigouy, Benoit, et Vincent Mirouse. 2013. « ScientiFig: a tool to build publication-ready scientific figures ». Nature Methods 10 (11): 1048‑8. https://doi.org/10.1038/nmeth.2692.
- Linkert, M.; Rueden, C. T.; Allan, C.; Burel, J.-M.; Moore, W.; Patterson, A.; Loranger, B.; Moore, J.; Neves, C.; MacDonald, D.; Tarkowska, A.; Sticco, C.; Hill, E.; Rossner, M.; Eliceiri, K. W. & Swedlow, J. R. (2010), 'Metadata matters: access to image data in the real world', Journal of Cell Biology 189(5), 777--782.

Text translated mostly with 

- www.DeepL.com/Translator (free version)

