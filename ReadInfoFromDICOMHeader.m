

pathData = '/home/hammesj/Desktop/hammesj/PSMA_VisualRating//';


%Find alls folders in pathData, then remove . and .. (first two entries)
subjectFolders = dir(pathData);
subjectFolders(not([subjectFolders(:).isdir])) = [];
subjectFolders(1:2) = [];



%preAllocate ImageProperties
dcmHeaderInfo(length(subjectFolders)).SubjectID = '';


% Run Through Patient Folders and do the analysis
for i = 1:length(subjectFolders)
    
    % Loop through subfolders to find the final folder containing the
    % all the images
    pathPETDICOM = findFilepathDICOMSlices([pathData subjectFolders(i).name filesep 'PET'])

    
    %retrieve Info about Decaydata from Dicom header
    dicomFiles = dir(pathPETDICOM);
    dicomInfoPET = dicominfo([pathPETDICOM filesep dicomFiles(5).name]);
    
    dcmHeaderInfo(i).SubjectID = subjectFolders(i).name;
    dcmHeaderInfo(i).patientWeight = dicomInfoPET.PatientWeight;
    dcmHeaderInfo(i).nuclideHalfLife = dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
    dcmHeaderInfo(i).injectedDose = dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
    dcmHeaderInfo(i).injectionTime = dicomTime2Seconds(dicomInfoPET.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
    dcmHeaderInfo(i).imageAcquisitionTime = dicomTime2Seconds(dicomInfoPET.PerformedProcedureStepStartTime);
    dcmHeaderInfo(i).inPlaneResolution = dicomInfoPET.PixelSpacing;
    
end



%WriteResultsToFile
writetable(struct2table(dcmHeaderInfo), [pathData 'dicomHeaderInfo.csv'])
disp('Done. Result ist stored in dcmHeaderInfo and written to file')