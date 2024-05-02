package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;

public class FixedDeserializer extends Deserializer {

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) {
        return visitor.visitFixed(data);
    }
}
