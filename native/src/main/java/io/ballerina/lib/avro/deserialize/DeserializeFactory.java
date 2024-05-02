package io.ballerina.lib.avro.deserialize;

import io.ballerina.runtime.api.types.Type;
import org.apache.avro.Schema;

public class DeserializeFactory {

    public static Deserializer generateDeserializer(Schema schema, Type type) {
        return switch (schema.getType()) {
            case NULL -> new NullDeserializer();
            case FLOAT, DOUBLE -> new DoubleDeserializer();
            case STRING, ENUM -> new StringDeserializer();
            case ARRAY -> new ArrayDeserializer(schema, type);
            case FIXED -> new FixedDeserializer();
            case MAP -> new MapDeserializer(type);
            case RECORD -> new RecordDeserializer(schema, type);
            default -> new GenericDeserializer();
        };
    }
}
