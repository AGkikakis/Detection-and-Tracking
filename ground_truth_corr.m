function statistics=ground_truth_corr(stats,ground_truth)

tau=10;
%create cell to return
% statistics=cell(1);
%Make stats a matrix 
centers=zeros(size(ground_truth));
for frame=1:210,
    for objects=1:4,
        centers(objects,frame,:)=stats(frame,objects).Centroid;
    end
end

%Calculate the error
error=zeros(4,4);
for i=1:4,
    for j=1:4,
        euclidian=sqrt( sum( (centers(i,:,:)-ground_truth(j,:,:)).^2 ,3) );
        error(i,j)=sum(sum(euclidian>tau));
    end
end



%Find the least errors
[x y]=find(minimax(error));
%Find correspondances eg. detected person 1 is matched with person 2 of the
%ground truth
correspondance=[x y];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate trajectory error
traj_error=zeros(numel(centers(:,1,1)),numel(centers(1,:,1)));
for traj=1:4,
    traj_error(1,:)=sqrt( sum( (centers(traj,:,:)-ground_truth(correspondance(traj,1),:,:)).^2 ,3) );
end

%euclidian=sqrt( sum( (centers(traj,:,:)-ground_truth(correspondance(traj,1),:,:)).^2 ,3) );
mean_traj=mean(traj_error(:));
var_traj=std(traj_error(:));

detection_error=1000*ones(4,210);
%Objects detected in a 10 pixels radious of any ground truth
obj_detected=zeros(numel(centers(:,1,1)),numel(centers(1,:,1)));
mean_obj_detected=zeros(numel(centers(:,1,1)),numel(centers(1,:,1)));

for i=1:210,
    for j=1:4,
        for s=1:4,
            diff=centers(s,i,:)-ground_truth(j,i,:);
            euclidian_dist=sqrt(sum(diff.*diff));
            detection_error(j,i)=min(detection_error(j,i),euclidian_dist);
            if euclidian_dist<tau,
                obj_detected(j,i)=obj_detected(j,i)+1;
            end
        end
    end
end

statistics.Detection_Error=sum(sum(detection_error>tau))/numel(detection_error);
statistics.Mean_Obj_Detected_within_ground_truth_radius=mean(obj_detected(:));
statistics.Mean_Dist_Detected_within_ground_truth_radius=...
    mean(detection_error(logical(detection_error<tau)));

statistics.N_of_false_pairings=sum(error(logical(minimax(error))));
statistics.N_of_pairings=numel(ground_truth(:,:,1));
statistics.Trajectory_Error=sum(error(logical(minimax(error))))/numel(ground_truth(:,:,1));
statistics.Trajectory_Mean=mean_traj;
statistics.Trajectory_Variance=var_traj;

end