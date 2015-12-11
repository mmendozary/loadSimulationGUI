%% Example for modifying [Metering].[powerMeters] database  
% The seccions in this example show the procedure of how to insert new
% values in the table of readings in the powerMeter database
%

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


%% Section 2 Database connection for write access
% The connection example that below is for inserting new values.
% It gives READ/WRITE access. The password has been left blanc for
% security issues (please ask Julian cardenas for the password)
% For READ ONLY access the function can be used without parameters.
% See also DB_READ_EXAMPLE 
%
db_names = {'powerMeters','WaterHeaters','HeatingUnits'};
db_users = {'sw_powerMeters','sw_waterheaters','sw_ETS'};
selectedDB = 2;

login.username = db_users{selectedDB};
login.password = 'unb.sql.2015';
conn = open_sql_conn( db_names{selectedDB} , login );


%% Section 3 Inserting Values to Tables. Inserting observations
%
%% 
% Section 3a Reading Tables
% Reading Table is not necessary we are calling it to select the names of
% the variables qwe would like to insert 
%

[deviceTable, columns] = db_get_devices( conn );

% printing contents of the table of meters
% disp(deviceTable);
% disp(columns.COLUMN_NAME');
%%
% Section 3.b
if (~isempty(deviceTable))
    % Selecting the device.(in this example the first device in the table of devices)
    queryParams.deviceId = deviceTable.deviceId(1);
    % variables to insert
    % Example:
    %   queryParams.varNames = {'dt', 'Power_P1'};
    %   queryParams.varValues = {[now-1; now], [3.5; 4.6] };
    
    switch ( selectedDB )
        case 1 % powerMeters
            % (In this example: 'dt', 'Power_P1')
            varNames = columns.COLUMN_NAME([3,16]);
            % values to insert (one row of values in this example)
            varValues = {[now], [4.6] };
        case 2 % WaterHeaters
            % (In this example: 'dt','WaterFlowRate_Q')
            varNames = columns.COLUMN_NAME([3,4]);
            % values to insert (two rows of values in this example)
            varValues = {[now-1; now], [3.5; 4.6] };
        case 3 % HeatingUnts
            % (In this example: 'dt','ETSPower')
            varNames = columns.COLUMN_NAME([3,6]);
            % values to insert (three rows of values in this example)
            varValues = {[now-1; now-0.5; now], [30.5; 40.6; 10] };
    end
    queryParams.varNames = varNames;
    queryParams.varValues = varValues;
    
    count = db_insert_device_readings( conn, queryParams );
    fprintf('%d rows succesfully updated\n',count);
else
    fprintf('No devices found in database\n');
end

%% Section 4 Clean up
close(conn)
