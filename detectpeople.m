function mask = detectpeople( frame, bgframe, ignore_at )
%DETECTPEOPLE Computes a cleaned mask which contain the mass of all the
%detected people.
%   frame:      the RGB frame from which people will be detected
%   bgframe:    the background frame (for background extraction)
%   ignore_at:  array of points on the frame, where we will ignore the
%   objects detected within 50 pixels of their range (box)
%   
%   return:     a logical matrix defining the detected objects

% ignore the laptop and the person who is calling the dance by default
if nargin < 3, ignore_at = [[140, 180]; [226, 120]; [370, 590]]; end
% figure(1); imshow(frame);

% compute the initial foreground mask
fore = similar_fore_colours(frame, bgframe);
% figure(2); imshow(fore);

% Remove groups with less than 100 pixels
forem = bwareaopen(fore, 100);
% figure(3); imshow(forem);
    
% erode, dilate and close to fill in gaps
foremm = bwmorph(forem,'erode',1);
foremm = bwmorph(foremm,'dilate',2.5);
foremm = imclose(foremm,strel('disk',3));
% figure(4); imshow(foremm);

% select largest object
forel = bwlabel(foremm, 4);

% ignore detected objects in around predefined points
r=100;
for k=1:length(ignore_at),
    c = ignore_at(k,:);
    label = forel(max(c(1)-r,1):min(c(1)+r,end),max(c(2)-r,1):min(c(2)+r,end));
    label = label(label ~= 0);
    label = unique(label(:));
    for l=1:length(label),
        forel(forel==label(l)) = 0;
    end
end

% return the logical mask (not labels)
mask = logical(forel);
% figure(5); imshow(mask);

end

