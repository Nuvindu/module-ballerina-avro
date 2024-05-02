package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;

public class GenericDeserializer extends Deserializer {

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) {
        return data;
    }
}
