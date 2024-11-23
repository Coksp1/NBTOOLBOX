classdef nb_dataSource
% Description:
%
% A abstract class.
%
% Subclasses:
%
% nb_ts, nb_cs, nb_data, nb_bd, nb_cell
%
% Constructor:
%
%   obj = nb_dataSource;
% 
% See also: 
% nb_ts, nb_cs, nb_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected,Dependent=true)
        
        % Number of datasets stored in the object. As a double. 
        numberOfDatasets         
        
        % Number of variables stored in the object. As a double. 
        numberOfVariables       
        
    end

    properties
        
        % The data of the object. As a double or logical.
        data                    = [];
        
        % The names of the different dataset. As a cellstr.
        dataNames               = {};
        
        % A nb_struct with the local variables of the nb_ts object. 
        % I.e. a field with name 'test' can be reach with the string 
        % input %#test. Only for dates and vintage inputs.
        localVariables          = [];
        
        % Add user data. Can be of any type.
        userData                = '';
        
        % Variables of the object. As a cellstr.
        variables               = {};
        
    end
    
    properties (Access=protected,Hidden=true)
          
        % Indicator if the object is beeing updated
        isBeingMerged           = 0;
        
        % Indicator if the object is beeing updated
        isBeingUpdated          = 0;
        
        % A structure with the links to the datasources. This
        % property also store all method calls of an updateable
        % object.
        links                   = struct([]);
        
        % An indicator on sorting or no sorting of the variables.
        sorted                  = true;
        
        % Indicate that the object is updateable (1) or not (0).
        updateable              = 0;
        
    end
    
    methods
        
        function [obj,message] = nb_addPostFixGUI(obj,postfix,vars)

            if nargin < 3
                vars = {};
            end

            message        = '';
            indN           = regexp(postfix,'\d','start');
            postfixT       = postfix;
            postfixT(indN) = '';
            ind            = regexp(postfixT,'[!"@#£¤$%&/()=?`\^~¨*-:;§|><{},]','once');
            if ~isempty(ind)
                message = ['Invalid postfix ''' postfix ''' provided. The postfix cannot contain [, !, ", @, #, £, ¤, $, '...
                           '%, &, /, (, ), =, ?, `, \, ^, ~, ¨, *, -, :, ;, §, |, >, <, {, }, ], and ,'];
                return
            end
            
            if isempty(vars)
                var = obj.variables;
                var = strcat(var,postfix);
                obj.variables = var;
            else
                [~,ind] = ismember(vars,obj.variables);
                var     = strcat(vars,postfix);
                obj.variables(ind) = var;
            end

            if obj.isUpdateable()

                % Add operation to the link property, so when the object 
                % is updated the operation will be done on the updated 
                % object
                obj = obj.addOperation(@addPostfix,{postfix,vars});

            end

        end
        
        function value = get.numberOfVariables(obj)
            if isempty(obj.data)
                value = 0;
            elseif isa(obj,'nb_bd')
                value = size(obj.locations,2) / obj.numberOfDatasets;
            else
                value = size(obj.data,2);
            end
        end
        
        function value = get.numberOfDatasets(obj)
            if isempty(obj.data)
                value = 0;
            elseif isa(obj,'nb_bd')
                value = size(obj.locations,2) / size(obj.variables,2);
            else
                value = size(obj.data,3);
            end
        end
        
        function s = saveobj(obj)
            s = struct(obj);
        end
        
        function obj = setLinks(obj,propertyValue)
            
            obj.links = propertyValue;
            if isempty(obj.links)
                obj.updateable = 0;                
            elseif isempty(obj.links.subLinks)
                obj.updateable = 0;
                obj.links      = struct([]);
            else
                obj.updateable = 1;
            end
            
        end
        
        function propertyValue = get.dataNames(obj)
        % Secure that dataNames property always is a row vector!
        
            propertyValue = obj.dataNames;
            if size(propertyValue,1) > 1
                propertyValue = propertyValue';
            end
            
        end
        
        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.data, varargin{:});
        end
        
    end
    
    methods (Abstract=true)
        
        s   = struct(obj)
        obj = empty(obj)
        
        % Syntax:
        %
        % [obj,another] = secureSameSpan(obj,another)
        %
        % Description:
        %
        % Secure same span along the first dimension (time, obs or types)
        % of the two datasets.
        % 
        % Input:
        % 
        % - obj     : An object of class nb_dataSource.
        %
        % - another : An object of class nb_dataSource.
        % 
        % Output:
        % 
        % - obj     : An object of class nb_dataSource.
        %
        % - another : An object of class nb_dataSource.
        %
        % Written by Kenneth Sæterhagen Paulsen
        [obj,another] = secureSameSpan(obj,another)
        
    end
    
    methods (Access=public,Hidden=true)
        
        function obj = addOperation(obj,funcHandle,inputs)
        % Add a operation to the linked source
        %
        % funcHandle : MATLAB function handle to the method to 
        %              call.
        %
        % inputs     : A cell array with the called methods inputs
        
            if nargin < 3
                inputs = {};
            end
                        
            % Creat the method call array
            methodCall = {{funcHandle,inputs}};
            
            % Assign the method call to all links
            subLinks               = obj.links.subLinks;
            subLinks(1).operations = [subLinks(1).operations, methodCall];
            obj.links.subLinks     = subLinks;
        
        end
        
    end
    
    methods(Static=true,Hidden=true)
       
        function dispMethods(className)
            
            classConst = str2func(className);
            obj        = classConst();
            switch lower(className)
                case 'nb_ts'
                    [groups,remove] = nb_dataSource.getTSGroups();
                case 'nb_data'
                    [groups,remove] = nb_dataSource.getDataGroups();
                case 'nb_cs'
                    [groups,remove] = nb_dataSource.getCSGroups();
                case 'nb_cell'
                    [groups,remove] = nb_dataSource.getCellGroups();    
            end
            
            disp(nb_createDispTable(obj,groups,remove,'methods'))
            
        end
        
        function [groups,remove] = getTSGroups()
            
            groups = {
                'Add, create and set methods:',     {'addDataset','addDatasets','addLags','addPageCopies','addPages',...
                                                     'addTimeTrend','addVariable','createSeasonalDummy','createShift',...
                                                     'createTimeDummy','createVarDummy','createVariable','doTransformations',...
                                                     'checkExpressions','easterDummy','setValue','structure2Dataset'}
                'Convert frequency:',               {'convert','denton'}                                      
                'Convert object methods:',          {'asCell','asCellForMPRReport','double','getCode','getVariable',...
                                                     'struct','toMFile','toRise_ts','toStructure','toTseries','todyn_ts',...
                                                     'tonb_cell','tonb_cs','tonb_data','writeTex'}                                  
                'Data link methods:',               {'breakLink','deleteMethodCalls','getMethodCalls','getSource','setLinks',....
                                                     'setMethodCalls','update'}                                     
                'Dating methods:',                  {'dates','getRealEndDate','getRealEndDatePages','getRealStartDate'}   
                'Expand methods:',                  {'expand','expandPeriods','extrapolate','extrapolateStock',...
                                                     'keepInitial','recursiveExtrapolate'}
                'Filtering methods:',               {'bkfilter','bkfilter1s','detrend','doTransformations','hpfilter',...
                                                     'hpfilter1s','mavg','mstd','x12Census'}
                'Initialization methods:',          {'fromRise_ts','nan','nb_ts','ones','rand','simulate','zeros'}
                'is methods:',                      {'isDistribution','isUpdateable','isempty','isfinite','isnan',...
                                                     'isscalar','isCrossSectional','isRealTime','isTimeseries'}
                'Logical operators',                {'and','hasVariable','not','or'}                                     
                'Math methods:',                    {'abs','acos','acosd','acosd','acosh','acot','acotd','acoth',...
                                                     'acsc','acscd','acsch','asec','asecd','asech','asin','asind',...
                                                     'asinh','atan','atand','atanh','conj','cos','cosd','cosh','cot','cotd',...
                                                     'coth','csc','cscd','csch','cumnansum','cumprod','cumsum','exp',...
                                                     'expm1','log','log10','log1p','log2','pow2','real','reallog','realpow',...
                                                     'realsqrt','sec','secd','sech','sin','sind','sinh','sqrt','tan',...
                                                     'tand','tanh'}
                'Math operators:',                  {'minus','mldivide','mpower','mrdivide','mtimes','plus',...
                                                     'power','rdivide','times','uminus','uplus'}
                'Merging methods:',                 {'append','appendRecursive','deptcat','horzcat','merge','merge2Series',...
                                                     'vertcat'}
                'Missing observations methods:',    {'assignNan','fillNaN','interpolate','nan2var','set2nan','setToNaN',...
                                                     'strip','stripButLast'}
                'Naming and reordering methods:',   {'addPostfix','addPrefix','packing','permute','rename','renameMore',...
                                                     'reorder','sort','sortProperty','squeeze'} 
                'Real-time methods:',               {'cleanRealTime','realTime2RecCondData','release','splitByPublishDates',...
                                                     'stripFcstFromRealTime'}                                     
                'Relation operators:',              {'eq','ge','gt','le','lt','ne'}
                'Rounding methods:',                {'ceil','floor','round'}
                'Split methods:',                   {'splitByPublishDates','splitSample','splitSeries'}
                'Statistical methods:',             {'autocorr','corr','cov','demean','ecdf','estimateDist','hdi',...
                                                     'jbTest','ksdensity','kurtosis','map2Distribution','max','mean',...
                                                     'median','min','mode','parcorr','pca','percentiles','skewness',...
                                                     'std','stdise','sum','summary','var'}
                'Timing methods:',                  {'addLags','lag','lead','rlag'}
                'Transformation methods:',          {'aegrowth','agrowth','demean','diff','egrowth','epcn','growth',...
                                                     'iegrowth','iepcn','igrowth','ipcn','mavg','meanDiff','meanGrowth',...
                                                     'mstd','pcn','q2y','reIndex','ret','sgrowth','stdise','subAvg',...
                                                     'subSum','sum','sumOAF','undiff'}
                'Shrink sample methods:',           {'cutSample','deleteVariables','getVariable','keepVariables',...
                                                     'lastObservation','removeObservations','shrinkSample','window'}                                     
            };
            remove = {}; 
        
        end
        
        function [groups,remove] = getDataGroups()
            
            groups = {
                'Add, create and set methods:',     {'addDataset','addDatasets','addPageCopies','addPages',...
                                                     'addVariable','createObsDummy','createVarDummy','createVariable',...
                                                     'setValue','structure2Dataset'}                                      
                'Convert object methods:',          {'asCell','asCellForMPRReport','double','getCode','getVariable',...
                                                     'struct','toMFile','toStructure','tonb_cell','tonb_cs','tonb_ts',...
                                                     'writeTex'}                                  
                'Data link methods:',               {'breakLink','deleteMethodCalls','getMethodCalls','getSource','setLinks',....
                                                     'setMethodCalls','update'}                                     
                'Observations count methods:',      {'observations','getRealEndObs','getRealStartObs'}   
                'Expand methods:',                  {'expand','expandPeriods'}
                'Filtering methods:',               {'bkfilter','bkfilter1s','detrend','hpfilter','hpfilter1s','mavg','mstd'}
                'Initialization methods:',          {'fromRise_ts','nan','nb_data','ones','rand','zeros'}
                'is methods:',                      {'isDistribution','isUpdateable','isempty','isfinite','isnan',...
                                                     'isscalar','isCrossSectional','isTimeseries'}
                'Logical operators',                {'and','hasVariable','not','or'}                                     
                'Math methods:',                    {'abs','acos','acosd','acosd','acosh','acot','acotd','acoth',...
                                                     'acsc','acscd','acsch','asec','asecd','asech','asin','asind',...
                                                     'asinh','atan','atand','atanh','conj','cos','cosd','cosh','cot','cotd',...
                                                     'coth','csc','cscd','csch','cumnansum','cumprod','cumsum','exp',...
                                                     'expm1','log','log10','log1p','log2','pow2','real','reallog','realpow',...
                                                     'realsqrt','sec','secd','sech','sin','sind','sinh','sqrt','tan',...
                                                     'tand','tanh'}
                'Math operators:',                  {'minus','mldivide','mpower','mrdivide','mtimes','plus',...
                                                     'power','rdivide','times','uminus','uplus'}
                'Merging methods:',                 {'append','deptcat','horzcat','merge','merge2Series','vertcat'}
                'Missing observations methods:',    {'assignNan','interpolate','nan2var','set2nan',...
                                                     'strip','stripButLast'}
                'Naming and reordering methods:',   {'addPostfix','addPrefix','packing','permute','rename','renameMore',...
                                                     'reorder','sort','sortProperty','squeeze'}                                  
                'Relation operators:',              {'eq','ge','gt','le','lt','ne'}
                'Rounding methods:',                {'ceil','floor','round'}
                'Split methods:',                   {'splitSeries'}
                'Statistical methods:',             {'autocorr','corr','cov','demean','ecdf','estimateDist','hdi',...
                                                     'histcounts','ksdensity','kurtosis','map2Distribution','max','mean',...
                                                     'median','min','mode','parcorr','pca','percentiles','skewness',...
                                                     'std','stdise','sum','summary','var'}
                'Timing methods:',                  {'lag','lead','rlag'}
                'Transformation methods:',          {'demean','diff','egrowth','epcn','growth','iegrowth','iepcn',...
                                                     'igrowth','ipcn','mavg','meanDiff','meanGrowth','mstd','pcn',...
                                                     'reIndex','ret','stdise','sum','undiff'}
                'Shrink sample methods:',           {'deleteVariables','getVariable','keepVariables',...
                                                     'lastObservation','window'}                                     
            };
            remove = {}; 
            
        end
        
        function [groups,remove] = getCSGroups()
            
            groups = {
                'Add, create and set methods:',     {'addDataset','addDatasets','addPageCopies','addPages',...
                                                     'addVariable','addType','createType','createVariable','setValue',...
                                                     'structure2Dataset'}                                      
                'Convert object methods:',          {'asCell','asCellForMPRReport','double','getCode','getVariable',...
                                                     'struct','toMFile','toStructure','tonb_cell','tonb_data','tonb_ts',...
                                                     'writeTex'}                                  
                'Data link methods:',               {'breakLink','deleteMethodCalls','getMethodCalls','getSource','setLinks',....
                                                     'setMethodCalls','update'} 
                'Expand methods:',                  {'expand'}                                     
                'Initialization methods:',          {'nan','nb_cs','ones','rand','zeros'}
                'is methods:',                      {'isDistribution','isUpdateable','isempty','isfinite','isnan',...
                                                     'isscalar','isCrossSectional','isTimeseries'}
                'Logical operators',                {'and','hasVariable','not','or'}                                     
                'Math methods:',                    {'abs','acos','acosd','acosd','acosh','acot','acotd','acoth',...
                                                     'acsc','acscd','acsch','asec','asecd','asech','asin','asind',...
                                                     'asinh','atan','atand','atanh','conj','cos','cosd','cosh','cot','cotd',...
                                                     'coth','csc','cscd','csch','cumnansum','cumprod','cumsum','exp',...
                                                     'expm1','log','log10','log1p','log2','pow2','real','reallog','realpow',...
                                                     'realsqrt','sec','secd','sech','sin','sind','sinh','sqrt','tan',...
                                                     'tand','tanh'}
                'Math operators:',                  {'minus','mldivide','mpower','mrdivide','mtimes','plus',...
                                                     'power','rdivide','times','uminus','uplus'}
                'Merging methods:',                 {'deptcat','horzcat','interwine','merge','merge2Series','vertcat'}
                'Missing observations methods:',    {'assignNan','interpolate'}
                'Naming and reordering methods:',   {'addPostfix','addPrefix','packing','permute','rename','renameMore',...
                                                     'reorder','sort','sortProperty','sortTypes','squeeze','ctranspose',...
                                                     'transpose'}                                  
                'Relation operators:',              {'eq','ge','gt','le','lt','ne'}
                'Rounding methods:',                {'ceil','floor','round'}
                'Statistical methods:',             {'corr','cov','demean','estimateDist','kurtosis',...
                                                     'map2Distribution','max','mean','median','min','mode',...
                                                     'percentiles','skewness','std','sum','summary','var'}
                'Transformation methods:',          {'demean','diag','sum'}
                'Shrink sample methods:',           {'deleteTypes','deleteVariables','getVariable','keepTypes','keepVariables','window'}                                     
            };
            remove = {'intertwine'}; 
        
        end
        
        function [groups,remove] = getCellGroups()
            
            groups = {
                'Add, create and set methods:',     {'addDataset','addDatasets','addPageCopies','addPages',...
                                                     'addColumn','addRow','setValue'}                                      
                'Convert object methods:',          {'asCell','asCellForMPRReport','double','struct','toMFile',...
                                                     'toStructure'}                                  
                'Data link methods:',               {'breakLink','deleteMethodCalls','getMethodCalls','getSource','setLinks',....
                                                     'setMethodCalls','update'}                                    
                'Initialization methods:',          {'nan','nb_cell','ones','rand','zeros'}
                'is methods:',                      {'isDistribution','isUpdateable','isempty','isfinite','isnan',...
                                                     'isscalar','isCrossSectional','isTimeseries'}
                'Logical operators',                {'and','hasVariable','not','or'}                                     
                'Math methods:',                    {'abs','acos','acosd','acosd','acosh','acot','acotd','acoth',...
                                                     'acsc','acscd','acsch','asec','asecd','asech','asin','asind',...
                                                     'asinh','atan','atand','atanh','conj','cos','cosd','cosh','cot','cotd',...
                                                     'coth','csc','cscd','csch','cumnansum','cumprod','cumsum','exp',...
                                                     'expm1','log','log10','log1p','log2','pow2','real','reallog',...
                                                     'realsqrt','sec','secd','sech','sin','sind','sinh','sqrt','tan',...
                                                     'tand','tanh'}
                'Math operators:',                  {'uminus','uplus'}                                     
                'Merging methods:',                 {'deptcat','horzcat','merge','merge2Series','vertcat'}
                'Missing observations methods:',    {'assignNan','interpolate'}
                'Naming and reordering methods:',   {'addPostfix','addPrefix','packing','permute','rename','renameMore',...
                                                     'reorder','sortProperty','ctranspose','transpose'}                                  
                'Relation operators:',              {'eq','ge','gt','le','lt','ne'}
                'Rounding methods:',                {'ceil','floor','round'}
                'Statistical methods:',             {'demean','map2Distribution'}
                'Shrink sample methods:',           {'window'}                                     
            };
            remove = {'deleteVariables'}; 
        
        end
        
    end
    
    methods (Static=true,Access=protected)
       
        function [dat,vars] = mergeDataAndParameters(dat,vars,parameters)
            
            if ~isstruct(parameters)
                error([mfilename ':: The parameters input must be a struct.'])
            end
            pars      = fieldnames(parameters)';
            vars      = [vars,pars];
            parValues = struct2cell(parameters);
            try
                parValues = cell2mat(parValues)';
            catch
                error([mfilename ':: The parameters input must be a struct, where all the fields are scalar double.'])
            end
            if ~nb_sizeEqual(parValues,size(pars))
                error([mfilename ':: The parameters input must be a struct, where all the fields are scalar double.'])
            end
            parValues = parValues(ones(size(dat,1),1),:,ones(size(dat,3),1));
            dat       = [dat,parValues];
            
        end
        
    end

end
    
    
