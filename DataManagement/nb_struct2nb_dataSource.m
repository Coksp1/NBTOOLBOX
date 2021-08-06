function obj = nb_struct2nb_dataSource(s)
% Syntax:
%
% obj = nb_struct2nb_dataSource(s)
%
% Description:
%
% Convert a struct with nb_dataSource objects as fields to an object of a 
% subclass of the nb_dataSource class.
% 
% Input:
% 
% - s : A struct with nb_dataSource as fields.
% 
% Output:
% 
% - obj : A nb_dataSource object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    fields = fieldnames(s);
    first  = s.(fields{1}); 
    switch class(first)
        case 'nb_ts'
            obj = nb_ts();
        case 'nb_data'
            obj = nb_data();
        case 'nb_cs'
            obj = nb_cs();
        case 'nb_cell'
            obj = nb_cell();
        otherwise
            error([mfilename ':: The fields of the struct must be of a subclass of the nb_dataSource class.'])
    end
    for ii = 2:length(fields)
        obj = addPages(obj,s.(fields{ii}));
    end
    obj.dataNames = fields';
    
end
