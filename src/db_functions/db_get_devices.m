function [deviceTable, var_names] = db_get_devices( conn )
%DB_GET_DEVICES Retrieves information on the meters already stored and
% configured in the database
% called as 
% [deviceTable, data_col_names] = DB_GET_DEVICES(  SQLConnection ); or
% [deviceTable, data_col_names] = DB_GET_DEVICES( db_name ); 
% when no database connection SQLConnection is given the function opens and
% closes a connection internally   
%  %
% Example 
%  Make connection to database.  Note that the password has been omitted.
%  Using JDBC driver.
%
%  SQLConnection = DATABASE('powerMeters', 'sql_user', '', ...
%     'Vendor', 'Microsoft SQL Server', 'AuthType' 'Server', ...
%     'Server', 'livingLabLM.ad.unb.ca', ...
%     'PortNumber', 1433);
%
%
%  meterTable  = DB_GET_METERS( SQLConnection  );
%


% Julian Cardenas 2015

deviceTable = [];  
var_names = [];

narginchk(0,1); % one or two function parameters required 

connCreated = false;
if nargin == 1
    if ~isconnection(conn)
        err = MException('DB:connectionError', 'Invalid db connection.');
        throw(err);    
    end
elseif (nargin == 0)
        conn = get_powermeter_sql_conn();
        connCreated = true;
end

dbases = {'powerMeters';'HeatingUnits';'WaterHeaters'};
dbasedbIDs = strmatch(conn.Instance, dbases);
if isempty(dbasedbIDs)
    err = MException('DB:invalidDatabase', 'Database not known.');
    throw(err);
end

try
    
    switch (dbasedbIDs)
        case 1
            [deviceTable, var_names] = db_get_meters( conn );
        case 2
            [deviceTable, var_names] = db_get_heatingunits( conn );
        case 3
            [deviceTable, var_names] = db_get_waterheaters( conn );
        otherwise
            deviceTable =[]; var_names = {};
    end
    
    
catch e
    e.message
    e.stack
end

if connCreated   % close the connection if it was created.
    close(conn);
end

end

%%
function [meterTable, data_col_names] = db_get_meters( conn )
%DB_GET_METERS Retrieves information on the meters already stored and
% configured in the database
% called as 
% [meterTable, data_col_names] = DB_GET_METERS(  SQLConnection ); or
% [meterTable, data_col_names] = DB_GET_METERS(); 
% when no database connection SQLConnection is given the function opens and
% closes a connection internally   
%  %
% Example 
%  Make connection to database.  Note that the password has been omitted.
%  Using JDBC driver.
%
%  SQLConnection = DATABASE('powerMeters', 'sql_user', '', ...
%     'Vendor', 'Microsoft SQL Server', 'AuthType', 'Server', ...
%     'Server', 'livingLabLM.ad.unb.ca', ...
%     'PortNumber', 1433);
%
%
%  meterTable  = DB_GET_METERS( SQLConnection  );
%


% Julian Cardenas 2015

meterTable = [];  %#ok<NASGU>
data_col_names = [];

narginchk(0,1); % one or two function parameters required 

connCreated = false;
if nargin == 1
    if ~isconnection(conn)
        err = MException('DB:connectionError', 'Invalid db connection.');
        throw(err);    
    end
elseif (nargin == 0)
        conn = get_powermeter_sql_conn();
        connCreated = true;
end

sqlQuery = [...
    'SELECT 	Meters.MeterID AS deviceId'...
    ' , Meters.MeterName'...
    ' ,	Meters.MeterConfiguration'...
    ' ,	Meters.MeterDescription'...
    ' ,	MeterDatasheets.datasheetURL as datasheet'...
    ' ,	Locations.urlGoogleMaps as Location'...
    ' FROM 	 (  ( powermeters.Metering.Meters '...
    ' INNER JOIN powermeters.Metering.MeterDatasheets '...
    ' ON 	Meters.MeterDatasheetID = MeterDatasheets.datasheetID )'...
    ' INNER JOIN powermeters.Metering.Locations '...
    ' ON 	Meters.LocationID = Locations.LocationID )'];
try
    meterTable = fetch(conn, sqlQuery);
        
catch e
    e.message
    e.stack
end

sqlQuery = ['SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS ' ... 
    ' WHERE TABLE_SCHEMA = ''Metering''  ' ...
    ' AND TABLE_NAME = ''Accuvim_II_RealTime_Readings'' '];
try
    data_col_names = fetch(conn, sqlQuery);
catch e
    e.message
    e.stack
end
    
if connCreated   % close the connection if it was created.
    close(conn);
end

end

%%
function [deviceTable, var_names] = db_get_heatingunits( conn )
deviceTable = [];  
var_names = [];

