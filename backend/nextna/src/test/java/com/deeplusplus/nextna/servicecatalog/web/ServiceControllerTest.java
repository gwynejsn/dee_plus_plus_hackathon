package com.deeplusplus.nextna.servicecatalog.web;

import com.deeplusplus.nextna.servicecatalog.application.CreateServiceCommand;
import com.deeplusplus.nextna.servicecatalog.application.ServiceCatalogService;
import com.deeplusplus.nextna.servicecatalog.application.ServiceResponseDto;
import com.deeplusplus.nextna.servicecatalog.domain.ServiceNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
class ServiceControllerTest {

    private MockMvc mockMvc;

    @Mock
    private ServiceCatalogService catalogService;

    @BeforeEach
    void setUp() {
        ServiceController controller = new ServiceController(catalogService);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new ServiceCatalogExceptionHandler())
                .build();
    }

    @Test
    void shouldCreateService() throws Exception {
        ServiceResponseDto dto = new ServiceResponseDto(
                "srv-12345",
                "Espresso",
                "FOOD_ORDER",
                new BigDecimal("120.00"),
                5,
                true,
                Instant.now(),
                Instant.now()
        );

        when(catalogService.createService(any(CreateServiceCommand.class))).thenReturn(dto);

        String payload = """
                {
                    "name": "Espresso",
                    "category": "FOOD_ORDER",
                    "unitPrice": 120.00,
                    "baselineDurationMinutes": 5
                }
                """;

        mockMvc.perform(post("/api/v1/services")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value("srv-12345"))
                .andExpect(jsonPath("$.name").value("Espresso"))
                .andExpect(jsonPath("$.category").value("FOOD_ORDER"))
                .andExpect(jsonPath("$.unitPrice").value(120.00))
                .andExpect(jsonPath("$.baselineDurationMinutes").value(5))
                .andExpect(jsonPath("$.active").value(true));
    }

    @Test
    void shouldReturn404WhenServiceNotFound() throws Exception {
        when(catalogService.getServiceById("srv-none"))
                .thenThrow(new ServiceNotFoundException("Service with id 'srv-none' was not found"));

        mockMvc.perform(get("/api/v1/services/srv-none"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.message").value("Service with id 'srv-none' was not found"));
    }

    @Test
    void shouldReturnAllServices() throws Exception {
        ServiceResponseDto dto = new ServiceResponseDto(
                "srv-1",
                "Fade Cut",
                "BARBERSHOP",
                new BigDecimal("250.00"),
                35,
                true,
                Instant.now(),
                Instant.now()
        );

        when(catalogService.getAllServices()).thenReturn(List.of(dto));

        mockMvc.perform(get("/api/v1/services"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value("srv-1"))
                .andExpect(jsonPath("$[0].name").value("Fade Cut"));
    }

    @Test
    void shouldDeactivateService() throws Exception {
        mockMvc.perform(delete("/api/v1/services/srv-1"))
                .andExpect(status().isNoContent());

        verify(catalogService).deactivateService("srv-1");
    }

    @Test
    void shouldActivateService() throws Exception {
        mockMvc.perform(patch("/api/v1/services/srv-1/activate"))
                .andExpect(status().isNoContent());

        verify(catalogService).activateService("srv-1");
    }
}
