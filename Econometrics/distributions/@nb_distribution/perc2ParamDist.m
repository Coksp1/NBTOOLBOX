function [obj,err] = perc2ParamDist(dist,perc,values,varargin)
% Syntax:
%
% [obj,err] = nb_distribution.perc2ParamDist(dist,perc,values,varargin)
%
% Description:
%
% This method estimate the parameters of the wanted distribution based on
% a set of percentiles. It will minimize the distance between the 
% parameterized distribution and the provided percentiles. 
% 
% Input:
% 
% - dist       : A string with the distribution to match to the 
%                percentiles.
%
%                See help on the nb_distribution.type property for the  
%                supported distributions.
%
% - perc       : The percentiles to fit. Must at least provide as many 
%                percentiles as there are parameters of the distibution. 
%                E.g. [10,30,50,70,90]
% 
% - values     : The values of the distribution at the given percentiles.
%
% Optional input:
%
% - 'optimizer' : See doc of the optimizer input to the nb_callOptimizer
%                 function. Default is 'fmincon'.
%
% - 'optimset'  : See doc of the opt input to the nb_callOptimizer
%                 function. 
%
% Output:
% 
% - obj        : An object of class nb_distribution
%
% - err        : Ask for this output if you want to return a potential
%                error instead of it being thrown by this method. If an
%                error occure this output is non-empty, while obj is.
%
% Examples:
%
% orig   = nb_distribution('type','normal','parameters',{0,2});
% perc   = [10,30,50,70,90];
% values = percentile(orig,perc);
% obj    = nb_distribution.perc2ParamDist('normal',perc,values);
% plot([orig,obj])
%
% See also:
% nb_distribution.perc2Dist, nb_callOptimizer
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    [optimizer,varargin] = nb_parseOneOptional('optimizer','fmincon',varargin{:});
    optimset             = nb_parseOneOptional('optimset',[],varargin{:});
    if nb_isempty(optimset)
        optimset = nb_getDefaultOptimset(optimizer);
        if isfield(optimset,'Display')
            optimset.Display = 'off';
        elseif isfield(optimset,'display')
            optimset.display = 'off';
        end
    end
    
    perc   = perc(:);
    values = values(:);
    if length(perc) ~= length(values)
        error([mfilename ':: The perc and values input must have same size'])
    end
    
    % Check inputs
    [~,ind]  = sort(perc);
    values   = values(ind);
    [~,ind]  = sort(values);
    [~,ind2] = sort(ind);
    if any(ind~=ind2)
        error([mfilename ':: The values input must be be increasing (potentially after reordering of perc)'])
    end
    perc = perc/100;
    
    % Construct distribution to optimize
    obj = nb_distribution('type',dist);
    if length(obj.parameters) > size(perc,1) 
        error(['You must have at least as many percentiles as the selected distribution ',...
               'has parameters (' int2str(length(obj.parameters)) ').'])
    end
    
    % Estimate parameters
    init             = [obj.parameters{:}];
    func             = str2func(['nb_distribution.' dist '_icdf']);
    fh               = @(x)estimator(x,func,perc,values); 
    [estPar,~,~,err] = nb_callOptimizer(optimizer,fh,init(:),[],[],optimset,'Error during nb_distribution.perc2ParamDist:: ');
    if ~isempty(err)
        if nargout < 2
            error(err);
        else
            obj = [];
            return
        end
    end
    
    % Make assign parameter values
    obj.parameters = num2cell(estPar');
    
end

%==========================================================================
function f = estimator(x,func,percIn,valuesIn)

    param  = num2cell(x');
    values = func(percIn,param{:});
    f      = sum((values - valuesIn).^2);

end
