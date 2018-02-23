%batchAnalyzePSMA_PETCT


pathData = '/media/mmni_raid2/Filesystem/hammesj/PSMA_Tracervergleich/';
pathCTNiftiTemp = [pathData 'CTNiftiTemp'];
pathPETNiftiTemp = [pathData 'PETNiftiTemp'];

%List of SUV Thresholds for Metastasis detection
SUVThresholdList = [0.0001];

SUVMaxThreshold = 1.5;

%set thresholds for CT Hounsfiled units
ctBoneThreshold = 270;

%Decide if metastases should be counted and measured
performClusterAnalysis = false;
metastasisVolumeThreshold = 20; %roughly 1ml

%Calculate Voxel Volume from standard PET parameters
voxelVolume = 0.4072 * 0.4072 * 0.3;




    %Delete Temp Folders if they are present
    try
        rmdir(pathCTNiftiTemp, 's');
    end
    try
        rmdir(pathPETNiftiTemp, 's');
    end
    

%Find alls folders in pathData, then remove . and .. (first two entries)
subjectFolders = dir(pathData);
subjectFolders(not([subjectFolders(:).isdir])) = [];
subjectFolders(1:2) = [];



%preAllocate ImageProperties
ImageProperties(length(subjectFolders)).PatientID = '';





