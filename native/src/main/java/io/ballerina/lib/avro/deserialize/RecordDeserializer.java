/*
 * Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.avro.deserialize;

import io.ballerina.lib.avro.deserialize.visitor.DeserializeVisitor;
import io.ballerina.runtime.api.types.Type;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

public class RecordDeserializer extends Deserializer {

    public RecordDeserializer(Schema schema, Type type) {
        super(schema, type);
    }

    @Override
    public Object fromAvro(DeserializeVisitor visitor, Object data) throws Exception {
        return visitor.visit(this, (GenericRecord) data);
    }

    @Override
    public Object visit(DeserializeVisitor visitor, GenericData.Array<Object> data) throws Exception {
        return visitor.visit(this, data);
    }

    public Object visit(DeserializeVisitor visitor, GenericRecord data) throws Exception {
        return visitor.visit(this, data);
    }
}