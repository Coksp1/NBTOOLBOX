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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        format = 'vintage';
    end

    switch lower(format)
        
        case 'vintagelong'
            
            try
                t = char(datetime('now'),'yyyyMMddHHmmss');
            catch
                t = datestr(now,'yyyymmddHHMMSS');
            end
        
        case 'vintage'
    
            try
                t = char(datetime('now'),'yyyyMMddHHmm');
            catch
                t = datestr(now,'yyyymmddHHMM');
            end
            
        case 'vintagemilliseconds'
            
            try
                t = char(datetime('now'),'yyyyMMddHHmmssSSS');
            catch
                t = datestr(now,'yyyymmddHHMMSSFFF');
            end
            
        case 'vintageshort'
    
            try
                t = char(datetime('now'),'yyyyMMdd');    
            catch
                t = datestr(now,'yyyymmdd'); %#ok<*TNOW1,*DATST>
            end

        case 'gui'
            
            try
                c    = datetime('now');
                date = char(c,'dd/MM/yyyy');
                time = char(c,'HH:mm');
                t    = ['Date: ' date '  Time: ' time];
            catch
                c = clock; %#ok<CLOCK>
                y = sprintf('%.0f',c(1));
                m = sprintf('%.0f',c(2)+100);
                m = m(2:3);
                d = sprintf('%.0f',c(3)+100);
                d = d(2:3);
                h = sprintf('%.0f',c(4)+100);
                h = h(2:3);
                n = sprintf('%.0f',c(5)+100);
                n = n(2:3);
                t = ['Date: ' d '/' m '/' y '  Time: ' h ':' n];
            end
            
        otherwise
            
            error([mfilename ':: Unsupported format ' format])
            
    end

end