% Run Through Patient Folders and do the analysis
for i = 1:length(subjectFolders)
    
    % Loop through subfolders to find the final folder containing the
    % all the images
    pathCTDICOM = findFilepathDICOMSlices([pathData subjectFolders(i).name filesep 'CT'])
    pathPETDICOM = findFilepathDICOMSlices([pathData subjectFolders(i).name filesep 'PET'])

    
    %retrieve Info about Decaydata from Dicom header
    dicomFiles = dir(pathPETDICOM);
    dicomInfoPET = dicominfo([pathPETDICOM filesep dicomFiles(5).name]);
    patientWeight = dicomInfoPET.PatientWeight;
    nuclideHalfLife = dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
    injectedDose = dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
        
    injectionTime = dicomTime2Seconds(dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
    imageAcquisitionTime = dicomTime2Seconds(dicomInfoPET.AcquisitionTime);
    
    %Check for time discrepancy (Acquisition after 0:00 a.m. while
    %injection was before 0:00 a.m.)
    if str2num(dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime(1:2)) > str2num(dicomInfoPET.AcquisitionTime(1:2))
        imageAcquisitionTime = imageAcquisitionTime + 24*3600;
    end 
    
    inPlaneResolution = dicomInfoPET.PixelSpacing;
    
        
    
    %Make Temp Folders again
    mkdir(pathCTNiftiTemp);
    mkdir(pathPETNiftiTemp);
    
    
    %DICOM Import. Use second pair of commands with 'nii'-parameter to
    %avoid file compression
    
    %dicm2nii(pathPETDICOM, pathPETNiftiTemp);
    %dicm2nii(pathCTDICOM, pathCTNiftiTemp);
    dicm2nii(pathPETDICOM, pathPETNiftiTemp, 'nii');
    dicm2nii(pathCTDICOM, pathCTNiftiTemp, 'nii');
    
    % Pause to give the OS time to finish its zipping and writing operations
    readingError = true;
    while readingError
        
        try
            
            %Find niftis in temp folders
            pathCTdir = dir([pathCTNiftiTemp filesep '*.nii']); %pathCTdir = dir([pathCTNiftiTemp filesep '*.nii.gz']);
            pathPETdir = dir([pathPETNiftiTemp filesep '*.nii']); %pathPETdir = dir([pathPETNiftiTemp filesep '*.nii.gz']);
            
            pathCT = [pathCTNiftiTemp filesep pathCTdir.name];
            pathPET = [pathPETNiftiTemp filesep pathPETdir.name];
            
            %load images
            acct = load_nii(pathCT);
            pet412 = load_nii(pathPET);
            
            readingError = false;
        catch
            disp('waiting for OS to clean up temp folders');
            pause(1)
        end
        
    end
    
    
    
    % Resize CT to PET dimensions
    acctResized = pet412;
    
    xDim = size(pet412.img, 1);
    yDim = size(pet412.img, 2);
    zDim = size(pet412.img, 3);
    
    for axialPlane=1:zDim
        acctResized.img(:,:,axialPlane) = imresize(acct.img(:,:,axialPlane), [xDim yDim]);
    end
    
    
    % create bone mask according to threshold
    ctBoneMask = acctResized.img > ctBoneThreshold;
    
    % smooth bone mask
    ctBoneMask = smooth3(ctBoneMask,'gaussian') > 0.2;
    
    % fill holes in bone mask
    ctBoneMask = fillHolesSliceWise(ctBoneMask);
    
    %Remove upper 75 Slices to exclude Skull
    ctBoneMask(:,:,(zDim-70):zDim) = false;
    
    % Mask PET image with ctBoneMask
    petOnlyBone = pet412;
    petOnlyBone.img = petOnlyBone.img .* ctBoneMask;
       
    %Count Voxels
    numberBoneVoxels = nnz(ctBoneMask);
    boneVolume = numberBoneVoxels * voxelVolume;
    

    
    for j = 1:length(SUVThresholdList)
        
        
        SUVThreshold = SUVThresholdList(j);
        PETThreshold = SUVThreshold * injectedDose * exp(-log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime)) / (patientWeight * 1000) ;
        PETMaxThreshold = SUVMaxThreshold * injectedDose * exp(-log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime)) / (patientWeight * 1000) ;
    
        
        % Voxels in PET above SUV-threshold
        petAboveThreshold = petOnlyBone;
        petAboveThreshold.img = single(petOnlyBone.img > PETThreshold);
        
        % Voxels in PET above minimal SUV-threshold and below max SUV-Threshold
        petBelowMaxSUVThrehsold = petOnlyBone;
        petBelowMaxSUVThrehsold.img = petAboveThreshold.img .* pet412.img;
        petBelowMaxSUVThrehsold.img = single(petBelowMaxSUVThrehsold.img < PETMaxThreshold & petOnlyBone.img > PETThreshold);
        
                
        numberPETposVoxels = nnz(petAboveThreshold.img);
        petPosVolume = numberPETposVoxels * voxelVolume;
        
        
        petMaskedAboveThreshold = pet412.img .* petAboveThreshold.img;
 
        petMaskedBelowSUVMaxThreshold = pet412.img .* petBelowMaxSUVThrehsold.img;

        
        %Mean Activity in PET-positive Voxels
        SumOfPETAboveThresholdActivity = sum(petMaskedAboveThreshold(:));
        MeanActivityPETBone = SumOfPETAboveThresholdActivity/nnz(petAboveThreshold.img);
        
        
        %Mean Activity in PET-positive Voxels (below SUV Max Threshold)
        SumOfPETBelowMaxThresholdActivity = sum(petMaskedBelowSUVMaxThreshold(:));
        MeanActivityPETBoneBelowSUVMaxThreshold = SumOfPETBelowMaxThresholdActivity/nnz(petMaskedBelowSUVMaxThreshold);
        
        MeanSUVPETBone = MeanActivityPETBone * (patientWeight * 1000) / injectedDose * exp(log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime));
        MeanSUVPETBoneBelowSUVMaxThreshold = MeanActivityPETBoneBelowSUVMaxThreshold * (patientWeight * 1000) / injectedDose * exp(log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime));
        
        
        
        %Remove first and last two slices in z direction to prevent artifacts
        petWithoutBorders = petOnlyBone;
        petWithoutBorders.img(:,:,1:2) = 0;
        petWithoutBorders.img(:,:,(zDim-2):zDim) = 0;
        
        %Find coordinates of hottest Voxel
        indexOfHottesVoxel = find(petWithoutBorders.img == max(petWithoutBorders.img(:)));
        [xHot yHot zHot] = ind2sub([xDim yDim zDim], indexOfHottesVoxel);
        
        %SUV of hottest Voxel in Bone
        SUVHottestBoneVoxel = max(petWithoutBorders.img(:)) * (patientWeight * 1000) / injectedDose * exp(log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime));
        
        
        
        
        %Save in ImageProperties
        indexVariable = length(SUVThresholdList)*(i-1)+j;
        
        ImageProperties(indexVariable).PatientID = subjectFolders(i).name;
        ImageProperties(indexVariable).HUThreshold = ctBoneThreshold;
        ImageProperties(indexVariable).BoneVolume = boneVolume;
        ImageProperties(indexVariable).InjectedDose = injectedDose;
        ImageProperties(indexVariable).SUVThreshold = SUVThreshold;
        ImageProperties(indexVariable).petPosVolume = petPosVolume;
        ImageProperties(indexVariable).percentPetPos = numberPETposVoxels/numberBoneVoxels;
        ImageProperties(indexVariable).MeanSUVPETposBone = MeanSUVPETBone;
        ImageProperties(indexVariable).MeanSUVPETBoneBelowSUVMaxThreshold = MeanSUVPETBoneBelowSUVMaxThreshold;
        ImageProperties(indexVariable).SUVHottesBonetVoxel = SUVHottestBoneVoxel;
        ImageProperties(indexVariable).CoordinatesHottestVoxel = ['x=' num2str(xHot) ' y=' num2str(yHot) ' z=' num2str(zHot)];
        
        if performClusterAnalysis
            [BlobCounter, Bloblist] = clusterAnalysisPET(make_nii(petMaskedAboveThreshold), PETThreshold, metastasisVolumeThreshold)
            ImageProperties(indexVariable).MetastasisCount = BlobCounter;
            ImageProperties(indexVariable).MeanMetastasisVolume = mean([Bloblist.Volume]) * voxelVolume;
            ImageProperties(indexVariable).MaxMetastasisVolume = max([Bloblist.Volume]) * voxelVolume;
            
        end
        
        
    end
    
    %Delete Temp Folders if they are present
    try
        rmdir(pathCTNiftiTemp, 's');
    end
    try
        rmdir(pathPETNiftiTemp, 's');
    end
    
       
end



%WriteResultsToFile
writetable(struct2table(ImageProperties), [pathData 'PSMA_TracerComparison_Results.csv'])
disp('Done. Result ist stored in ImageProperties and written to file')