/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct SuiData<T: Codable & Sendable>: Codable, Sendable {
	public let data: T

	public init(data: T) {
		self.data = data
	}
}
