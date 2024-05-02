package io.ballerina.lib.avro.visitor;

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import java.util.Map;

public interface ISerializeVisitor {

    String visitString(Object data);
    GenericRecord visitRecord(BMap<?, ?> data, Schema schema) throws Exception;
    Map<String, Object> visitMap(BMap<?, ?> data, Schema schema) throws Exception;
    GenericData.Array<Object> visitArray(BArray data, Schema schema) throws Exception;
    Object visitEnum(Object data, Schema schema);
    GenericData.Fixed visitFixed(Object data, Schema schema);
}
