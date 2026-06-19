// WeightSample.swift
// 体重样本（单点）。PRD §6.1。

import Foundation

struct WeightSample: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let kg: Double
}
