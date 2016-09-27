%% Load data
data = load_data('DATA1','bgframe.jpg',...
    'positions1.mat','frame*.jpg');

%% Visualise data
visualise(data.frames, [], true, 9);

%% Detect and track people
clear nstats;
for t=1:length(data.frames),
    if t==1,
        nstats(t,:) = trackpeople( ...
            data.frames{t},data.bgframe);
    else
        nstats(t,:) = trackpeople( ...
            data.frames{t},data.bgframe,nstats);
    end
end

%% Visualise tracked people
dvisualise(data.frames, nstats, data.gtpositions, false, 9, 50);
% frames, props (centers), ground-truth, loop, fps, max-line-length

%% Evaluation
disp(ground_truth_corr(nstats, data.gtpositions));
