import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/graphql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;
configurable decimal BASE_SHIPPING = ?;
configurable decimal BASE_TAX = ?;
configurable int SERVICE_PORT = ?;

public type Item record {|
    int id;
    string title;
    string description;
    string includes;
    string intended;
    string color;
    string material;
    string url;
    decimal price;
|};

final mysql:Client dbClient = check new (
    host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE, connectionPool = ({maxOpenConnections: 3, maxConnectionLifeTime: 30})
);

function getCatalog() returns Item[]|error {
    io:println(`GET CATALOG`);
    sql:ParameterizedQuery query = `SELECT * FROM item`;
    stream<Item, error?> employeeStream = dbClient->query(query);

    Item[] res = [];
    check from Item employee in employeeStream
        do {
            res.push(employee);
        };
    return res;
}

service / on new graphql:Listener(SERVICE_PORT) {

    function init() {
        io:println(`GRAPHQL API IS UP ON PORT ${SERVICE_PORT}`);
    }

    resource function get list() returns Item[]|error {
        Item[]|error c = getCatalog();
        if (c is error) {
            return c;
        } else {
            return c;
        }
    }

}
