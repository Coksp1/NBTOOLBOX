function obj = unstruct(s)
% Syntax:
%
% obj = nb_model_estimate.unstruct(s)
%
% Description:
%
% Convert a struct to an object which is a subclass of the 
% nb_model_estimate class. This is how the nb_model_estimate object is
% loaded.
% 
% Input:
% 
% - s   : A struct. See nb_model_estimate.struct.
% 
% Output:
% 
% - obj : An object which is a subclass of the nb_model_estimate class.
%
% See also:
% nb_model_estimate.struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(s,'nb_model_sampling')
        obj = s; % This is for backward compatibility
        return
    end

    try 
        class = s.class;
    catch
        error([mfilename ':: The struct is not on the correct format.'])
    end
    
    % Initialize
    func = str2func(class);
    s    = rmfield(s,'class');
    obj  = func();
    
    % Spesial properties of the DSGE
    if isa(obj,'nb_dsge')
        % posteriorPath is a dependent property!
        obj = setSystemPriorPath(obj,s.systemPriorPath);
        s   = nb_rmfield(s,{'posteriorPath','systemPriorPath'});
    end
    
    % The data original must be taken care of at the end!
    origFound = false;
    if isfield(s,'dataOrig')
        func                   = str2func([s.dataOrig.class '.unstruct']);
        dataO                  = func(s.dataOrig);
        s                      = nb_rmfield(s,'dataOrig');
        origFound              = true;
        obj.preventSettingData = false;
    end
    
    % All other properties
    obj = setProps(obj,s);
        
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
    
    % Load estOptions properly
    estOpt              = obj.estOptions;
    real_time_estim     = false;
    missing             = false;
    try real_time_estim = estOpt.real_time_estim; catch; end %#ok<CTCH>
    try missing         = ~isempty(estOpt.missingMethod); catch; end %#ok<CTCH>
    if missing
        
        saved           = estOpt.missingStored;
        keep            = estOpt.missingStoredVars;
        nVars           = length(keep);
        missingDataFull = estOpt.missingData;
        estOpt          = rmfield(estOpt,{'missingStored','missingStoredVars','missingData'});
        estOpt          = nb_uncollapsStruct(estOpt);
        nPer            = length(estOpt);
        addIncr         = true;
        if nPer > 1
            if estOpt(end).recursive_estim_start_ind - estOpt(1).recursive_estim_start_ind > 0
                addIncr = false;
            end
        end
        for ii = 1:nPer
            
            % Reload missingData
            if addIncr
                estOpt(ii).estim_end_ind = estOpt(ii).recursive_estim_start_ind + (ii - 1);
            else
                estOpt(ii).estim_end_ind = estOpt(ii).recursive_estim_start_ind;
            end
            if ~isempty(missingDataFull) 
                missingData                                   = missingDataFull;
                missing                                       = missingData(1:estOpt(ii).missingEndInd,:);
                sPer                                          = estOpt(ii).missingStartInd;
                periods                                       = estOpt(ii).estim_end_ind - sPer;
                missing                                       = missing(end-periods:end,:); 
                missingData(sPer:estOpt(ii).estim_end_ind,:)  = missing;
                missingData(estOpt(ii).estim_end_ind+1:end,:) = true;
                estOpt(ii).missingData                        = missingData;
            end
            
            % Get data
            if ~isempty(obj.options.data)
                dataOfOthers             = double(obj.options.data);
                nVarsOther               = size(dataOfOthers,2);
                nObs                     = size(dataOfOthers,1);
                s                        = saved(ii).startInd;
                e                        = saved(ii).endInd;
                dataTemp                 = nan(nObs,nVars);
                dataTemp(1:e,~keep)      = dataOfOthers(1:e,~keep(1:nVarsOther));
                dataTemp(s:e,keep)       = saved(ii).data;
                estOpt(ii).data          = dataTemp;
            end
            
            
        end
        
    elseif real_time_estim
            
        saved           = estOpt.stored;
        keep            = estOpt.storedVars;
        nVars           = length(keep);
        dataOfOthers    = double(obj.options.data);
        nVarsOther      = size(dataOfOthers,2);
        nObs            = size(dataOfOthers,1);
        estOpt          = rmfield(estOpt,{'stored','storedVars'});
        estOpt          = nb_uncollapsStruct(estOpt);
        nPer            = length(estOpt);
        for ii = 1:nPer
            
            % Get data
            estOpt(ii).estim_end_ind = estOpt(ii).recursive_estim_start_ind + (ii - 1);
            s                        = saved(ii).startInd;
            e                        = saved(ii).endInd;
            dataTemp                 = nan(nObs,nVars);
            dataTemp(1:e,~keep)      = dataOfOthers(1:e,~keep(1:nVarsOther),ii);
            dataTemp(s:e,keep)       = saved(ii).data;
            estOpt(ii).data          = dataTemp;
            
        end
        
    end
    obj.estOptions = estOpt;
    
    % Set so old loaded objects are set default parsing options that has
    % been added afterwards
    if isa(obj,'nb_dsge')
        default     = nb_dsge.getDefaultParser();
        obj.parser  = nb_structcat(obj.parser,default,'first');
    end
    
    % If new options are added we add default values for those...
    tempFunc    = str2func([class '.template']);
    opt         = tempFunc();
    obj.options = nb_structcat(obj.options,opt,'first');
    
end
