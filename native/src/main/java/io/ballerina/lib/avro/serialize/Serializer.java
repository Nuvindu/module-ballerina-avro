package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import org.apache.avro.Schema;

public abstract class Serializer {

    private final Schema schema;

    public Serializer() {
        this.schema = null;
    }

    public Serializer(Schema schema) {
        this.schema = new Schema.Parser().parse(schema.toString());
    }

    protected Schema getSchema() {
        return schema;
    }

    public abstract Object generateMessage(SerializeVisitor serializeVisitor, Object data) throws Exception;
}
