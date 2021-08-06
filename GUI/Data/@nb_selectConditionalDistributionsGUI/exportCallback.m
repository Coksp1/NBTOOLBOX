function exportCallback(gui,hObject,~,type)
% Syntax:
%
% exportCallback(gui,hObject,~,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        type = false;
    end
    
    % Check if covariance matrix must be calculated
    if isa(gui.model,'nb_model_generic')
    
        endo = gui.model.solution.endo;
        ind  = ismember(gui.variables,endo);
        if any(ind)
            if isempty(gui.sigma)
                nb_errorWindow(['When endogenous variables are conditioned on you need to calculate the '...
                           'covariance matrix to be used by the copula. See Copula->Settings'])
                return
            else
                endoCond = gui.variables(ind);
                endoCond = [strcat(endoCond,'_lag0'),nb_cellstrlag(endoCond,length(gui.dates)-1,'varFast')];
                endoCond = strrep(endoCond,'_lag','_period');
                ind      = ismember(endoCond,gui.sigma.variables);
                if any(~ind)
                    nb_errorWindow(['When endogenous variables are conditioned on you need to calculate the '...
                                   'covariance matrix to be used by the copula. See Copula->Settings. The following '...
                                   'variables are missing from the covariance matrix; '  toString(endoCond(~ind))])
                    return
                end
            end
        end
        
    end

    % Get the file name
    [filename,pathname] = uiputfile({'*.mat','MAT (*.mat)'},...
                                     '',     nb_getLastFolder(gui));

    % Read input file
    %------------------------------------------------------
    if isscalar(filename) || isempty(filename) || isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);

    % Find name and extension
    [~,saveN] = fileparts(filename);

    % Write to .mat file
    dens.data        = gui.distributions;
    dens.dates       = gui.dates;
    dens.variables   = gui.variables; 
    dens.sigma       = gui.sigma; 
    dens.initPeriods = gui.initPeriods; %#ok<STRNU>
    save([pathname,saveN],'-struct','dens');
    
    % Close window if wanted
    if type
        close(get(hObject,'parent'))
        finishUp(gui,[],[]);
    end
    
end
