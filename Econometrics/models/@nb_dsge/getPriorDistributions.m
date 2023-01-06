function [distr,paramNames] = getPriorDistributions(obj)
% Syntax:
%
% [distr,paramNames] = getPriorDistributions(obj)
%
% Description:
%
% Get prior distributions of model.
% 
% Input:
% 
% - obj        : An object of class nb_dsge. 
% 
% Output:
% 
% - distr      : A 1 x numCoeff nb_distribution object.
%
% - paramNames : A 1 x numCoeff cellstr with the names of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
       error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if nb_isempty(obj.options.prior)
        error([mfilename ':: No prior is selected for any parameters.'])
    end
    
    if isRise(obj)
        
        priorS        = obj.options.prior;
        paramNames    = fieldnames(priorS);
        numD          = length(paramNames);
        distr(1,numD) = nb_distribution;
        
        for ii = 1:numD

            priorT = priorS.(paramNames{ii});
            if length(priorT) == 3
                % Uniform prior
                low         = priorT{2};
                high        = priorT{3};
                distr(1,ii) = nb_distribution('type','uniform','parameters',{low,high});
            else
                
                distrName = priorT{4};
                if strfind(distrName,'(')
                    error([mfilename ':: Cannot get priors given to RISE using the quantile specification.'])
                end
                mo = [];
                if strcmpi(distrName,'left_triang')
                    mo = 0;
                    distrName = 'tri';
                elseif strcmpi(distrName,'right_triang')
                    mo = 1;
                    distrName = 'tri';
                elseif strcmpi(distrName,'inv_gamma')
                    distrName = 'invgamma';
                elseif strcmpi(distrName,'pareto')
                    error([mfilename ':: This function cannot plot pareto priors, which is used for the variable ' priorT{ii,1}])
                end
                
                me = priorT{2};
                v  = priorT{3}^2;
                if length(priorT) > 4
                    lb = priorT{5}; 
                else
                    lb = [];
                end 
                if length(priorT) > 5
                    ub = priorT{6}; 
                else
                    ub = [];
                end
                distr(1,ii) = nb_distribution.parametrization(me,v,distrName,lb,ub,[],[],mo);
            end

        end
        
    elseif isNB(obj)
        
        priorC        = obj.options.prior;
        paramNames    = priorC(:,1);
        numD          = length(paramNames);
        distr(1,numD) = nb_distribution;
        
        for ii = 1:numD

            priorT    = priorC(ii,:);
            distrName = func2str(priorT{3});
            distrName = strrep(distrName,'nb_distribution.','');
            distrName = strrep(distrName,'_pdf','');
            if strcmp(distrName,'truncated')
                inputs      = priorT{4};
                distrName   = inputs{1};
                param       = inputs{2};
                lowerB      = inputs{3};
                upperB      = inputs{4};
                distr(1,ii) = nb_distribution('type',distrName,'parameters',param,'lowerBound',lowerB,...
                                              'upperBound',upperB);
            elseif strcmp(distrName,'meanshift')
                inputs      = priorT{4};
                distrName   = inputs{1};
                param       = inputs{2};
                lowerB      = inputs{3};
                upperB      = inputs{4};
                meanShift   = inputs{5};
                distr(1,ii) = nb_distribution('type',distrName,'parameters',param,'lowerBound',lowerB,...
                                              'upperBound',upperB,'meanShift',meanShift);
            else
                distr(1,ii) = nb_distribution('type',distrName,'parameters',priorT{4});
            end
            
            % This is the start value, which we store in the userData 
            % property for use in DAG
            set(distr(1,ii),'userData',priorT{2})
            
        end
        
    else
        error([mfilename ':: Cannot plot priors when model is estimated with dynare.'])
    end
    
end
