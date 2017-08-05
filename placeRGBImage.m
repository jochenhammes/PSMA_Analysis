function outputImage = placeRGBImage(baseImage, imageToPlace,x,y, transparencyMap)
%   places an RGB image onto another RGB-image


xSize = size(imageToPlace,2);
ySize = size(imageToPlace,1);
outputImage = baseImage;

    for i = 1:ySize
        for j = 1:xSize
            if transparencyMap(i,j) > 0
                outputImage(i+y,j+x,1) = imageToPlace(i,j);
                outputImage(i+y,j+x,2) = imageToPlace(i,j);
                outputImage(i+y,j+x,3) = imageToPlace(i,j);
            end
        end
    end
    

end


