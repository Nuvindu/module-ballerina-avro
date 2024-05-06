package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;
import org.apache.avro.Schema;

public class ByteDeserializer extends Deserializer {
    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data, Schema schema) throws Exception {
        return visitor.visitBytes(data);
    }
}
