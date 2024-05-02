package io.ballerina.lib.avro.serialize;

import org.apache.avro.Schema;

public class MessageFactory {

    public static Serializer createMessage(Schema schema) {
        return switch (schema.getType()) {
            case NULL -> new NullSerializer();
            case STRING -> new StringSerializer(schema);
            case ARRAY -> new ArraySerializer(schema);
            case FIXED -> new FixedSerializer(schema);
            case ENUM -> new EnumSerializer(schema);
            case MAP -> new MapSerializer(schema);
            case RECORD -> new RecordSerializer(schema);
            default -> new GenericSerializer();
        };
    }
}
