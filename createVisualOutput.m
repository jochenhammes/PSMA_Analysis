function [ visualOutput ] = createVisualOutput(ImageProperties, Bloblist, petAboveThreshold, ctBoneMask, outputFolder)
% Creates Visual Output and stores it in folder

try 
    localSettings
catch
    FontSize = 30;   
end

%Create MIP in coronal viewing plane
petMIP = flipdim(squeeze(max(petAboveThreshold, [], 2))',1);
ctBoneMaskMIP = flipdim(squeeze(max(ctBoneMask, [], 2))',1);

%Resize masks
petMIP = round(imresize(petMIP, [650 480]));
ctBoneMaskMIP = round(imresize(ctBoneMaskMIP, [650 480]));

%Convert to logical and invert images
petMIP = logical(petMIP);
ctBoneMaskMIP = logical(ctBoneMaskMIP);

%Create Transparency Masks
transparencyMaskPET =  petMIP;
transparencyMaskBone = ctBoneMaskMIP;

%Load Template image
visualOutput = imread('TemplatePSMAAnaylsisOutput.jpg');

%Place MIPs on template, second argument multiplies by scaling factor: 
% 0 --> black, 190 --> gray
visualOutput = placeRGBImage(visualOutput, ctBoneMaskMIP.*0, 20, 250, transparencyMaskBone);
visualOutput = placeRGBImage(visualOutput, ctBoneMaskMIP.*190, 440, 250, transparencyMaskBone);
visualOutput = placeRGBImage(visualOutput, petMIP.*0, 440, 250, transparencyMaskPET);



currentpatientID = ImageProperties(length(ImageProperties)).PatientID;
currentDateString = datestr(datetime('now'));
currentBoneVolume = num2str(ImageProperties(length(ImageProperties)).BoneVolume,5)
currentPetPosVol = num2str(ImageProperties(length(ImageProperties)).petPosVolume,5)
currentPercentPetPos = num2str(ImageProperties(length(ImageProperties)).percentPetPos * 100 ,2)
currentMeanSUV = num2str(ImageProperties(length(ImageProperties)).MeanSUVPETposBone,2)
currentZ_MeanSUV = num2str(ImageProperties(length(ImageProperties)).Z_MeanSUV,3)
currentMaxSUV = num2str(ImageProperties(length(ImageProperties)).SUVHottesBonetVoxel,3)
currentSUVThreshold = num2str(ImageProperties(length(ImageProperties)).SUVThreshold,2)
currentHUThreshold = num2str(ImageProperties(length(ImageProperties)).HUThreshold,3)

visualOutput = AddTextToImage(visualOutput, currentpatientID, [110 270], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentDateString(1:end-9), [162 270], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentSUVThreshold, [110 1070], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentHUThreshold, [162 1070], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentBoneVolume, [1025 360], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentPetPosVol, [1078 360], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentPercentPetPos, [1131 360], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentMeanSUV, [1184 450], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentZ_MeanSUV, [1237 630], [0 0 0], 'Arial', FontSize); 
visualOutput = AddTextToImage(visualOutput, currentMaxSUV, [1290 450], [0 0 0], 'Arial', FontSize); 

if ~isempty(Bloblist)
    visualOutput = AddTextToImage(visualOutput, num2str(length(Bloblist)), [1343 450], [0 0 0], 'Arial', FontSize); 
end


newFigure = figure;
imshow(visualOutput);
imwrite(visualOutput, [outputFolder currentpatientID '.jpg']);

end

