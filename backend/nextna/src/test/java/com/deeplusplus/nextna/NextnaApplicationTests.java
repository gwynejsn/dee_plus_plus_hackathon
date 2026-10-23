package com.deeplusplus.nextna;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.modulith.core.ApplicationModules;
import org.springframework.modulith.docs.Documenter;

@SpringBootTest
class NextNaApplicationTests {

	@Test
	void contextLoads() {
	}

	@Test
	void writeDocumentationSnippets() {
		var modules = ApplicationModules.of(NextNaApplication.class).verify();
		new Documenter(modules)
				.writeModulesAsPlantUml()
				.writeIndividualModulesAsPlantUml();
	}
}