narginchk(0,1); % one or two function parameters required 

connCreated = false;
if nargin == 1
    if ~isconnection(conn)
        err = MException('DB:connectionError', 'Invalid db connection.');
        throw(err);    
    end
elseif (nargin == 0)
        conn = get_powermeter_sql_conn();
        connCreated = true;
end

sqlQuery = [...
    'SELECT 	ETSs.ETSID AS deviceId'...
    ' ,	ETSs.ETSName'...
    ' ,	ETSs.ETSDescription'...
    ' ,	ETSConfigs.configName'...
    ' ,	ETSStatus.commandStatus'...
    ' ,	ETSStatus.outTemp_Tout'...
    ' ,	ETSStatus.inTemp_Tin'...
    ' ,	Locations.urlGoogleMaps'...
    ' FROM 	 (  (  ( HeatingUnits.Simulation.ETSs '...
    ' INNER JOIN HeatingUnits.Simulation.ETSConfigs '...
    ' ON 	ETSs.ETSConfigurationID = ETSConfigs.configID )'...
    ' INNER JOIN HeatingUnits.Simulation.ETSStatus '...
    ' ON 	ETSs.ETSStatusID = ETSStatus.statusID )'...
    ' INNER JOIN HeatingUnits.Simulation.Locations '...
    ' ON 	ETSs.LocationID = Locations.LocationID )'];
try
    deviceTable = fetch(conn, sqlQuery);
        
catch e
    e.message
    e.stack
end

sqlQuery = ['SELECT TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS ' ... 
    ' WHERE TABLE_NAME LIKE ''%Reading%'' '];
try
    var_names = fetch(conn, sqlQuery);
catch e
    e.message
    e.stack
end
    
if connCreated   % close the connection if it was created.
    close(conn);
end

end

%%
function [deviceTable, var_names] = db_get_waterheaters( conn )
deviceTable = [];  
var_names = [];

narginchk(0,1); % one or two function parameters required 

connCreated = false;
if nargin == 1
    if ~isconnection(conn)
        err = MException('DB:connectionError', 'Invalid db connection.');
        throw(err);    
    end
elseif (nargin == 0)
        conn = get_powermeter_sql_conn();
        connCreated = true;
end

sqlQuery = [...
    'SELECT 	WaterHeaters.WaterHeaterID AS deviceId'...
    ' ,	WaterHeaters.WaterHeaterName'...
    ' ,	WaterHeaters.WaterHeaterDescription'...
    ' ,	WaterHeaters.ts'...
    ' ,	WaterHeaterConfigs.configName'...
    ' ,	WaterHeaterConfigs.SpecificHeat_Cp'...
    ' ,	WaterHeaterConfigs.SurfThermalConduction_G'...
    ' ,	WaterHeaterConfigs.RatingPower_Pr'...
    ' ,	WaterHeaterConfigs.Volume_Vo'...
    ' ,	WaterHeaterConfigs.ThermostatHi_TH'...
    ' ,	WaterHeaterConfigs.ThermostatLo_TL'...
    ' ,	WaterHeaterConfigs.SamplePeriod_Ts'...
    ' ,	WaterHeaterConfigs.DaysToModel_D'...
    ' ,	WaterHeaterStatus.commandStatus'...
    ' ,	WaterHeaterStatus.AmbientTemp_Tout'...
    ' ,	WaterHeaterStatus.WaterTemp_Tin'...
    ' ,	WaterHeaterStatus.PeakAmp'...
    ' ,	WaterHeaterStatus.PeakShift'...
    ' ,	Locations.urlGoogleMaps'...
    ' FROM 	 (  (  ( WaterHeaters.Simulation.WaterHeaters '...
    ' INNER JOIN WaterHeaters.Simulation.WaterHeaterConfigs '...
    ' ON 	WaterHeaters.WaterHeaterConfigurationID = WaterHeaterConfigs.configID )'...
    ' INNER JOIN WaterHeaters.Simulation.WaterHeaterStatus '...
    ' ON 	WaterHeaters.WaterHeaterStatusID = WaterHeaterStatus.statusID )'...
    ' INNER JOIN WaterHeaters.Simulation.Locations '...
    ' ON 	WaterHeaters.LocationID = Locations.LocationID )'];
try
    deviceTable = fetch(conn, sqlQuery);
        
catch e
    e.message
    e.stack
end

sqlQuery = ['SELECT TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS ' ... 
    ' WHERE TABLE_NAME LIKE ''%Reading%'' '];
try
    var_names = fetch(conn, sqlQuery);
catch e
    e.message
    e.stack
end
    
if connCreated   % close the connection if it was created.
    close(conn);
end


end

