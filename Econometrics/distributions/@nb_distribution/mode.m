function x = mode(obj)
% Syntax:
%
% x = mode(obj)
%
% Description:
%
% Evaluate the mode of the given distribution.
% 
% Input:
% 
% - obj : An object of class nb_distribution
% 
% Output:
% 
% - x   : numel(obj) == 1 : A double with size as 1 x 1
%         otherwise       : A double with size 1 x nobj
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj1 = size(obj,1); 
    nobj  = size(obj,2);
    lb    = reshape({obj.lowerBound},nobj1,nobj);
    ub    = reshape({obj.upperBound},nobj1,nobj);
    ms    = reshape({obj.meanShift},nobj1,nobj);
    x     = nan(nobj1,nobj);
    for jj = 1:nobj1
        
        for ii = 1:nobj

            objT = obj(jj,ii);
            lbT  = lb{jj,ii};
            ubT  = ub{jj,ii};
            if isempty(lbT) && isempty(ubT)

                func     = str2func(['nb_distribution.' objT.type '_mode']);
                x(jj,ii) = func(objT.parameters{:});
                if ~isempty(ms{jj,ii})
                    x(jj,ii) = x(jj,ii) + ms{jj,ii};
                end
                
            else

                if strcmpi(objT.type,'kernel')

                    domain  = objT.parameters{1};
                    density = objT.parameters{2};
                    indS    = 1;
                    indE    = length(domain);
                    if ~isempty(lbT)
                        indS = find(lbT <= domain,1);
                    end
                    if ~isempty(ubT)
                        indE = find(ubT >= domain,1,'last');
                    end

                    tDomain  = domain(indS:indE);
                    tDensity = density(indS:indE);
                    [~,ind]  = max(tDensity);
                    x(jj,ii) = tDomain(ind);
                    
                    if ~isempty(ms{jj,ii})
                        x(jj,ii) = x(jj,ii) + ms{jj,ii};
                    end

                else
                    if isempty(ms{jj,ii})
                        x(jj,ii) = nb_distribution.truncated_mode(objT.type,objT.parameters,lbT,ubT);
                    else
                        x(jj,ii) = nb_distribution.meanshift_mode(objT.type,objT.parameters,lbT,ubT,ms{jj,ii});
                    end
                end
                
            end
            
        end
        
    end

end
