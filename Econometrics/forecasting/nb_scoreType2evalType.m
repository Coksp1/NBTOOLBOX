function [evalType,type] = nb_scoreType2evalType(type)
% Syntax:
%
% [evalType,type] = nb_scoreType2evalType(type)
%
% Description:
%
% Get evaluation type from score type.
% 
% Input:
% 
% - type     : Score type, as a one line char. May include a frequency
%              frequency postfix (_4 or _12).
% 
% Output:
% 
% - evalType : Evaluation type, as a one line char. With frequency postfix.
%
% - type     : Score type, as a one line char. Without frequency postfix.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    type = regexp(type,'_','split');
    if size(type,2) == 1
        type = type{1};
        freq = '';
    else
        freq = type{2};
        type = type{1};
    end
    switch lower(type)
        case {'mse','rmse','smse'}
            evalType = 'SE';
        case {'mae','smae'}
            evalType = 'ABS';
        case {'me','mean','std'}
            evalType = 'DIFF';
        case {'esls','eels','mls'}
            evalType = 'LOGSCORE';
        otherwise 
            error([mfilename ':: Unsupported forecast evaluation type ' type]) 
    end  
    if ~isempty(freq)
        evalType = [evalType,'_',freq];
    end

end
