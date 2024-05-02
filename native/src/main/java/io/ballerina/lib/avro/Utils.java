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

package io.ballerina.lib.avro;

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import org.apache.avro.Schema;

import java.util.List;

import static io.ballerina.lib.avro.ModuleUtils.getModule;

public final class Utils {

    private Utils() {
    }

    public static final String AVRO_SCHEMA = "avroSchema";
    public static final String ERROR_TYPE = "Error";
    public static final String SERIALIZATION_ERROR = "Avro serialization error";
    public static final String DESERIALIZATION_ERROR = "Avro deserialization error";
    public static final String STRING_TYPE = "BStringType";
    public static final String ARRAY_TYPE = "BArrayType";
    public static final String MAP_TYPE = "BMapType";
    public static final String RECORD_TYPE = "BRecordType";
    public static final String INTEGER_TYPE = "BIntegerType";

    public static BError createError(String message, Throwable throwable) {
        BError cause = ErrorCreator.createError(throwable);
        return ErrorCreator.createError(getModule(), ERROR_TYPE, StringUtils.fromString(message), cause, null);
    }

    public static Schema checkType(Schema.Type givenType, List<Schema> schemas) {
        for (Schema schema: schemas) {
            if (schema.getType().equals(Schema.Type.UNION)) {
                checkType(givenType, schema.getTypes());
            } else if (schema.getType().equals(givenType)) {
                return schema;
            }
        }
        return null;
    }
}
