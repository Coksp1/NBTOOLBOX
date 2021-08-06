function obj = set_identification(obj,type,varargin)
% Syntax:
%
% obj = set_identification(obj,type,varargin)
%
% Description:
%
% Identify a VAR model. Either using cholesky restrictions or combinations
% of sign and zero restrictions (short, mid and long term).
% 
% The method solve must be called after adding the identifying restrictions
%
% See Andrew Binning (2013), "Underidentified SVAR models: A 
% framework for combining short and long-run restrictions with 
% sign-restrictions". This code is an adaption of his code to the
% NBToolbox, except that also magnitude restriction is possible using 
% this code.
%
% Input:
% 
% - obj  : A vector of nb_var objects, or subclasses of this class.
%
% - type : Either 'cholesky' or 'combination'
%
% - varargin (Optinal inputs) :
%
%   > 'cholesky'    : 
%
%       - 'ordering' : A cellstr with the ordering of the identification.
%                      Default is to use the ordering of the dependent
%                      variables of the model. The ordering is so that the
%                      first variable is the variable that is only 
%                      influenced by one shock in period 1, the second  
%                      variable is the variable that is influenced by two 
%                      shock in period 1, and so on.
%
%                      Caution : All variables of the VAR must be included
%                                in this option.
%
%   > 'combination' :
%
%       - 'maxDraws'    : The number of maximal rotations when looking
%                         for a identification satifying the sign
%                         restrictions. Can be set to inf. Default is
%                         10000.
%
%       - 'draws'       : The number of wanted draws of the matrix of the
%                         map from structural shocks to dependent
%                         variables (C). Default is one. 
%
%                          Caution : When it comes to producing IRFs
%                                    with sign restrictions you have two 
%                                    options. The first is to set 'draws'
%                                    to a large number, say 1000, and then
%                                    produce irf for each of those draws.
%                                    The second approach is to draw  
%                                    parameters using bootstrap, MC
%                                    methods or from the posterior, and 
%                                    then to make one draw of the C for 
%                                    each draw of the paramters.
%
%       - 'restrictions' : A nRestriction x 4 cell;
%
%                          {Dep,Shock,period,type,value;...}
%
%                          > Dep    : The dependent variable to add the
%                                     restriction to. As a string.
%
%                          > Shock  : The name of the identified structural 
%                                     shock. As a string.
%
%                          > period : The period of the restriction, as a
%                                     double. For on impact set 0 and for
%                                     cumulative restriction set it to inf.
%                                       
%                                     Use s:e to add a restriction on the
%                                     cumulative contribution of a shock
%                                     to a variable starting at s and
%                                     ending at e. E.g. 0:10.
%
%                          > type   : Either 0 for zero restriction,
%                                     '+'/'-' for sign restrictions or 
%                                     '>'/'<' for magnitude restrictions.
%
%                                     Or 'none' : If you want to add a  
%                                     structural shock with no restriction,  
%                                     as you already have exactly 
%                                     identified N-1 shocks.
%
%                          > value  : A 1x1 double with the value of the
%                                     magnitude restriction.
% 
% Output:
% 
% - obj : Identified nb_var objects. See the property field identification
%         of the property solution.
%
% Examples:
% See ...\Econometrics\test\test_nb_var 
%
% Written by Kenneth Sæterhagen Paulsen
% Subfunctions are written by Andrew Binning 2013

