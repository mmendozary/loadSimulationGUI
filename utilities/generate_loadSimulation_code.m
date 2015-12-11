function generate_loadSimulation_code()
%generate_loadSimulation_code
%

%   Copyright 2012 The MathWorks, Inc.

% Use the Simulink Coder API to generate code for loadSimulationGUI:

%% We ended up using interpreted code,.No need to build the code
% loadSimulationModel = 'loadSimulatorGUI';
% 
% if(~bdIsLoaded(loadSimulationModel))
%     open_system(loadSimulationModel);
% end
% 
% slbuild(loadSimulationModel);
% coder.report.generate(loadSimulationModel);

end

