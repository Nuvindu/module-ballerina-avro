// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/test;

@test:Config {
    groups: ["array", "string"]
}
public isolated function testStringArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "stringArray", 
            "namespace": "data", 
            "items": "string"
        }`;

    string[] colors = ["red", "green", "blue"];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    string[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, colors);
}

@test:Config {
    groups: ["array", "float"]
}
public isolated function testFloatArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "floatArray", 
            "namespace": "data", 
            "items": "float"
        }`;

    float[] numbers = [22.4, 556.84350, 78.0327];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(numbers);
    float[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, numbers);
}

@test:Config {
    groups: ["array", "double"]
}
public isolated function testDoubleArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "doubleArray", 
            "namespace": "data", 
            "items": "double"
        }`;

    float[] numbers = [22.439475948, 556.843549485340, 78.032985693457];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(numbers);
    float[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, numbers);
}

@test:Config {
    groups: ["array", "errors"]
}
public isolated function testInvalidDecimalArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "decimalArray", 
            "namespace": "data", 
            "items": "double"
        }`;

    decimal[] numbers = [22.439475948, 556.843549485340, 78.032985693457];

    Schema avro = check new (schema);
    byte[]|Error encode = avro.toAvro(numbers);
    io:println(encode);
    test:assertTrue(encode is Error);
}

@test:Config {
    groups: ["array", "boolean"]
}
public isolated function testBooleanArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "booleanArray", 
            "namespace": "data", 
            "items": "boolean"
        }`;

    boolean[] numbers = [true, true, false];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(numbers);
    boolean[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, numbers);
}

@test:Config {
    groups: ["enum"]
}
public isolated function testEnums() returns error? {
    string schema = string `
        {
            "type" : "enum",
            "name" : "Numbers", 
            "namespace": "data", 
            "symbols" : [ "ONE", "TWO", "THREE", "FOUR" ]
        }`;

    Numbers number = "ONE";

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(number);
    Numbers deserialize = check avro.fromAvro(encode);
    test:assertEquals(number, deserialize);
}

@test:Config {
    groups: ["errors", "enum"]
}
public isolated function testEnumsWithString() returns error? {
    string schema = string `
        {
            "type" : "enum",
            "name" : "Numbers", 
            "namespace": "data", 
            "symbols" : [ "ONE", "TWO", "THREE", "FOUR" ]
        }`;

    string number = "FIVE";

    Schema avro = check new (schema);
    byte[]|Error encode = avro.toAvro(number);
    test:assertTrue(encode is Error);
}

@test:Config {
    groups: ["maps"]
}
public isolated function testMaps() returns error? {
    string schema = string `
        {
            "type": "map",
            "values" : "int",
            "default": {}
        }`;

    map<int> colors = {"red": 0, "green": 1, "blue": 2};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<int> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["record", "array"]
}
public isolated function testRecordsInArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "recordArray", 
            "namespace": "data", 
            "items": {
                "type": "record",
                "name": "Student",
                "fields": [
                    {
                        "name": "name",
                        "type": ["string", "null"]
                    },
                    {
                        "name": "subject",
                        "type": ["string", "null"]
                    }
                ]
            }
        }`;

    Student[] students = [{
        name: "Liam",
        subject: "geology"
    }, {
        name: "John",
        subject: "math"
    }];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(students);
    Student[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, students);
}

@test:Config {
    groups: ["check", "fixed"]
}
public isolated function testFixed() returns error? {
    string schema = string `
        {
            "type": "fixed",
            "name": "name",
            "size": 16
        }`;

    byte[] value = "u00ffffffffffffx".toBytes();

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    byte[] deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, value);
}

@test:Config {
    groups: ["record"]
}
public function testDbSchemaWithRecords() returns error? {
    string schema = string `
        {
            "connect.name": "io.debezium.connector.sqlserver.SchemaChangeKey",
            "connect.version": 1,
            "fields": [
                {
                "name": "databaseName",
                "type": "string"
                }
            ],
            "name": "SchemaChangeKey",
            "namespace": "io.debezium.connector.sqlserver",
            "type": "record"
        }`;

    SchemaChangeKey changeKey = {
        databaseName: "my-db"
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(changeKey);
    SchemaChangeKey deserialize = check avro.fromAvro(serialize);
    test:assertEquals(changeKey, deserialize);

}

@test:Config {
    groups: ["record"]
}
public function testComplexDbSchema() returns error? {
    string jsonFileName = string `tests/resources/schema_1.json`;
    json result = check io:fileReadJson(jsonFileName);
    string schema = result.toString();

    Envelope envelope = {
        before: {
            ID: 1,
            OfferID: "offer1",
            PropertyId: 100,
            PlayerUnityID: "player1",
            HALoOfferStatus: "status1",
            StatusDateTime: 1633020142,
            OfferSegmentID: 200,
            RedemptionDate: 1633020142,
            OfferItemID: 300,
            OfferPrizeCode: "prize1",
            AmountRedeemed: 500.0,
            ItemQuantity: 5,
            OfferType: "type1",
            CreatedDate: 1633020142,
            CreatedBy: "creator1",
            UpdatedDate: 1633020142,
            UpdatedBy: "updater1"
        },
        after: {
            ID: 2,
            OfferID: "offer2",
            PropertyId: 101,
            PlayerUnityID: "player2",
            HALoOfferStatus: "status2",
            StatusDateTime: 1633020143,
            OfferSegmentID: 201,
            RedemptionDate: 1633020143,
            OfferItemID: 301,
            OfferPrizeCode: "prize2",
            AmountRedeemed: 600.0,
            ItemQuantity: 6,
            OfferType: "type2",
            CreatedDate: 1633020143,
            CreatedBy: "creator2",
            UpdatedDate: 1633020143,
            UpdatedBy: "updater2"
        },
        'source: {
            version: "1.0",
            connector: "connector1",
            name: "source1",
            ts_ms: 1633020144,
            snapshot: "snapshot1",
            db: "db1",
            sequence: "sequence1",
            schema: "schema1",
            'table: "table1",
            change_lsn: "lsn1",
            commit_lsn: "lsn2",
            event_serial_no: 1
        },
        op: "op1",
        ts_ms: 1633020145,
        'transaction: {
            id: "transaction1",
            total_order: 1,
            data_collection_order: 1
        }
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(envelope);
    Envelope deserialize = check avro.fromAvro(serialize);
    test:assertEquals(deserialize, envelope);
}

