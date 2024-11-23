function [obj,m,s] = mZScoreData(obj,backward,forward,shift)
% Syntax:
%
% obj = mZScore(obj,backward,forward)
%
% Description:
%
% Taking moving Z-Score of all the timeseries of the 
% nb_ts class
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - backward : Number of periods backward in time to calculate the 
%              moving Z-Score
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving Z-Score
% 
% - shift    : Number og the last observations not to include in the 
%              calculations og the mean and standard deviation.
% 
% Output:
% 
% - obj      : An nb_ts object storing the calculated moving 
%              Z-Score
%
% - m        : Array 
% 
% Examples: 
% 
% data = nb_ts(rand(50,2)*3,'','2011Q1',{'Var1','Var2'});
% 
% zScore10 = mZScore(data,9,0); % (10 quarter moving Z-Score)
% zScore10 = mZScore(data,9,0,1); % (10 qtr mvg Z-Score shifted 1 qtr)
% 
% Written by Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if nargin < 4
        shift = 0;
        if nargin < 3
            forward = 0;
        end
    end
    
    if (backward < 0 )
        error([mfilename ':: The input parameter backward must be positive.'])
    end
    
    if (forward < 0 )
        error([mfilename ':: The input parameter forward must be positive.'])
    end
    
    if (shift < 0 )
        error([mfilename ':: The input parameter shift must be positive.'])
    end

    n = nan(size(obj.data));
    m = nan(size(obj.data));
    s = nan(size(obj.data));
    d = obj.data(1:end,:,:);

    for ii = 1 + backward + shift: size(d,1) - forward     
        m(ii,:,:) = mean(d(ii - backward - shift:ii + forward - shift,:,:),1,'omitnan');
        s(ii,:,:) = std(d(ii - backward - shift:ii + forward - shift,:,:),0,'omitnan');
        n(ii,:,:) = (d(ii,:,:) - m(ii,:,:))./s(ii,:,:);
    end
    obj.data = n;
       
end
