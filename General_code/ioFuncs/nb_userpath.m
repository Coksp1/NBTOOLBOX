function uPath = nb_userpath(type)
% Syntax:
%
% uPath = nb_userpath(type)
%
% Description:
%
% Get userpath. If the path return by the MATLAB function userpath is empty
% the pwd is used instead.
% 
% Input:
% 
% - type : A string with either
%
%          > 'normal' : userpath or pwd (without semicolon at the end).
%                       (default)
%
%          > 'gui'    : Same as normal but added \nb_GUI at the end 
% 
% Output:
% 
% - uPath : A string. For more see inputs  
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        type = 'normal';
    end
    
    if strcmpi(type,'gui')
        
        uPath = userpath;
        if isempty(uPath)
            uPath = [strrep(pwd,';',''),'\nb_GUI'];
        else
            uPath = [strrep(uPath,';',''),'\nb_GUI'];
        end
        
    else
        
        uPath = userpath;
        if isempty(uPath)
            uPath = strrep(pwd,';','');
        else
            uPath = strrep(uPath,';','');
        end
        
    end
    
end

