package com.apiece.springboot_sns.api.dto.common;

import java.util.Map;

public record ErrorResponse(
        String code,

        String message,

        Map<String, String> fieldErrors
) {

    public static ErrorResponse of(String code, String message) {
        return new ErrorResponse(code, message, null);
    }

    public static ErrorResponse ofValidation(Map<String, String> fieldErrors) {
        return new ErrorResponse("BAD_REQUEST", "Validation failed", fieldErrors);
    }
}
