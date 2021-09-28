// pierre Delobel
// 27/09/2021
// Macro for red Sirius analysis with twice BVR images Bright Field and Polarised
// analyze all file with specified extention from a folder
// specialised for biopsies with manual selection of exclued zones

// specified informations
// scale unit are suposed to be set by the microscope
// inclusion/exclusion sized are based on µm 
// initial development scaled on human biopsies observed 
// on a Leica Thunder microscope  with HC PL FLUOTAR    20x/0.55 DRY
// extention format is based on "lif" images but it can be modified line 30
// open order is supposed to be BGR BF and BGR polazised but it can be adjusted in the window interaction

// pictures must be taken BF first then polarised
// imageJ open order can be modified to ordonates as required


// on the "zones" image : black represents the exclusion zones, green corresponds to the analyzed section, the cyan corresponds to the collagen
// and white represents fibrosis
// collagen is analyzed exclusively on the green section
// fibrosis is analyzed exclusively on the collagen

// the spots are suppressed if they are lower than a variable minimum between the cut, the collagen and the fibrosis

// auto local threshold https://imagej.net/Auto_Local_Threshold (september the 27th 2021)
//

/////  It's possible to modified the image extention HERE :
extention_images_base=".lif";

//run("Threshold...");

//doCommand("Record...");//deleteable
doCommand("Monitor Memory...");
//setOption("BlackBackground", true);

// Note: This only works with Black background and White foreground!
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 black count=1");

run("Set Measurements...", "area limit redirect=None decimal=2"); // General settings

// double quantification of collagen and fibrosis  (ordered collagen)
// the result file "Summary" is a contains the following information
//Slice
//Count	Total Area	Average Size	%Area




// Imagename  		the name of the open image
// aireCoupe  		the total area of the slice considered analyseable.  	  	
// aireCollagene  	he surface of the image_base + "collagen" i.e. visible sirius red (membranes)
// aireFibrose		the surface of the true red fibrosis in polarized light
// a different file is created for each run
initialise();

// definition of fixed variables
var image, path, pathR,  image_base, extention_images_base;
var TimeString;
var x, y, width, height;
var coupeMIN, collagenMIN, fibrosisMIN;
var blacksupression, BFr, BFg, BFb, POLAr, POLAg, POLAb;

// filter adjustment to remove small particles 
coupeMIN=5000;//5000 minimal size µ² for section area
collagenMIN=50;//50 minimal size µ² for section area
fibrosisMIN=0;// 0 minimal size µ² for section area

Dialog.create("Analysis of polarized "+extention_images_base+" images marked red sirius");
	Dialog.addMessage("one "+extention_images_base+" image with 6 channels,\n for measuring collagen and fibrosis sirius red marking image in 2 channels RGB direct color and polarized light\n open order of the 6 channels : BGR, BGR");

	Dialog.addNumber("channel imageJ number for\nBF red ?",2);
	Dialog.addNumber("BF green ?",1);
	Dialog.addNumber("BF blue ?",0);
	Dialog.addNumber("pola red ?",5);
	Dialog.addNumber("pola green ?",4);
	Dialog.addNumber("pola blue ?",3);
	Dialog.addNumber("lot of black inoperable patches (1 yes 0 no)",1);
				
Dialog.show();

BFr = Dialog.getNumber();
BFg = Dialog.getNumber();
BFb = Dialog.getNumber();
POLAr = Dialog.getNumber();
POLAg = Dialog.getNumber();
POLAb = Dialog.getNumber();
blacksupression = Dialog.getNumber();


// choix du répertoire a traiter
path = getDirectory("Select the folder containing the "+extention_images_base+" images");
print("analyzed folder :"+path);

// création du fichier de résultats
pathR = getDirectory("Choose the results folder");
//path + "/analyse_auto/";
//File.makeDirectory(pathR);

nomDate();// create the date code "TimeString" for the output file name
print("start of the analysis  : "+TimeString);
print("Basic parameters of the rejection of the stains :\nMinimum size of the pieces of cut : "+coupeMIN);
print("minimum size of collagen pieces : "+collagenMIN);//50
print("minimum size of the fibrosis pieces : "+fibrosisMIN);//0

archiveLOG();
archivesummary();

// creation of the file list
list = getFileList(path);

