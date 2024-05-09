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
import io.ballerina.runtime.api.utils.TypeUtils;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;

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

    public Schema getSchema() {
        return new Schema.Parser().parse(schema.toString());
    }

    public Type getType() {
        return TypeUtils.getReferredType(type);
    }

    public abstract Object fromAvro(DeserializeVisitor visitor, Object data) throws Exception;
    public abstract Object visit(DeserializeVisitor visitor, GenericData.Array<Object> data) throws Exception;
}