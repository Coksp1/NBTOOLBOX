function posterior = dynareToPosterior(dynare_file_short)
% Syntax:
%
% posterior = nb_dsge.dynareToPosterior(dynare_file_short)
%
% Description:
%
% Convert posterior draws from dynare output to the format needed to
% utilize does draws by the NB Toolbox.
% 
% Input:
% 
% - dynare_file_short : Name of the dynare file without extension.
% 
% Output:
% 
% - posterior         : A struct with the posterior draws from the DSGE
%                       model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    posterior     = struct('betaD',[],'sigmaD',[],'type','dynare');
    posteriorPath = [dynare_file_short '\\metropolis\\' dynare_file_short '_mh%d_blck%d.mat'];
    matFilename   = sprintf(posteriorPath, 1,1);
    if exist(matFilename,'file') % Has there been produced posterior draws?

        cont = 1;
        ii   = 1;
        x    = [];
        while cont
            try
                matFilename = sprintf(posteriorPath,ii,1);
                matData     = load(matFilename);
                x           = [x;matData.x2]; %#ok<AGROW>
            catch %#ok<CTCH>
               cont = 0; 
            end
            ii = ii + 1;
        end

        cont = 1;
        ii   = 1;
        while cont
            try
                matFilename = sprintf(posteriorPath,ii,2);
                matData     = load(matFilename);
                x           = [x;matData.x2]; %#ok<AGROW>
            catch %#ok<CTCH>
               cont = 0; 
            end
            ii = ii + 1;
        end
        
        x         = permute(x,[2,3,1]);
        posterior = struct('betaD',x,...
                           'sigmaD',nan(0,0,size(x,3)),...
                           'type','dynare');

    end

end
