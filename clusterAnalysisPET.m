function [Blobcounter, Bloblist] = clusterAnalysisPET(inputNifti, petThreshold, voxelCountThreshold, individualSUVFactor, PatientID, SUVThreshold)

if ~exist('individualSUVFactor','var')
  individualSUVFactor=1;
end


MatrixSize = size(inputNifti.img);
Blobcounter = 0;

thresholdedBinaryImage = inputNifti;
thresholdedBinaryImage.img = inputNifti.img > petThreshold;

outputImageMask = thresholdedBinaryImage;
outputImageMask.img = thresholdedBinaryImage.img .* 0;

%initialize temporary Matrix for calculations
tempMatrix = inputNifti.img;

for i = 2:(MatrixSize(1)-1)
    for j = 2:(MatrixSize(2)-1)
        for k = 2:(MatrixSize(3)-1)

        if thresholdedBinaryImage.img(i,j,k) && ~outputImageMask.img(i,j,k)
            
           [ExtractedVoxels nVoxels] = FloodFill3D_JH(thresholdedBinaryImage.img, [i j k]); 
           %disp(nVoxels);
           
           %disp(nVoxels);
           if nVoxels > voxelCountThreshold
               
               %Mark all voxels of blob in outputImageMask
               %outputImageMask.img(i,j,k) = 1;
               outputImageMask.img(ExtractedVoxels) = 1;
               Blobcounter = Blobcounter + 1;
                       
               %Calculate max and mean value for current blob
               tempMatrix = tempMatrix .*0;
               tempMatrix(ExtractedVoxels) = 1;
               tempMatrix = tempMatrix .* inputNifti.img;
               currentMax = max(tempMatrix(:));
               currentMean = sum(tempMatrix(:))/nVoxels;
               
               %Find geometric center of ExtractedVoxels
               [xCoordinates yCoordinates zCoordinates]=ind2sub(size(ExtractedVoxels),find(ExtractedVoxels == 1));
               currentCenterOfBlob = geometricCenter3D(xCoordinates,yCoordinates,zCoordinates);      
               
               %Find hottest voxel of ExtractedVoxels
%               [xHot yHot zHot]=ind2sub(size(tempMatrix),find(tempMatrix == currentMax));
                          
               %Save results to Bloblist
               Bloblist(Blobcounter).PatientID = PatientID;
               Bloblist(Blobcounter).SUVThreshold = SUVThreshold;
               Bloblist(Blobcounter).Number = Blobcounter;
               Bloblist(Blobcounter).Volume = nVoxels;
               Bloblist(Blobcounter).Max = currentMax / individualSUVFactor;
               Bloblist(Blobcounter).Mean = currentMean / individualSUVFactor;
               Bloblist(Blobcounter).VolTimesMean = currentMean / individualSUVFactor * nVoxels;
               Bloblist(Blobcounter).CenterPoint = currentCenterOfBlob;
              
          
           end
               
        end


        end
    end
    disp([num2str(round(100*i/MatrixSize(1))) '%']);
end

end

