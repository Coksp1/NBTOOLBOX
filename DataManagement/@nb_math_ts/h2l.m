function obj = h2l(obj,freq,type)
% Syntax:
%
% obj = h2l(obj,freq,type)
%
% Description:
%
% Will for each observation calculate the weighted cumulative sum over the  
% last N periods (Including the present). The weights will depend on the 
% frequency and the selected type. Examples will be given in the case of
% monthly data and freq = 4;
% - 'levelSummed'  : Y(q)      = Y(m) + Y(m-1) + Y(m-2)
% - 'diffSummed'   : Y(q)      = Y(m) + 2*Y(m-1) + 3*Y(m-2) +
%                                2*Y(m-3) + Y(m-4)
% - 'levelAverage' : Y(q)      = 1/3*(Y(m) + Y(m-1) + Y(m-2))
% - 'diffAverage'  : Y(q)      = 1/3*Y(m) + 2/3*Y(m-1) + Y(m-2) +  
%                                2/3*Y(m-3) + 1/3*Y(m-4)
% 
% Input:
% 
% - obj  : An object of class nb_math_ts.
% 
% - freq : The low frequency to convert high frequency observations to.
%
% - type : See description of method. Default is 'levelAverage'
% 
% Output:
% 
% - obj : An object of class nb_math_ts. Caution: The frequency of the
%         nb_math_ts will not be converted. See nb_math_ts.convert in this
%         case.
%
% See also:
% nb_math_ts.convert
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'levelAverage';
    end

    if obj.startDate.frequency > 12
        error(['This method is only defined for frequencies lower then ',...
               'or equal to monthly.'])
    end
    
    divFreq = obj.startDate.frequency/freq;
    switch lower(type)
        case 'levelsummed'
            w = ones(1,divFreq);
            k = divFreq;
        case 'diffsummed'
            w = 1:divFreq;
            w = [w, fliplr(w(1:end-1))];
            k = size(w,2);
        case 'levelaverage'
            w = ones(1,divFreq)*1/divFreq;
            k = divFreq;
        case 'diffaverage'
            w = 1:divFreq;
            w = [w, fliplr(w(1:end-1))];
            w = w/divFreq;
            k = size(w,2);
        otherwise
            error(['Unsupported type ' type])
    end
    obj.data = nb_subSum(obj.data,k,w);

end
