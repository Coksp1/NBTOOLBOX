function f = pdf(obj,x)
% Syntax:
%
% f = pdf(obj,x)
%
% Description:
%
% Evaluate the pdf of the given distribution at the value(s) x.
% 
% Input:
% 
% - obj : An object of class nb_distribution
%
% - x   : A double with any size if numel(obj) == 1, otherwise it must be
%         a Tx1 double.
% 
% Output:
% 
% - f   : numel(obj) == 1 : A double with the same size as x
%         otherwise       : A double with size T x nobj
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj1 = size(obj,1);
    nobj  = size(obj,2);
    if nobj1 ~= 1
        if nobj == 1
            obj  = obj(:);
            nobj = nobj1;
        else
            error([mfilename ':: The obj input must be a nb_distribution vector.'])
        end
    end
    
    if nobj ~= 1
        if size(x,2) ~= 1
            if size(x,1) ~=1
                error([mfilename ':: The x input must be a column vector when dealing with a vector of nb_distribution objects.'])
            else
                x = x';
            end
        end
        f  = nan(size(x,1),nobj);
        lb = {obj.lowerBound};
        ub = {obj.upperBound};
        ms = {obj.meanShift};
        for ii = 1:nobj
            
            if ~isempty(ms{ii})
                f = nb_distribution.meanshift_pdf(x,obj(ii).type,obj(ii).parameters,lb{ii},ub{ii},ms{ii});
            else
                if isempty(lb{ii}) && isempty(ub{ii})
                    func    = str2func(['nb_distribution.' obj(ii).type '_pdf']);
                    f(:,ii) = func(x,obj(ii).parameters{:});
                else
                    f(:,ii) = nb_distribution.truncated_pdf(x,obj(ii).type,obj(ii).parameters,lb{ii},ub{ii});
                end
            end
              
        end
        
    else
        
        lb = obj.lowerBound;
        ub = obj.upperBound;
        if ~isempty(obj.meanShift)
            f = nb_distribution.meanshift_pdf(x,obj.type,obj.parameters,lb,ub,obj.meanShift);
        else
            if isempty(lb) && isempty(ub)
                func = str2func(['nb_distribution.' obj.type '_pdf']);
                f    = func(x,obj.parameters{:});
            else
                f = nb_distribution.truncated_pdf(x,obj.type,obj.parameters,lb,ub);
            end
        end 
        
    end
    
end
