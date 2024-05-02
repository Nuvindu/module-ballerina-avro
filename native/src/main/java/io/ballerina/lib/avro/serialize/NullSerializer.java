package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;

public class NullSerializer extends Serializer {

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) throws Exception {
        if (data != null) {
            throw new Exception("The value does not match with the null schema");
        }
        return null;
    }
}
