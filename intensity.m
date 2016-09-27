function oframe = intensity( iframe, normalise, scale )
%INTENSITY The saturation of the pixels of a frame.
%   iframe:     the input frame
%   normalise:  flag to normialise or not the value in [0,1]
%   scale:      the normalisation scale (default is 255)

if nargin < 2, normalise = false; end
if nargin < 3, scale = 255.; end

oframe = mean(double(iframe), 3); % saturation
if normalise, oframe = oframe / scale; end

end

