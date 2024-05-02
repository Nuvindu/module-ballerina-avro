package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;
import io.ballerina.runtime.api.types.Type;

import java.util.Map;

public class MapDeserializer extends Deserializer {

    public MapDeserializer(Type type) {
        super(type);
    }

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) throws Exception {
        return visitor.visitMap((Map<String, Object>) data, getType());
    }
}
