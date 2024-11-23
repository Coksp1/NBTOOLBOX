function obj = denton(obj,z,k,type,d)
% Syntax:
%
% obj = denton(obj,z,k,type,d)
%
% Description:
%
% The Denton method of transforming a series from low to high frequency.
% 
% See Denton (1971), Adjustment of Monthly or Quarterly Series to Annual  
% Totals: An Approach Based on Quadratic Minimization.
%
% Input:
% 
% - obj  : A nobs x nvars x npage nb_math_ts object with the main  
%          variables to transform.
%
% - z    : A nobs*k x nvars x npage double with observations on the 
%          judgment.
% 
% - k    : The number intra low frequency observations. If you have annual
%          data and want out quarterly data use 4.
%
% - type : Either 'sum', 'average', 'first' or 'last'. 'average' is 
%          default.
%
% - d    : 1 : first differences, 2 : second differences.
%
% Output:
% 
% - x    : Output series as a nobs*k x nvars x npage nb_math_ts object.
%
% See also:
% nb_math_ts.convert, nb_denton
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        d = 1;
        if nargin < 4
            type = 'average';
            if nargin < 3
                k = 4;
                if nargin < 2
                    z = [];
                end
            end
        end
    end
     
    if obj.startDate.frequency == 1
        if ~ismember(k,[4,12])
            error([mfilename ':: The k input can only be 4 or 12 when dealing with yearly data'])
        end
        outFreq = k;
    elseif obj.startDate.frequency == 4
        if k ~= 3
            error([mfilename ':: The k input can only be 3 when dealing with quarterly data'])
        end
        outFreq = 12;
    else
        error([mfilename ':: The denton method is only supported for yearly or quarterly data.'])
    end
    
    
    startZ = obj.startDate.convert(outFreq,1);
    endZ   = obj.endDate.convert(outFreq,0);
    if isempty(z)
        zData = [];
    else
        
        if ~isa(z,'nb_math_ts')
            error([mfilename ':: The z input must be an object of class nb_math_ts.'])
        end
        if z.startDate.frequency ~= outFreq
            error([mfilename ':: The z input must have frequency ' nb_date.getFrequencyAsString(outFreq)])
        end
        if z.dim3 ~= obj.dim3
            error([mfilename ':: The obj and z inputs must have the same number of pages.'])
        end
        zTemp = z;
        if zTemp.startDate < startZ
            zTemp = window(zTemp,startZ);
        end
        if zTemp.endDate > endZ
            zTemp = window(zTemp,'',endZ);
        end
        if zTemp.startDate > startZ || zTemp.endDate < endZ
            zTemp = expand(zTemp,startZ,endZ,'zeros','off');
        end
        if z.dim2 ~= obj.dim2
            error([mfilename ':: The z input must have as many variables as obj.'])
        end
        zData = double(zTemp);
        
    end

    dentonData    = nb_denton(obj.data,zData,k,type,d);
    obj.startDate = startZ;
    obj.endDate   = endZ;
    obj.data      = dentonData;
    
end
