package com.deeplusplus.nextna.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI nextNaOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("NextNa Virtual Buzzer & Queue Management API")
                        .description("REST & Real-Time SSE APIs for NextNa Virtual Buzzer and Queue Management System for MSMEs")
                        .version("v1.0.0")
                        .contact(new Contact()
                                .name("Dee++ Team")
                                .url("https://github.com/dee-plus-plus"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Local Development Server")
                ));
    }
}
