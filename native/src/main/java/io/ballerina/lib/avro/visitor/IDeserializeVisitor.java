package io.ballerina.lib.avro.visitor;

import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import java.util.Map;

public interface IDeserializeVisitor {

    public double visitDouble(Object data);
    public BString visitString(Object data);
    BMap<BString, Object> visitMap(Map<String, Object> data, Type type) throws Exception;
    BArray visitFixed(Object data);
    Object visitArray(Schema schema, GenericData.Array<Object> data, Type type) throws Exception;
    BMap<BString, Object> visitRecords(Type type, Schema schema, GenericRecord rec) throws Exception;
}
