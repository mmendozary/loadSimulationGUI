%% Example for accessing  database
% The seccions in this example show the procedure to get values already
% stored in the database
%

%% Check for Database Toolbox™
% Check to see if the Database Toolbox is installed
%

dbTbxVer = ver('database');
if isempty(dbTbxVer)
    fprintf('This example requires the Database Toolbox.\n');
    return
end

%% Check for Database Toolbox™ licensing
% Check to see if the Database Toolbox is installed
%

dbTbxLicensed = license('test', 'database');
if (~dbTbxLicensed)
    fprintf('No licenses available to use the Database Toolbox.\n');
    return
end

%% Section 1 Driver Specification
% The database is accessed using the JDBC driver. This driver should be
% downloaded and stored in your machine. The path should be then included
% in tha javaclasspath in Matlab as follows
%

driver_path = 'C:\Program Files\Microsoft JDBC Driver 4.0 for SQL Server\sqljdbc_4.0\enu\sqljdbc4.jar';
java_path = javaclasspath;
if (isempty(strfind(java_path, driver_path)))
    javaaddpath (driver_path);
end


%% Section 2 Database connection for reading access
% The connection example that below is for reading purposes.
% For READ/WRITE access a user with those rights should be used
% See also DB_WRITE_EXAMPLE 
%
db_names = {'powerMeters','WaterHeaters','HeatingUnits'};
selectedDB = 3;

conn = open_sql_conn( db_names{selectedDB} );

%% Section 3 Reading Tables
% Reading Table of meters contents and observation variable names
%

[deviceTable, columns] = db_get_devices( conn );

% printing contents of the table of meters
disp(deviceTable);
disp(columns.COLUMN_NAME');


%% Section 5 Reading Values from Tables. Reading observations
%
if (~isempty(deviceTable))
    % Selecting the Meter.(in this example the first Meter in the table of meters)
    queryParams.deviceId = deviceTable.deviceId(1);
    
    % Time span we would like to donwload values. (in this example, all the samples
    %  stored since theOctober 1st, 2015). Note: endDate could have een left empty
    queryParams.startDate = '2015-10-1';
    queryParams.endDate = ceil(now);
    
    % Variables (column names) to read.
    
    switch ( selectedDB )
        case 1 % powerMeters
            % (In this example: 'dt', 'Power_P1','Power_P2','Power_P3','Power_PSum')
            varNames = columns.COLUMN_NAME([3,16:19]);
        case 2 % WaterHeaters
            % (In this example: 'dt','WaterFlowRate_Q','WaterTemperature_T','InputPower')
            varNames = columns.COLUMN_NAME([3]);
        case 3 % HeatingUnts
            % (In this example: 'dt','ETSPower','outdoorTemp','indoorTemp','estimatedCapacity')
            varNames = columns.COLUMN_NAME([3:6,12]);
    end
        
    queryParams.varNames = varNames;
    
    % reading the database
    data  = db_get_device_readings( conn, queryParams );
    
    % printing contents of the table of meters
    disp(data);
else
    fprintf('No devices found in database\n');
end
%% Section 6 Clean up
close(conn)
