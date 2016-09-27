function c = minimax( M )
%MINIMAX The Minimax decision making algorithm used for minimising the
%distance for a worst scenario.
%   M:      the matrix with the all-to-all distances
%   
%   return  the optimal (logical) positions on the matrix

[w,h]=size(M);
if w~=h, error('Input must be square matrix.'); end

c=zeros(size(M));
M=M+1;  % We add one to make sure we don't have zero values
for i=1:w,
    % compute the sums od the columns and rows
    sx=sum(M,2,'omitnan');
    sy=sum(M,1,'omitnan');
    
    % in case the column or row has olny NaN values, the sum will be zero,
    % so we change it to NaN. This is safe, as in eny other case the sum
    % will never be zero
    sx(sx==0)=NaN;
    sy(sy==0)=NaN;
    
    % find the column or row with the maximum sum and keep the coordinates
    % of the minimun distance
    if (max(sx) > max(sy)),
        [~,x]=max(sx,[],'omitnan');
        [~,y]=min(M(x,:),[],'omitnan');
    else
        [~,y]=max(sy,[],'omitnan');
        [~,x]=min(M(:,y),[],'omitnan');
    end
    % mark the cell with the minimum value and erase is column and row from
    % the matrix
    c(x,y)=1;
    M(x,:)=NaN;
    M(:,y)=NaN;
end

end

