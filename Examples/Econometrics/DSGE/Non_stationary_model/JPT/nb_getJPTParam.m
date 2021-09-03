%% Parameterization of the JPT model

% Mode estimates from paper
param = struct();
param.ALPHA_NW          = 0.167;
param.BC_NW             = 0.859;
param.BETA_NW           = 100/(0.134+100);
param.BL_NW             = 0;
param.DELTA_NW          = 0.025;
param.DPQ_P_NW_SS       = (0.702 + 100)/100;
param.DUT_NW_SS         = 1 + (0.597/100);
param.DZT_NW_SS         = 1 + (0.303 - (param.ALPHA_NW/...
                          (1 - param.ALPHA_NW))*0.597)/100;
param.LAMBDA_DUT_NW     = 0.156;
param.LAMBDA_DZT_NW     = 0.286;
param.LAMBDA_I_NW       = 0.772;
param.LAMBDA_L_NW       = 0;
param.LAMBDA_PSI_NW     = 0.967;
param.LAMBDA_RHO_NW     = 0.590; 
param.LAMBDA_RN3M_NW    = 0;
param.LAMBDA_U_NW       = 0; % This is not a shock as in JPT
param.LAMBDA_THETAH_NW  = 0.971;
param.OMEGA_DPQ_Y_NW    = 0.208;
param.OMEGA_P_NW        = 1.709;
param.OMEGA_R_NW        = 0.858;
param.OMEGA_Y_NW        = 0.051;
param.PHI_PQ_NW         = 0.2; % NEMO calibration
param.PHI_I1_NW         = 2.657;
param.PHI_W_NW          = 1.0080; % NEMO calibration
param.PHI_U_NW          = 5.434;
param.PSI_NW_SS         = 1.135/(1.135 - 1);
param.RHO_NW_SS         = 1;
param.THETAH_NW_SS      = 1.171/(1.171 - 1);
param.ZETA_NW           = 4.444;
param.Z_I_NW_SS         = 1;
param.Z_L_NW_SS         = 1;
param.Z_U_NW_SS         = 1;
param.Z_RN3M_NW_SS      = 1;
param.std_E_DUT_NW      = 0.630;
param.std_E_DZT_NW      = 0.933;
param.std_E_I_NW        = 5.103;
param.std_E_L_NW        = 0;
param.std_E_PSI_NW      = 0.310;
param.std_E_RHO_NW      = 0.036;
param.std_E_RN3M_NW     = 0.210;
param.std_E_THETAH_NW   = 0.219;
param.std_E_U_NW        = 0; % This is not a shock as in JPT

save('jpt_coeff','-struct','param');

% Calibrated to NEMO values
param = struct();
param.ALPHA_NW          = 0.167;
param.BC_NW             = 0.72;
param.BETA_NW           = 0.99939;
param.BL_NW             = 0;
param.DELTA_NW          = 0.018;
param.DPQ_P_NW_SS       = (1.02)^(1/4);
param.DUT_NW_SS         = 1 + (0.597/100);
param.DZT_NW_SS         = 1.0056;
param.LAMBDA_DUT_NW     = 0.156;
param.LAMBDA_DZT_NW     = 0.0246;
param.LAMBDA_I_NW       = 0.537;
param.LAMBDA_L_NW       = 0.76;
param.LAMBDA_PSI_NW     = 0.0791;
param.LAMBDA_RHO_NW     = 0; % This is not a shock as in NEMO
param.LAMBDA_RN3M_NW    = 0;
param.LAMBDA_U_NW       = 0.3; 
param.LAMBDA_THETAH_NW  = 0.0193;
param.OMEGA_DPQ_Y_NW    = 0;
param.OMEGA_P_NW        = 5.08;
param.OMEGA_R_NW        = 0.9;
param.OMEGA_Y_NW        = 0.2;
param.PHI_PQ_NW         = 0.2; % NEMO calibration
param.PHI_I1_NW         = 1.15;
param.PHI_W_NW          = 1.0080; % NEMO calibration
param.PHI_U_NW          = 4;
param.PSI_NW_SS         = 4.94;
param.RHO_NW_SS         = 1;
param.THETAH_NW_SS      = 1.171/(1.171 - 1);
param.ZETA_NW           = 4.444;
param.Z_I_NW_SS         = 1;
param.Z_L_NW_SS         = 1;
param.Z_U_NW_SS         = 1;
param.Z_RN3M_NW_SS      = 1;
param.std_E_DUT_NW      = 0.630;
param.std_E_DZT_NW      = 0.933;
param.std_E_I_NW        = 1.73;
param.std_E_L_NW        = 0.0195;
param.std_E_PSI_NW      = 0.953;
param.std_E_RHO_NW      = 0; % This is not a shock as in NEMO
param.std_E_RN3M_NW     = 0.0024;
param.std_E_THETAH_NW   = 0.2;
param.std_E_U_NW        = 0.0567; 

save('nb_jpt_coeff','-struct','param');