// analysis program with extension control
for (i=0;i<list.length;i++) {
	if (endsWith(list[i], extention_images_base)){
        image = list[i];
        image_base=replace(image,extention_images_base,"");// radical des noms
         //image_base = File.nameWithoutExtension;// nom sans extention oui mais peu se tromper de fichier
        
        print ("image processing : "+image);
        	saveLOG();             
        canaux(); // opening of the image and removal of unnecessary channels
        	saveLOG();  
        ZoI(); // areas of interest to be analyzed
        	saveLOG(); 
		sauveImages(); // RGB and pola cropped tiff images + cut mask 
			saveLOG(); 		
		seuillages();
			saveLOG();
        sauveResultats();
        	saveLOG();   
        	// exit;   
        run("Close All");
        call("java.lang.System.gc");//to empty the garbage
	}
}

// finalization of the program

if (isOpen("Summary")) {
	selectWindow("Summary");
	saveAs("Results", pathR+"Summary"+TimeString+".csv");
}
if (isOpen("Log")) {
	selectWindow("Log");
	saveAs("Text", pathR+"Log_"+TimeString+".txt");
}

initialise();	

////////////////////////////////////////////////////////////////////////////////////
// unitary functions

// opening of the image and removal of unnecessary channels
function canaux(){
	run("Bio-Formats Importer", "open="+path+image+" autoscale color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT  series_1");
	
	print("titre de la dernière image ouverte : "+getTitle());

// polarized RGB image creation
	run("Merge Channels...", "c1=["+ image +" - C="+POLAr+"] c2=["+ image +" - C="+POLAg+"] c3=["+ image +" - C="+POLAb+"] keep");// cree RGB
	rename(image_base +" - POLA");
	selectWindow(image+" - C="+POLAb);
	close();
	selectWindow(image+" - C="+POLAg);	
	close();
// RGB and Lab image creation in bright field
	run("Merge Channels...", "c1=["+ image +" - C="+BFr+"] c2=["+ image +" - C="+BFg+"] c3=["+ image +" - C="+BFb+"] keep");// cree RGB	
	rename(image_base+"_RGB");
	cropcrop();

    selectWindow(image+" - C="+BFr);
    run("Despeckle");
    run("Scale...", "x=0.5 y=0.5 width=4672 height=3503 interpolation=Bilinear average create title=c2");
    setAutoThreshold("Otsu");
    run("Convert to Mask");

    selectWindow(image+" - C="+BFg);
    run("Despeckle");
    run("Scale...", "x=0.5 y=0.5 width=4672 height=3503 interpolation=Bilinear average create title=c1");
    setAutoThreshold("Otsu");
    run("Convert to Mask");

    selectWindow(image+" - C="+BFb);
    run("Despeckle");
    run("Scale...", "x=0.5 y=0.5 width=4672 height=3503 interpolation=Bilinear average create title=c0");
    setAutoThreshold("Otsu");
    run("Convert to Mask");

    selectWindow("c0");
    imageCalculator("AND create", "c0","c1");
    selectWindow("Result of c0");
    imageCalculator("AND create", "Result of c0","c2");

    selectWindow("c0");
    close();
    selectWindow("c1");
    close();
    selectWindow("c2");
    close();
    selectWindow("Result of c0");
    close();
    selectWindow("Result of Result of c0");
    run("Scale...", "x=2 y=2 width=9344 height=7006 interpolation=Bilinear average create title=tachesnoires");
    selectWindow("Result of Result of c0");
    close();

	run("Merge Channels...", "c1=["+ image +" - C="+BFr+"] c2=["+ image +" - C="+BFg+"] c3=["+ image +" - C="+BFb+"] keep");// cree RGB	
	rename(image_base+"_RGB2");
	
	selectWindow(image_base+"_RGB2");
	run("Duplicate...", "title=LAB");
	run("Lab Stack");
	run("8-bit");
	run("Split Channels");// cree C1- C2- et C3- LAB
	selectWindow("C1-LAB");
	rename("L");
	selectWindow("C2-LAB");
	rename("A");
	selectWindow("C3-LAB");
	rename("B");
}

