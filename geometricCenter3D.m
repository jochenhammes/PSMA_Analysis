function centerPoint = geometricCenter3D(xCoordinates, yCoordinates, zCoordinates)
%calculates the geometric center of a list of 3D coordiantes
    
x = mean(xCoordinates);
y = mean(yCoordinates);
z = mean(zCoordinates);

centerPoint = round([x y z]);

end

