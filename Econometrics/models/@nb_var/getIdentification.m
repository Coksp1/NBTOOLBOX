function matrix = getIdentification(obj)
% Syntax:
%
% matrix = getIdentification(obj)
%
% Description:
%
% Get restrictions on the structural shock matrix, i.e C in the equation
% below:
%
% y(t) = A*y(t-1) + B*x(t) + C*e(t), where e(t) ~ N(0,I).
% 
% Input:
% 
% - obj : A identified scalar nb_var object.
% 
% Output:
% 
% - matrix : nEndo x nEndo cell array.
%
% See also:
% nb_var.set_identification
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only handle a scalar nb_var object.'])
    end
    if ~isIdentified(obj)
        error([mfilename ':: The model must be identified.'])
    end
    if strcmpi(obj.solution.identification.type,'combination')
        restrictions = obj.solution.identification.restrictions;
    else
        restrictions = getCholeskyRestrictions(obj);
    end
    endo      = [obj.dependent.name,obj.block_exogenous.name];
    shocks    = unique(restrictions(:,2));
    periods   = restrictions(:,3);
    periods   = cellfun(@(x)nb_conditional(isnumeric(x), num2str(x), x),periods,'uniformOutput',false);
    periods   = unique(periods);
    numPer    = length(periods);
    numEndo   = length(endo);
    numShocks = length(shocks);
    matrix    = repmat({'none'},[numEndo,numShocks,numPer]);

    for ii = 1:size(restrictions,1)
        
        var   = restrictions{ii,1};
        shock = restrictions{ii,2};
        rest  = restrictions{ii,4};
        per   = restrictions{ii,3};
        val   = restrictions{ii,5};
        if ~ischar(per)
            if isnan(per)
                error('All the selected periods must be integers greater than or equal to 0.')
            elseif per < 0
                error('All the selected periods must be integers greater than or equal to 0.')
            end
            per = num2str(per);
        end
        
        if any(strcmpi(rest,{'<','>'}))
            rest = [rest,val]; %#ok<AGROW>
        end
        
        indEndo  = strcmp(var,endo);
        indShock = strcmp(shock,shocks);
        indPer   = strcmp(per,periods);
        matrix{indEndo,indShock,indPer} = rest;
    end
    shocks = shocks';
    endo   = endo';
    periods = strcat({'Period '},periods);
    matrix = [permute(periods,[2,3,1]),shocks(:,:,ones(1,numPer));
              endo(:,:,ones(1,numPer)),matrix];

end

%==========================================================================
function restrictions = getCholeskyRestrictions(obj)

    order   = obj.solution.identification.ordering;
    endoNum = length(order);
    temp    = 1:endoNum - 1;
    sTable  = cumsum(temp');
    sTable  = sTable(end);
    
    % Initialize restrictions
    restrictions          = cell(sTable,5);
    tFill                 = repmat({'0'},sTable,2);
    restrictions(:,[3,4]) = tFill;
    restrictions(:,5)     = {''};
    
    % Create the table of the cholesky restrictions
    kk = 0;
    for ii = 1:endoNum - 1
        numRest = endoNum - ii;
        for jj = 1:numRest
            restrictions{jj + kk,1} = order{ii};
            restrictions{jj + kk,2} = ['E_' order{ii + jj}];
        end
        
        kk = kk + jj;
    end
    
    % Add the structural shock with no restrictions
    restrictions = [restrictions;{order{end},['E_' order{1}],'0','none',''}];

end
