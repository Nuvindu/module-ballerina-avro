package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import io.ballerina.runtime.api.values.BMap;
import org.apache.avro.Schema;

public class RecordSerializer extends Serializer {

    public RecordSerializer(Schema schema) {
        super(schema);
    }

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) throws Exception {
        return serializeVisitor.visitRecord((BMap) data, getSchema());
    }
}
