function hstats = condense(data, fps)
% compute the background image
Imback = (data.bgframe);
[MR,MC,Dim] = size(Imback);
if nargin < 2, fps=9; end

dt=1/fps;

% Kalman filter initialization
%xt=At * (xt-1) + Bt * Ut + et
% et ~ N(0 , R ) 
%xt = [ xpos , ypos , xvelocity , y velocity] ~ N(0 , R ) 
R=[[0.2845,0.0045]',[0.0045,0.0455]'];
H=[[1,0]',[0,1]',[0,0]',[0,0]'];
% Measurement noise ~ Gauss(0 , Q )
% histograms error
Q=0.01*eye(4);
N=4;
A_still=[[1;0;0;0],[0;1;0;0],[0;0;1;0],[0;0;0;1]];  % still
A_norm_motion=[[1;0;0;0],[0;1;0;0],[dt;0;1;0],[0;dt;0;1]]; % normal motion

% initialisation
NCON=100;           % number of condensation samples
MAXTIME=length(data.frames);        % number of frames

x=zeros(N,NCON,MAXTIME,4);          % state vectors
weights=zeros(N,NCON,MAXTIME);      % est. probability of state
trackstate=zeros(N,NCON,MAXTIME);   % state=1,2;
P=zeros(N,NCON,MAXTIME,4,4);        % est. covariance of state vec.

% initialize estimated covariance
P(:,:,:,1:4,1:4) = 100;

pstop=0.3;      % probability of stopping vertical motion
% xc=zeros(4,1);   % selected state
TP=zeros(4,4);   % predicted covariance

