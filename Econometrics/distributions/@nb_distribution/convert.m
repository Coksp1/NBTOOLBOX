function obj = convert(obj)
% Syntax:
%
% convert(obj)
%
% Description:
%
% Convert a distribution to type 'kernel'
% 
% Input:
% 
% - obj : A matrix of nb_distributions objects
% 
% Output:
% 
% - obj : A matrix of nb_distributions objects with type set to 'kernel'
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Convert each distribution
    [s1,s2] = size(obj);
    obj     = obj(:);
    nobj    = numel(obj);
    ms      = {obj.meanShift};
    for ii = 1:nobj
        
        if strcmpi(obj.type,'kernel')
            continue
        end
        
        start  = getStartOfDomain(obj(ii)); 
        finish = getEndOfDomain(obj(ii));
        if finish - start > 1
            start  = floor(start);
            finish = ceil(finish);
        elseif finish - start > 0.1
            start  = floor(start*10)/10;
            finish = ceil(finish*10)/10;
        elseif finish - start > 0.01
            start  = floor(start*100)/100;
            finish = ceil(finish*100)/100;
        else
            start  = floor(start*1000)/1000;
            finish = ceil(finish*1000)/1000;
        end
        incr   = (finish - start)/999;
        x      = start:incr:finish;

        % The meanShift property will be corrected for in cdf and pdf 
        % methods
        f = pdf(obj(ii),x);
        if ~isempty(ms{ii})
            x = x - ms{ii};
        end
        
        % Make a nb_distribution object and assign properties
        obj(ii).parameters = {x',f'};
        obj(ii).type       = 'kernel';

    end
   
    % Reshape to input size
    obj = reshape(obj,[s1,s2]);

end
