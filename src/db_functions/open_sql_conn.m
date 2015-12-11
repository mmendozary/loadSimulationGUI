function conn = open_sql_conn( db_name, login )
%% OPEN_SQL_CONN Connect to a database in a MSSQL server hosted by livingLabLM.ad.unb.ca
%
%   conn = OPEN_SQL_CONN( dn_name ) returns the connection to the database
%   'db_name' in the SQL server using a guest account
%   
%   conn = OPEN_SQL_CONN( db_name, login ) returns the connection to the
%   database 'db_name' in SQL server using a specific login account
% Parameter login is a structure with at least two fields:
%   login.username
%   login.password
% containing loging credentials to the SQL server
%
% Basically the function makes the call:
%   conn = database(db_name, login.username, login.password, ...
%     'Vendor', 'Microsoft SQL Server', 'AuthType', 'Server', ...
%     'Server', 'livingLabLM.ad.unb.ca', ...
%     'PortNumber', 1433);
%

% TODO: if needed, use a configuration file or allow a variable number of
% parameters in order to use different servers. 
%

% Julian Cardenas
% 2015


narginchk(1,2); % none or one function parameters required

if ( nargin == 1 )
    login.username = 'sql_user';
    login.password = '2015';
end

if (~ischar( db_name ))
    err = MException('DB:connectionError', 'database name required');
    throw(err);
end

if (~isfield(login, 'username'))
    err = MException('DB:connectionError', 'login.username required');
    throw(err);
end

if (~isfield(login, 'password'))
    err = MException('DB:connectionError', 'login.password required');
    throw(err);
end


conn = [];

try
    conn = database( db_name, login.username, login.password, ...
        'Vendor', 'Microsoft SQL Server', 'AuthType', 'Server', ...
        'Server', 'livingLabLM.ad.unb.ca', ...
        'PortNumber', 1433);
    
    if ( ~isconnection(conn) )
        errMessage = sprintf('Failed to connect to the database. %s', conn.Message);
        err = MException('DB:invalidConnection', errMessage);
        throw(err);
    end
    
    setdbprefs('DataReturnFormat', 'dataset');
    
catch e
    e.message
end