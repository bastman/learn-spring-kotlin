package com.example.demo

import com.example.demo.app.EnvironmentName
import mu.KLogging
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import java.util.*
import javax.annotation.PostConstruct

@SpringBootApplication
class DemoApplication(
        @Value(value = "\${app.envName}") private val environmentName: EnvironmentName
) : ApplicationListener<ApplicationReadyEvent> {

    @PostConstruct
    internal fun started() {
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"))
        logger.info("=== CREATE SPRING BOOT APP (envName=$environmentName) ===")
    }

    override fun onApplicationEvent(contextRefreshedEvent: ApplicationReadyEvent) {
        logger.info("=== STARTED SPRING BOOT APP (envName=$environmentName) ===")
        System.gc()
    }

    companion object : KLogging()
}




