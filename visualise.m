function visualise( frames, stats, loop, fps )
%VISUALISE Playback the frames combined with their computed statistics.
%   frames:     a cell array of RGB frames
%   stats:      the respective stats (optional)
%   loop:       describes if we want to auto-replay the video
%   fps:        the frame-rate (default is 9 fps)

if nargin < 2, stats = []; end
if nargin < 3, loop = false; end
if nargin < 4, fps = 9; end

fig = figure('Name', 'Playback');
N = size(stats, 2);
while true,
    for i=1:length(frames),
        imshow(frames{i}); % show RGB image
        hold on;
        color=['m', 'g', 'c', 'y']; % colors for circles
        for c=1:N,
%             r = stats(i,c).Radius;
            r = 17; % default radius is 17
            
            % show tracked people using circles
            for j=max(2, i-50):i,
               line([stats(j-1,c).Centroid(1), ...
                   stats(j,c).Centroid(1)], ...
                   [stats(j-1,c).Centroid(2), ...
                   stats(j,c).Centroid(2)], ...
                   'Color', color(c), 'LineWidth', 2); 
            end
            viscircles(stats(i,c).Centroid,r, ...
                'EdgeColor', color(c));
        end
        hold off;
        drawnow();
        pause(1/fps);  % sleep to keep the frame-rate
        if ~ishandle(fig), break; end % stop if figure is closed
    end
    if ~loop || ~ishandle(fig), break; end
end

end

