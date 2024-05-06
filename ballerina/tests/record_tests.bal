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
    groups: ["record"]
}
public isolated function testRecords() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "subject", "type": "string"}
            ]
        }`;

    Student student = {
        name: "Liam",
        subject: "geology"
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(student);
    Student deserialize = check avro.fromAvro(serialize);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record"]
}
public isolated function testRecordsWithDifferentTypeOfFields() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "age", "type": "int"}
            ]
        }`;

    Person student = {
        name: "Liam",
        age: 52
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Person deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record"]
}
public isolated function testNestedRecords() returns error? {
    string schema = string `
    {
        "namespace": "example.avro",
        "type": "record",
        "name": "Lecturer",
        "fields": [
            {
                "name": "name",
                "type": {
                    "type": "map",
                    "values" : "int",
                    "default": {}
                }
            },
            {
                "name": "age",
                "type": "long"
            },
            {
                "name": "instructor",
                "type": {
                    "name": "Instructor",
                    "type": "record",
                    "fields": [
                        {
                            "name": "name",
                            "type": "string"
                        },
                        {
                            "name": "student",
                            "type": {
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
                            }
                        }
                    ]
                }
            }
        ]
    }`;

    Lecturer3 lecturer = {
        name: {"John": 1, "Sam": 2, "Liam": 3},
        age: 11,
        instructor: {
            name: "Liam",
            student: {
                name: "Sam",
                subject: "geology"
            }
        }
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(lecturer);
    Lecturer3 deserialize = check avro.fromAvro(serialize);
    // deserialize.instructor.student.name = "Sam";
    test:assertEquals(deserialize, lecturer);
}

@test:Config {
    groups: ["record", "array"]
}
public isolated function testArraysInRecords() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "colors", "type": {"type": "array", "items": "string"}}
            ]
        }`;

    Color colors = {
        name: "Red",
        colors: ["maroon", "dark red", "light red"]
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(colors);
    Color deserialize = check avro.fromAvro(serialize);
    test:assertEquals(colors, deserialize);
}

type Color1 record {
    string name;
    byte[] colors;
};

@test:Config {
    groups: ["record", "errors"]
}
public isolated function testArraysInRecordsWithInvalidSchema() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "colors", "type": "bytes"}
            ]
        }`;

    Color1 colors = {
        name: "Red",
        colors: "ss".toBytes()
    };

    Schema avroProducer = check new (schema);
    byte[] serialize = check avroProducer.toAvro(colors);
    string schema2 = string `
    {
        "namespace": "example.avro",
        "type": "record",
        "name": "Student",
        "fields": [
            {"name": "name", "type": "string"},
            {"name": "colors", "type": {"type": "array", "items": "int"}}
        ]
    }`;
    Schema avroConsumer = check new (schema2);
    Color1|Error deserialize = avroConsumer.fromAvro(serialize);
    test:assertTrue(deserialize is Error);
}

