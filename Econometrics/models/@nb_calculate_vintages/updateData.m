function obj = updateData(obj,varargin)
% Syntax:
%
% obj = updateData(obj,varargin)
%
% Description:
%
% Update the data of the model.
% 
% Input:
% 
% - obj        : A vector of nb_calculate_vintages objects.
% 
% Optional input:
%
% - 'parallel' : Use this string as one of the optional inputs to run the
%                estimation in parallel.
%
% - 'cores'    : The number of cores to open, as an integer. Default
%                is to open max number of cores available. Only an 
%                option if 'parallel' is given. 
%
% - 'waitbar'  : Use this string to give a waitbar during updatin of data. 
%                I.e. when looping over models.
%
% - 'write'    : Use this option to write errors to a file instead of 
%                throwing the error.
%
% Output:
% 
% - obj : A vector of nb_calculate_vintages objects.
%
% See also:
% nb_model_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    inputs = nb_model_generic.parseOptional(varargin{:});
    inputs = nb_logger.openLoggerFile(inputs,obj);
    
    % Update the data
    nobj  = size(obj,1);
    names = getModelNames(obj);
    for ii = 1:nobj
        if isa(obj(ii),'nb_calculate_vintages')
            try
                [obj(ii).options.dataSource,~,newContexts] = update(obj(ii).options.dataSource, obj(ii).options.store2);
                obj(ii).contexts2Run                       = [obj(ii).contexts2Run,newContexts];
                obj(ii).valid                              = true;
            catch Err
                message = ['Error while updating the data of model; ' names{ii} '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                obj(ii).valid = false;
            end
        end
    end
    
    % Close written file
    nb_logger.closeLoggerFile(inputs);

end
