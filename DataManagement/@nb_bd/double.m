function dataOfObject = double(obj,type)
% Syntax:
%
% dataOfObject = double(obj,type)
%
% Description:
%
% Get the data of the nb_bd object as a double matrix
% 
% This method overrides the nb_dataSource method inherited by the other
% data objects, as we 
%
% Input:
% 
% - obj          : An object of class nb_ts, nb_cs or nb_data
%
% - type         : Either 'full' (default), 'stripped' or 'sparse'. Can
%                  also be logical true ('full') or false ('sparse').
%
% Output:
%
% - dataOfObject : The data of the nb_bd object.
%
% Examples:
%
% dataOfObject = double(obj)
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'full';
    end
    if nb_isLogical(type)
        if type 
            type = 'full';
        else
            type = 'sparse';
        end
    elseif ~nb_isOneLineChar(type)
        error([mfilename ':: The type input must be a logical or a one line char.'])
    end

    switch lower(type)
        
        case 'full'
            % Logical data will be converted to double in the getFullRep method
            dataOfObject = getFullRep(obj);
        case 'stripped'
            dataOfObject = getStrippedRep(obj);
        otherwise
            data = obj.data;
            if isa(data,'logical')
                dataOfObject = double(data);
            else
                dataOfObject = data;
            end
    end
    
end
