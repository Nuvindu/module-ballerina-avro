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

package io.ballerina.lib.avro.deserialize.visitor;

import io.ballerina.lib.avro.deserialize.ArrayDeserializer;
import io.ballerina.lib.avro.deserialize.Deserializer;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Type;
import org.apache.avro.generic.GenericData;

public class DeserializeArrayVisitor extends DeserializeVisitor {

    public Object visit(ArrayDeserializer arrayDeserializer, GenericData.Array<Object> data) throws Exception {
        Object[] objects = new Object[data.size()];
        Type arrayType = ((ArrayType) arrayDeserializer.getType()).getElementType();
        int index = 0;
        for (Object element : data) {
            GenericData.Array<Object> dataArray = (GenericData.Array<Object>) element;
            Type arrType = arrayType instanceof ArrayType ? arrayType : arrayDeserializer.getType();
            objects[index++] = visitNestedArray(new ArrayDeserializer(arrayDeserializer.getSchema().getElementType(),
                    arrType), dataArray);
        }
        return ValueCreator.createArrayValue(objects, (ArrayType) arrayDeserializer.getType());
    }

    public Object visitNestedArray(ArrayDeserializer arrayDeserializer,
                                   GenericData.Array<Object> data) throws Exception {
        Deserializer deserializer = createDeserializer(arrayDeserializer.getSchema(), arrayDeserializer.getType());
        return deserializer.visit(this, data);
    }
}
