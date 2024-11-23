function writeModel2File(obj,filename,varargin)
% Syntax:
%
% writeModel2File(obj,filename,varargin)
%
% Description:
%
% Write model to .nb file.
% 
% Input:
% 
% - obj : A scalar nb_dsge object.
%
% - filename : A one line char with the file name to write to. Must have
%              .nb or no extension.
%
% Optional input:
%
% - 'parameters'   : One of:
%                    > 'file'  : Write the parameters to a seperate file
%                                with name [filename '_param.mat']. 
%                                Default.
%                    > 'block' : Write the assignment of the parameters
%                                to the parameterization block of the 
%                                model file.
%                    > 'off'   : Don't write the parameter values to any
%                                format.
%
% - 'precision'    : See nb_num2str. Default is 14.
%
% - 'steady_state' : One of:
%                    > 'file'  : Write the intitial condition for solving 
%                                the steady state to a seperate file
%                                with name [filename '_ss.mat']. 
%                                Default.
%                    > 'block' : Write the assignment of the intitial  
%                                condition for solving the steady state
%                                to the steady_state_model block of the 
%                                model file.
%                    > 'off'   : Don't write the intitial condition for  
%                                solving the steady state to any format.
% 
% Output:
% 
% 
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: Object must be a scalar nb_dsge.'])
    end
    
    [precision,varargin] = nb_parseOneOptional('precision',14,varargin{:});
    [paramOpt,varargin]  = nb_parseOneOptional('parameters','file',varargin{:});
    [ssOpt,~]            = nb_parseOneOptional('steady_state','file',varargin{:});
    
    % Secure correct extension
    [p,n,e] = fileparts(filename);
    if isempty(e)
        e = '.nb';
    else
        if ~strcmpi(e,'.nb')
            error([mfilename ':: The file extension must be .nb.'])
        end
    end
    if ~isempty(p)
        p = [p,filesep];
    end
    fullname = [p,n,e];

    % Get equations
    unitRootBlock = cell(0,1);
    if ~isempty(obj.unitRootVariables.name)
        if obj.isStationarized
            eqs = [obj.parser.stationaryEquations; obj.parser.growthEquations];
        else
            eqs           = obj.parser.equations;
            unitRootBlock = writeUnitRootBlock(obj.parser);
        end
    else
        eqs = obj.parser.equations;
    end 
    
    % Get static equations
    if ~isempty(obj.parser.static)
        sEqs = cell(size(eqs,1),1);
        sEqs(obj.parser.staticLoc) = strcat({'[static] '},obj.parser.static);
        allEqs                     = [eqs,sEqs]';
        eqs                        = allEqs(:);
        ind                        = ~cellfun(@isempty,eqs);
        eqs                        = eqs(ind);
    end
    
    % Write each block
    endoBlock     = writeNames('endogenous',obj.endogenous.name(~obj.endogenous.isAuxiliary));
    exoBlock      = writeNames('exogenous',obj.exogenous.name);
    paramBlock    = writeNames('parameters',obj.parameters.name);
    obsBlock      = writeNames('observables',obj.observables.name);
    modelBlock    = writeModel(eqs);
    repBlock      = writeRep(obj.reporting);
    paramValBlock = writeParam(obj,paramOpt,[p,n],precision);
    ssBlock       = writeSS(obj.options.steady_state_init,ssOpt,[p,n],precision);
    optimalBlock  = writeLossFunction(obj);
    breakPBlock   = writeBreakPointsBlock(obj);

    % Combine all the blocks of the model file
    string = [
        endoBlock
        exoBlock
        paramBlock
        paramValBlock
        obsBlock
        modelBlock
        ssBlock
        breakPBlock
        unitRootBlock
        optimalBlock
        repBlock
    ];

    % Write .nb file
    nb_cellstr2file(string,fullname);

end

%==========================================================================
function block  = writeNames(type,names)

    if isempty(names)
        block = cell(0,1); 
        return
    end

    block    = cell(length(names) + 2,1);
    block{1} = type;
    for ii = 1:length(names)
        block{1+ii} = names{ii};
    end
    block{end} = '';
    
end

