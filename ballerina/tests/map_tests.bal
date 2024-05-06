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
    groups: ["maps", "bytes"]
}
public isolated function testMapsWithBytes() returns error? {
    string schema = string `
        {
            "type": "map",
            "values" : "bytes",
            "default": {}
        }`;

    map<byte[]> colors = {"red": "0".toBytes(), "green": "1".toBytes(), "blue": "2".toBytes()};
    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<byte[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "fixed"]
}
public isolated function testMapsWithFixed() returns error? {
    string schema = string `
        {
            "type": "map",
            "values" : {
                "type": "fixed",
                "name": "name",
                "size": 1
            },
            "default": {}
        }`;

    map<byte[]> colors = {"red": "0".toBytes(), "green": "1".toBytes(), "blue": "2".toBytes()};
    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<byte[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "fixed"]
}
public isolated function testMapsOfFixedMaps() returns error? {
    string schema = string `
        {
            "type": "map",
            "values" : {
                "type": "map",
                "values" : {
                    "type": "fixed",
                    "name": "name",
                    "size": 1
                },
                "default": {}
            },
            "default": {}
        }`;

    map<map<byte[]>> colors = {
        "red": {"r": "0".toBytes(), "g": "1".toBytes(), "b": "2".toBytes()},
        "green": {"r": "0".toBytes(), "g": "1".toBytes(), "b": "2".toBytes()},
        "blue": {"r": "0".toBytes(), "g": "1".toBytes(), "b": "2".toBytes()}
    };
    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<map<byte[]>> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "record"]
}
public isolated function testMapsWithRecords() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "record",
                "name": "Instructor",
                "fields": [
                    {
                        "name": "name",
                        "type": ["null", "string"]
                    },
                    {
                        "name": "student",
                        "type": ["null", {
                            "type": "record",
                            "name": "Student",
                            "fields": [
                                {
                                    "name": "name",
                                    "type": "string"
                                },
                                {
                                    "name": "subject",
                                    "type": "string"
                                }
                            ]
                        }]
                    }
                ]
            },
            "default": {}
        }`;

        

    map<Instructor> instructors = {
        "john": {name: "John", student: {name: "Alice", subject: "Math"}},
        "doe": {name: "Doe", student: {name: "Bob", subject: "Science"}},
        "jane": {name: "Jane", student: {name: "Charlie", subject: "English"}}
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(instructors);
    map<Instructor> deserialize = check avro.fromAvro(encode);
    test:assertEquals(instructors, deserialize);
}

@test:Config {
    groups: ["maps"]
}
public isolated function testMapsWithInt() returns error? {
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
    groups: ["maps", "enum"]
}
public isolated function testMapsWithEnum() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "enum",
                "name": "Numbers",
                "symbols": ["ONE", "TWO", "THREE"]
            },
            "default": {}
        }`;

    map<Numbers> colors = {"red": "ONE", "green": "TWO", "blue": "THREE"};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<Numbers> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "enum", "array"]
}
public isolated function testMapsWithEnumArrays() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "name" : "enums", 
                "namespace": "data", 
                "items": {
                    "type": "enum",
                    "name": "Numbers",
                    "symbols": [ "ONE", "TWO", "THREE", "FOUR" ]
                }
            },
            "default": {}
        }`;

    map<Numbers[]> colors = {"red": ["ONE", "TWO", "THREE"], "green": ["ONE", "TWO", "THREE"], "blue": ["ONE", "TWO", "THREE"]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<Numbers[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "float"]
}
public isolated function testMapsWithFloat() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": "float",
            "default": {}
        }`;

    map<float> colors = {"red": 2.3453, "green": 435.563, "blue": 20347.23};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<float> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "double"]
}
public isolated function testMapsWithDouble() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": "double",
            "default": {}
        }`;

    map<float> colors = {"red": 2.3453, "green": 435.563, "blue": 20347.23};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<float> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "double", "array"]
}
public isolated function testMapsWithDoubleArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "name" : "enums", 
                "namespace": "data", 
                "items": "double"
            },
            "default": {}
        }`;

    map<float[]> colors = {"red": [2.3434253, 435.56433, 20347.22343], "green": [2.3452343, 435.56343, 20347.2423], "blue": [2.3453243, 435.56243, 20347.22343]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<float[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "long"]
}
public isolated function testMapsWithLong() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": "long",
            "default": {}
        }`;

    map<int> colors = {"red": 2, "green": 435, "blue": 2034723};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<int> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "string"]
}
public isolated function testMapsWithStrings() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": "string",
            "default": {}
        }`;

    map<string> colors = {"red": "2", "green": "435", "blue": "2034723"};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<string> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "boolean"]
}
public isolated function testMapsWithBoolean() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": "boolean",
            "default": {}
        }`;

    map<boolean> colors = {"red": true, "green": false, "blue": false};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<boolean> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps"]
}
public isolated function testMapsWithMaps() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "map",
                "values": "long"
            },
            "default": {}
        }`;

    map<map<int>> colors = {
        "red": {"r": 2, "g": 3, "b": 4},
        "green": {"r": 5, "g": 6, "b": 7},
        "blue": {"r": 8, "g": 9, "b": 10}
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<map<int>> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "k"]
}
public isolated function testMapsWithNestedMaps() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "map",
                "values": {
                    "type": "map",
                    "values": "int"
                }
            },
            "default": {}
        }`;

    map<map<map<int>>> colors = {
        "red": {"r": {"r": 2, "g": 3, "b": 4}, "g": {"r": 5, "g": 6, "b": 7}, "b": {"r": 8, "g": 9, "b": 10}},
        "green": {"r": {"r": 2, "g": 3, "b": 4}, "g": {"r": 5, "g": 6, "b": 7}, "b": {"r": 8, "g": 9, "b": 10}},
        "blue": {"r": {"r": 2, "g": 3, "b": 4}, "g": {"r": 5, "g": 6, "b": 7}, "b": {"r": 8, "g": 9, "b": 10}}
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<map<map<int>>> deserialize = check avro.fromAvro(encode);
    test:assertEquals(colors, deserialize);
}

@test:Config {
    groups: ["maps", "long"]
}
public isolated function testMapsWithLongArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": "long"
            },
            "default": {}
        }`;

    map<int[]> colors = {"red": [252, 122, 41], "green": [235, 163, 23], "blue": [207, 123]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<int[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "int", "az"]
}
public isolated function testMapsWithIntArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": "int"
            },
            "default": {}
        }`;

    map<int[]> colors = {"red": [252, 122, 41], "green": [235, 163, 23], "blue": [207, 123]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<int[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "float"]
}
public isolated function testMapsWithFloatArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": "float"
            },
            "default": {}
        }`;

    // 207.234345
    map<float[]> colors = {"red": [252.32, 122.45, 41.342], "green": [235.321, 163.3, 23.324], "blue": [207.23434, 123.23]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<float[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "string"]
}
public isolated function testMapsWithStringArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": "string"
            },
            "default": {}
        }`;

    map<string[]> colors = {"red": ["252", "122", "41"], "green": ["235", "163", "23"], "blue": ["207", "123"]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<string[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "bytes"]
}
public isolated function testMapsWithBytesArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": "bytes"
            },
            "default": {}
        }`;

    map<byte[][]> colors = {"red": ["252".toBytes(), "122".toBytes(), "41".toBytes()], "green": ["235".toBytes(), "163".toBytes(), "23".toBytes()], "blue": ["207".toBytes(), "123".toBytes()]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<byte[][]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "bytes"]
}
public isolated function testMapsWithFixedArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": {
                    "type": "fixed",
                    "name": "name",
                    "size": 3
                }
            },
            "default": {}
        }`;

    map<byte[][]> colors = {"red": ["252".toBytes(), "122".toBytes(), "411".toBytes()], "green": ["235".toBytes(), "163".toBytes(), "213".toBytes()], "blue": ["207".toBytes(), "123".toBytes()]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<byte[][]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "boolean"]
}
public isolated function testMapsWithBooleanArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": "boolean"
            },
            "default": {}
        }`;

    map<boolean[]> colors = {"red": [true, false, true], "green": [false, true, false], "blue": [true, false]};

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(colors);
    map<boolean[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, colors);
}

