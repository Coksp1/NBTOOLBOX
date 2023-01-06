function obj = unstruct(s)
% Syntax:
%
% obj = nb_model_convert.unstruct(s)
%
% Description:
%
% Convert a struct to an object which is a subclass of the 
% nb_model_convert class.
% 
% Input:
% 
% - s   : A struct. See nb_model_convert.struct.
% 
% Output:
% 
% - obj : An object which is a subclass of the nb_model_convert class.
%
% See also:
% nb_model_convert.struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(s,'nb_model_convert')
        obj = s; % This is for backward compatibility
        return
    end

    try 
        class = s.class;
    catch
        error([mfilename ':: The struct is not on the correct format.'])
    end
    
    func   = str2func(class);
    s      = rmfield(s,'class');
    obj    = func();
    fields = fieldnames(s);
    for ii = 1:length(fields)
        try
            obj.(fields{ii}) = s.(fields{ii});
        catch Err
            if not(strcmpi(Err.identifier,'MATLAB:class:noSetMethod') || strcmpi(Err.identifier,'MATLAB:class:SetProhibited') )
                rethrow(Err)
            end
        end
    end
    
    % Load model
    if strcmpi(s.model.class,'nb_model_group') || strcmpi(s.model.class,'nb_model_selection_group')
        obj.model = nb_model_group.unstruct(s.model);
    else
        obj.model = nb_model_generic.unstruct(s.model);
    end
    obj.historyOutput = nb_ts.unstruct(s.historyOutput);
    
end
