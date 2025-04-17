package dev.j1.bend.lifecycle

import jakarta.annotation.PreDestroy
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import kotlin.system.measureTimeMillis

@Component
class GracefulShutdownHandler {

    private val logger = LoggerFactory.getLogger(javaClass)

    @PreDestroy
    fun onShutdown() {
        logger.info("🛑 Received shutdown signal. Starting graceful shutdown...")

        val timeTaken = measureTimeMillis {
            flushPendingEvents()
        }

        logger.info("✅ Graceful shutdown completed in ${timeTaken}ms")
    }

    private fun flushPendingEvents() {
        logger.info("📤 Flushing pending events...")

        // TODO: 예시용 delay (실제 로직으로 대체)
        try {
            Thread.sleep(1000) // 예: Kafka producer flush, OTEL exporter flush 등
        } catch (e: InterruptedException) {
            logger.warn("⚠️ Graceful shutdown interrupted", e)
            Thread.currentThread().interrupt()
        }

        logger.info("📦 All pending events flushed")
    }
}