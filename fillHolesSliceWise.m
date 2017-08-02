function [ outputMatrix ] = fillHolesSliceWise( inputMatrix )
%fills Holes Slice Wise


xDim = size(inputMatrix, 1);
yDim = size(inputMatrix, 2);
zDim = size(inputMatrix, 3);

%prevent skull from being filled
if zDim > 320
    zDim = 320
end

outputMatrix = inputMatrix;

for i=1:zDim
    outputMatrix(:,:,i) = imfill(inputMatrix(:,:,i), 'holes');
end

end

