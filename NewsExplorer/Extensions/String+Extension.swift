//
//  String+Extension.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import Foundation

extension String {
    func formattedDate() -> String {
        let input = ISO8601DateFormatter()
        let output = DateFormatter()
        output.dateStyle = .medium

        guard let date = input.date(from: self) else { return self }
        return output.string(from: date)
    }
    
    func toRelativeTime() -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: self) else { return self }
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}
