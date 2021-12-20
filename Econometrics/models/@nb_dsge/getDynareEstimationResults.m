function results = getDynareEstimationResults(dynare_file_short)
% Syntax:
%
% results = nb_dsge.getDynareEstimationResults(dynare_file_short)
%
% Description:
%
% Get estimation result from Dynare estimation. Including prior settings.
% 
% Input:
% 
% - dynare_file_short : Name of the dynare file without extension.
% 
% Output:
% 
% - posterior         : A struct with the dynare estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get priors
    results   = struct;
    priorPath = [dynare_file_short '\\prior\\definition.mat'];
    try
        loaded = load(priorPath);
        if ~isfield(loaded,'bayestopt_')
            error('Could not locate prior settings from dynare estimation');
        end
        bayestopt_ = loaded.bayestopt_;
        numEst     = length(bayestopt_.pshape);
        priorOut   = cell(numEst,4);
        for ii = 1:numEst
            
            % Get start value (Don't know how to do this...)
            priorOut{ii,2} = nan; %bayestopt_
            
            % Get name of parameter
            priorOut{ii,1} = bayestopt_.name{ii};
            
            % Get prior distribution
            switch bayestopt_.pshape(ii)
                case 1
                    % Beta (Do not support generlized stuff here!)
                    dist = 'beta';
                    prior = {bayestopt_.p6(ii),bayestopt_.p7(ii)};
                case 2
                    % Gamma
                    dist = 'gamma';
                    prior = {bayestopt_.p6(ii),bayestopt_.p7(ii)};
                case 3 
                    % Normal
                    dist = 'normal';
                    prior = {bayestopt_.p6(ii),bayestopt_.p7(ii)};
                case {4,6} %????
                    % Inverse gamma
                    dist = 'invgamma';
                    prior = {bayestopt_.p6(ii),bayestopt_.p7(ii)};
                case 5
                    % Uniform
                    dist = 'uniform';
                    prior = {bayestopt_.p3(ii),bayestopt_.p4(ii)}; 
                otherwise
                    error([mfilename ':: Unsupported prior type ' int2str(bayestopt_.pshape(ii))]);
            end
            
            lowerB = bayestopt_.lb(ii);
            upperB = bayestopt_.ub(ii);
            if lowerB == -inf && upperB == inf
                func   = str2func(['@nb_distribution.' dist '_pdf']); 
                inputs = prior;
            else
                func   = @nb_distribution.truncated_pdf;  
                inputs = {dist,prior,lowerB,upperB};
            end
            priorOut{ii,3} = func;
            priorOut{ii,4} = inputs;
            
        end
        
        results.prior = priorOut;
        
    catch Err
        
    end
     
    % Get estimation results
    try
        loaded          = load([dynare_file_short '_mode.mat']);
        invhess         = inv(loaded.hh);
        results.xparam1 = loaded.xparam1;
        results.stds    = sqrt(diag(invhess));
        results.param   = loaded.parameter_names;
        %results.invhess = invhess;
    catch Err
        
    end
       
end
