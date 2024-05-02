package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;
import io.ballerina.runtime.api.types.Type;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;

public class ArrayDeserializer extends Deserializer {

    public ArrayDeserializer(Schema schema, Type type) {
        super(schema, type);
    }

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) throws Exception {
        return visitor.visitArray(getSchema(), (GenericData.Array<Object>) data, getType());
    }
}
