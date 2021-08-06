function ss = getSteadyState(obj,vars,out)
% Syntax:
%
% ss = getSteadyState(obj)
% ss = getSteadyState(obj,vars,out)
%
% Description:
%
% Get steady-state solution of model as a cell matrix.
% 
% Input:
% 
% - obj  : A nb_dsge model where the steady-state solution is solved for.
% 
% - vars : The variables you want the steady-state of. Can also be (an)
%          expression(s). Either as a cellstr or a char.
%
% - out  : Either 'cell' (default), 'struct', 'double' or 'headers'  
%          (include model names as headers to the output cell, 
%          only when numel(obj)>1).
%
% Output:
% 
% - ss : A nEndo x (1 + nRegimes) cell matrix if vars is empty, or else
%        the first dimension is given by length(vars) ('cell').
%
%        A nEndo x nRegimes double if vars is empty, or else the first
%        dimension is given by length(vars) ('double').
%
% See also:
% nb_model_generic.solution
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        out = 'cell';
        if nargin < 2
            vars = {};
        end
    end
    
    headers = false;
    if strcmpi(out,'headers')
        out     = 'cell';
        headers = true;
    end
    
    if numel(obj) > 1
        
        nobj  = numel(obj);
        obj   = obj(:); 
        ssVal = cell(nobj,1);
        ssN   = cell(nobj,1);
        for ii = 1:nobj
            ssT = getSteadyState(obj(ii),vars);
            if size(ssT,2) > 2
                error([mfilename ':: This method only handle scalar nb_dsge objects in the case of models with break-points.'])
            end
            ssN{ii}   = ssT(:,1);
            ssVal{ii} = ssT(:,2);
        end
        
        uniq    = unique(vertcat(ssN{:}));
        ss      = cell(length(uniq),nobj+1);
        ss(:,1) = uniq;
        for ii = 1:nobj
            [~,loc]      = ismember(ssN{ii},uniq);
            ss(loc,ii+1) = ssVal{ii};
        end
        if headers
            names = [{''},nb_rowVector(getModelNames(obj))];
            ss    = [names;ss];
        end
 
    else % Scalar nb_dsge
        
        if ~isfield(obj.solution,'ss')
            if isNB(obj)
                error([mfilename ':: The steady state is not yet solved for. See the nb_dsge.checkSteadyState method.'])
            else
                error([mfilename ':: The steady state is not yet solved for. See the nb_dsge.solve method.'])
            end
        end
        
        ss = obj.solution.ss;
        if iscell(ss)
            ss = [ss{:}];
        end
        
        if size(ss,1) < obj.dependent.number
            % SS of endogenous variables of the observation equations 
            % is not yet added, so we correct for that here
            nEndo      = size(obj.parser.all_endogenous,2);
            ssObs      = zeros(nEndo,1);
            ind        = ismember(obj.parser.all_endogenous,obj.parser.endogenous);
            ssObs(ind) = ss;
            ss         = ssObs;
        end
        
        if isempty(vars)
            ss = num2cell(ss);
            ss = [obj.dependent.name',ss];
            ss = flip(ss,1);
        else
            % Interpret expression of steady-state values
            if ischar(vars)
                vars = cellstr(vars);
            end
            ssIn = permute(ss,[3,1,2]);
            ss   = nan(length(vars),1,size(ssIn,3));
            for ii = 1:length(vars)
                ss(ii,:,:) = nb_eval(vars{ii},obj.dependent.name,ssIn);
            end
            ss = permute(ss,[1,3,2]);
            ss = num2cell(ss);
            ss = [vars(:),ss];
        end
        
        if headers
            if isBreakPoint(obj)
                breakD = cell(1,obj.parser.nBreaks);
                for ii = 1:obj.parser.nBreaks
                    breakD{ii} = toString(obj.parser.breakPoints(ii).date);
                end
                names = [{'','Initial'},breakD];
            else
                names = [{''},nb_rowVector(getModelNames(obj))];
            end
            ss = [names;ss];
        end
        
    end
    
    if strcmpi(out,'double')
        ss = cell2mat(ss(:,2:end));
    end
    
    if strcmpi(out,'struct')
        ss = cell2struct(ss(:,2:end),ss(:,1));
    end
    
end
