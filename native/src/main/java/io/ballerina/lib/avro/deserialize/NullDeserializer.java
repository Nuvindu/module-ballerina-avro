package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;

public class NullDeserializer extends Deserializer {

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) throws Exception {
        if (data != null) {
            throw new Exception("The value does not match with the null schema");
        }
        return null;
    }
}
