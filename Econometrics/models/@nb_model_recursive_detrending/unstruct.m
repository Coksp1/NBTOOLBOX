function obj = unstruct(s)
% Syntax:
%
% obj = nb_model_recursive_detrending.unstruct(s)
%
% Description:
%
% Convert a struct to an object which is a subclass of the 
% nb_model_recursive_detrending class.
% 
% Input:
% 
% - s   : A struct. See nb_model_recursive_detrending.struct.
% 
% Output:
% 
% - obj : An object of the nb_model_recursive_detrending class.
%
% See also:
% nb_model_recursive_detrending.struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(s,'nb_model_recursive_detrending')
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
        
        if strcmp(fields{ii},'modelIter')
            modelI(1,length(s.modelIter)) = nb_singleEq(); %#ok<AGROW>
            for tt = 1:length(s.modelIter)
                modelI(1,tt) = nb_model_generic.unstruct(s.modelIter{tt});
            end
            obj.modelIter = modelI;
        elseif strcmp(fields{ii},'model')
            obj.model = nb_model_generic.unstruct(s.model);
        else
            try
                obj.(fields{ii}) = s.(fields{ii});
            catch Err
                if not(strcmpi(Err.identifier,'MATLAB:class:noSetMethod') || strcmpi(Err.identifier,'MATLAB:class:SetProhibited') )
                    rethrow(Err)
                end
            end
        end
    end
    
end
