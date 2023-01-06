function t = nb_clock(format)
% Syntax:
%
% t = nb_clock
%
% Description:
%
% Get the current time on the given format. 
% 
% Input:
%
% - format : A string with the format:
%
%            > 'vintagemilliseconds' : 'yyyymmddhhnnssqqq'
%            > 'vintagelong'         : 'yyyymmddhhnnss'
%            > 'vintage'             : 'yyyymmddhhnn'
%            > 'vintageshort'        : 'yyyymmdd'
%            > 'gui'                 : 'Date: dd/mm/yyyy Time: hh:nn'
%
% Output:
% 
% t : A string.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        format = 'vintage';
    end

    switch lower(format)
        
        case 'vintagelong'
            
            t = datestr(now,'yyyymmddHHMMSS');
        
        case 'vintage'
    
            t = datestr(now,'yyyymmddHHMM');
            
        case 'vintagemilliseconds'
            
            t = datestr(now,'yyyymmddHHMMSSFFF');
            
        case 'vintageshort'
    
            t = datestr(now,'yyyymmdd');    
            
        case 'gui'
            
            c = clock;
            y = sprintf('%.0f',c(1));
            m = sprintf('%.0f',c(2)+100);
            d = sprintf('%.0f',c(3)+100);
            h = sprintf('%.0f',c(4)+100);
            n = sprintf('%.0f',c(5)+100);
            t = ['Date: ' d(2:3) '/' m(2:3) '/' y '  Time: ' h(2:3) ':' n(2:3)];
            
        otherwise
            
            error([mfilename ':: Unsupported format ' format])
            
    end

end
