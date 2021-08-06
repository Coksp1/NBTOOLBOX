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
%            > 'vintagelong'  : 'yyyymmddhhmmss'
%            > 'vintage'      : 'yyyymmddhhmm'
%            > 'vintageshort' : 'yyyymmdd'
%            > 'gui'          : 'Date: dd/mm/yyyy Time: hh:mm'
%
% Output:
% 
% t : A string.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        format = 'vintage';
    end

    c  = clock;
    y  = sprintf('%.0f',c(1));
    m  = sprintf('%.0f',c(2)+100);
    d  = sprintf('%.0f',c(3)+100);
    h  = sprintf('%.0f',c(4)+100);
    mi = sprintf('%.0f',c(5)+100);
    switch lower(format)
        
        case 'vintagelong'
            
            sec = sprintf('%.0f',c(6)+100);
            t   = [y m(2:3) d(2:3) h(2:3) mi(2:3) sec(2:3)];
        
        case 'vintage'
    
            t  = [y m(2:3) d(2:3) h(2:3) mi(2:3)];
            
        case 'vintageshort'
    
            t  = [y m(2:3) d(2:3)];    
            
        case 'gui'
            
            t  = ['Date: ' d(2:3) '/' m(2:3) '/' y '  Time: ' h(2:3) ':' mi(2:3)];
            
        otherwise
            
            error([mfilename ':: Unsupported format ' format])
            
    end

end