for fr = 1 : MAXTIME,
    
    if fr==1,
        %returns a cell containing for each detected object
        % the values histogram, centroid, radius
        s = trackpeople( ...
            data.frames{fr},data.bgframe);
    else
        %if we are on frame 2,3..N we also send the previous state for
        %histogram comparison
        s = trackpeople( ...
            data.frames{fr},data.bgframe,hstats);
    end
    hstats(fr,:)=s;
    
    for object = 1:N,

        % condensation tracking
        % generate NCON new hypotheses from current NCON hypotheses
        % first create an auxiliary array ident() containing state vector j
        % SAMPLE*p_k times, where p is the estimated probability of j
        if fr ~= 1,
            SAMPLE=1000;
            ident=zeros(SAMPLE,1);
            idcount=0;
            for con = 1 : NCON,    % generate sampling distribution
                num=floor(SAMPLE*weights(object,con,fr-1));  % number of samples to generate
                if num > 0
                    ident(idcount+1:idcount+num) = con;
                    idcount=idcount+num;
                end
            end
        end

        % generate NCON new state vectors
        for con = 1 : NCON,
            % sample randomly from the auxiliary array ident()
            if fr==1 % make a random state vector
                xc = [s(object).Centroid(1)+rand(1), ...
                    s(object).Centroid(2)+rand(1), ...
                    0,0]';
            else
                k = ident(ceil(idcount*rand(1))); % select which old sample
                xc = reshape(x(object,k,fr-1,:), 4, 1);  % get its state vector

                % a priori belief %%%%%%%
                % sample about this vector from the distribution
                % (assume no covariance)
                tp = reshape(P(object,con,fr-1,:,:),4,4);
                xc = xc + 5*sqrt(tp)*rand(4,1);
            end

            % hypothesize if it is moving standing or rotating
            if fr == 1    % First frame objects are standing still
                xp = xc;   % no process at start
                A = A_still;
                trackstate(object,con,fr)=1;
            else
                r=rand(1);   % random number for state selection
                if r < pstop,
                    A = A_still;
                    xc(3:4) = 0;
                    trackstate(object,con,fr)=1;
                else
                    A = A_norm_motion;
                    % add some random motion due to imprecision
                    % about time of bounce
                    xc(1) = xc(1) + 3*abs(xc(3))*(rand(1)-0.5);
                    xc(2) = xc(2) + 3*abs(xc(4))*(rand(1)-0.5);
                    xc(3) = (2*(randi(2)-1)-1)*xc(3)*0.7;  % invert horizontal velocity
                    xc(4) = (2*(randi(2)-1)-1)*xc(4)*0.7;  % invert vertical velocity (lossy)
                    trackstate(object,con,fr)=2;  % set into bounce state
                end
                xp=A*xc;      % predict next state vector
            end

            % update & evaluate new hypotheses via Kalman filter
            % predictions
            if fr > 1,
                TP=reshape(P(object,con,fr-1,:,:), 4, 4);  % extract old P() - covariance matrix
            end
            Std_t = A*TP*A' + Q;    % predicted error
            % corrections
            K = Std_t*H'/(H*Std_t*H'+R);      % gain
            cc=s(object).Centroid(1);
            cr=s(object).Centroid(2);
            x(object,con,fr,:) = (xp + K*([cc,cr]' - H*xp))';    % corrected state
            P(object,con,fr,:,:) = (eye(4)-K*H)*Std_t;    % corrected error

            % weight hypothesis by distance from observed data
            dvec = [cc,cr] - [x(object,con,fr,1),x(object,con,fr,2)];
            weights(object,con,fr) = 1/(dvec*dvec');
            
        end
        
        % rescale new hypothesis weights
        % normalize all w
        % w(Σi)=1
        totalw=sum(weights(object,:,fr));
        weights(object,:,fr)=weights(object,:,fr)/totalw;

        % select top hypothesis to draw
        subset=weights(object,:,fr);
        top = find(subset == max(subset));
%         trackstate(object,top,fr)
        
        hstats(fr,object).Centroid(1)=x(object,top,fr,1);
        hstats(fr,object).Centroid(2)=x(object,top,fr,2);

    %         % draw some samples over one image
    %         if frame == 15 & fig1 > 0
    %           figure(fig1)
    %           hold on
    %           for c = -0.99*radius: radius/10 : 0.99*radius
    %             r = sqrt(radius^2-c^2);
    %             if trackstate{objects}(particle,frame)==1                 % stop
    %               plot(x{objects}(particle,frame,1)+c,x{objects}(particle,frame,2)+r,'c.')
    %               plot(x{objects}(particle,frame,1)+c,x{objects}(particle,frame,2)-r,'c.')
    %             elseif trackstate{objects}(particle,frame)==2             % bounce
    %               plot(x{objects}(particle,frame,1)+c,x{objects}(particle,frame,2)+r,'y.')
    %               plot(x{objects}(particle,frame,1)+c,x{objects}(particle,frame,2)-r,'y.')
    %             else                                  % normal
    %               plot(x{objects}(particle,frame,1)+c,x{objects}(particle,frame,2)+r,'k.')
    %               plot(x{objects}(particle,frame,1)+c,x{objects}(particle,frame,2)-r,'k.')
    %             end
    %           end
    %         end
    %       end


    %       % display final top hypothesis
    %       if fig1 > 0
    %         figure(fig1)
    %         hold on
    %         for c = -0.99*radius: radius/10 : 0.99*radius
    %           r = sqrt(radius^2-c^2);
    %     %      plot(x(top,i,1)+c,x(top,i,2)+r+1,'b.')
    %     %      plot(x(top,i,1)+c,x(top,i,2)+r,'y.')
    %           plot(x(top,frame,1)+c,x(top,frame,2)+r,'r.')
    %           plot(x(top,frame,1)+c,x(top,frame,2)-r,'r.')
    %     %      plot(x(top,i,1)+c,x(top,i,2)-r,'y.')
    %     %      plot(x(top,i,1)+c,x(top,i,2)-r-1,'b.')
    %         end
    %     %    eval(['saveas(gcf,''COND/cond',int2str(i-1),'.jpg'',''jpg'')']);  
    %       end
    end
end

end
