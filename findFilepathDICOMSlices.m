function [ filepath ] = findFilepathDICOMSlices( pathDICOMParent )
    
    % Loop through subfolders to find the final folder containing the
    % all the images
    
    
    filepath = pathDICOMParent;
    
    finalFolderReached = false;
    while not(finalFolderReached)
        Subfolders = dir(filepath);
        Subfolders(not([Subfolders(:).isdir])) = [];
        Subfolders(1:2) = [];
        if isempty(Subfolders)
            finalFolderReached = true;
            break
        end
        filepath = [filepath filesep Subfolders(1).name];
    end



end