%==========================================================================
function block = writeModel(eqs)

    if isempty(eqs)
        block = cell(0,1); 
        return
    end

    block    = cell(size(eqs,1) + 3,1);
    block{1} = 'model';
    block{2} = '';
    for ii = 1:size(eqs,1)
        eq    = eqs{ii};
        split = regexp(eq,'-\(.+\)$','start');
        if ~isempty(split)
            % Change lhs -(rhs) to lhs = rhs
            eq = [eq(1:split-1),' = ',eq(split+2:end-1)];
        end
        block{2+ii} = [eq,';'];
    end
    block{end} = '';


end

%==========================================================================
function block = writeUnitRootBlock(parser)

    block    = cell(length(parser.unitRootVars) + 2,1);
    block{1} = 'unitroot';
    for ii = 1:length(parser.unitRootVars)
        block{1+ii} = [parser.unitRootVars{ii},',',parser.unitRootGrowth{ii},',',...
                       parser.unitRootOptions{ii,1},',',parser.unitRootOptions{ii,2},',',...
                       parser.unitRootOptions{ii,3}];
    end
    block{end} = '';

end

%==========================================================================
function block = writeRep(repTable)

    if isempty(repTable)
        block = cell(0,1); 
        return
    end

    block    = cell(size(repTable,1) + 2,1);
    block{1} = 'reporting';
    for ii = 1:size(repTable,1)
        block{1+ii} = [repTable{ii,1},'=',repTable{ii,2} ';'];
    end
    block{end} = '';
    
end

%==========================================================================
function block = writeParam(obj,paramOpt,filename,precision)

    block = cell(0,1);
    if strcmpi(paramOpt,'file') 
        param = obj.getParameters('struct');
        save([filename '_param.mat'],'param')
        return
    elseif strcmpi(paramOpt,'off') 
        return
    end

    if isempty(names)
        return
    end

    param    = obj.getParameters();
    block    = cell(size(param,1) + 2,1);
    block{1} = 'parameterization';
    for ii = 1:size(param,1)
        block{1+ii} = [param{ii,1},'=',nb_num2str(param{ii,2},precision)];
    end
    block{end} = '';
    
end

%==========================================================================
function block = writeSS(ssInit,ssOpt,filename,precision)

    block = cell(0,1);
    if nb_isempty(ssInit)
        return
    end
    if strcmpi(ssOpt,'file') 
        save([filename '_ss.mat'],'ssInit')
        return
    elseif strcmpi(ssOpt,'off') 
        return
    end

    if isempty(names)
        return
    end

    ssInit   = nb_struct2cellarray(ssInit,'matrix');
    block    = cell(size(ssInit,1) + 2,1);
    block{1} = 'steady_state_model';
    for ii = 1:size(ssInit,1)
        block{1+ii} = [ssInit{ii,1},'=',nb_num2str(ssInit{ii,2},precision)];
    end
    block{end} = '';
    
end

%==========================================================================
function block = writeLossFunction(obj,precision)

    if ~obj.parser.optimal
        block = cell(0,1);
        return
    end
    lossVars      = nb_base(obj.parser.lossVariableNames);
    params        = nb_base(obj.parameters.name);
    lossFunc      = toString(obj.parser.lossFunction(lossVars,params));
    lc_discount   = nb_num2str(obj.options.lc_discount,precision);
    lc_commitment = nb_num2str(obj.options.lc_commitment,precision);
    block         = cell(2,1);
    block{1}      = ['planner_objective{discount=' lc_discount ',commitment=' lc_commitment '}' lossFunc ';'];
    block{2}      = '';

end

%==========================================================================
function block = writeBreakPointsBlock(obj)

    if isempty(obj.parser.breakPoints)
        block = cell(0,1);
        return
    end
    
    block = cell(length(obj.parser.breakPoints)+1,1);
    for ii = 1:length(obj.parser.breakPoints)
        strDate   = toString(obj.parser.breakPoints.date);
        params    = nb_cellstr2String(obj.parser.breakPoints.parameters,',');
        block{ii} = ['breakPoint{' strDate '}' params];
    end
    block{end} = '';
    
end
