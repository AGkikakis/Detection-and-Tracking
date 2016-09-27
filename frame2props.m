function props = frame2props( frame, bgframe, npeople, hprops )
%FRAME2PROPS Calculates the properties of an RGB frame, which are an
%extension of the REGIONPROPS properties.
%   frame:      the RGB frame from which people will be traked
%   bgframe:    the background frame (for background extraction)
%   npeople:    tha number of people we want to track
%   hprops:     the properties of the previous frames (history)
%   
%   return:     a Px1 structure array for the properties of the frame,
%               where P is the number of tracked people, and their
%               additional fields:
%               'Hist' is their 2D (red/green) histogram

% defaut number of people is 4
if nargin < 3, npeople=4; end

% detect the moving masses using background subtraction with
% similar foreground colours
mask=detectpeople(frame,bgframe);

% compute the labeled mask
labels=bwlabel(mask, 4);

% in case of colision among the detected objects, split the largest masses
% so that we have the desired number of masses
[labels, props] = splitlargest(labels, npeople);
nlabels=length(props);

% compute histograms and properties for every person
for l=1:nlabels,
    mask=zeros(size(labels));
    mask(labels==l)=1; % keep only one person mass
    rgb=applymask(frame, logical(mask));
    props(l).Hist=hist2d(rgb);
end

% this indices array keep the correct order of the people
ids=zeros(1,npeople);

% in case we have information about the history frames, we change
% the order of the detected people to be the same as in the previous
% frames, else we use the ordinary order
if (nargin > 3),
    bdist=zeros(length(hprops(1,:)),length(props)); % distance matrix
    edist=zeros(length(hprops(1,:)),length(props));
    
    for i=1:length(hprops(end,:)),
        % compute the average of the previous histograms of this person
        mhist=hprops(1,i).Hist;
        L=1;
        for j=2:length(hprops(:,i)),
            if norm(hprops(j,i).Centroid - ...
                    hprops(j-1,i).Centroid,2) < 10,
                mhist=mhist+hprops(j,i).Hist;
                L=L+1;
            end
        end
        mhist=mhist/length(L);
        
        % compute the Bhattacharyya distance between this person and all
        % the detected people
        for j=1:length(props),
            edist(i,j)=norm(hprops(end,i).Centroid-props(j).Centroid,2);
            bdist(i,j)=bhattacharyya(mhist, props(j).Hist);
        end
    end
    
    % use a pessimistic decision making algorithm to solve the conflict
    % under uncertainty
    bmap=minimax(bdist);
    [x, y]=find(edist < 10);
    if length(unique(x)) ~= 4 || length(unique(y)) ~= 4 || ...
            all(edist(logical(bmap)) < 10),
        [x, y]=find(bmap==1);
    end
%     [x, y]=find(bmap==1);
    ids(x)=y;
else
    % for the first frame use the default order
    ids=1:npeople;
end

% change the order of the computed properties
props=props(ids);

end
