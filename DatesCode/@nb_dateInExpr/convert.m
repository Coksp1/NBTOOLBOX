function obj = convert(obj,freq,~,varargin)
% Syntax:
%
% obj = convert(obj,freq,method,varargin)
%
% Description:
% 
% Convert the frequency of the data of the nb_dateInExpr object
% 
% Input:
% 
% - obj    : An object of class nb_dateInExpr
% 
% - freq   : The new freqency of the data. As an integer:
% 
%            > 1   : yearly
%            > 2   : semi annually
%            > 4   : quarterly
%            > 12  : monthly
%            > 52  : weekly
%            > 365 : daily
% 
% - method : Any    
% 
% Optional input:
% 
% - 'interpolateDate' : The input after this input must either be
%                       'start' or 'end'.
% 
%                       Date of interpolation. Where 'start' means 
%                       to interpolate the start date of the 
%                       periods of the old frequency, while 'end' 
%                       uses the end date of the periods.
% 
%                       Default is 'start'.
% 
%                       Caution : Only when converting to higher
%                                 frequency.
% 
% Output:
% 
% - obj : An nb_dateInExpr object.
% 
% Written by Kenneth S. Paulsen                                   

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    interpolateDate = nb_parseOneOptional('interpolateDate','start',varargin);
    if strcmpi(interpolateDate,'end')
        first = false;
    else
        first = true;
    end
    obj.date = convert(obj.date,freq,first);

end
