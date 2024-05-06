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
    groups: ["primitive", "int"]
}
public isolated function testIntValue() returns error? {
    string schema = string `
        {
            "type": "int",
            "name" : "intValue", 
            "namespace": "data"
        }`;

    int value = 5;

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    int deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, value);
}

@test:Config {
    groups: ["primitive", "float"]
}
public isolated function testFloatValue() returns error? {
    string schema = string `
        {
            "type": "float",
            "name" : "floatValue", 
            "namespace": "data"
        }`;

    float value = 5.5;

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    float deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, value);
}

@test:Config {
    groups: ["primitive", "double"]
}
public isolated function testDoubleValue() returns error? {
    string schema = string `
        {
            "type": "double",
            "name" : "doubleValue", 
            "namespace": "data"
        }`;

    float value = 5.5595;

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    float deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, value);
}

@test:Config {
   groups: ["primitive", "check", "l"]
}
public isolated function testLongValue() returns error? {
    string schema = string `
        {
            "type": "long",
            "name" : "longValue", 
            "namespace": "data"
        }`;

    int value = 555950000000000000;
    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    int deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, value);
}

@test:Config {
    groups: ["primitive", "check"]
}
public isolated function testStringValue() returns error? {
    string schema = string `
        {
            "type": "string",
            "name" : "stringValue", 
            "namespace": "data"
        }`;

    string value = "test";
    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    string deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, value);
}

@test:Config {
    groups: ["primitive", "check"]
}
public isolated function testBoolean() returns error? {
    string schema = string `
        {
            "type": "boolean",
            "name" : "booleanValue", 
            "namespace": "data"
        }`;

    boolean value = true;
    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(value);
    boolean deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, value);
}

@test:Config {
    groups: ["primitive", "null"]
}
public isolated function testNullValues() returns error? {
    string schema = string `
        {
            "type": "null",
            "name" : "nullValue", 
            "namespace": "data"
        }`;

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(());
    () deserializeJson = check avro.fromAvro(encode);
    test:assertEquals(deserializeJson, ());
}

@test:Config {
    groups: ["primitive", "null"]
}
public isolated function testNullValuesWithNonNullData() returns error? {
    string schema = string `
        {
            "type": "null",
            "name" : "nullValue", 
            "namespace": "data"
        }`;

    Schema avro = check new (schema);
    byte[]|error encode = avro.toAvro("string");
    test:assertTrue(encode is error);
}