@test:Config {
    groups: ["record", "union"]
}
public isolated function testRecordsWithUnionTypes() returns error? {
    string schema = string `
        {
            "type": "record",
            "name": "Course",
            "namespace": "example.avro",
            "fields": [
                {
                    "name": "name",
                    "type": ["string", "null"]
                },
                {
                    "name": "value",
                    "type": "float"
                },
                {
                    "name": "credits",
                    "type": ["null", "int"]
                },
                {
                    "name": "student",
                    "type": {
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
            ]
        }`;

    UnionRecord course = {
        name: "data",
        value: 0.0,
        credits: 5,
        student: {name: "Jon", subject: "geo"}
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(course);
    UnionRecord deserialize = check avro.fromAvro(serialize);
    test:assertEquals(deserialize, course);
}

@test:Config {
    groups: ["record", "primitive", "int"]
}
public isolated function testRecordsWithIntFields() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "age", "type": "int"}
            ]
        }`;

    Person student = {
        name: "Liam",
        age: 52
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Person deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record", "primitive", "long"]
}
public isolated function testRecordsWithLongFields() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "age", "type": "long"}
            ]
        }`;

    Person student = {
        name: "Liam",
        age: 52
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Person deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record", "primitive", "float"]
}
public isolated function testRecordsWithFloatFields() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "age", "type": "float"}
            ]
        }`;

    Students student = {
        name: "Liam",
        age: 52.656
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Students deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record", "primitive", "double"]
}
public isolated function testRecordsWithDoubleFields() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "age", "type": "double"}
            ]
        }`;

    Students student = {
        name: "Liam",
        age: 52.656
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Students deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record", "primitive", "boolean"]
}
public isolated function testRecordsWithBooleanFields() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "under19", "type": "boolean"}
            ]
        }`;

    StudentRec student = {
        name: "Liam",
        under19: false
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    StudentRec deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["record", "union"]
}
public isolated function testOptionalValuesInRecords() returns error? {
    string schema = string `
    {
        "type": "record",
        "name": "Lecturer5",
        "fields": [
            {
                "name": "name",
                "type": [
                    "null", 
                    {
                        "type": "map",
                        "values": "int"
                    }
                ]
            },
            {
                "name": "bytes",
                "type": ["null", "bytes"]
            },
            {
                "name": "instructorClone",
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
                }]
            },
            {
                "name": "instructors",
                "type": ["null", "Instructor"]
            }
        ]
    }`;

    Instructor instructor = {
        name: "John",
        student: {
            name: "Alice",
            subject: "Math"
        }
    };

    Lecturer5 lecturer5 = {
        name: {
            "John": 1, 
            "Sam": 2, 
            "Liam": 3
        },
        bytes: "ss".toBytes(),
        instructorClone: instructor.cloneReadOnly(),
        instructors: instructor
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(lecturer5);
    Lecturer5 deserialize = check avro.fromAvro(serialize);
    test:assertEquals(deserialize, lecturer5);
}

@test:Config {
    groups: ["record", "union"]
}
public isolated function testOptionalMultipleFieldsInRecords() returns error? {
    string schema = string `
    {
        "type": "record",
        "name": "Lecturer6",
        "fields": [
            {
                "name": "temporary",
                "type": ["null", "boolean"]
            },
            {
                "name": "maps",
                "type": [
                    "null", 
                    {
                        "type": "map",
                        "values": "int"
                    }
                ]
            },
            {
                "name": "number",
                "type": [
                    "null",
                    {
                        "type": "enum",
                        "name": "Numbers",
                        "symbols": [ "ONE", "TWO", "THREE", "FOUR" ]
                    }
                ]
            },
            {
                "name": "bytes",
                "type": ["null", {
                    "type": "fixed",
                    "name": "FixedBytes",
                    "size": 2
                }]
            },
            {
                "name": "age",
                "type": ["null", "long"]
            },
            {
                "name": "name",
                "type": ["null", "string"]
            },
            {
                "name": "floatNumber",
                "type": ["null", "float"]
            },
            {
                "name": "colors",
                "type": ["null", {
                    "type": "array",
                    "items": {
                        "type": "enum",
                        "name": "ColorEnum",
                        "symbols": ["ONE", "TWO", "THREE"]
                    }
                }]
            },
            {
                "name": "instructorClone",
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
                                "type": "string"
                                },
                                {
                                "name": "subject",
                                "type": "string"
                                }
                            ]
                        }]
                    }]
                }]
            },
            {
                "name": "instructors",
                "type": ["null", "Instructor"]
            }
        ]
    }`;

    Instructor instructor = {
        name: "John",
        student: {
            name: "Alice",
            subject: "Math"
        }
    };

    Numbers number = ONE;

    Lecturer6 lecturer6 = {
        temporary: false,
        maps: {
            "1": 100,
            "2": 200
        },
        bytes: "ss".toBytes(),
        age: 30,
        number: number,
        name: "Lecturer Name",
        floatNumber: 123.45,
        colors: [number, number, number],
        instructorClone: instructor.cloneReadOnly(),
        instructors: instructor
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(lecturer6);
    Lecturer6 deserialize = check avro.fromAvro(serialize);
    test:assertEquals(deserialize, lecturer6);
}
