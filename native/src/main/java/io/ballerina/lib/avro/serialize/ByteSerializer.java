package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import io.ballerina.runtime.api.values.BArray;

import java.nio.ByteBuffer;

public class ByteSerializer extends Serializer {
    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) throws Exception {
        return ByteBuffer.wrap(((BArray) data).getByteArray());
    }
}
