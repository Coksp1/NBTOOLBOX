function bgp = getBalancedGrowthPath(obj,vars,out)
% Syntax:
%
% bgp = getBalancedGrowthPath(obj)
% bgp = getBalancedGrowthPath(obj,vars,out)
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
% - out  : Either 'cell' (default), 'double' or 'headers' (include model 
%          names as headers to the output cell, only when numel(obj)>1).
%
% Output:
% 
% - bgp : A nEndo x (1 + nRegimes) cell matrix if vars is empty, or else
%         the first dimension is given by length(vars) ('cell').
%
%         A nEndo x nRegimes double if vars is empty, or else the first
%         dimension is given by length(vars) ('double').
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
        
        nobj   = numel(obj);
        obj    = obj(:); 
        bgpVal = cell(nobj,1);
        bgpN   = cell(nobj,1);
        for ii = 1:nobj
            bgpT = getBalancedGrowthPath(obj(ii),vars);
            if size(bgpT,2) > 2
                error([mfilename ':: This method only handle scalar nb_dsge objects in the case of models with break-points.'])
            end
            bgpN{ii}   = bgpT(:,1);
            bgpVal{ii} = bgpT(:,2);
        end
        
        uniq     = unique(vertcat(bgpN{:}));
        bgp      = cell(length(uniq),nobj+1);
        bgp(:,1) = uniq;
        for ii = 1:nobj
            [~,loc]      = ismember(bgpN{ii},uniq);
            bgp(loc,ii+1) = bgpVal{ii};
        end
        if headers
            names = [{''},nb_rowVector(getModelNames(obj))];
            bgp   = [names;bgp];
        end
 
    else % Scalar nb_dsge
        
        if ~isNB(obj)
            error([mfilename ':: Cannot solve for the balanced growth path when no using NB toolbox parser and solver.'])
        end
        
        if ~isfield(obj.solution,'bgp')
            error([mfilename ':: The balanced growth path is not yet solved for. See the nb_dsge.solveBalancedGrowthPath method.'])
        end
        
        bgp = obj.solution.bgp;
        if iscell(bgp)
            bgp = [bgp{:}];
        end
        potVars = [obj.parser.originalEndogenous,obj.unitRootVariables.name];
        if isempty(vars)
            bgp = num2cell(bgp);
            bgp = [potVars',bgp];
            bgp = flip(bgp,1);
        else
            % Interpret expression of BGP values
            if ischar(vars)
                vars = cellstr(vars);
            end
            bgpIn = permute(bgp,[3,1,2]);
            bgp   = nan(length(vars),1,size(bgpIn,3));
            for ii = 1:length(vars)
                bgp(ii,:,:) = nb_eval(vars{ii},potVars,bgpIn);
            end
            bgp = permute(bgp,[1,3,2]);
            bgp = num2cell(bgp);
            bgp = [vars(:),bgp];
        end
        
    end
    
    if strcmpi(out,'double')
        bgp = cell2mat(bgp(:,2:end));
    end
    
    if strcmpi(out,'struct')
        bgp = cell2struct(bgp(:,2:end),bgp(:,1));
    end
    
end
