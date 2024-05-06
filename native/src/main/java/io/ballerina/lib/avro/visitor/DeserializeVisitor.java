/*
 * Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.avro.visitor;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.util.Utf8;

import java.nio.ByteBuffer;
import java.util.Map;

import static io.ballerina.lib.avro.Avro.getMutableType;

public class DeserializeVisitor implements IDeserializeVisitor {

    public double visitDouble(Object data) {
        if (data instanceof Float) {
            return ((Float) data).doubleValue();
        }
        return (double) data;
    }

    public BString visitString(Object data) {
        return StringUtils.fromString(data.toString());
    }

    public BMap<BString, Object> visitMap(Map<String, Object> data, Type type) throws Exception {
        if (type instanceof MapType mapType) {
            BMap<BString, Object> avroRecord = ValueCreator.createMapValue(mapType);
            Object[] keys = data.keySet().toArray();
            for (Object key : keys) {
                avroRecord.put(StringUtils.fromString(key.toString()), data.get(key));
            }
            return avroRecord;
        } else {
            throw new Exception("Type is not a valid map type");
        }
    }

    public BArray visitFixed(Object data) {
        GenericData.Fixed fixed = (GenericData.Fixed) data;
        return ValueCreator.createArrayValue(fixed.bytes());
    }
    @SuppressWarnings({"unchecked", "deprecation"})
    public BMap<BString, Object> visitMap(Map<String, Object> data, Type type, Schema schema) throws Exception {
        assert type instanceof MapType;
        BMap<BString, Object> avroRecord = ValueCreator.createMapValue(type);
        Object[] keys = data.keySet().toArray();
        for (Object key : keys) {
            Object value = data.get(key);
            Schema.Type valueType = schema.getValueType().getType();
            switch (valueType) {
                case ARRAY ->
                        avroRecord.put(StringUtils.fromString(key.toString()), visitArray(schema.getValueType(),
                                       (GenericData.Array<Object>) value, ((MapType) type).getConstrainedType()));
                case BYTES ->
                        avroRecord.put(StringUtils.fromString(key.toString()),
                                       ValueCreator.createArrayValue(((ByteBuffer) value).array()));
                case FIXED ->
                        avroRecord.put(StringUtils.fromString(key.toString()),
                                       ValueCreator.createArrayValue(((GenericFixed) value).bytes()));
                case RECORD ->
                        avroRecord.put(StringUtils.fromString(key.toString()),
                                       visitRecords(((MapType) type).getConstrainedType().getCachedReferredType(),
                                                    schema.getValueType(), (GenericRecord) value));
                case ENUM, STRING ->
                        avroRecord.put(StringUtils.fromString(key.toString()),
                                       StringUtils.fromString(value.toString()));
                case FLOAT ->
                        avroRecord.put(StringUtils.fromString(key.toString()), Double.parseDouble(value.toString()));
                case MAP ->
                        avroRecord.put(StringUtils.fromString(key.toString()),
                                       visitMap((Map<String, Object>) value,
                                                ((MapType) type).getConstrainedType(), schema.getValueType()));
                default ->
                        avroRecord.put(StringUtils.fromString(key.toString()), value);
            }
        }
        return avroRecord;
    }

    public Object visitArray(Schema schema, GenericData.Array<Object> data, Type type) throws Exception {
        switch (schema.getElementType().getType()) {
            case STRING -> {
                BString[] stringArray = new BString[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    stringArray[i] = StringUtils.fromString(data.get(i).toString());
                }
                return ValueCreator.createArrayValue(stringArray);
            }
            case INT, LONG -> {
                long[] longArray = new long[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    longArray[i] = (long) data.get(i);
                }
                return ValueCreator.createArrayValue(longArray);
            }
            case FLOAT, DOUBLE -> {
                double[] floatArray = new double[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    floatArray[i] = Double.parseDouble(data.get(i).toString());
                }
                return ValueCreator.createArrayValue(floatArray);

            }
            case BOOLEAN -> {
                boolean[] booleanArray = new boolean[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    booleanArray[i] = (boolean) data.get(i);
                }
                return ValueCreator.createArrayValue(booleanArray);
            }
            case RECORD -> {
                Object[] recordArray = new Object[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    if (type instanceof ArrayType arrayType) {
                        recordArray[i] = visitRecords((arrayType.getElementType()).getCachedReferredType(),
                                                      schema.getElementType(), (GenericRecord) data.get(i));
                    }
                }
                assert type instanceof ArrayType;
                return ValueCreator.createArrayValue(recordArray, (ArrayType) type);
            }
            case BYTES -> {
                BArray[] values = new BArray[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    ByteBuffer byteBuffer = (ByteBuffer) data.get(i);
                    values[i] = ValueCreator.createArrayValue(byteBuffer.array());
                }
                return ValueCreator.createArrayValue(values, (ArrayType) type);
            }
            default -> {
                return new int[]{};
            }
        }
    }

    public BMap<BString, Object> visitRecords(Type type, Schema schema, GenericRecord rec) throws Exception {
        BMap<BString, Object> avroRecord;
        Type originalType = type;
        if (type instanceof IntersectionType intersectionType) {
            type = getMutableType(intersectionType);
            avroRecord = ValueCreator.createRecordValue((RecordType) type);
        } else if (type instanceof RecordType recordType) {
            avroRecord = ValueCreator.createRecordValue(recordType);
        } else {
            throw new Exception("Type is not a valid record type");
        }
        for (Schema.Field field : schema.getFields()) {
            Object fieldData = rec.get(field.name());
            switch (field.schema().getType()) {
                case MAP:
                    Type mapType = extractMapType(type);
                    avroRecord.put(StringUtils.fromString(field.name()),
                                   visitMap((Map<String, Object>) rec.get(field.name()), mapType));
                    break;
                case ARRAY:
                    avroRecord.put(StringUtils.fromString(field.name()), visitArray(field.schema(),
                                   (GenericData.Array<Object>) rec.get(field.name()), type));
                    break;
                case BYTES:
                    ByteBuffer byteBuffer = (ByteBuffer) rec.get(field.name());
                    avroRecord.put(StringUtils.fromString(field.name()),
                                   ValueCreator.createArrayValue(byteBuffer.array()));
                    break;
                case STRING:
                    avroRecord.put(StringUtils.fromString(field.name()),
                                   StringUtils.fromString(rec.get(field.name()).toString()));
                    break;
                case RECORD:
                    Type recType = extractRecordType((RecordType) type);
                    avroRecord.put(StringUtils.fromString(field.name()),
                                   visitRecords(recType, field.schema(), (GenericRecord) rec.get(field.name())));
                    break;
                case INT:
                    avroRecord.put(StringUtils.fromString(field.name()), Long.parseLong(fieldData.toString()));
                    break;
                case FLOAT:
                    avroRecord.put(StringUtils.fromString(field.name()), Double.parseDouble(fieldData.toString()));
                    break;
                case UNION:
                    visitUnionRecords(type, avroRecord, field, fieldData);
                    break;
                default:
                    avroRecord.put(StringUtils.fromString(field.name()), rec.get(field.name()));
            }
        }
        if (originalType.isReadOnly()) {
            avroRecord.freezeDirect();
        }
        return avroRecord;
    }

    private void visitUnionRecords(Type type, BMap<BString, Object> avroRecord,
                                   Schema.Field field, Object fieldData) throws Exception {
        for (Schema schemaType : field.schema().getTypes()) {
            if (fieldData == null) {
                avroRecord.put(StringUtils.fromString(field.name()), null);
                break;
            }
            switch (schemaType.getType()) {
                case RECORD -> {
                    if (fieldData instanceof GenericRecord) {
                        avroRecord.put(StringUtils.fromString(field.name()),
                                       visitRecords(type, schemaType, (GenericRecord) fieldData));
                    }
                }
                case STRING -> {
                    if (fieldData instanceof Utf8) {
                        avroRecord.put(StringUtils.fromString(field.name()),
                                       StringUtils.fromString(fieldData.toString()));
                    }
                }
                case INT, LONG -> {
                    if (fieldData instanceof Integer || fieldData instanceof Long) {
                        avroRecord.put(StringUtils.fromString(field.name()),
                                       ((Number) fieldData).longValue());
                    }
                }
                case FLOAT, DOUBLE -> {
                    if (fieldData instanceof Double) {
                        avroRecord.put(StringUtils.fromString(field.name()), fieldData);
                    }
                }
                default -> {
                    if (fieldData instanceof Boolean) {
                        avroRecord.put(StringUtils.fromString(field.name()), fieldData);
                    }
                }
            }
        }
    }

    private static Type extractMapType(Type type) {
        Type mapType = type;
        for (Map.Entry<String, Field> entry : ((RecordType) type).getFields().entrySet()) {
            Field fieldValue = entry.getValue();
            if (fieldValue != null) {
                Type fieldType = fieldValue.getFieldType();
                if (fieldType instanceof MapType) {
                    mapType = fieldType;
                } else if (TypeUtils.getReferredType(fieldType) instanceof MapType) {
                    mapType = TypeUtils.getReferredType(fieldType);
                } else if (fieldType instanceof IntersectionType) {
                    Type getType = getMutableType((IntersectionType) fieldType);
                    if (getType instanceof MapType) {
                        mapType = getType;
                    }
                }
            }
        }
        return mapType;
    }

    private static RecordType extractRecordType(RecordType type) {
        Map<String, Field> fieldsMap = type.getFields();
        RecordType recType = type;
        for (Map.Entry<String, Field> entry : fieldsMap.entrySet()) {
            Field fieldValue = entry.getValue();
            if (fieldValue != null) {
                Type fieldType = fieldValue.getFieldType();
                if (fieldType instanceof RecordType) {
                    recType = (RecordType) fieldType;
                } else if (fieldType instanceof IntersectionType) {
                    Type getType = getMutableType((IntersectionType) fieldType);
                    if (getType instanceof RecordType) {
                        recType = (RecordType) getType;
                    }
                } else if (TypeUtils.getReferredType(fieldType) instanceof RecordType) {
                    recType = (RecordType) TypeUtils.getReferredType(fieldType);
                }
            }
        }
        return recType;
    }
}