@test:Config {
    groups: ["maps", "record"]
}
public isolated function testMapsWithRecordArray() returns error? {
    string schema = string `
        {
            "type": "map",
            "values": {
                "type": "array",
                "items": {
                    "type": "record",
                    "name": "Instructor",
                    "fields": [
                        {
                            "name": "name",
                            "type": ["null", "string"]
                        },
                        {
                            "name": "student",
                            "type": ["null", {
                                "type": "record",
                                "name": "Student",
                                "fields": [
                                    {
                                        "name": "name",
                                        "type": "string"
                                    },
                                    {
                                        "name": "subject",
                                        "type": "string"
                                    }
                                ]
                            }]
                        }
                    ]
                }
            },
            "default": {}
        }`;

        

    map<Instructor[]> instructors = {
        "john": [{name: "John", student: {name: "Alice", subject: "Math"}}, {name: "John", student: {name: "Alice", subject: "Math"}}],
        "doe": [{name: "Doe", student: {name: "Bob", subject: "Science"}}, {name: "Doe", student: {name: "Bob", subject: "Science"}}],
        "jane": [{name: "Jane", student: {name: "Charlie", subject: "English"}}, {name: "Jane", student: {name: "Charlie", subject: "English"}}]
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(instructors);
    map<Instructor[]> deserialize = check avro.fromAvro(encode);
    test:assertEquals(instructors, deserialize);
}

@test:Config {
    groups: ["maps", "record"]
}
public isolated function testMapsWithNestedRecordMaps() returns error? {
    string schema = string `
    {
        "type": "map",
        "values": {
            "type": "map",
            "values": {
                "type": "record",
                "name": "Lecturer",
                "fields": [
                    {
                        "name": "name",
                        "type": ["null", "string"]
                    },
                    {
                        "name": "instructor",
                        "type": ["null", {
                            "type": "record",
                            "name": "Instructor",
                            "fields": [
                                {
                                    "name": "name",
                                    "type": ["null", "string"]
                                },
                                {
                                    "name": "student",
                                    "type": ["null", {
                                        "type": "record",
                                        "name": "Student",
                                        "fields": [
                                            {
                                                "name": "name",
                                                "type": ["null", "string"]
                                            },
                                            {
                                                "name": "subject",
                                                "type": ["null", "string"]
                                            }
                                        ]
                                    }]
                                }
                            ]
                        }]
                    }
                ]
            }
        }
    }`;


    Lecturer lec = {
        name: "John",
        instructor: {
            name: "Jane",
            student: {
                name: "Charlie",
                subject: "English"
            }
        }
    };

    map<map<Lecturer>> lecturers = {
        "john": {"john": lec, "doe": lec},
        "doe": {"john": lec, "doe": lec},
        "jane": {"john": lec, "doe": lec}
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(lecturers);
    map<map<Lecturer>> deserialize = check avro.fromAvro(encode);
    test:assertEquals(lecturers, deserialize);
}


@test:Config {
    groups: ["maps", "record", "wx"]
}
public isolated function testMapsWithNestedRecordArrayMaps() returns error? {
    string schema = string `
    {
        "type": "map",
        "values": {
            "type": "map",
            "values": {
                "type": "array",
                "items": {
                    "type": "record",
                    "name": "Lecturer",
                    "fields": [
                        {
                            "name": "name",
                            "type": ["null", "string"]
                        },
                        {
                            "name": "instructor",
                            "type": ["null", {
                                "type": "record",
                                "name": "Instructor",
                                "fields": [
                                    {
                                        "name": "name",
                                        "type": ["null", "string"]
                                    },
                                    {
                                        "name": "student",
                                        "type": ["null", {
                                            "type": "record",
                                            "name": "Student",
                                            "fields": [
                                                {
                                                    "name": "name",
                                                    "type": ["null", "string"]
                                                },
                                                {
                                                    "name": "subject",
                                                    "type": ["null", "string"]
                                                }
                                            ]
                                        }]
                                    }
                                ]
                            }]
                        }
                    ]
                }
            }
        }
    }`;


    Lecturer[] lecs = [{name: "John", instructor: {name: "Jane", student: {name: "Charlie", subject: "English"}}},
                            {name: "Doe", instructor: {name: "Jane", student: {name: "Charlie", subject: "English"}}}];

    map<map<Lecturer[]>> lecturers = {
        "john": {"r": lecs, "g": lecs, "b": lecs},
        "doe": {"r": lecs, "g": lecs, "b": lecs},
        "jane": {"r": lecs, "g": lecs, "b": lecs}
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(lecturers);
    map<map<Lecturer[]>> deserialize = check avro.fromAvro(encode);
    test:assertEquals(lecturers, deserialize);
}
