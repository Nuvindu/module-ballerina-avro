package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;

public class DoubleDeserializer extends Deserializer {

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) {
        return visitor.visitDouble(data);
    }
}
