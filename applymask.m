function frame = applymask( frame, mask )
%APPLYMASK Apply a mask on an RGB frame, filling the unused pixels with
%NaN
%   frame:  the input columns x rows x channels RGB frame
%   mask:   the columns x rows mask 
%   
%   return: a columns x rows x channels frame filled with NaN values where
%   the mask does not apply

% concatenate the mask for the 3 channels
rgbmask = cat(3, mask, mask, mask);

% fill with NaN where the mask does not apply
frame(~rgbmask) = NaN;

end

