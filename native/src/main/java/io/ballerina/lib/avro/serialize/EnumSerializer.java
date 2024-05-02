package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import org.apache.avro.Schema;

public class EnumSerializer extends Serializer {

    public EnumSerializer(Schema schema) {
        super(schema);
    }

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) {
        return serializeVisitor.visitEnum(data, getSchema());
    }
}
