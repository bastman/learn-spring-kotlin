package com.example.demo.config

import com.example.demo.api.ApiConfig
import com.google.common.base.Predicates
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpStatus
import springfox.documentation.builders.ApiInfoBuilder
import springfox.documentation.builders.ParameterBuilder
import springfox.documentation.builders.RequestHandlerSelectors
import springfox.documentation.builders.ResponseMessageBuilder
import springfox.documentation.schema.ModelRef
import springfox.documentation.service.Parameter
import springfox.documentation.spi.DocumentationType
import springfox.documentation.spi.service.contexts.Defaults
import springfox.documentation.spring.web.plugins.Docket
import springfox.documentation.swagger2.annotations.EnableSwagger2

@Configuration
@EnableSwagger2
class Swagger(private val apiConfig: ApiConfig) {

    private fun ApiConfig.getBasePackageName() = this::class.java.`package`.name

    @Bean
    fun mainApi(): Docket {
        return newDocket(apiConfig)
                .groupName("Main")
                .useDefaultResponseMessages(false)
                .also { addGlobalOperationParameters(it, apiConfig) }
                .also { addGlobalResponseMessages(it) }

                .select()
                .apis(RequestHandlerSelectors
                        .basePackage(apiConfig.getBasePackageName()))
                .build()
    }

    @Bean
    fun monitoringApi(): Docket {
        return newDocket(apiConfig)
                .groupName("Monitoring")
                .useDefaultResponseMessages(true)
                .also { addGlobalOperationParameters(it, apiConfig) }
                .also { addGlobalResponseMessages(it) }

                .select()
                .apis(Predicates.not(RequestHandlerSelectors.basePackage(apiConfig.getBasePackageName())))
                .build()
    }

    companion object {
        private fun newDocket(apiConfig: ApiConfig): Docket =
                Docket(DocumentationType.SWAGGER_2)
                        .apiInfo(
                                ApiInfoBuilder()
                                        .title(apiConfig.title)
                                        .build()
                        )

        private fun addGlobalOperationParameters(docket: Docket, apiConfig: ApiConfig): Docket =
                docket.globalOperationParameters(
                        listOf(
                                globalHeaderParameter(apiConfig.headerTraceId, "traceId (UUID)")
                        )
                )

        private fun globalHeaderParameter(name: String, description: String): Parameter =
                ParameterBuilder()
                        .name(name)
                        .description(description)
                        .parameterType("header")
                        .modelRef(ModelRef("string"))
                        .build()

        private fun addGlobalResponseMessages(docket: Docket): Docket {
            val httpStatusCode = HttpStatus.INTERNAL_SERVER_ERROR.value()
            val httpStatusMessage = HttpStatus.INTERNAL_SERVER_ERROR.reasonPhrase

            for (method in Defaults().defaultResponseMessages().keys) {
                docket.globalResponseMessage(
                        method,
                        listOf(
                                ResponseMessageBuilder()
                                        .code(httpStatusCode)
                                        .message(httpStatusMessage)
                                        .build()
                        )
                )
            }

            return docket
        }
    }

}
