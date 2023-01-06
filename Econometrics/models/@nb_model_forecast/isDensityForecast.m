function ret = isDensityForecast(obj)
% Syntax:
%
% ret = isDensityForecast(obj)
%
% Description:
%
% Has the nb_model_forecast object produced density forecast or not?
% 
% Input:
% 
% - obj : A nb_model_forecast object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                fcst = obj(ii,jj,kk).forecastOutput;
                if ~nb_isempty(fcst)
                    
                   draws = fcst.draws;
                   if isempty(draws)
                       draws = 1;
                   end
                   pDraws = fcst.parameterDraws;
                   if isempty(pDraws)
                       pDraws = 1;
                   end
                   if draws*pDraws > 1
                       ret(ii,jj,kk) = true;
                   end
                   
                end
            end
        end
    end
    
end