// image crop to reduce total size to the usefull section
function cropcrop(){	
	print(" ZoI function on : "+image_base+"_RGB");
	selectWindow(image_base+"_RGB");

	// cutting of all images
	setTool("rectangle");
    
    waitForUser("1 - Select the slice area on "+image_base+"_RGB THEN click OK");// wait until the person has selected an area and clicked on OK
    
	getSelectionBounds(x, y, width, height);
	print("selection informations x, y, width, height:"+x+", "+y+", "+width+", "+height);
	for (n=1; n<=nImages; n++) {
			selectImage(n); //select n'th image
			makeRectangle(x, y, width, height);
			run("Crop");
	}
}

// area of interest to be analyzed
function ZoI(){	
// the section
	imageCalculator("Add create 32-bit", "A","B");
	selectWindow("Result of A");
	rename(image_base +"_coupe");	
	run("8-bit");
	run("Gaussian Blur...", "sigma=4");
	setAutoThreshold("Otsu dark");
	run("Convert to Mask");// section white=255 black background=0
    // supression of particles smaller than a minute in size, regardless of their shape
	run("Analyze Particles...", "size=0-"+coupeMIN+" circularity=0.00-1.00 clear add");
		roiManager("Deselect");
		setForegroundColor(0, 0, 0);
		roiManager("Fill");
		roiManager("Reset");
		roiManager("Show All");
	selectWindow(image_base +"_coupe");// white section=255 black background=0
	run("Duplicate...", "title=coupeINV");
	run("Invert");// black section=0 white background=255

    // creation of a complete image for the suppression of non exploitable zones
	selectWindow(image+" - C="+POLAr);
	run("Red");

	// reduction of polarized areas with strong signals
	run("Duplicate...", "title=tachesRouges ignore");
	setAutoThreshold("Triangle dark");
	run("Create Selection");
	resetThreshold();
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	selectWindow(image_base+"_RGB");
	run("Add Image...", "image=tachesRouges x=0 y=0 opacity=75 zero");
	selectWindow("tachesRouges");
	close();

	selectWindow(image_base+"_RGB");
	run("Add Image...", "image=coupeINV x=0 y=0 opacity=100 zero");//zero transparent
	setTool("freehand");
	selectWindow("coupeINV");
	close();
	roiManager("reset");	
	roiManager("Show All");

	
    // addition in the ROI of the black spots for their suppression
    if(blacksupression==1){
	    selectWindow("tachesnoires");
	    setAutoThreshold("MaxEntropy dark");
	    run("Create Selection");
	    selectWindow(image_base+"_RGB");
	    run("Restore Selection");
	    //run("Make Inverse");
	    roiManager("Add");	
	}
	
    waitForUser("2 - areas to exclude :\n Surround then click 't' to add them to the ROI on "+image_base+"_RGB\n THEN click OK");// waits for the person to select an area and click on OK
	selectWindow(image_base +"_coupe");
	roiManager("Deselect");
	roiManager("Fill");
	roiManager("Reset");
	roiManager("Show All");
	setForegroundColor(255, 255, 255);
	run("Select None");
	run("Select All");

// final area of the section 
        roisetSAVE(image_base +"_coupe",coupeMIN,"noir");
		CreateSelection("_coupe");
}	

// saved unanalyzed crop images + cut mask
function sauveImages(){
	selectWindow(image_base+"_RGB");
		run("Remove Overlay");
		run("Select All");
		run("Duplicate...", "title=sauve1");
		saveAs("Tiff", pathR+image_base+"_RGB"+".tif");
		close();
	selectWindow(image_base +" - POLA");
		run("Select All");
		run("Duplicate...", "title=sauve2");
		saveAs("Tiff", pathR+image_base +"_POLA"+".tif");
		close();
	selectWindow(image_base +"_coupe");
		run("Select All");
		run("Duplicate...", "title=sauve3");
		saveAs("Tiff", pathR+image_base+"_masquecoupe"+".tif");
		close();
}

