#EBONI Instructions

#### Start graphical user interface: ####
run "PSMA_PETCT_Analysis_GUI.m"


#### Folder structure of input data: ####
Please only select the PARENT-folder in the graphical user interface. This PARENT-folder must contain a PATIENT-subfolder. 
The PATIENT folder must contain two subfolders named CT and PET each containing the respective dicom images. 
The dicom images may be stored in subfolders again. The program will search the entire directory structure and load all images contained in subfolders of PET and CT.

