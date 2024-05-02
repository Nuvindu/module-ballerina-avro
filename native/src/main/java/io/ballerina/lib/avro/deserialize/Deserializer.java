package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import org.apache.avro.Schema;

public abstract class Deserializer {

    private final Schema schema;
    private final Type type;

    public Deserializer() {
        this.schema = null;
        this.type = null;
    }

    public Deserializer(Type type) {
        this.schema = null;
        this.type = TypeUtils.getReferredType(type);
    }

    public Deserializer(Schema schema, Type type) {
        this.schema = new Schema.Parser().parse(schema.toString());
        this.type = TypeUtils.getReferredType(type);
    }

    protected Schema getSchema() {
        return schema;
    }

    protected Type getType() {
        return type;
    }

    public abstract Object fromAvroMessage(DeserializeVisitor visitor, Object data) throws Exception;
}
