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

type Stud record {
    string name;
    float age;
};

public type Student1 record {
    string name;
    byte[] favorite_color;
};

@test:Config {
    groups: ["check", "qww"]
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

@test:Config{
    groups: ["avro", "check", "t"]
}
public isolated function testAvroSerDes() returns error? {
    string schema = string `
        {
            "namespace": "example.avro",
            "type": "record",
            "name": "Student",
            "fields": [
                {"name": "name", "type": "string"},
                {"name": "favorite_color", "type": "bytes"}
            ]
        }`;

    Student1 student = {
        name: "Liam",
        favorite_color: "yellow".toBytes()
    };

    Schema avro = check new(schema);
    byte[] encode = check avro.toAvro(student);
    Student1 deserialize = check avro.fromAvro(encode);
    test:assertEquals(deserialize, student);
}

@test:Config {
    groups: ["check", "recs", "s"]
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
    groups: ["primitive", "nest", "check", "read"]
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
    groups: ["nest", "check", "z"]
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
    groups: ["errors", "qwe", "check"]
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

type UnionRec record {
    string? name;
    int? credits;
    float gg;
    Stu? student;
};

type Stu record {
    string? name;
    string? subject;
};

@test:Config {
    groups: ["check", "unions"]
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
                    "name": "gg",
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

    UnionRec course = {
        name: "data",
        gg: 0.0,
        credits: 5,
        student: {name: "Jon", subject: "geo"}
    };

    Schema avro = check new (schema);
    byte[] serialize = check avro.toAvro(course);
    UnionRec deserialize = check avro.fromAvro(serialize);
    test:assertEquals(deserialize, course);
}

@test:Config {
    groups: ["check", "recs", "s"]
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
    groups: ["check", "recs", "sss"]
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

    Stud student = {
        name: "Liam",
        age: 52.656
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Stud deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}

@test:Config {
    groups: ["check", "recs", "s"]
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

    Stud student = {
        name: "Liam",
        age: 52.656
    };

    Schema avro = check new (schema);
    byte[] encode = check avro.toAvro(student);
    Stud deserialize = check avro.fromAvro(encode);
    test:assertEquals(student, deserialize);
}
