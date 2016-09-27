function fore = similar_fore_colours( iframe, bgframe, tau )
%SIMILAR_FORE_COLOURS A brief backgroud subtraction method which use
%saturation of the frame and the bacground frame to detect object.
%   iframe:     the input frame
%   bgframe:    the background frame
%   tau:        the threshold (default 10 gray scales)
%   
%   return:     a logical matrix which identifies the foreground object

if nargin < 3, tau = 10; end

sB = intensity(bgframe); % background saturation
sB(sB==0) = 1; % to avoid deviation by 0

% compute ratio constrains
constrain = tau ./ sB;
alpha = 1 - constrain;
beta = 1 + constrain;

si = intensity(iframe); % frame saturation
si(si==0) = 1; % to drop the pixels with the same value
ratio = si ./ sB;
fore = ratio < alpha | ratio > beta; % compute the foreground mask

end