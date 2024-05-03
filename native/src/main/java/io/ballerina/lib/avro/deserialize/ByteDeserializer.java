package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;
import io.ballerina.runtime.api.creators.ValueCreator;

import java.nio.ByteBuffer;

public class ByteDeserializer extends Deserializer {
    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) throws Exception {
        return ValueCreator.createArrayValue(((ByteBuffer) data).array());
    }
}
