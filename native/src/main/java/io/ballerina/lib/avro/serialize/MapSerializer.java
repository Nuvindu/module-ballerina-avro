package io.ballerina.lib.avro.serialize;

import io.ballerina.lib.avro.visitor.SerializeVisitor;
import io.ballerina.runtime.api.values.BMap;
import org.apache.avro.Schema;

public class MapSerializer extends Serializer {

    public MapSerializer(Schema schema) {
        super(schema);
    }

    @Override
    public Object generateMessage(SerializeVisitor serializeVisitor, Object data) throws Exception {
        return serializeVisitor.visitMap((BMap) data, getSchema());
    }
}
