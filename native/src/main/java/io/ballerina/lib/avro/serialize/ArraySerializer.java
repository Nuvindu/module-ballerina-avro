package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import io.ballerina.runtime.api.values.BArray;
import org.apache.avro.Schema;

public class ArraySerializer extends Serializer {

    public ArraySerializer(Schema schema) {
        super(schema);
    }

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) throws Exception {
        return serializeVisitor.visitArray((BArray) data, getSchema());
    }
}
