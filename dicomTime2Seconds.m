function [secondsOutput] = dicomTime2Seconds(dicomTime)
% converts DICOM time to Seconds of the respective day starting at  00:00:00h

dicomTimeHours = str2num(dicomTime(1:2));
dicomTimeMinutes = str2num(dicomTime(3:4));
dicomTimeSeconds = str2num(dicomTime(5:6));

secondsOutput = dicomTimeSeconds + 60 * dicomTimeMinutes + 3600 * dicomTimeHours;

end

