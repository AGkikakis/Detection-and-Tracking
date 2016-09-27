function visualiselabels( labels, show )
%VISUALISELABELS Visualise the area of detected labels with different
%colours
%   labels:     the labels-mask
%   show:       the figure number (default is 1)

if nargin < 2, show=1; end

% select the different labels (including background = 0)
dfore = unique(reshape(labels,size(labels,1)*size(labels,2),1));

% construct the RGB space
rmask=zeros(size(labels));
gmask=zeros(size(labels));
bmask=zeros(size(labels));

D=length(dfore);
if nargin < 3, numlabels=D-1; end

% give colours to the labels
for d=2:D,
    rmask(labels==dfore(d))=mod(d-2,numlabels)/double(D-1);
    gmask(labels==dfore(d))=mod(d-1,numlabels)/double(D-1);
    bmask(labels==dfore(d))=mod(d-0,numlabels)/double(D-1);
end

% concatenate the channels to construct the image
rgbmask=cat(3, rmask, gmask, bmask);

figure(show); imshow(rgbmask);

end