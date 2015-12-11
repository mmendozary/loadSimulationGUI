function set_up_project()
%set_up_project  Configure the environment for this project
%
%   Set up the environment for the current project. This function is set to
%   Run at Startup.

%   Copyright 2011-2014 The MathWorks, Inc.

global projectRoot

% Use Simulink Project API to get the current project:
project = simulinkproject;

% Set the location of slprj to be the "work" folder of the current project:
projectRoot = project.RootFolder;
myCacheFolder = fullfile(projectRoot, 'work');
if ~exist(myCacheFolder, 'dir')
    mkdir(myCacheFolder)
end
Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder, ...
   'CodeGenFolder', myCacheFolder);

% Change working folder to the "work" folder:
cd(myCacheFolder);

%% JDBC Driver Specification
% The database is accessed using the JDBC driver. This driver should be
% downloaded and stored in your machine. The path should be then included
% in tha javaclasspath in Matlab as follows
%

driver_path = 'C:\Program Files\Microsoft JDBC Driver 4.0 for SQL Server\sqljdbc_4.0\enu\sqljdbc4.jar';
java_path = javaclasspath;
if (isempty(strfind(java_path, driver_path)))
    javaaddpath (driver_path);
end

end
