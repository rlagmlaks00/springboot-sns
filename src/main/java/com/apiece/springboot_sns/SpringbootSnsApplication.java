package com.apiece.springboot_sns;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class SpringbootSnsApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringbootSnsApplication.class, args);
    }
}
