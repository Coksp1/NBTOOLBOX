function p = rbc_param(type)

p=struct();

% Parameters of the RBC model
p.alpha    = 0.60;
p.beta     = 0.999;
p.delta    = 0.1;
p.rho_a    = 0.5;
p.rho_c    = 0.7;
p.rho_i    = 0.7;
p.rho_y    = 0.2;
p.std_a    = 1;
p.std_c    = 1;
p.std_i    = 1.5;
p.std_y    = 0.5;
p.y_growth = 1.025;

if type > 1

    % Parameters of the observation model
    p.lambda_y_star = 0.9;
    p.std_e_y_noise = 0.6;
    p.std_e_y_star  = 0.4;
    
    p.lambda_c_star = 0.9;
    p.std_e_c_noise = 0.3;
    p.std_e_c_star  = 0.2;
    p.c_growth      = 1.025;

    p.lambda_i_star = 0.9;
    p.std_e_i_noise = 2.9;
    p.std_e_i_star  = 2.0;
    p.i_growth      = 1.025;

end


