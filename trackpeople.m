function stats = trackpeople( frame, bgframe, hstats )
%TRACKPEOPLE Tracks people in a frame given the background frame and the
%history of the statistics. If the history is not given, it assumes that
%this is the first frame.
%   frame:      the RGB frame from which people will be traked
%   bgframe:    the background frame (for background extraction)
%   hstats:     the statistics of the previous frames (history)
%   
%   return:     a Px1 structure array for the statistics of the frame,
%               where P is the number of tracked people, and its fields:
%               'Centroid' is the centroid for each person detected
%               'Radius' is the radius of the circle that contains them
%               'Hist' is their 2D (red/green) histogram

isfirst=nargin<3;
if isfirst, numofpeople=4;
else numofpeople=length(hstats(end,:));
end

if (isfirst),
    props=frame2props(frame,bgframe,numofpeople);
else
    props=frame2props(frame,bgframe,numofpeople,hstats);
end

% get center of mass and radius of largest
for p=1:length(props),
    stats(p) = struct( ...
        'Centroid',props(p).Centroid, ...
        'Radius',sqrt(props(p).Area/pi), ...
        'Hist',props(p).Hist);
end

end

