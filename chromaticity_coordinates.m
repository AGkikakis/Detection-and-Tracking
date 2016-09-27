function oframe = chromaticity_coordinates( iframe )
%CHROMATICITY_COORDINATES Compute the normalised red and green channels of
%an RGB image
%   iframe:     the input RGB image
%   
%   return:     the chromaticity coordinates of the RGB image (red and
%   green)

sat = intensity(iframe) * 3; % saturation
sat(sat==0) = 1; % set sat=1 where sat=0, to avoid deviding by zero

% light normalisation (keep only red and green)
oframe = double(iframe(:,:,1:2)) ./ cat(3, sat, sat);

end

