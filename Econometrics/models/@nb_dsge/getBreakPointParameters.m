function [params,values,stdvalues] = getBreakPointParameters(parser,init)
% Syntax:
%
% [params,values] = nb_dsge.getBreakPointParameters(parser,init)
% [params,values,stdvalues] = nb_dsge.getBreakPointParameters(parser,init)
%
% Description:
%
% Get break point parameters names and values.
% 
% Input:
% 
% - parser : See the nb_dsge.parser property.
% 
% - init   : Give true to use the date prior to estimation.
%
% Output:
% 
% - params : A nParam x 1 cellstr with the names of the parameters.
%
% - values : A nParam x 1 double with the values of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nBreaks     = parser.nBreaks;
    breakPoints = parser.breakPoints;
    numNew      = 0;
    for ii = 1:nBreaks
        numNew = numNew + length(breakPoints(ii).parameters);
    end

    params = cell(numNew,1);
    values = nan(numNew,1);
    kk     = 1;
    for ii = 1:nBreaks
        if init
            breakP = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).initDate));
        else
            breakP = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).date));
        end
        breakP                = breakP(:);
        breakV                = breakPoints(ii).values(:);
        nBP                   = size(breakV,1);
        params(kk:kk+nBP-1,:) = breakP;
        values(kk:kk+nBP-1,:) = breakV;
        kk                    = kk + nBP;
    end
    
    if nargout > 2
        
        stdvalues = nan(numNew,1);
        kk        = 1;
        for ii = 1:nBreaks
            breakSTDV                = breakPoints(ii).stdValues(:);
            nBP                      = size(breakSTDV,1);
            stdvalues(kk:kk+nBP-1,:) = breakSTDV;
            kk                       = kk + nBP;
        end
        
    end

end
