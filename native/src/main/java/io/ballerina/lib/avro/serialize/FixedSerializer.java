package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import org.apache.avro.Schema;

public class FixedSerializer extends Serializer {

    public FixedSerializer(Schema schema) {
        super(schema);
    }

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) {
        return serializeVisitor.visitFixed(data, getSchema());
    }
}
