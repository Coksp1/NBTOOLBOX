function obj = cell2Date(cellstr,freq)
% Syntax:
%
% obj = nb_date.cell2Date(cellstr,freq)
%
% Description:
%
% Converts a cellstring of dates into a nb_date object.
% 
% Input:
% 
% - cellstr : The cellstring of dates that you want to convert.
%
% - freq    : The frequency of your data. You can choose between 1, 2, 4,
%             12, 52, and 365.
% 
% Output:
% 
% - date    : A NumberOfDatesx1 vector containing nb_date objects.
%
% Examples:
%
% g =  {'2011Q2'     
%       '2011Q3'
%       '2011Q4'
%       '2012Q1'
%       '2012Q2'
%       '2012Q3'
%       '2012Q4'
%       '2013Q1'
%       '2013Q2'}    
% 
% a = nb_date.cell2Date(g,4)
%
% a =              
%
%    '2011Q2'
%    '2011Q3'
%    '2011Q4'
%    '2012Q1'
%    '2012Q2'
%    '2012Q3'
%    '2012Q4'
%    '2013Q1'
%    '2013Q2'
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch freq
        case 1
            func = @nb_year;
        case 2
            func = @nb_semiAnnual;
        case 4
            func = @nb_quarter;
        case 12
            func = @nb_month;
        case 52
            func = @nb_week;
        case 365 
            func = @nb_day;
        otherwise
            error(['The frequency you have chosen is not supported. '...
                   'Your options are 1, 4, 12, 52 or 365'])
    end

    date(size(cellstr,1),size(cellstr,2)) = func();
    for ii = 1:length(cellstr)
        date(ii) = func(cellstr{ii});
    end
    obj = date;
        
end

