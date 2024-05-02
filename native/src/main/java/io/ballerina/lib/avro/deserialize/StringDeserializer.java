package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;

public class StringDeserializer extends Deserializer {

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) {
        return visitor.visitString(data);
    }
}
