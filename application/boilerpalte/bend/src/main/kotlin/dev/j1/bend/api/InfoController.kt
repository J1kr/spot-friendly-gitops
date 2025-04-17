// src/main/kotlin/dev/j1/bend/api/InfoController.kt
package dev.j1.bend.api

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Mono

data class InfoResponse(
    val version: String,
    val timestamp: Long
)

@RestController
class InfoController {

    @GetMapping("/api/info")
    fun getInfo(): Mono<InfoResponse> {
        return Mono.just(
            InfoResponse(
                version = "v0.0.1",
                timestamp = System.currentTimeMillis()
            )
        )
    }
}