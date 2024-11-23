function obj = unstruct(s)
% Syntax:
%
% obj = nb_model_group.unstruct(s)
%
% Description:
%
% Convert a struct to an object which is a subclass of the 
% nb_model_group class.
% 
% Input:
% 
% - s   : A struct. See nb_model_group.struct.
% 
% Output:
% 
% - obj : An object which is a subclass of the nb_model_group class.
%
% See also:
% nb_model_group.struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(s,'nb_model_group')
        obj = s; % This is for backward compatibility
        return
    end

    try 
        class = s.class;
    catch
        error([mfilename ':: The struct is not on the correct format.'])
    end
    func = str2func(class);
    s    = rmfield(s,'class');
    obj  = func();
    
    % The data original must be taken care of at the end!
    origFound = false;
    if isfield(s,'dataOrig')
        func                   = str2func([s.dataOrig.class '.unstruct']);
        dataO                  = func(s.dataOrig);
        s                      = nb_rmfield(s,'dataOrig');
        origFound              = true;
        obj.preventSettingData = false;
    end
    
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
    
    % Convert data to an object as well
    if isa(obj,'nb_model_selection_group')
        
        opt = s.options;
        obj = obj.setOptions(opt);
        obj = obj.setReporting(s.reporting);
        obj = obj.setTransformations(s.transformations);
        
        % Convert data to an object as well, this will also set the
        % obj.options.data options. See set.dataOrig!
        if origFound
            obj.dataOrig = dataO;
        else
            % Here we need to secure backward compability
            func         = str2func([s.options.data.class '.unstruct']);
            obj.dataOrig = getOrigData(obj,func(s.options.data));
        end
        obj.preventSettingData = true;
        
    end
    
    % Load models
    models = s.models;
    for ii = 1:length(models)
        modelT = models{ii};
        if strcmpi(modelT.class,'nb_model_group') || strcmpi(modelT.class,'nb_model_selection_group')
            modelT = nb_model_group.unstruct(modelT);
        else
            modelT = nb_model_generic.unstruct(modelT);
        end
        models{ii} = modelT;
    end
    obj.models = models;
    
end