@test:Config {
    groups: ["record"]
}
public function testComplexDbSchemaWithNestedRecords() returns error? {
    string jsonFileName = string `tests/resources/schema_2.json`;
    json result = check io:fileReadJson(jsonFileName);
    string schema = result.toString();

    Envelope2 envelope2 = {
        before: {
            CorePlayerID: 123,
            AccountNumber: "123456",
            LastName: "Doe",
            FirstName: "John",
            MiddleName: "M",
            Gender: "M",
            Language: "English",
            Discreet: false,
            Deceased: false,
            IsBanned: false,
            EmailAddress: "john.doe@example.com",
            IsVerified: true,
            EmailStatus: "Verified",
            MobilePhone: "1234567890",
            HomePhone: "0987654321",
            HomeStreetAddress: "123 Street",
            HomeCity: "City",
            HomeState: "State",
            HomePostalCode: "12345",
            HomeCountry: "Country",
            AltStreetAddress: "456 Street",
            AltCity: "Alt City",
            AltState: "Alt State",
            AltCountry: "Alt Country",
            DateOfBirth: 1234567890,
            EnrollDate: 1234567890,
            PredomPropertyId: "PropertyId",
            AccountType: "Type",
            InsertDtm: 1234567890,
            AltPostalCode: "54321",
            BatchID: 123,
            GlobalRank: "Rank",
            GlobalValuationScore: 1.0,
            PlayerType: "Type",
            AccountStatus: "Status",
            RegistrationSource: "Source",
            BannedReason: "Reason",
            TierCode: "Code",
            TierName: "Name",
            TierEndDate: 1234567890,
            VIPFlag: false
        },
        after: {
            CorePlayerID: 456,
            AccountNumber: "654321",
            LastName: "Smith",
            FirstName: "Jane",
            MiddleName: "K",
            Gender: "F",
            Language: (),
            Discreet: true,
            Deceased: false,
            IsBanned: false,
            EmailAddress: "jane.smith@example.com",
            IsVerified: false,
            EmailStatus: "Unverified",
            MobilePhone: "0987654321",
            HomePhone: "1234567890",
            HomeStreetAddress: "456 Street",
            HomeCity: "Alt City",
            HomeState: "Alt State",
            HomePostalCode: "54321",
            HomeCountry: "Alt Country",
            AltStreetAddress: "123 Street",
            AltCity: "City",
            AltState: "State",
            AltCountry: "Country",
            DateOfBirth: 9876543210,
            EnrollDate: 9876543210,
            PredomPropertyId: "AltPropertyId",
            AccountType: "AltType",
            InsertDtm: 9876543210,
            AltPostalCode: "12345",
            BatchID: 456,
            GlobalRank: "AltRank",
            GlobalValuationScore: 2.0,
            PlayerType: "AltType",
            AccountStatus: "AltStatus",
            RegistrationSource: "AltSource",
            BannedReason: "AltReason",
            TierCode: "AltCode",
            TierName: "AltName",
            TierEndDate: 9876543210,
            VIPFlag: true
        },
        'source: {
            version: "1.0",
            connector: "connector",
            name: "name",
            ts_ms: 123456789,
            snapshot: "snapshot",
            db: "db",
            sequence: "sequence",
            schema: "schema",
            'table: "table",
            change_lsn: "lsn",
            commit_lsn: "lsn",
            event_serial_no: 1
        },
        op: "op",
        ts_ms: 123456789,
        'transaction: {
            id: "id",
            total_order: 1,
            data_collection_order: 1
        },
        MessageSource: "MessageSource"
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(envelope2);
    Envelope2 deserialize = check avro.fromAvro(serialize);
    test:assertEquals(deserialize, envelope2);
}
