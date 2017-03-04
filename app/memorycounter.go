package main

import (
	"sync/atomic"
)

type (
	// MemoryCounter is stored in memory
	MemoryCounter struct {
		counter uint64
	}
)

// GetCounter is used to get the counters value
func (m *MemoryCounter) GetCounter() uint64 {
	return m.counter
}

// AtomicIncCounter increment atomically
func (m *MemoryCounter) AtomicIncCounter() {
	atomic.AddUint64(&m.counter, 1)
}
