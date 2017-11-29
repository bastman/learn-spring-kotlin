package com.example.demo.config

import com.example.demo.api.ApiConfig
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.builders.WebSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.http.SessionCreationPolicy

@Configuration
@EnableWebSecurity
class WebSecurity(
        private val apiConfig: ApiConfig
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity) {
        val apiBaseUrl = apiConfig.baseUrl

        if (apiConfig.authEnabled) {
            http
                    .csrf().disable()
                    .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .and()
                    .antMatcher("$apiBaseUrl/**")
                    .authorizeRequests()
                    .anyRequest().hasRole("API_USER")
                    .and()
                    .httpBasic();

        } else {
            http
                    .csrf().disable()
                    .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .and()
                    .antMatcher("$apiBaseUrl/**")
                    .authorizeRequests()
                    .anyRequest()
                    .permitAll()
        }
    }

    override fun configure(web: WebSecurity) {
        web.ignoring()
                .antMatchers(
                        // actuator
                        "/health",
                        "/info",
                        // swagger
                        "/v2/api-docs",
                        "/configuration/ui",
                        "/swagger-resources/**",
                        "/configuration/security",
                        "/swagger-ui.html",
                        "/webjars/**"

                )
                .antMatchers(HttpMethod.OPTIONS, "/**");
    }

}