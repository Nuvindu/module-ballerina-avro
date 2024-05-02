package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.visitor.DeserializeVisitor;
import io.ballerina.runtime.api.types.Type;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericRecord;

public class RecordDeserializer extends Deserializer {

    public RecordDeserializer(Schema schema, Type type) {
        super(schema, type);
    }

    @Override
    public Object fromAvroMessage(DeserializeVisitor visitor, Object data) throws Exception {
        return visitor.visitRecords(getType(), getSchema(), (GenericRecord) data);
    }
}
