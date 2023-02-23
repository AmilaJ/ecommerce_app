import ballerina/graphql;

import ballerina/sql;
import ballerinax/mysql;

# A service representing a network-accessible GraphQL API
service / on new graphql:Listener(8090) {
    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db =  check new ("sahackathon.mysql.database.azure.com", "choreo", "wso2!234", "amilaja_db", 3306, connectionPool={maxOpenConnections: 3});
    }
    # A resource for generating greetings
    # Example query:
    #   query GreetWorld{ 
    #     greeting(name: "World") 
    #   }
    # Curl command: 
    #   curl -X POST -H "Content-Type: application/json" -d '{"query": "query GreetWorld{ greeting(name:\"World\") }"}' http://localhost:8090
    # 
    # + name - the input string name
    # + return - string name with greeting message or error
    resource function get greeting(string name) returns string|error {
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }


    resource function get catalog() returns catalog|error {
        item[]| sql:Error itemResult = self.db->queryRow(`SELECT * FROM catalog`);

        // Process the stream and convert results to Album[] or return error.
        if (itemResult is sql:Error) {
            return error("Error in retrieving data from database "+ itemResult.toString());
        } else {
            item[] items= [];
            foreach item item in itemResult {
                items.push(item);
            }
            return {items: items};
        }
        
        
    }


}

type item record {|
    string title;
    string description;
    string includes;
    string intendedfor;
    string color;
    string material;
    decimal price;
|};

type catalog record {|
    item[] items;
     
|};

//