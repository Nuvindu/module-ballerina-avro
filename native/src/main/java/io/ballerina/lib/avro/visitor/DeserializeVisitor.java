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
import org.apache.avro.generic.GenericEnumSymbol;
import org.apache.avro.generic.GenericFixed;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.util.Utf8;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static io.ballerina.lib.avro.Utils.getMutableType;

public class DeserializeVisitor implements IDeserializeVisitor {

    public double visitDouble(Object data) {
        if (data instanceof Float) {
            return Double.parseDouble(data.toString());
        }
        return (double) data;
    }

    public BArray visitBytes(Object data) {
        return ValueCreator.createArrayValue(((ByteBuffer) data).array());
    }

    public BArray visitFixed(Object data) {
        GenericData.Fixed fixed = (GenericData.Fixed) data;
        return ValueCreator.createArrayValue(fixed.bytes());
    }

    public BString visitString(Object data) {
        return StringUtils.fromString(data.toString());
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
            case ARRAY -> {
                Object[] objects = new Object[data.size()];
                Type arrayType = ((ArrayType) type).getElementType();
                for (int i = 0; i < data.size(); i++) {
                    objects[i] = visitArray(schema.getElementType(),
                                            (GenericData.Array<Object>) data.get(i), arrayType);
                }
                return ValueCreator.createArrayValue(objects, (ArrayType) type);
            }
            case STRING -> {
                return visitStringArray(data);
            }
            case ENUM -> {
                Object[] enums = new Object[data.size()];
                for (int i = 0; i < data.size(); i++) {
                    enums[i] = visitString(data.get(i));
                }
                return ValueCreator.createArrayValue(enums, (ArrayType) type);
            }
            case INT -> {
                return visitIntArray(data);
            }
            case LONG -> {
                return visitLongArray(data);
            }
            case FLOAT, DOUBLE -> {
                return visitDoubleArray(data);
            }
            case BOOLEAN -> {
                return visitBooleanArray(data);
            }
            case RECORD -> {
                return visitRecordArray(schema, data, type);
            }
            case FIXED -> {
                assert type instanceof ArrayType;
                return visitFixedArray(data, (ArrayType) type);
            }
            default -> {
                assert type instanceof ArrayType;
                return visitBytesArray(data, (ArrayType) type);
            }
        }
    }

    private BArray visitBytesArray(GenericData.Array<Object> data, ArrayType type) {
        List<BArray> values = new ArrayList<>();
        for (Object datum : data) {
            values.add(visitBytes(datum));
        }
        return ValueCreator.createArrayValue(values.toArray(new BArray[data.size()]), type);
    }

    private BArray visitFixedArray(GenericData.Array<Object> data, ArrayType type) {
        List<BArray> values = new ArrayList<>();
        for (Object datum : data) {
            values.add(visitFixed(datum));
        }
        return ValueCreator.createArrayValue(values.toArray(new BArray[data.size()]), type);
    }

    private BArray visitRecordArray(Schema schema, GenericData.Array<Object> data, Type type) throws Exception {
        List<Object> recordList = new ArrayList<>();
        if (type instanceof ArrayType arrayType) {
            for (Object datum : data) {
                recordList.add(visitRecords(arrayType.getElementType().getCachedReferredType(),
                               schema.getElementType(), (GenericRecord) datum));
            }
        }
        assert type instanceof ArrayType;
        return ValueCreator.createArrayValue(recordList.toArray(new Object[data.size()]), (ArrayType) type);

    }

    private static BArray visitBooleanArray(GenericData.Array<Object> data) {
        boolean[] booleanArray = new boolean[data.size()];
        int index = 0;
        for (Object datum : data) {
            booleanArray[index++] = (boolean) datum;
        }
        return ValueCreator.createArrayValue(booleanArray);
    }

    private BArray visitDoubleArray(GenericData.Array<Object> data) {
        List<Double> doubleList = new ArrayList<>();
        for (Object datum : data) {
            doubleList.add(visitDouble(datum));
        }
        double[] doubleArray = doubleList.stream().mapToDouble(Double::doubleValue).toArray();
        return ValueCreator.createArrayValue(doubleArray);
    }

    private static BArray visitLongArray(GenericData.Array<Object> data) {
        List<Long> longList = new ArrayList<>();
        for (Object datum : data) {
            longList.add((Long) datum);
        }
        long[] longArray = longList.stream().mapToLong(Long::longValue).toArray();
        return ValueCreator.createArrayValue(longArray);
    }

    private static BArray visitIntArray(GenericData.Array<Object> data) {
        List<Long> longList = new ArrayList<>();
        for (Object datum : data) {
            longList.add(((Integer) datum).longValue());
        }
        long[] longArray = longList.stream().mapToLong(Long::longValue).toArray();
        return ValueCreator.createArrayValue(longArray);
    }

    private BArray visitStringArray(GenericData.Array<Object> data) {
        BString[] stringArray = new BString[data.size()];
        for (int i = 0; i < data.size(); i++) {
            stringArray[i] = visitString(data.get(i));
        }
        return ValueCreator.createArrayValue(stringArray);
    }

    @SuppressWarnings("unchecked")
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
                case MAP -> {
                    Type mapType = extractMapType(type);
                    avroRecord.put(StringUtils.fromString(field.name()),
                                   visitMap((Map<String, Object>) rec.get(field.name()), mapType, field.schema()));
                }
                case ARRAY ->
                        avroRecord.put(StringUtils.fromString(field.name()), visitArray(field.schema(),
                                       (GenericData.Array<Object>) rec.get(field.name()), type));
                case BYTES -> {
                    ByteBuffer byteBuffer = (ByteBuffer) rec.get(field.name());
                    avroRecord.put(StringUtils.fromString(field.name()),
                                   ValueCreator.createArrayValue(byteBuffer.array()));
                }
                case STRING ->
                        avroRecord.put(StringUtils.fromString(field.name()),
                                       StringUtils.fromString(rec.get(field.name()).toString()));
                case RECORD -> {
                    Type recType = extractRecordType((RecordType) type);
                    avroRecord.put(StringUtils.fromString(field.name()),
                            visitRecords(recType, field.schema(), (GenericRecord) rec.get(field.name())));
                }
                case INT ->
                        avroRecord.put(StringUtils.fromString(field.name()), Long.parseLong(fieldData.toString()));
                case FLOAT ->
                        avroRecord.put(StringUtils.fromString(field.name()), Double.parseDouble(fieldData.toString()));
                case UNION ->
                        visitUnionRecords(type, avroRecord, field, fieldData);
                default ->
                        avroRecord.put(StringUtils.fromString(field.name()), rec.get(field.name()));
            }
        }
        if (originalType.isReadOnly()) {
            avroRecord.freezeDirect();
        }
        return avroRecord;
    }

    @SuppressWarnings("unchecked")
    private void visitUnionRecords(Type type, BMap<BString, Object> avroRecord,
                                   Schema.Field field, Object fieldData) throws Exception {
        for (Schema schemaType : field.schema().getTypes()) {
            if (fieldData == null) {
                avroRecord.put(StringUtils.fromString(field.name()), null);
                break;
            }
            switch (schemaType.getType()) {
                case BYTES -> {
                    if (fieldData instanceof ByteBuffer) {
                        BArray byteArray = ValueCreator.createArrayValue(((ByteBuffer) fieldData).array());
                        avroRecord.put(StringUtils.fromString(field.name()), byteArray);
                    }
                }
                case FIXED -> {
                    if (fieldData instanceof GenericFixed) {
                        BArray byteArray = ValueCreator.createArrayValue(((GenericData.Fixed) fieldData).bytes());
                        avroRecord.put(StringUtils.fromString(field.name()), byteArray);
                    }
                }
                case ARRAY -> {
                    if (fieldData instanceof GenericData.Array<?>) {
                        Object[] objectArray = ((GenericData.Array<?>) fieldData).toArray();
                        if (schemaType.getElementType().getType().equals(Schema.Type.STRING)
                                || schemaType.getElementType().getType().equals(Schema.Type.ENUM)) {
                            BString[] stringArray = new BString[objectArray.length];
                            BArray ballerinaArray = ValueCreator.createArrayValue(stringArray);
                            int i = 0;
                            for (Object obj : objectArray) {
                                stringArray[i] = StringUtils.fromString(obj.toString());
                                i++;
                            }
                            avroRecord.put(StringUtils.fromString(field.name()), ballerinaArray);
                        } else {
                            avroRecord.put(StringUtils.fromString(field.name()), fieldData);
                        }
                    }
                }
                case MAP -> {
                    if (fieldData instanceof Map<?, ?>) {
                        BMap<BString, Object> avroMap = ValueCreator.createMapValue();
                        Object[] keys = ((Map<String, Object>) fieldData).keySet().toArray();
                        for (Object key : keys) {
                            avroMap.put(StringUtils.fromString(key.toString()),
                                    ((Map<String, Object>) fieldData).get(key));
                        }
                        avroRecord.put(StringUtils.fromString(field.name()), avroMap);
                    }
                }
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
                    } else {
                        avroRecord.put(StringUtils.fromString(field.name()), Double.parseDouble(fieldData.toString()));
                    }
                }
                case ENUM -> {
                    if (fieldData instanceof GenericEnumSymbol<?>) {
                        avroRecord.put(StringUtils.fromString(field.name()),
                                       StringUtils.fromString(fieldData.toString()));
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
                    Type referredType = getMutableType((IntersectionType) fieldType);
                    if (referredType instanceof MapType) {
                        mapType = referredType;
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
