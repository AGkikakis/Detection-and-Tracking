function data = load_data( dirname, bgname, gtname, datapt )
%LOAD_DATA Loads the data given the directory, background frame name and
%the ground-truth file name
%   dirname:    the directory path which contains the frames files
%   bgfame:     the background frame name (it should be incuded in the
%   specified directory) 
%   gtname:     the ground-truth file name (it should be included in the
%   specified directory)
%
%   return:     a structure with frames, tha background frame and the
%   ground-truth positions
%                       'frames'    cell array containing all the RGB frames
%                       'bgframe'   the RGB background frame
%                       'gtpositions'   the ground-truth centroids

if nargin < 4, datapt = 'frame*.jpg'; end
if nargin < 3, gtname = 'positions1.mat'; end
if nargin < 2, bgname = 'bgframe.jpg'; end
if nargin < 1, dirname = 'DATA1'; end

load(fullfile(dirname, gtname))
data.gtpositions = positions; % load ground-truth positions
data.bgframe = imread(fullfile(dirname, bgname)); % load background
fframes = dir(fullfile(dirname, datapt)); % find filenames of this pattern

% load frames
for i=1:length(fframes),
    data.frames{i} = imread(fullfile(dirname, fframes(i).name));
end

end