package io.ballerina.lib.avro.visitor;

import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import static io.ballerina.lib.avro.Utils.ARRAY_TYPE;
import static io.ballerina.lib.avro.Utils.INTEGER_TYPE;
import static io.ballerina.lib.avro.Utils.MAP_TYPE;
import static io.ballerina.lib.avro.Utils.RECORD_TYPE;
import static io.ballerina.lib.avro.Utils.STRING_TYPE;
import static io.ballerina.lib.avro.Utils.checkType;

public class SerializeVisitor implements ISerializeVisitor {

    @Override
    public String visitString(Object data) {
        return ((BString) data).getValue();
    }

    @Override
    public GenericRecord visitRecord(BMap<?, ?> data, Schema schema) throws Exception {
        GenericRecord genericRecord = new GenericData.Record(schema);
        for (Schema.Field field: schema.getFields()) {
            Object fieldData = data.get(StringUtils.fromString(field.name()));
            Schema.Type type = field.schema().getType();
            switch (type) {
                case UNION ->
                        genericRecord.put(field.name(), visitUnion(fieldData, field));
                case RECORD ->
                        genericRecord.put(field.name(), visitRecord((BMap<?, ?>) fieldData, field.schema()));
                case MAP ->
                        genericRecord.put(field.name(), visitMap((BMap<?, ?>) fieldData, field.schema()));
                case ARRAY ->
                        genericRecord.put(field.name(), visitArray((BArray) fieldData, field.schema()));
                case INT, LONG, FLOAT, DOUBLE, BOOLEAN, STRING, BYTES ->
                        genericRecord.put(field.name(), visitRecordPrimitives(fieldData, type));
                case ENUM ->
                        genericRecord.put(field.name(), visitEnum(fieldData, field.schema()));
                default ->
                        genericRecord.put(field.name(), fieldData);
            }
        }
        return genericRecord;
    }

    private Object visitRecordPrimitives(Object data, Schema.Type type) {
        switch (type) {
            case INT -> {
                return ((Long) data).intValue();
            }
            case BYTES -> {
                ByteBuffer byteBuffer = ByteBuffer.allocate(((BArray) data).getByteArray().length);
                byteBuffer.put(((BArray) data).getByteArray());
                byteBuffer.position(0);
                return byteBuffer;
            }
            case STRING -> {
                return data.toString();
            }
            default -> {
                return data;
            }
        }
    }

    @Override
    public Map<String, Object> visitMap(BMap<?, ?> data, Schema schema) throws Exception {
        Map<String, Object> avroMap = new HashMap<>();
        Schema.Type type = schema.getValueType().getType();
        for (Object value : data.getKeys()) {
            switch (type) {
                case INT, LONG, FLOAT, DOUBLE, BOOLEAN, STRING, BYTES ->
                        avroMap.put(value.toString(), visitRecordPrimitives(data.get(value), type));
                case RECORD ->
                        avroMap.put(value.toString(), visitRecord((BMap<?, ?>) data.get(value), schema.getValueType()));
                case MAP ->
                        avroMap.put(value.toString(), visitMap((BMap<?, ?>) data.get(value), schema.getValueType()));
                case ARRAY ->
                        avroMap.put(value.toString(), visitArray((BArray) data.get(value), schema.getValueType()));
                case ENUM ->
                        avroMap.put(value.toString(), visitEnum(data.get(value), schema.getValueType()));
                default ->
                        throw new IllegalArgumentException("Unsupported schema type: " + type);
            }
        }
        return avroMap;
    }

    @Override
    public Object visitEnum(Object data, Schema schema) {
        return new GenericData.EnumSymbol(schema, data);
    }

    @Override
    public GenericData.Fixed visitFixed(Object data, Schema schema) {
        return new GenericData.Fixed(schema, ((BArray) data).getByteArray());
    }
    
    @Override
    public GenericData.Array<Object> visitArray(BArray data, Schema schema) throws Exception {
        GenericData.Array<Object> array = new GenericData.Array<>(data.size(), schema);
        switch (schema.getElementType().getType()) {
            case STRING -> {
                return visitStringArray(data, array);
            }
            case INT, LONG -> {
                return visitLongArray(data, array);
            }
            case FLOAT, DOUBLE -> {
                return visitDoubleArray(data, array);
            }
            case BOOLEAN -> {
                return visitBooleanArray(data, array);
            }
            case MAP -> {
                return visitMapArray(data, schema, array);
            }
            case RECORD -> {
                return visitRecordArray(data, schema, array);
            }
            default -> {
                return visitBytes(data, array);
            }
        }
    }

    private static GenericData.Array<Object> visitRecordArray(BArray data, Schema schema,
                                                              GenericData.Array<Object> array) {
        Arrays.stream(data.getValues())
                .filter(Objects::nonNull)
                .forEach(record -> {
                    try {
                        array.add(new SerializeVisitor().visitRecord((BMap<?, ?>) record, schema.getElementType()));
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                });
        return array;
    }

    private static GenericData.Array<Object> visitMapArray(BArray data, Schema schema,
                                                           GenericData.Array<Object> array) {
        Arrays.stream(data.getValues())
                .filter(Objects::nonNull)
                .forEach(record -> {
                    try {
                        array.add(new SerializeVisitor().visitMap((BMap<?, ?>) record, schema.getElementType()));
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                });
        return array;
    }

    private GenericData.Array<Object> visitBytes(BArray data, GenericData.Array<Object> array) {
        Arrays.stream(data.getValues())
                .filter(Objects::nonNull)
                .forEach(bytes -> {
                    ByteBuffer byteBuffer = ByteBuffer.allocate(((BArray) bytes).getByteArray().length);
                    byteBuffer.put(((BArray) bytes).getByteArray());
                    byteBuffer.position(0);
                    array.add(byteBuffer);
                });
        return array;
    }

    private GenericData.Array<Object> visitBooleanArray(BArray data, GenericData.Array<Object> array) {
        for (Object obj: data.getBooleanArray()) {
            array.add(obj);
        }
        return array;
    }

    private GenericData.Array<Object> visitDoubleArray(BArray data, GenericData.Array<Object> array) throws Exception {
        try {
            for (Object obj: data.getFloatArray()) {
                array.add(obj);
            }
            return array;
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
    }

    private GenericData.Array<Object> visitLongArray(BArray data, GenericData.Array<Object> array) {
        for (Object obj: data.getIntArray()) {
            array.add(obj);
        }
        return array;
    }

    private GenericData.Array<Object> visitStringArray(BArray data, GenericData.Array<Object> array) {
        array.addAll(Arrays.asList(data.getStringArray()));
        return array;
    }

    private Object visitUnion(Object data, Schema.Field field) throws Exception {
        Type typeName = TypeUtils.getType(data);
        switch (typeName.getClass().getSimpleName()) {
            case STRING_TYPE -> {
                return data.toString();
            }
            case ARRAY_TYPE -> {
                return visitArray((BArray) data, field.schema());
            }
            case MAP_TYPE -> {
                return visitMap((BMap<?, ?>) data, field.schema());
            }
            case RECORD_TYPE -> {
                return visitRecord((BMap<?, ?>) data, checkType(Schema.Type.RECORD, field.schema().getTypes()));
            }
            case INTEGER_TYPE -> {
                for (Schema schema : field.schema().getTypes()) {
                    if (schema.getType().equals(Schema.Type.INT)) {
                        return ((Long) data).intValue();
                    }
                }
                return data;
            }
            default -> {
                return data;
            }
        }
    }
}
