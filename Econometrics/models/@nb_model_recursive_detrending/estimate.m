function obj = estimate(obj,varargin)
% Syntax:
%
% obj = estimate(obj,varargin)
%
% Description:
%
% Estimate the model(s) represented by nb_model_recursive_detrending 
% object(s).
% 
% Caution: If the underlying model is of class nb_dsge, only recursive
%          filtering is done with the call to this function!
%
% Input:
%
% - obj : A vector of nb_model_recursive_detrending objects.
% 
% Optional input:
%
% - Optional inputs given to the nb_dsge.filter method, if the model 
%   property is of class nb_dsge. Otherwise it has no effect.
%
%   Caution : The 'endDate' inputs to the filter method will be 
%             overwritten!
%
% Output:
% 
% - obj : A vector of nb_model_recursive_detrending objects, where the  
%         estimation results are stored in the property results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = size(obj,1);
    
    [waitbar,varargin] = nb_parseOneOptionalSingle('waitbar',0,1,varargin{:});
    if waitbar
        h    = nb_waitbar([],'Recursive estimation',nobj);
        note = nb_when2Notify(nobj);
    end
    
    names = getModelNames(obj);
    for ii = 1:nobj
        
        if isempty(obj(ii).modelIter)
            error([mfilename ':: You must first call the createVariables method on the object ' names{ii} '.'])
        end
        
        if isa(obj(ii).model,'nb_dsge') % Filter
            
            for tt = 1:length(obj(ii).modelIter)
                obj(ii).modelIter(tt) = filter(obj(ii).modelIter(tt), varargin{:},...
                                        'endDate',obj(ii).options.recursive_start_date + (tt - 1));
            end
            
        else % Estimate
            
            % Set the estim_end_date options to replicate recursive
            % estimation
            for tt = 1:length(obj(ii).modelIter)
                obj(ii).modelIter(tt) = set(obj(ii).modelIter(tt),...
                                            'estim_end_date',   obj(ii).options.recursive_start_date + (tt - 1),...
                                            'recursive_estim',  false,...
                                            'real_time_estim',  false);
            end
            obj(ii).modelIter = estimate(obj(ii).modelIter, varargin{:});
            
            % Get results 
            res         = struct;
            elapsedTime = nan(1,length(obj(ii).modelIter));
            for mm = 1:length(obj(ii).modelIter)
                res             = nb_realTimeEstimator.mergeResults(res,obj(ii).modelIter(mm).results);
                elapsedTime(mm) = obj(ii).modelIter(mm).results.elapsedTime;
            end
            res.elapsedTime          = sum(elapsedTime);
            res.includedObservations = obj(ii).modelIter(end).results.includedObservations;
            obj(ii).results          = res;
            
        end
        
        if waitbar
            if rem(ii,note) == 0
                h.status = h.status + note;
                h.text   = ['Estimation of Model '  int2str(ii) ' of ' int2str(nobj) ' finished.'];  
            end
        end
        
    end
    
end
