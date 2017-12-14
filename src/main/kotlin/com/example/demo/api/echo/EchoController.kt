package com.example.demo.api.echo

import com.example.demo.api.ApiConfig
import com.fasterxml.jackson.annotation.JsonProperty
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController


data class EchoRequest(val lat: Double?, val lng: Double, @get:JsonProperty("isWeird") val isWeird: Boolean, val status: SomeStatus)
enum class SomeStatus { ACCEPTED, PROCESSING, COMPLETE; }
typealias EchoResponse = EchoRequest


@RestController
class EchoController {

    @PostMapping("${ApiConfig.API_BASE_URL}/echo")
    fun echo(@RequestBody req: EchoRequest): EchoResponse = req
}
