function obj = initialize(freq,dim1,dim2)
% Syntax:
%
% obj = nb_date.initialize(freq,dim1,dim2)
%
% Description:
%
% Initialize a vector of date objects. 
%
% Input:
%
% - freq : The wanted frequency of the date of today. 1,2,4,12,52 or 365.
%
% - dim1 : The size of the first dimension.
%
% - dim2 : The size of the second dimension.
%
% Output:
% 
% obj : A vector of nb_date objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch freq
        case 1
            obj(dim1,dim2) = nb_year();
        case 2
            obj(dim1,dim2) = nb_semiAnnual();
        case 4
            obj(dim1,dim2) = nb_quarter();
        case 12
            obj(dim1,dim2) = nb_month();
        case 52
            obj(dim1,dim2) = nb_week();
        case 365
            obj(dim1,dim2) = nb_day();
        otherwise
            error([mfilename ':: Unsupported frequency ' int2str(freq) '.'])
    end
    
end
