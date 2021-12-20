function p = getParameters(obj,varargin)
% Syntax:
%
% p = getParameters(obj,varargin)
%
% Description:
%
% Same as obj.parameters only that the name and values are concatenated
% into a nParam x 2 cell matrix instead of a struct.
% 
% Input:
% 
% - obj  : An object of class nb_model_generic.
% 
% Optional input
%
% - varargin : If 'struct' is provided among the optional inputs the 
%              returned will be a struct where the parameters are the 
%              fieldnames and the parameter values as
%              fields. Otherwise a nParam x 2 cell matrix. First column 
%              is the parameter names, while the second column is the 
%              parameter values ('struct' is not supported if 
%              numel(obj) > 1).
%
%            : Give 'headers' to add model names as headers for each 
%              column of the return cell. Only if numel(obj) > 1.
%
%            : Give 'double' to return the value as a numerical array.
%
%            : Give 'skipBreaks' to not remove any break-point parameters.
%
% Output:
% 
% - p   : See the type input.
%
% See also:
% parameters
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~iscellstr(varargin)
        error([mfilename ':: All optional inputs must be of type char.'])
    end
    
    [outAsStruct,varargin] = nb_parseOneOptionalSingle('struct',false,true,varargin{:}); 
    [headers,varargin]     = nb_parseOneOptionalSingle('headers',false,true,varargin{:}); 
    [reverse,varargin]     = nb_parseOneOptionalSingle('reverse',false,true,varargin{:}); 
    [doubleOut,varargin]   = nb_parseOneOptionalSingle('double',false,true,varargin{:});
    [skipBreaks,varargin]  = nb_parseOneOptionalSingle('skipBreaks',false,true,varargin{:});
    
    if numel(obj) > 1
        
        obj  = obj(:);
        nobj = size(obj,1);
        if outAsStruct 
            error([mfilename ':: If ''struct'' is used the obj input must be a scalar nb_model_generic object.'])
        elseif reverse
            error([mfilename ':: If ''reverse'' is used the obj input must be a scalar nb_model_generic object.'])
        else
            pNames  = cell(1,nobj);
            pValues = cell(1,nobj);
            for ii = 1:nobj
                p           = getParameters(obj(ii),varargin{:});
                pNames{ii}  = p(:,1);
                pValues{ii} = p(:,2);
            end
            pNamesAll = unique(vertcat(pNames{:}));
            nParam    = length(pNamesAll);
            p         = repmat({nan},[nParam,nobj+1]);
            for ii = 1:nobj
                [~,loc]     = ismember(pNames{ii},pNamesAll);
                p(loc,ii+1) = pValues{ii};
            end
            p(:,1) = pNamesAll;
        end
        
        if ~isempty(varargin)
            [ind,loc] = ismember(varargin,pNamesAll);
            if any(~ind)
                error([mfilename ':: Could not locate the parameters ' toString(varargin(~ind)) '.'])
            else
               p = p(loc,:); 
            end
        else
            [~,i] = sort(pNamesAll);
            p     = p(i,:); 
        end
        
        if doubleOut
            p     = cell2mat(p(:,2));
        elseif headers
            names = [{''},nb_rowVector(getModelNames(obj))];
            p     = [names;p];
        end
        return
        
    end
    ps = obj.parameters;
    p  = [ps.name,num2cell(ps.value(:,:,end))];
        
    if isa(obj,'nb_dsge')
        if isBreakPoint(obj) && ~skipBreaks
                
            nBreaks     = obj.estOptions.parser.nBreaks;
            breakPoints = obj.estOptions.parser.breakPoints;
            numNew      = 0;
            for ii = 1:nBreaks
                numNew = numNew + length(breakPoints(ii).parameters);
            end

            newP = cell(numNew,2);
            kk   = 1;
            for ii = 1:nBreaks
                params              = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).date));
                params              = params(:);
                values              = num2cell(breakPoints(ii).values(:));
                nBP                 = size(values,1);
                newP(kk:kk+nBP-1,:) = [params,values];
                kk                  = kk + nBP;
            end
            p = [p; newP];
            
        end
    end
    
    if isempty(p)
        if outAsStruct
           p = struct;  
        end
        return
    end
    
    if ~isempty(varargin)
        [ind,loc] = ismember(varargin,p(:,1));
        if any(~ind)
            error([mfilename ':: Could not locate the parameters ' toString(varargin(~ind)) '.'])
        else
           p = p(loc,:); 
        end
        reverse = true; % Prevent ordering when 'struct' is given
    else
        if ~reverse
            [~,i] = sort(p(:,1));
            p     = p(i,:); 
        end
    end
    
    if outAsStruct
        p = cell2struct(p(:,2),strrep(p(:,1),' ','_'));
        if ~reverse
            p = orderfields(p);
        end
    elseif doubleOut
        p = cell2mat(p(:,2));
    end
    
end
