package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;

public class GenericSerializer extends Serializer {

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) {
        return data;
    }
}
