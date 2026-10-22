package com.deeplusplus.NextNa.servicecatalog.domain;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class CatalogServiceTest {

    @Test
    void shouldCreateServiceSuccessfully() {
        CatalogService service = CatalogService.create(
                "Haircut",
                ServiceCategory.BARBERSHOP,
                ServicePrice.of(new BigDecimal("150.00")),
                DurationMinutes.of(30)
        );

        assertThat(service.getId()).isNotNull();
        assertThat(service.getId().value()).startsWith("srv-");
        assertThat(service.getName()).isEqualTo("Haircut");
        assertThat(service.getCategory()).isEqualTo(ServiceCategory.BARBERSHOP);
        assertThat(service.getPrice().amount()).isEqualByComparingTo("150.00");
        assertThat(service.getBaselineDuration().minutes()).isEqualTo(30);
        assertThat(service.isActive()).isTrue();
    }

    @Test
    void shouldFailWhenNameIsBlank() {
        assertThatThrownBy(() -> CatalogService.create(
                "   ",
                ServiceCategory.BARBERSHOP,
                ServicePrice.of(BigDecimal.TEN),
                DurationMinutes.of(20)
        )).isInstanceOf(InvalidServiceNameException.class);
    }

    @Test
    void shouldFailWhenPriceIsNegative() {
        assertThatThrownBy(() -> ServicePrice.of(new BigDecimal("-1.00")))
                .isInstanceOf(InvalidServicePriceException.class);
    }

    @Test
    void shouldFailWhenDurationIsInvalid() {
        assertThatThrownBy(() -> DurationMinutes.of(0))
                .isInstanceOf(InvalidDurationException.class);

        assertThatThrownBy(() -> DurationMinutes.of(481))
                .isInstanceOf(InvalidDurationException.class);
    }

    @Test
    void shouldActivateAndDeactivate() {
        CatalogService service = CatalogService.create(
                "Espresso",
                ServiceCategory.FOOD_ORDER,
                ServicePrice.of(new BigDecimal("120.00")),
                DurationMinutes.of(5)
        );

        service.deactivate();
        assertThat(service.isActive()).isFalse();

        service.activate();
        assertThat(service.isActive()).isTrue();
    }

    @Test
    void shouldUpdateDetails() {
        CatalogService service = CatalogService.create(
                "Car Wash",
                ServiceCategory.CARWASH,
                ServicePrice.of(new BigDecimal("200.00")),
                DurationMinutes.of(45)
        );

        service.updateDetails(
                "Premium Car Wash",
                ServiceCategory.CARWASH,
                ServicePrice.of(new BigDecimal("350.00")),
                DurationMinutes.of(60)
        );

        assertThat(service.getName()).isEqualTo("Premium Car Wash");
        assertThat(service.getPrice().amount()).isEqualByComparingTo("350.00");
        assertThat(service.getBaselineDuration().minutes()).isEqualTo(60);
    }
}
