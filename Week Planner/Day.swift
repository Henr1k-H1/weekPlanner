////
////  Days.swift
////  trainingPlan
////
////  Created by Henrik Scharm on 4/17/23.
////
//
import SwiftUI

struct Day: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
}

let days = [
        Day(name: "Monday"),
        Day(name: "Tuesday"),
        Day(name: "Wednesday"),
        Day(name: "Thursday"),
        Day(name: "Friday"),
        Day(name: "Saturday"),
        Day(name: "Sunday")
    ]
