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
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BError;

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
    public static final String FLOAT_TYPE = "BFloatType";

    public static BError createError(String message, Throwable throwable) {
        BError cause = ErrorCreator.createError(throwable);
        return ErrorCreator.createError(getModule(), ERROR_TYPE, StringUtils.fromString(message), cause, null);
    }

    public static Type getMutableType(IntersectionType intersectionType) {
        for (Type type : intersectionType.getConstituentTypes()) {
            Type referredType = TypeUtils.getImpliedType(type);
            if (referredType instanceof UnionType) {
                for (Type elementType : ((UnionType) referredType).getMemberTypes()) {
                    if (elementType instanceof MapType) {
                        return elementType;
                    }
                }
            }
            if (TypeUtils.getImpliedType(intersectionType.getEffectiveType()).getTag() == referredType.getTag()) {
                return referredType;
            }
        }
        throw new IllegalStateException("Unsupported intersection type found: " + intersectionType);
    }
}