// thresholding of the different collagen and fibrosis zones
function seuillages(){
// the collagen
	selectWindow("A");
	run("Duplicate...", "title="+image_base +"_collagen");
	run("Gaussian Blur...", "sigma=3");
	selectImage(image_base +"_collagen");//plus necessaire mais simplifie la lecture
	selectSelection("_coupe","_collagen");
	if(indexOf(image_base, "01sirius")>0){
		seuil="MaxEntropy dark";
		}else {
		seuil="Moments dark";
	}
	print(" threshold applied for collagen of "+image_base+" : "+seuil);
	setAutoThreshold(seuil);
    //waitForUser("3 - controle du seuillage Moments \nmodifier en MaxEntropy dark pour les sirius01 \npour le collagen");
	run("Convert to Mask");
    // collagen area
  		roisetSAVE(image_base +"_collagen",collagenMIN,"noir");
		CreateSelection("_collagen");
// the fibrosis
	selectWindow(image+" - C="+POLAr);// 
	run("Duplicate...", "title="+image_base +"_fibrosis");
	selectSelection("_collagen","_fibrosis");
	setAutoThreshold("Triangle dark");
	run("Convert to Mask");
    // fibrosis area
  		roisetSAVE(image_base +"_fibrosis",fibrosisMIN,"noir");
	run("Merge Channels...", "c1="+image_base +"_fibrosis c2="+image_base +"_coupe c3="+image_base +"_collagen keep");
	rename("zones");
}

// saving results
function sauveResultats(){
	selectWindow("Summary");
	saveAs("Results", pathR+"Summary");
	selectWindow("zones");
	saveAs("Tiff", pathR+image_base+"_zones"+".tif");
}   

// saving ROI
function roisetSAVE(nom,TailleMin,fond){
	if (fond =="blanc"){
		BG="";
		setForegroundColor(255,255,255);
	}else {
		BG=" dark";
		setForegroundColor(0,0,0);
	}
	selectImage(nom);	
	if(TailleMin>0){
		setAutoThreshold("MaxEntropy"+BG);
		run("Analyze Particles...", "size=0-"+TailleMin+" circularity=0-1.00 clear add");
		roiManager("Deselect");
		roiManager("Fill");
		roiManager("Reset");
		roiManager("Show All");
	}
	setAutoThreshold("MaxEntropy"+BG);
	run("Analyze Particles...", "size="+ TailleMin +"-Infinity circularity=0.00-1.00 show=Nothing clear summarize add");
	roiManager("Deselect");
    roiManager("save", pathR+nom+"_RoiSet.zip");
    roiManager("Reset")
    roiManager("Show All");
}



// selection and saving ROI of the part of interest of the cut
function CreateSelection(planBase){
	roiManager("Reset");
	roiManager("Show All");
	run("Create Selection");
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Save", pathR+image_base+planBase+"selection.roi");
}

// selection of the part of interest of the cut
function selectSelection(planBase,planFinal){
	selectWindow(image_base +planFinal);
	roiManager("Reset");
	roiManager("Show All");
	roiManager("Open", pathR+image_base+planBase+"selection.roi");
	roiManager("Show All");
	roiManager("Select", 0);
	run("Clear Outside");
}


/////////////////////////////////////////////////////////
// initial basic functions
// besoin de var TimeString, pathR;

// Initialisation
function initialise (){	
	roiManager("Reset");
	roiManager("Show All");
	setForegroundColor(255,255,255);
	setBackgroundColor(0,0,0);
	run("Close All");
	while (nImages>0) close();
	if (isOpen("Summary")) {
		selectWindow("Summary");
		run("Close");
	}
	if (isOpen("Results")) {
		selectWindow("Results");
		run("Close");
	}
	;
}

// date name creation code for output files    
function nomDate(){
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     TimeString="";
     TimeString =TimeString+year+"-";
     if (month<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+month+1+"-";
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"_";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour+"-";
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute;
}

// save the old log file
function archiveLOG(){
	if(File.exists(pathR+"Log.txt")){
		File.copy(pathR+"Log.txt", pathR+"Log_before_"+TimeString+".txt") ;
		print("archive de l'ancien fichier log  : Log_before_"+TimeString+".txt");
	}
}

// saves the old summary file
function archivesummary(){
	if(File.exists(pathR+"Summary")){
		File.copy(pathR+"Summary", pathR+"Summary_before_"+TimeString+".txt") ;
		print("archive de l'ancien fichier Summary  : Summary_before_"+TimeString+".txt");
	}
}

// backup of logs on the way
function saveLOG(){
	selectWindow("Log");
	saveAs("Text", pathR+"Log.txt");
} 
