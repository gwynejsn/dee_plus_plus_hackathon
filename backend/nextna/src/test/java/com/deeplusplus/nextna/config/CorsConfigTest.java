package com.deeplusplus.nextna.config;

import org.junit.jupiter.api.Test;
import org.springframework.web.servlet.config.annotation.CorsRegistration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

class CorsConfigTest {

    @Test
    void shouldRegisterCorsMappingsWithoutErrors() {
        CorsConfig corsConfig = new CorsConfig();
        CorsRegistry registry = new CorsRegistry();

        assertDoesNotThrow(() -> corsConfig.addCorsMappings(registry));
    }
}
