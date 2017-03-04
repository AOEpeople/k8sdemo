package main

import "testing"

func TestCounter(t *testing.T) {
	var counter = new(MemoryCounter)

	if counter.GetCounter() != 0 {
		t.Error("counter not zero")
	}

	counter.AtomicIncCounter()

	if counter.GetCounter() != 1 {
		t.Error("counter not one")
	}
}
