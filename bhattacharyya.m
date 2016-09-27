function [bdist, bcoeff] = bhattacharyya( hist1, hist2, distopt )
%BHATTACHARYYA Computes the Bhattacharyya coefficient and distance for the
%input 2D histograms
%   hist1:      the first 2D histogram
%   hist2:      the second 2D histogram
%   distopt:    option for the distance measure to use:
%               'bhattacharyya' (default)
%               'hellinger'
%   
%   return:     the selected distance and the BH coefficient

if nargin < 3, distopt='b'; end

% estimate the bhattacharyya co-efficient
bcoeff=min(sum(sqrt(hist1(:) .* hist2(:))), 1);

% get the distance between the two distributions as follows
if strcmp(distopt,'bhattacharyya') == 0 || strcmp(distopt,'b') == 0,
    bdist=-log(bcoeff); % Bhattacharyya distance
elseif strcmp(distopt,'hellinger') == 0 || strcmp(distopt,'h') == 0,
    bdist=sqrt(1. - bcoeff); % Hellinger distance
end

end

