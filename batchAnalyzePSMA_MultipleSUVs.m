%batchAnalyzePSMA_PETCT



pathData = '/Volumes/MMNI_RAID/RAID_MMNI/PSMA_Matlab/PSMA_PETCT_Data/'
pathCTNiftiTemp = [pathData 'CTNiftiTemp'];
pathPETNiftiTemp = [pathData 'PETNiftiTemp'];

SUVThresholdList = [2 3.5 5];



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


%Calculate Voxel Volume from standard PET parameters
voxelVolume = 0.4072 * 0.4072 * 0.3;



% Run Through Patient Folders and do the analysis
for i = 1:length(subjectFolders)
    
    pathCTDICOM = [pathData subjectFolders(i).name filesep 'CT'];
    
    % Loop through subfolders to find the final folder containing the
    % all the images
    finalFolderReached = false;
    while not(finalFolderReached)
        CTSubfolders = dir(pathCTDICOM);
        CTSubfolders(not([CTSubfolders(:).isdir])) = [];
        CTSubfolders(1:2) = [];
        if isempty(CTSubfolders)
            finalFolderReached = true;
            break
        end
        pathCTDICOM = [pathCTDICOM filesep CTSubfolders(1).name];
    end

    pathPETDICOM = [pathData subjectFolders(i).name filesep 'PET'];
    finalFolderReached = false;
    while not(finalFolderReached)
        PETSubfolders = dir(pathPETDICOM);
        PETSubfolders(not([PETSubfolders(:).isdir])) = [];
        PETSubfolders(1:2) = [];
        if isempty(PETSubfolders)
            finalFolderReached = true;
            break
        end
        pathPETDICOM = [pathPETDICOM filesep PETSubfolders(1).name];
    end
    
    %retrieve Info about Decaydata from Dicom header
    dicomFiles = dir(pathPETDICOM);
    dicomInfoPET = dicominfo([pathPETDICOM filesep dicomFiles(5).name]);
    patientWeight = dicomInfoPET.PatientWeight;
    nuclideHalfLife = dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
    injectedDose = dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
    injectionTime = dicomTime2Seconds(dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
    imageAcquisitionTime = dicomTime2Seconds(dicomInfoPET.PerformedProcedureStepStartTime);
    
        
    
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
    
    
    
    %set thresholds for CT Hounsfiled units
    ctBoneThreshold = 270;
    
    
    
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
    
    % Mask PET image with ctBoneMask
    petOnlyBone = pet412;
    petOnlyBone.img = petOnlyBone.img .* ctBoneMask;
       
    %Count Voxels
    numberBoneVoxels = nnz(ctBoneMask);
    boneVolume = numberBoneVoxels * voxelVolume;
    

    
    for j = 1:length(SUVThresholdList)
        
        
        SUVThreshold = SUVThresholdList(j);
        PETThreshold = SUVThreshold * injectedDose * exp(-log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime)) / (patientWeight * 1000) ;
    
        
        % Voxels in PET above SUV-threshold
        petAboveThreshold = petOnlyBone;
        petAboveThreshold.img = single(petOnlyBone.img > PETThreshold);
        
                
        numberPETposVoxels = nnz(petAboveThreshold.img);
        petPosVolume = numberPETposVoxels * voxelVolume;
        
        %Mean Activity in PET-positive Voxels
        petMaskedAboveThreshold = pet412.img .* petAboveThreshold.img;
        
        SumOfPETAboveThresholdActivity = sum(petMaskedAboveThreshold(:));
        MeanActivityPETBone = SumOfPETAboveThresholdActivity/nnz(petAboveThreshold.img);
        
        MeanSUVPETBone = MeanActivityPETBone * (patientWeight * 1000) / injectedDose * exp(log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime));
        
        
        
        %Remove first and last two slices in z direction to prevent artifacts
        petWithoutBorders = petOnlyBone;
        petWithoutBorders.img(:,:,1:2) = 0;
        petWithoutBorders.img(:,:,(zDim-2):zDim) = 0;
        
        %Find coordinates of hottest Voxel
        indexOfHottesVoxel = find(petWithoutBorders.img == max(petWithoutBorders.img(:)));
        [xHot yHot zHot] = ind2sub([xDim yDim zDim], indexOfHottesVoxel);
        
        %SUV of hottest Voxel in Bone
        SUVHottestBoneVoxel = max(petWithoutBorders.img(:)) * (patientWeight * 1000) / injectedDose * exp(log(2)/nuclideHalfLife * (imageAcquisitionTime-injectionTime));
        
        
        
        %Output
        %disp(['Bone Volume: ' num2str(boneVolume) ' ml']);
        %disp(['Bone Metastasis  Volume: ' num2str(petPosVolume) ' ml']);
        %disp(['Bone Metastasis in Percent of Bone Volume: ' num2str(numberPETposVoxels/numberBoneVoxels*100) ' %']);
        %disp(['Mean SUV in Metastases: ' num2str(MeanSUVPETBone)]);
        %disp(['Coordinates of highest SUV: x=' num2str(xHot) ' y=' num2str(yHot) ' z=' num2str(zHot)]);
        
        
        %Save in ImageProperties
        indexVariable = length(SUVThresholdList)*(i-1)+j;
        
        ImageProperties(indexVariable).PatientID = subjectFolders(i).name;
        ImageProperties(indexVariable).HUThreshold = ctBoneThreshold;
        ImageProperties(indexVariable).BoneVolume = boneVolume;
        ImageProperties(indexVariable).SUVThreshold = SUVThreshold;
        ImageProperties(indexVariable).petPosVolume = petPosVolume;
        ImageProperties(indexVariable).percentPetPos = numberPETposVoxels/numberBoneVoxels;
        ImageProperties(indexVariable).MeanSUVPETposBone = MeanSUVPETBone;
        ImageProperties(indexVariable).SUVHottesBonetVoxel = SUVHottestBoneVoxel;
        ImageProperties(indexVariable).CoordinatesHottestVoxel = ['x=' num2str(xHot) ' y=' num2str(yHot) ' z=' num2str(zHot)];
        
        
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
writetable(struct2table(ImageProperties), [pathData 'PSMA_BoneAnalysis_MultSUV.csv'])
disp('Done. Result ist stored in ImageProperties and written to file')