% Copyright Andrew Binning 2013
% Please feel free to use and modify this code as you see if fit. If you
% use this code in any academic work, please cite 
% Andrew Binning, 2013.
% "Underidentified SVAR models: A framework for combining short and long-run restrictions with sign-restrictions,"
% Working Paper 2013/14, Norges Bank.

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'cholesky';
    end

    obj  = obj(:);
    nobj = numel(obj);
    if nobj > 1
        
        for ii = 1:nobj
            obj(ii) = set_identification(obj(ii),type,varargin{:});
        end
        
    elseif nobj == 1
        
        switch lower(type)
            
            case 'cholesky'
                
                ind  = find(strcmpi('ask',varargin),1);
                if isempty(ind)
                    ask = false;
                else
                    ask = varargin{ind+1};
                end
                
                vars = [obj.block_exogenous.name,obj.dependent.name];
                if isa(obj,'nb_favar')
                    vars = [vars,obj.estOptions.factors];
                end
                if isa(obj,'nb_pitvar')
                    vars = strcat(vars,'_normal');
                end
                ind  = find(strcmpi('ordering',varargin),1);
                if isempty(ind)
                    ordering = vars;
                else
                    ordering = varargin{ind+1};
                    if ~iscellstr(ordering)
                        error([mfilename ':: The ordering input must be a cellstr.'])
                    end
                    
                    ind1 = ismember(vars,ordering);
                    ind2 = ismember(ordering,vars);
                    if ~all(ind1) || ~all(ind2) || length(ordering) ~= length(vars) 
                        error([mfilename ':: The ordering input must include all the variables of the VAR, and just them.'])
                    end
                    
                end
                
                obj.solution.identification = struct('type',type,'ordering',{ordering},'ask',ask);
                
            case 'combination'
               
                ind  = find(strcmpi('maxdraws',varargin),1);
                if isempty(ind)
                    maxDraws = 10000;
                else
                    maxDraws = varargin{ind+1};
                    if not(isnumeric(maxDraws) && isscalar(maxDraws))
                        error([mfilename ':: The maxDraws input must be an integer.'])
                    end
                end
                
                ind  = find(strcmpi('draws',varargin),1);
                if isempty(ind)
                    draws = 1;
                else
                    draws = varargin{ind+1};
                    if not(isnumeric(draws) && isscalar(draws))
                        error([mfilename ':: The draws input must be an integer.'])
                    end
                end
                
                dep  = [obj.dependent.name,obj.block_exogenous.name];
                if isa(obj,'nb_favar')
                   dep = [dep,obj.estOptions.factors]; 
                end
                
                ind  = find(strcmpi('restrictions',varargin),1);
                if isempty(ind)
                    restrictions = cell(0,4); 
                    warning('set_identification:noRestrictions',[mfilename ':: No identifying restrictions are beeing foreced upon the VAR! Please use the ''restrictions'' option.'])
                else
                    restrictions = varargin{ind+1};
                    if ~iscell(restrictions) || not(size(restrictions,2) == 4 || size(restrictions,2) == 5)
                        error([mfilename ':: The restriction input must be a nRestrictions x 4 (5) cell.'])
                    end
                    
                    ind = ~ismember(restrictions(:,1),dep);
                    if any(ind)
                        error([mfilename ':: You have added restriction on variables that does not exist; '...
                            nb_cellstr2String(unique(restrictions(ind)),', ',' and ') '.'])
                    end
                    
                end
                
                % Construct the matrix of zero restrictions
                [Q,Zind,SR,SRind,MR,MRV,MRind,CR,CRmax,index,flag,shocks] = checkRestrictions(obj,restrictions);
                obj.solution.identification = struct(...
                    'draws',        draws,...
                    'flag',         flag,...
                    'index',        index,...
                    'maxDraws',     maxDraws,...
                    'Q',            {Q},...
                    'restrictions', {restrictions},...
                    'shocks',       {shocks},...
                    'SR',           SR,...
                    'SRind',        SRind,...
                    'MR',           MR,...
                    'MRV',          MRV,...
                    'MRind',        MRind,...
                    'CR',           {CR},...
                    'CRmax',        {CRmax},...
                    'type',         type,...
                    'Zind',         Zind);
                
            otherwise
                error([mfilename ':: Unsupported identification type ' type])
        end
        
    end

end

%==========================================================================
% SUB
%==========================================================================
function [Q,Zind,SR,SRind,MR,MRV,MRind,CR,CRmax,index,flag,shocks] = checkRestrictions(obj,restrictions)

    % Primary test of restrictions
