function x = variance(obj)
% Syntax:
%
% x = variance(obj)
%
% Description:
%
% Evaluate the variance of the given distribution.
%
% The variance is normalized with T-1
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nobj1 = size(obj,1); 
    nobj  = size(obj,2);
    lb    = reshape({obj.lowerBound},nobj1,nobj);
    ub    = reshape({obj.upperBound},nobj1,nobj);
    ms    = reshape({obj.meanShift},nobj1,nobj);
    x     = nan(nobj1,nobj);
    for jj = 1:nobj1
    
        for ii = 1:nobj

            if ~isempty(lb{jj,ii}) || ~isempty(ub{jj,ii}) % Truncated distribution

                % Use the same seed when returning the "random" numbers
                seed          = 2.0719e+05;
                defaultStream = RandStream.getGlobalStream;
                savedState    = defaultStream.State;
                s             = RandStream.create('mt19937ar','seed',seed);
                RandStream.setGlobalStream(s);

                % Some distribution may have a close form solution here,
                % but most are based on "simulations"
                if isempty(ms{jj,ii})
                    x(jj,ii) = nb_distribution.truncated_variance(obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii});
                else
                    x(jj,ii) = nb_distribution.meanshift_variance(obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii},ms{jj,ii});
                end

                % Reset the seed
                defaultStream.State = savedState;
                RandStream.setGlobalStream(defaultStream);

            else
                func     = str2func(['nb_distribution.' obj(jj,ii).type '_variance']);
                x(jj,ii) = func(obj(jj,ii).parameters{:});
            end

        end

    end

end
