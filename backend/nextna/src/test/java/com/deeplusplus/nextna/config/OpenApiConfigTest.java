package com.deeplusplus.nextna.config;

import io.swagger.v3.oas.models.OpenAPI;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class OpenApiConfigTest {

    @Test
    void shouldCreateOpenApiBeanWithConfiguration() {
        OpenApiConfig config = new OpenApiConfig();
        OpenAPI openAPI = config.nextNaOpenAPI();

        assertNotNull(openAPI);
        assertNotNull(openAPI.getInfo());
        assertEquals("NextNa Virtual Buzzer & Queue Management API", openAPI.getInfo().getTitle());
        assertEquals("v1.0.0", openAPI.getInfo().getVersion());
        assertNotNull(openAPI.getServers());
        assertEquals(1, openAPI.getServers().size());
    }
}