%     if ind <= nf
%         if f(ind,indShock) == 0
%             error([mfilename ':: You cannot add both a zero and a sign restriction for the same dependent variable (' depRestr ') '...
%                 'and period (' int2str(periods(ii)) ') for the shock ' shockRestr])
%         end
%     end
    
    dep  = [obj.dependent.name,obj.block_exogenous.name];
    if isa(obj,'nb_favar')
        dep = [dep,obj.estOptions.factors];
    end
    nDep = length(dep);
    
    % Get the structural shocks
    shocks = restrictions(:,2);
    if ~iscellstr(shocks)
        error([mfilename ':: The second column of the restrictions input must consist of only strings with the name of the structural shocks!'])
    end
    shocks = unique(shocks);

    % Get the zero restrictions
    typeOfR      = restrictions(:,4);
    zeroRestr    = cellfun(@isnumeric,typeOfR);
    periods      = cell2mat(restrictions(zeroRestr,3));
    isLR         = isinf(periods);
    nHor         = max(max([periods(~isLR);-1]) + 1 + any(isLR),1);  
    zeroRestrInd = find(zeroRestr);
    f            = ones(nDep*nHor,nDep);
    for ii = 1:size(zeroRestrInd,1)
        
        depRestr   = restrictions{zeroRestrInd(ii),1};
        indEq      = find(strcmpi(depRestr,dep),1);
        shockRestr = restrictions{zeroRestrInd(ii),2};
        indShock   = find(strcmpi(shockRestr,shocks),1);
        if isinf(periods(ii))
            ind = indEq + (nHor-1)*nDep; 
        else
            ind = indEq + periods(ii)*nDep;
        end
        f(ind,indShock) = 0;
        
    end
    Zind = unique(sort(periods));
    
    % Check for overidentification
    [Q,index,flag] = findQs(nDep,f);
    if flag == 1
        error('Rank condition not satisfied, the model is overidentified');
    end
    
    % Get the sign restrictions
    typeOfR   = restrictions(:,4);
    signRestr = strcmp('+',typeOfR) | strcmp('-',typeOfR);
    if any(signRestr)
        
        periods      = cell2mat(restrictions(signRestr,3));
        isLR         = isinf(periods);
        nHor         = max(periods(~isLR)) + 1 + any(isLR);  
        signRestrInd = find(signRestr);
        SR           = nan(nDep*nHor,nDep);
        for ii = 1:size(signRestrInd,1)

            depRestr   = restrictions{signRestrInd(ii),1};
            indEq      = find(strcmpi(depRestr,dep),1);
            shockRestr = restrictions{signRestrInd(ii),2};
            indShock   = find(strcmpi(shockRestr,shocks),1);
            sign       = restrictions{signRestrInd(ii),4};
            if isinf(periods(ii))
                ind = indEq + nDep*(nHor-1); 
            else
                ind = indEq + periods(ii)*nDep;
            end
            if strcmp(sign,'+')
                SR(ind,indShock) = 1;
            else
                SR(ind,indShock) = -1;
            end

        end
        SRind = unique(sort(periods));
    
    else
        SR    = [];
        SRind = [];
    end
    
    % Get the magnitude restrictions
    magnRestr = strcmp('>',typeOfR) | strcmp('<',typeOfR);
    if any(magnRestr)
        
        periods      = cell2mat(restrictions(magnRestr,3));
        isLR         = isinf(periods);
        nHor         = max(periods(~isLR)) + 1 + any(isLR);  
        magnRestrInd = find(magnRestr);
        MR           = nan(nDep*nHor,nDep);
        MRV          = nan(nDep*nHor,nDep);
        for ii = 1:size(magnRestrInd,1)

            depRestr   = restrictions{magnRestrInd(ii),1};
            indEq      = find(strcmpi(depRestr,dep),1);
            shockRestr = restrictions{magnRestrInd(ii),2};
            indShock   = find(strcmpi(shockRestr,shocks),1);
            type       = restrictions{magnRestrInd(ii),4};
            try
                value = restrictions{magnRestrInd(ii),5};
            catch %#ok<CTCH>
                error([mfilename ':: When addign magnitude restrictions, the restriction input must have 5 columns.'])
            end
            if isinf(periods(ii))
                ind = indEq + nDep*(nHor-1); 
            else
                ind = indEq + periods(ii)*nDep;
            end
            if strcmp(type,'>')
                MR(ind,indShock) = 1;
            else
                MR(ind,indShock) = -1;
            end
            MRV(ind,indShock) = value;

        end
        MRind = unique(sort(periods));
        
    else
        MR    = [];
        MRV   = [];
        MRind = [];
    end
    
    % Get the cumulative restrictions
    cumRestr = strcmp('cum>',typeOfR) | strcmp('cum<',typeOfR);
    if any(cumRestr)
        
        try
            values = restrictions(cumRestr,5);
            values(cellfun(@isempty,values)) = {nan};
        catch %#ok<CTCH>
            error([mfilename ':: When addign cumulative restrictions, the restriction input must have 5 columns.'])
        end
        periods      = restrictions(cumRestr,3);
        depRestr     = restrictions(cumRestr,1);
        types        = restrictions(cumRestr,4);
        [~,indEq]    = ismember(depRestr,dep);
        shockRestr   = restrictions(cumRestr,2);
        [~,indShock] = ismember(shockRestr,shocks);
        CR           = cell(1,nDep);
        CRmax        = CR;
        for ii = 1:nDep
            ind       = indShock == ii;
            periodsS  = periods(ind);
            CR{ii}    = struct('indDep',num2cell(indEq(ind)),'value',values(ind),'type',types(ind),'periods',periodsS);
            CRmax{ii} = max([periodsS{:}]);
        end 
        
    else
        CR    = [];
        CRmax = [];
    end
    
end

function [Q,index,flag] = findQs(k,f)
%==========================================================================
% Finds the Q matrices that describe the linear restrictions on the shock
% impact matrix.  Based on the Rubio-Ramirez, Waggoner and Zha 2010.
%
% inputs:
% k = number of dependent variables
% f = matrix of short and long run restrictions
%
% outputs:
% Q = a cell that contains the linear restrictions for each equation
% index = the original column order of the matrix of restrictions
% flag = indicates whether the model is over, under or exactly identified
%
% Copyright Andrew Binning 2013
%==========================================================================
    E      = eye(k);
    Q_init = cell(k,2);
    for ii = 1:k
        Q_init{ii,1} = double(diag(f*E(:,ii)==0));
        Q_init{ii,2} = rank(Q_init{ii,1});
    end

    for ii = 1:k
        temp         = Q_init{ii,1};
        Q_init{ii,1} = temp(logical(sum(temp,2)),:);
    end

    [new,ord] = sort([Q_init{:,2}],2,'descend');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check identification

    if any(new - (k - (1:k)) > 0)  % over-identified
        flag = 1;
    elseif all(new - (k - (1:k)) == 0) % exactly identified
        flag = 0;
    elseif any(new - (k - (1:k)) < 0) % under-identified
        flag = -1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    index = nan(k,1);
    for ii = 1:k
        index(ord(ii)) = ii;
    end

    Q = cell(k,1);
    for ii = 1:k
        Q{ii} = Q_init{ord(ii),1};
    end

end
