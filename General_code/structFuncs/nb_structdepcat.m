function s = nb_structdepcat(t,r)
% Syntax:
%
% s = nb_structdepcat(t,r)
%
% Description:
%
% Generalize the [] operator for structs to handle struct with different 
% fields.
%
% s1 = struct('test',1,'test2',2);
% s2 = struct('test',2);
% s  = [s1,s2];
% 
% Will fail, but not
% 
% s = nb_structdepcat(s1,s2);
%
% Input:
% 
% - t : A struct or a nb_struct
%
% - r : A struct or a nb_struct
% 
% Output:
% 
% - s : A struct or a nb_struct. If one of the inputs is a nb_struct the
%       the output will be a nb_struct.
%
% See also:
% struct, nb_struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isempty(t)
        s = r;
        return
    elseif nb_isempty(r)
        s = t;
        return
    end

    if not(isstruct(t) && isstruct(r))
        error([mfilename ':: Both inputs must be of class struct or nb_struct'])
    end

    try %#ok<TRYNC>
        s = [t,r];
        return 
    end
        
    fieldsT = fieldnames(t);
    fieldsR = fieldnames(r);
    indT    = ismember(fieldsT,fieldsR);
    indR    = ismember(fieldsR,fieldsT);
    addedR  = fieldsT(~indT);
    addedT  = fieldsR(~indR);
    
    for ii = 1:length(addedT) 
        type = class(r(1).(addedT{ii}));
        switch type  
            case 'cell'
                type = {};
            case 'char'
                type = '';
            case 'struct'
                type = struct;
            otherwise
                type = [];
        end
        for jj = 1:length(t)
            t(jj).(addedT{ii}) = type;
        end
    end
    for ii = 1:length(addedR) 
        type = class(t(1).(addedR{ii}));
        switch type  
            case 'cell'
                type = {};
            case 'char'
                type = '';
            case 'struct'
                type = struct;
            otherwise
                type = [];
        end
        for jj = 1:length(r)
            r(jj).(addedR{ii}) = type;
        end
    end
    s = [t,r];
    
end
