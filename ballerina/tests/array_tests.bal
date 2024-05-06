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

import ballerina/test;

@test:Config {
    groups: ["array", "int"]
}
public isolated function testIntArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "integers", 
            "namespace": "data", 
            "items": "int"
        }`;

    int[] numbers = [22, 556, 78];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(numbers);
    int[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, numbers);
}

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
    groups: ["array", "string"]
}
public isolated function testEnumArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "enums", 
            "namespace": "data", 
            "items": {
                "type": "enum",
                "name": "Numbers",
                "symbols": [ "ONE", "TWO", "THREE", "FOUR" ]
            }
        }`;

    Numbers[] colors = ["ONE", "TWO", "THREE"];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    Numbers[] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, colors);
}

@test:Config {
    groups: ["array", "string"]
}
public isolated function testArrayOfEnumArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "enums", 
            "namespace": "data", 
            "items": {
                "type": "array",
                "name" : "enumsValues", 
                "namespace": "data", 
                "items": {
                    "type": "enum",
                    "name": "Numbers",
                    "symbols": [ "ONE", "TWO", "THREE", "FOUR" ]
                }
            }
        }`;

    Numbers[][] colors = [["ONE", "TWO", "THREE"], ["ONE", "TWO", "THREE"]];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    Numbers[][] deserializeJson = check avro.fromAvro(encode);
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
    groups: ["array", "long"]
}
public isolated function testLongArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "longArray", 
            "namespace": "data", 
            "items": "long"
        }`;

    int[] numbers = [223432, 55423326, 7823423];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(numbers);
    int[] deserializeJson = check avro.fromAvro(encode);
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
    groups: ["array", "error", "anydata"]
}
public isolated function testArraysWithAnydata() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "floatArray", 
            "namespace": "data", 
            "items": "bytes"
        }`;

    anydata numbers = ["22.4".toBytes(), "556.84350", 78.0327];
    Schema avro = check new (schema);
    byte[]|Error encode = avro.toAvro(numbers);
    test:assertTrue(encode is Error);
}

@test:Config {
    groups: ["array", "byte"]
}
public isolated function testArraysWithFixed() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "fixedArray", 
            "namespace": "data", 
            "items": {
                "type": "fixed",
                "name": "FixedBytes",
                "size": 2
            }
        }`;

    byte[][] numbers = ["22".toBytes(), "55".toBytes(), "78".toBytes()];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(numbers);
    byte[][] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, numbers);
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
    groups: ["record", "array"]
}
public isolated function testRecordArraysInArrays() returns error? {
    string schema = string `
        {
            "type": "array",
            "name" : "recordArray", 
            "namespace": "data", 
            "items": {
                "type": "array",
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
            }
        }`;

    Student[][] students = [[{
        name: "Liam",
        subject: "geology"
    }, {
        name: "John",
        subject: "math"
    }], [{
        name: "Liam",
        subject: "geology"
    }, {
        name: "John",
        subject: "math"
    }]];

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(students);
    Student[][] deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, students);
}
