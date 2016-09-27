function c = minimin( M )
%MINIMIN Summary of this function goes here
%   Detailed explanation goes here

[w,h]=size(M);
if w~=h, error('Input must be square matrix.'); end

c=zeros(size(M));
M=M+1;  % We add one to make sure we don't have zero values
for i=1:w,
    sx = sum(M,2,'omitnan');
    sy = sum(M,1,'omitnan');
    sx(sx==0)=NaN;
    sy(sy==0)=NaN;
    if (min(sx) > min(sy)),
        [~,x]=min(sx,[],'omitnan');
        [~,y]=min(M(x,:),[],'omitnan');
    else
        [~,y]=min(sy,[],'omitnan');
        [~,x]=min(M(:,y),[],'omitnan');
    end
    c(x,y)=1;
    M(x,:)=NaN;
    M(:,y)=NaN;
end

end

