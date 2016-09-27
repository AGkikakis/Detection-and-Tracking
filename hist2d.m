function h2d = hist2d( rgb, show )
%HIST2D Compute the 2D normalised red/green histogram of the given RGB
%image.
%   rgb:    the input RGB image
%   show:   option to visualise the 2D histogram (default false)
%   
%   result: the 2D histogram of the image

impixels=numel(rgb)/size(rgb,3); % the number of pixels on the image
edges=(0:255) / 255; % edges for the histogram

% compute the red/green normalised channels
rg=chromaticity_coordinates(rgb);
r=reshape(rg(:,:,1),1,impixels);
g=reshape(rg(:,:,2),1,impixels);

% remove the NaN pixel and the pixels where both channels are zero
mask=(~isnan(r) & ~isnan(g)) & (r~=0 | g~=0);
hrg=[r(mask);g(mask)]';
h2d=hist3(hrg,'Edges',{edges, edges}) / length(hrg);

% visualise the histogram
if nargin > 1 && show > 0,
    figure(show);
    surf(h2d);
end

end

