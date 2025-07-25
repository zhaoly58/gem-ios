/*
 Generated by typeshare 1.13.2
 */

import Foundation

public struct EthereumTransactionReciept: Codable, Sendable {
	public let status: String
	public let gasUsed: String
	public let effectiveGasPrice: String
	public let l1Fee: String?

	public init(status: String, gasUsed: String, effectiveGasPrice: String, l1Fee: String?) {
		self.status = status
		self.gasUsed = gasUsed
		self.effectiveGasPrice = effectiveGasPrice
		self.l1Fee = l1Fee
	}
}
