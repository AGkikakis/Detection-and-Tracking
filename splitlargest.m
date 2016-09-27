function [labels, props] = splitlargest( labels, nlabels )
%SPLITLARGEST Takes a label-mask and changes the number of its labels
%spliting the largest masses.
%   labels:     the initial label-mask
%   nlebels:    the desirable number of labels
%   
%   return:     the new labels and all their properies (computed by
%   REGIONPROPS)

props=regionprops(labels,'all');
if nargin < 2, nlabels = length(props); end

% number of labels we have to add
mlabels=nlabels-length(props);

% loop over the number of labels we need to add
for l=1:mlabels,
    % choose the centres of the label with the largest area
    [~,i]=max(extractfield(props,'Area'));
    xc=props(i).Centroid(1);
    yc=props(i).Centroid(2);
    % and compute a point on the vertical axis of their orientation
    x0=xc+cosd(-props(i).Orientation+90);
    y0=yc+sind(-props(i).Orientation+90);
    % compute the parameters of the line that splits area
    a=(yc-y0)/(xc-x0);
    b=-a*xc+yc;
    % find the pixels of the new label
    v=[-a; 1];
    ilogic=props(i).PixelList*v<b;
    ids=props(i).PixelIdxList(ilogic);

    % change the value of the label
    label=max(unique(labels))+1;
    labels(ids)=label;
    
    % recalculate the properties of the labels
    props=regionprops(labels,'all');
end

% visualiselabels(labels);

end

